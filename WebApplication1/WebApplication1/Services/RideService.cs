using Microsoft.EntityFrameworkCore;
using VaygoTech.Data;
using VaygoTech.DTOs;
using VaygoTech.Models;

namespace VaygoTech.Services
{
    public class RideService
    {
        private readonly AppDbContext _context;

        public RideService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<(bool Success, string Message, object? Data)> RequestRideAsync(int userId, RideRequestDto request)
        {
            // Check user exists and is active
            var user = await _context.Users.FindAsync(userId);
            if (user == null || !user.IsActive)
                return (false, "User account is inactive", null);

            // Find nearest available online driver
            var drivers = await _context.Drivers.AsNoTracking()
                .Where(d => d.IsApproved && d.IsOnline
                         && d.SubscriptionExpiryDate != null
                         && d.SubscriptionExpiryDate > DateTime.UtcNow
                         && d.CurrentLat != null && d.CurrentLong != null)
                .ToListAsync();

            Driver? nearestDriver = null;
            double  minDistance   = double.MaxValue;

            foreach (var d in drivers)
            {
                var dist = HaversineKm(
                    (double)request.PickupLat, (double)request.PickupLong,
                    (double)d.CurrentLat!,     (double)d.CurrentLong!);

                if (dist < minDistance && dist <= 10.0)
                {
                    minDistance   = dist;
                    nearestDriver = d;
                }
            }

            var estimatedFare  = EstimateFare(request.PickupLat, request.PickupLong, request.DropLat, request.DropLong);
            var rideNumber     = GenerateRideNumber();

            var ride = new Ride
            {
                RideNumber    = rideNumber,
                UserId        = userId,
                DriverId      = nearestDriver?.DriverId,
                PickupLat     = request.PickupLat,
                PickupLong    = request.PickupLong,
                DropLat       = request.DropLat,
                DropLong      = request.DropLong,
                PickupAddress = request.PickupAddress,
                DropAddress   = request.DropAddress,
                EstimatedFare = estimatedFare,
                RideStatus    = nearestDriver != null ? "Requested" : "Requested",
                RequestedTime = DateTime.UtcNow
            };

            _context.Rides.Add(ride);
            await _context.SaveChangesAsync();

            return (true, nearestDriver != null
                ? "Ride requested. Driver assigned."
                : "Ride requested. Searching for drivers...", new
            {
                ride.RideId,
                ride.RideNumber,
                ride.EstimatedFare,
                ride.RideStatus,
                DriverAssigned = nearestDriver != null,
                Driver = nearestDriver == null ? null : new
                {
                    nearestDriver.DriverId,
                    nearestDriver.FullName,
                    nearestDriver.MobileNumber
                }
            });
        }

        public async Task<List<object>> GetRideHistoryAsync(int userId)
        {
            var rides = await _context.Rides.AsNoTracking()
                .Where(r => r.UserId == userId)
                .OrderByDescending(r => r.RequestedTime)
                .Select(r => (object)new
                {
                    r.RideId,
                    r.RideNumber,
                    r.PickupAddress,
                    r.DropAddress,
                    r.EstimatedFare,
                    r.FinalFare,
                    r.RideStatus,
                    r.Rating,
                    r.RequestedTime,
                    r.StartTime,
                    r.EndTime
                })
                .ToListAsync();

            return rides;
        }

        public async Task<(bool Success, string Message)> RateRideAsync(int userId, int rideId, RateRideRequest request)
        {
            var ride = await _context.Rides
                .FirstOrDefaultAsync(r => r.RideId == rideId && r.UserId == userId);

            if (ride == null)
                return (false, "Ride not found");

            if (ride.RideStatus != "Completed")
                return (false, "Only completed rides can be rated");

            if (ride.Rating != null)
                return (false, "Ride already rated");

            ride.Rating   = request.Rating;
            ride.Feedback = request.Feedback;
            await _context.SaveChangesAsync();

            return (true, "Rating submitted successfully");
        }

        public async Task<(bool Success, string Message)> AcceptRideAsync(int driverId, int rideId)
        {
            var ride = await _context.Rides.FindAsync(rideId);
            if (ride == null)
                return (false, "Ride not found");

            if (ride.RideStatus != "Requested")
                return (false, "Ride is no longer available");

            ride.DriverId   = driverId;
            ride.RideStatus = "Accepted";
            await _context.SaveChangesAsync();

            return (true, "Ride accepted successfully");
        }

        public async Task<(bool Success, string Message)> StartRideAsync(int driverId, int rideId)
        {
            var ride = await _context.Rides
                .FirstOrDefaultAsync(r => r.RideId == rideId && r.DriverId == driverId);

            if (ride == null)
                return (false, "Ride not found");

            if (ride.RideStatus != "Accepted")
                return (false, "Ride must be in Accepted state to start");

            ride.RideStatus = "Started";
            ride.StartTime  = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return (true, "Ride started successfully");
        }

        public async Task<(bool Success, string Message, object? Data)> EndRideAsync(int driverId, int rideId)
        {
            var ride = await _context.Rides
                .FirstOrDefaultAsync(r => r.RideId == rideId && r.DriverId == driverId);

            if (ride == null)
                return (false, "Ride not found", null);

            if (ride.RideStatus != "Started")
                return (false, "Ride must be in Started state to end", null);

            ride.RideStatus = "Completed";
            ride.EndTime    = DateTime.UtcNow;
            ride.FinalFare  = ride.EstimatedFare; // In future: calculate based on actual route/time
            await _context.SaveChangesAsync();

            return (true, "Ride completed", new
            {
                ride.RideId,
                ride.RideNumber,
                ride.FinalFare,
                ride.StartTime,
                ride.EndTime
            });
        }

        // Haversine formula — returns distance in kilometres
        private static double HaversineKm(double lat1, double lon1, double lat2, double lon2)
        {
            const double R = 6371;
            var dLat = ToRad(lat2 - lat1);
            var dLon = ToRad(lon2 - lon1);
            var a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2)
                  + Math.Cos(ToRad(lat1)) * Math.Cos(ToRad(lat2))
                  * Math.Sin(dLon / 2) * Math.Sin(dLon / 2);
            return R * 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
        }

        private static double ToRad(double deg) => deg * Math.PI / 180;

        private static decimal EstimateFare(decimal pickupLat, decimal pickupLon, decimal dropLat, decimal dropLon)
        {
            var distKm   = (decimal)HaversineKm((double)pickupLat, (double)pickupLon, (double)dropLat, (double)dropLon);
            const decimal baseFare  = 30m;
            const decimal perKmRate = 15m;
            return Math.Round(baseFare + distKm * perKmRate, 2);
        }

        private static string GenerateRideNumber()
        {
            return "VG" + DateTime.UtcNow.ToString("yyyyMMddHHmmss") + new Random().Next(100, 999);
        }
    }
}

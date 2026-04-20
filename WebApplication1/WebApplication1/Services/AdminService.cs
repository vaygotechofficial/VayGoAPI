using Microsoft.EntityFrameworkCore;
using VaygoTech.Data;
using VaygoTech.Models;

namespace VaygoTech.Services
{
    public class AdminService
    {
        private readonly AppDbContext _context;

        public AdminService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<object>> GetPendingDriversAsync()
        {
            var drivers = await _context.Drivers.AsNoTracking()
                .Where(d => d.RegistrationStatus == "DocumentsUploaded")
                .ToListAsync();

            var result = new List<object>();

            foreach (var d in drivers)
            {
                var kyc     = await _context.DriverKYCs.AsNoTracking().FirstOrDefaultAsync(k => k.DriverId == d.DriverId);
                var vehicle = await _context.Vehicles.AsNoTracking().FirstOrDefaultAsync(v => v.DriverId == d.DriverId);

                result.Add(new
                {
                    d.DriverId,
                    d.FullName,
                    d.MobileNumber,
                    d.RegistrationStatus,
                    d.CreatedDate,
                    KYC = kyc == null ? null : new
                    {
                        kyc.DrivingLicenseNumber,
                        kyc.LicenseExpiryDate,
                        kyc.AadhaarMasked,
                        kyc.AadhaarDocUrl,
                        kyc.LicenseDocUrl
                    },
                    Vehicle = vehicle == null ? null : new
                    {
                        vehicle.VehicleType,
                        vehicle.VehicleNumber,
                        vehicle.InsuranceExpiryDate,
                        vehicle.RCUrl,
                        vehicle.InsuranceUrl
                    }
                });
            }

            return result;
        }

        public async Task<(bool Success, string Message)> ApproveDriverAsync(int driverId)
        {
            var driver = await _context.Drivers.FindAsync(driverId);
            if (driver == null)
                return (false, "Driver not found");

            if (driver.RegistrationStatus == "Approved")
                return (false, "Driver is already approved");

            // Validate license expiry before approval
            var kyc = await _context.DriverKYCs.FirstOrDefaultAsync(k => k.DriverId == driverId);
            if (kyc?.LicenseExpiryDate != null && kyc.LicenseExpiryDate <= DateTime.UtcNow)
                return (false, "Cannot approve: driving license has expired");

            driver.IsApproved          = true;
            driver.RegistrationStatus  = "Approved";
            driver.RejectionReason     = null;

            if (kyc != null)
            {
                kyc.AadhaarVerified = true;
                kyc.LicenseVerified = true;
            }

            await _context.SaveChangesAsync();
            return (true, "Driver approved successfully");
        }

        public async Task<(bool Success, string Message)> RejectDriverAsync(int driverId, string reason)
        {
            var driver = await _context.Drivers.FindAsync(driverId);
            if (driver == null)
                return (false, "Driver not found");

            driver.IsApproved         = false;
            driver.RegistrationStatus = "Rejected";
            driver.RejectionReason    = reason;
            await _context.SaveChangesAsync();

            return (true, "Driver rejected");
        }

        public async Task<object> GetSubscriptionReportAsync()
        {
            var payments = await _context.SubscriptionPayments.AsNoTracking()
                .Include(p => p.Plan)
                .Where(p => p.PaymentStatus == "Success")
                .ToListAsync();

            var report = payments
                .GroupBy(p => p.Plan!.VehicleType)
                .Select(g => new
                {
                    VehicleType         = g.Key,
                    TotalSubscriptions  = g.Count(),
                    TotalRevenue        = g.Sum(p => p.Plan!.Amount)
                });

            return new
            {
                TotalRevenue        = payments.Sum(p => p.Plan!.Amount),
                TotalSubscriptions  = payments.Count,
                ByVehicleType       = report
            };
        }

        public async Task<object> GetRidesReportAsync()
        {
            var rides = await _context.Rides.AsNoTracking().ToListAsync();

            return new
            {
                TotalRides     = rides.Count,
                Completed      = rides.Count(r => r.RideStatus == "Completed"),
                Cancelled      = rides.Count(r => r.RideStatus == "Cancelled"),
                Requested      = rides.Count(r => r.RideStatus == "Requested"),
                TotalRevenue   = rides.Where(r => r.FinalFare.HasValue).Sum(r => r.FinalFare),
                AverageRating  = rides.Where(r => r.Rating.HasValue).Any()
                    ? Math.Round(rides.Where(r => r.Rating.HasValue).Average(r => (double)r.Rating!.Value), 2)
                    : (double?)null
            };
        }

        // Used by background jobs
        public async Task DeactivateExpiredDriversAsync()
        {
            var expiredDrivers = await _context.Drivers
                .Where(d => d.SubscriptionExpiryDate != null
                         && d.SubscriptionExpiryDate < DateTime.UtcNow
                         && d.IsOnline)
                .ToListAsync();

            foreach (var d in expiredDrivers)
                d.IsOnline = false;

            await _context.SaveChangesAsync();
        }

        public async Task CleanExpiredOtpsAsync()
        {
            var cutoff = DateTime.UtcNow.AddDays(-1);
            var stale = await _context.OTPLogs
                .Where(o => o.CreatedDate < cutoff)
                .ToListAsync();

            _context.OTPLogs.RemoveRange(stale);
            await _context.SaveChangesAsync();
        }
    }
}

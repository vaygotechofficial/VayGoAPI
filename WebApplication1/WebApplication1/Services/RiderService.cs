using Microsoft.EntityFrameworkCore;
using VaygoTech.Data;
using VaygoTech.DTOs;
using VaygoTech.Helpers;
using VaygoTech.Models;

namespace VaygoTech.Services
{
    public class RiderService
    {
        private readonly AppDbContext _context;
        private readonly EncryptionHelper _encryption;

        public RiderService(AppDbContext context, EncryptionHelper encryption)
        {
            _context    = context;
            _encryption = encryption;
        }

        public async Task<(bool Success, string Message, object? Data)> RegisterAsync(RiderRegisterRequest request)
        {
            var existing = await _context.Drivers
                .FirstOrDefaultAsync(d => d.MobileNumber == request.MobileNumber);

            if (existing != null)
            {
                // Update name if already registered
                existing.FullName = request.FullName;
                await _context.SaveChangesAsync();
                return (true, "Profile updated", new { existing.DriverId, existing.FullName, existing.MobileNumber });
            }

            var driver = new Driver
            {
                FullName           = request.FullName,
                MobileNumber       = request.MobileNumber,
                RegistrationStatus = "Pending",
                CreatedDate        = DateTime.UtcNow
            };
            _context.Drivers.Add(driver);
            await _context.SaveChangesAsync();

            return (true, "Driver registered successfully", new
            {
                driver.DriverId,
                driver.FullName,
                driver.MobileNumber,
                driver.RegistrationStatus
            });
        }

        public async Task<(bool Success, string Message)> UploadDocumentsAsync(int driverId, UploadDocumentsRequest request)
        {
            var driver = await _context.Drivers.FindAsync(driverId);
            if (driver == null)
                return (false, "Driver not found");

            // Validate license expiry
            if (request.LicenseExpiryDate <= DateTime.UtcNow)
                return (false, "Driving license has expired");

            // Validate insurance expiry
            if (request.InsuranceExpiryDate <= DateTime.UtcNow)
                return (false, "Vehicle insurance has expired");

            // Encrypt Aadhaar and store masked version
            var aadhaarEncrypted = _encryption.Encrypt(request.AadhaarNumber);
            var aadhaarMasked    = EncryptionHelper.MaskAadhaar(request.AadhaarNumber);

            // Upsert KYC record
            var kyc = await _context.DriverKYCs.FirstOrDefaultAsync(k => k.DriverId == driverId);
            if (kyc == null)
            {
                kyc = new DriverKYC { DriverId = driverId };
                _context.DriverKYCs.Add(kyc);
            }

            kyc.AadhaarMasked        = aadhaarMasked;
            kyc.AadhaarEncrypted     = aadhaarEncrypted;
            kyc.DrivingLicenseNumber = request.DrivingLicenseNumber;
            kyc.LicenseExpiryDate    = request.LicenseExpiryDate;
            kyc.AadhaarDocUrl        = request.AadhaarDocUrl;
            kyc.LicenseDocUrl        = request.LicenseDocUrl;

            // Upsert Vehicle record
            var vehicle = await _context.Vehicles.FirstOrDefaultAsync(v => v.DriverId == driverId);
            if (vehicle == null)
            {
                vehicle = new Vehicle { DriverId = driverId };
                _context.Vehicles.Add(vehicle);
            }

            vehicle.VehicleType         = request.VehicleType;
            vehicle.VehicleNumber       = request.VehicleNumber;
            vehicle.RCUrl               = request.RCUrl;
            vehicle.InsuranceUrl        = request.InsuranceUrl;
            vehicle.InsuranceExpiryDate = request.InsuranceExpiryDate;

            // Move driver to next registration stage
            driver.RegistrationStatus = "DocumentsUploaded";

            await _context.SaveChangesAsync();
            return (true, "Documents uploaded successfully. Awaiting admin approval.");
        }

        public async Task<(bool Success, string Message)> GoOnlineAsync(int driverId, GoOnlineRequest request)
        {
            var driver = await _context.Drivers.FindAsync(driverId);
            if (driver == null)
                return (false, "Driver not found");

            if (!driver.IsApproved)
                return (false, "Driver not yet approved by admin");

            if (driver.SubscriptionExpiryDate == null || driver.SubscriptionExpiryDate <= DateTime.UtcNow)
                return (false, "No active subscription. Please renew your subscription.");

            driver.IsOnline    = true;
            driver.CurrentLat  = request.CurrentLat;
            driver.CurrentLong = request.CurrentLong;
            await _context.SaveChangesAsync();

            return (true, "You are now online");
        }

        public async Task<(bool Success, string Message)> GoOfflineAsync(int driverId)
        {
            var driver = await _context.Drivers.FindAsync(driverId);
            if (driver == null)
                return (false, "Driver not found");

            driver.IsOnline = false;
            await _context.SaveChangesAsync();
            return (true, "You are now offline");
        }

        public async Task<object?> GetProfileAsync(int driverId)
        {
            var driver = await _context.Drivers.AsNoTracking()
                .FirstOrDefaultAsync(d => d.DriverId == driverId);
            if (driver == null) return null;

            var kyc = await _context.DriverKYCs.AsNoTracking()
                .FirstOrDefaultAsync(k => k.DriverId == driverId);

            var vehicle = await _context.Vehicles.AsNoTracking()
                .FirstOrDefaultAsync(v => v.DriverId == driverId);

            return new
            {
                driver.DriverId,
                driver.FullName,
                driver.MobileNumber,
                driver.IsApproved,
                driver.RegistrationStatus,
                driver.IsOnline,
                driver.SubscriptionExpiryDate,
                KYC = kyc == null ? null : new
                {
                    kyc.DrivingLicenseNumber,
                    kyc.LicenseExpiryDate,
                    kyc.AadhaarMasked,  // Never expose encrypted value
                    kyc.AadhaarVerified,
                    kyc.LicenseVerified
                },
                Vehicle = vehicle == null ? null : new
                {
                    vehicle.VehicleType,
                    vehicle.VehicleNumber,
                    vehicle.InsuranceExpiryDate
                }
            };
        }
    }
}

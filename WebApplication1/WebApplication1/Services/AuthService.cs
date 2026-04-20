using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using VaygoTech.Data;
using VaygoTech.DTOs;
using VaygoTech.Models;

namespace VaygoTech.Services
{
    public class AuthService
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _config;

        public AuthService(AppDbContext context, IConfiguration config)
        {
            _context = context;
            _config = config;
        }

        public async Task<(bool Success, string Message)> SendOtpAsync(SendOtpRequest request)
        {
            // Expire any previous unverified OTPs for this number
            var oldOtps = await _context.OTPLogs
                .Where(o => o.MobileNumber == request.MobileNumber && !o.IsVerified && o.ExpiryTime > DateTime.UtcNow)
                .ToListAsync();

            foreach (var old in oldOtps)
                old.IsVerified = true;

            var otpCode = new Random().Next(100000, 999999).ToString();

            _context.OTPLogs.Add(new OTPLog
            {
                MobileNumber = request.MobileNumber,
                OTPCode      = otpCode,
                IsVerified   = false,
                ExpiryTime   = DateTime.UtcNow.AddMinutes(5),
                CreatedDate  = DateTime.UtcNow
            });

            await _context.SaveChangesAsync();

            // TODO: Integrate SMS gateway here to send otpCode
            // For development, we return the OTP directly
            return (true, $"OTP sent. [Dev mode] OTP: {otpCode}");
        }

        public async Task<(bool Success, string Token, object? UserData, string Message)> VerifyOtpAsync(VerifyOtpRequest request)
        {
            var otpLog = await _context.OTPLogs
                .Where(o => o.MobileNumber == request.MobileNumber
                         && o.OTPCode      == request.OtpCode
                         && !o.IsVerified
                         && o.ExpiryTime   >  DateTime.UtcNow)
                .OrderByDescending(o => o.CreatedDate)
                .FirstOrDefaultAsync();

            if (otpLog == null)
                return (false, string.Empty, null, "Invalid or expired OTP");

            otpLog.IsVerified = true;
            await _context.SaveChangesAsync();

            if (request.UserType.ToLower() == "driver")
                return await AuthenticateDriverAsync(request.MobileNumber);

            return await AuthenticateUserAsync(request.MobileNumber);
        }

        private async Task<(bool, string, object?, string)> AuthenticateUserAsync(string mobile)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.MobileNumber == mobile);

            if (user == null)
            {
                user = new User
                {
                    MobileNumber = mobile,
                    FullName     = string.Empty,
                    IsActive     = true,
                    CreatedDate  = DateTime.UtcNow
                };
                _context.Users.Add(user);
                await _context.SaveChangesAsync();
            }

            var role = user.IsAdmin ? "admin" : "user";
            var token = GenerateToken(user.UserId.ToString(), mobile, role);

            return (true, token, new
            {
                user.UserId,
                user.FullName,
                user.MobileNumber,
                user.Email,
                user.IsAdmin
            }, "Login successful");
        }

        private async Task<(bool, string, object?, string)> AuthenticateDriverAsync(string mobile)
        {
            var driver = await _context.Drivers.FirstOrDefaultAsync(d => d.MobileNumber == mobile);

            if (driver == null)
            {
                driver = new Driver
                {
                    MobileNumber       = mobile,
                    FullName           = string.Empty,
                    RegistrationStatus = "Pending",
                    CreatedDate        = DateTime.UtcNow
                };
                _context.Drivers.Add(driver);
                await _context.SaveChangesAsync();
            }

            var token = GenerateToken(driver.DriverId.ToString(), mobile, "driver");

            return (true, token, new
            {
                driver.DriverId,
                driver.FullName,
                driver.MobileNumber,
                driver.IsApproved,
                driver.RegistrationStatus
            }, "Login successful");
        }

        public string GenerateToken(string id, string mobile, string role)
        {
            var key   = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]!));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, id),
                new Claim("mobile", mobile),
                new Claim(ClaimTypes.Role, role)
            };

            var token = new JwtSecurityToken(
                issuer:            _config["Jwt:Issuer"],
                audience:          _config["Jwt:Audience"],
                claims:            claims,
                expires:           DateTime.UtcNow.AddHours(24),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}

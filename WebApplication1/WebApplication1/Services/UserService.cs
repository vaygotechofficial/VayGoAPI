using Microsoft.EntityFrameworkCore;
using VaygoTech.Data;
using VaygoTech.DTOs;
using VaygoTech.Models;

namespace VaygoTech.Services
{
    public class UserService
    {
        private readonly AppDbContext _context;

        public UserService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<User?> GetProfileAsync(int userId)
        {
            return await _context.Users.AsNoTracking()
                .FirstOrDefaultAsync(u => u.UserId == userId);
        }

        public async Task<(bool Success, string Message)> UpdateProfileAsync(int userId, UpdateProfileRequest request)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserId == userId);
            if (user == null)
                return (false, "User not found");

            user.FullName = request.FullName;
            user.Email    = request.Email;
            await _context.SaveChangesAsync();
            return (true, "Profile updated successfully");
        }

        public async Task<List<User>> GetAllUsersAsync()
        {
            return await _context.Users.AsNoTracking().ToListAsync();
        }
    }
}

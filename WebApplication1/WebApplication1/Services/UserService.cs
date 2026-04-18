using VaygoTech.Data;
using VaygoTech.Models;
using System.Collections.Generic;
using System.Linq;
using Microsoft.EntityFrameworkCore;

public class UserService
{
    private readonly AppDbContext _context;

    public UserService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<List<User>> GetAllUsers()
    {
        try
        {
            return await _context.Users
                .AsNoTracking()
                .ToListAsync();
        }
        catch (Exception)
        {
            return new List<User>();
        }
    }

    public async Task<User> GetUserById(int id)
    {
        try
        {
            return await _context.Users
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.Id == id);
        }
        catch (Exception)
        {
            return null;
        }
    }

    public async Task<User> Authenticate(string email, string password)
    {
        try
        {
            return await _context.Users
                .FirstOrDefaultAsync(x => x.Email == email && x.Password == password);
        }
        catch (Exception)
        {
            return null;
        }
    }
}
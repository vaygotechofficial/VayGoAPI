using Microsoft.EntityFrameworkCore;
using VaygoTech.Models;

namespace VaygoTech.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Ride> Rides { get; set; }
    }
}
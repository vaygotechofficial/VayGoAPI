using Microsoft.EntityFrameworkCore;
using VaygoTech.Models;

namespace VaygoTech.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<User>                Users                { get; set; }
        public DbSet<Driver>              Drivers              { get; set; }
        public DbSet<DriverKYC>           DriverKYCs           { get; set; }
        public DbSet<Vehicle>             Vehicles             { get; set; }
        public DbSet<SubscriptionPlan>    SubscriptionPlans    { get; set; }
        public DbSet<DriverSubscription>  DriverSubscriptions  { get; set; }
        public DbSet<SubscriptionPayment> SubscriptionPayments { get; set; }
        public DbSet<Ride>                Rides                { get; set; }
        public DbSet<OTPLog>              OTPLogs              { get; set; }
    }
}

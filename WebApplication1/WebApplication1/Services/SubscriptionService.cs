using Microsoft.EntityFrameworkCore;
using VaygoTech.Data;
using VaygoTech.Models;

namespace VaygoTech.Services
{
    public class SubscriptionService
    {
        private readonly AppDbContext _context;

        public SubscriptionService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<SubscriptionPlan>> GetPlansAsync()
        {
            return await _context.SubscriptionPlans.AsNoTracking()
                .Where(p => p.IsActive)
                .ToListAsync();
        }

        public async Task<(bool Success, string Message, object? Data)> CreateOrderAsync(int driverId, int planId)
        {
            var driver = await _context.Drivers.FindAsync(driverId);
            if (driver == null)
                return (false, "Driver not found", null);

            var plan = await _context.SubscriptionPlans.FindAsync(planId);
            if (plan == null || !plan.IsActive)
                return (false, "Invalid or inactive subscription plan", null);

            // Check if driver already has an active subscription
            var activeSub = await _context.DriverSubscriptions
                .AnyAsync(s => s.DriverId == driverId && s.IsActive && s.EndDate > DateTime.UtcNow);

            if (activeSub)
                return (false, "Driver already has an active subscription", null);

            // Generate gateway order ID (integrate real UPI gateway here)
            var gatewayOrderId = "ORD_" + Guid.NewGuid().ToString("N").Substring(0, 16).ToUpper();

            var payment = new SubscriptionPayment
            {
                DriverId       = driverId,
                PlanId         = planId,
                GatewayOrderId = gatewayOrderId,
                PaymentStatus  = "Pending",
                CreatedDate    = DateTime.UtcNow
            };

            _context.SubscriptionPayments.Add(payment);
            await _context.SaveChangesAsync();

            return (true, "Order created. Complete UPI payment.", new
            {
                payment.PaymentId,
                payment.GatewayOrderId,
                plan.Amount,
                plan.VehicleType,
                plan.DurationInDays,
                // TODO: Return actual UPI payment URL from gateway
                PaymentUrl = $"upi://pay?pa=vaygo@upi&pn=VayGo&am={plan.Amount}&tn={gatewayOrderId}"
            });
        }

        public async Task<bool> ActivateSubscriptionAsync(int driverId, int paymentId)
        {
            var payment = await _context.SubscriptionPayments
                .Include(p => p.Plan)
                .FirstOrDefaultAsync(p => p.PaymentId == paymentId && p.DriverId == driverId);

            if (payment == null || payment.PaymentStatus != "Success")
                return false;

            // Deactivate any existing subscriptions
            var existing = await _context.DriverSubscriptions
                .Where(s => s.DriverId == driverId && s.IsActive)
                .ToListAsync();

            foreach (var s in existing)
                s.IsActive = false;

            var startDate = DateTime.UtcNow;
            var endDate   = startDate.AddDays(payment.Plan!.DurationInDays);

            _context.DriverSubscriptions.Add(new DriverSubscription
            {
                DriverId  = driverId,
                PlanId    = payment.PlanId,
                StartDate = startDate,
                EndDate   = endDate,
                IsActive  = true
            });

            var driver = await _context.Drivers.FindAsync(driverId);
            if (driver != null)
                driver.SubscriptionExpiryDate = endDate;

            await _context.SaveChangesAsync();
            return true;
        }
    }
}

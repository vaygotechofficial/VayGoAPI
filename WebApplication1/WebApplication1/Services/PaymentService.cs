using Microsoft.EntityFrameworkCore;
using VaygoTech.Data;
using VaygoTech.DTOs;
using VaygoTech.Helpers;

namespace VaygoTech.Services
{
    public class PaymentService
    {
        private readonly AppDbContext         _context;
        private readonly SubscriptionService  _subscriptionService;
        private readonly IConfiguration       _config;

        public PaymentService(AppDbContext context, SubscriptionService subscriptionService, IConfiguration config)
        {
            _context             = context;
            _subscriptionService = subscriptionService;
            _config              = config;
        }

        public async Task<(bool Success, string Message)> HandleWebhookAsync(WebhookRequest request)
        {
            // Verify HMAC-SHA256 signature
            var webhookSecret = _config["Payment:WebhookSecret"] ?? string.Empty;
            if (!string.IsNullOrEmpty(webhookSecret))
            {
                var payload           = $"{request.GatewayOrderId}|{request.UpiTransactionId}|{request.Status}";
                var expectedSignature = EncryptionHelper.ComputeHmacSha256(payload, webhookSecret);

                if (!string.Equals(expectedSignature, request.Signature, StringComparison.OrdinalIgnoreCase))
                    return (false, "Invalid webhook signature");
            }

            var payment = await _context.SubscriptionPayments
                .FirstOrDefaultAsync(p => p.GatewayOrderId == request.GatewayOrderId);

            if (payment == null)
                return (false, "Payment record not found");

            if (payment.PaymentStatus == "Success")
                return (true, "Already processed");

            payment.PaymentStatus   = request.Status;
            payment.UpiTransactionId = request.UpiTransactionId;

            if (request.Status == "Success")
                payment.PaidDate = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            if (request.Status == "Success")
                await _subscriptionService.ActivateSubscriptionAsync(payment.DriverId, payment.PaymentId);

            return (true, "Webhook processed successfully");
        }
    }
}

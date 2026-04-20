namespace VaygoTech.DTOs
{
    public class WebhookRequest
    {
        public string GatewayOrderId { get; set; } = string.Empty;
        public string UpiTransactionId { get; set; } = string.Empty;
        // Success | Failed
        public string Status { get; set; } = string.Empty;
        public string Signature { get; set; } = string.Empty;
    }
}

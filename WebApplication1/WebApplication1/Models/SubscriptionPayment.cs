using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace VaygoTech.Models
{
    [Table("SubscriptionPayments")]
    public class SubscriptionPayment
    {
        [Key]
        [Column("PaymentId")]
        public int PaymentId { get; set; }

        [Column("DriverId")]
        public int DriverId { get; set; }

        [Column("PlanId")]
        public int PlanId { get; set; }

        [Column("GatewayOrderId")]
        public string? GatewayOrderId { get; set; }

        [Column("UpiTransactionId")]
        public string? UpiTransactionId { get; set; }

        // Pending | Success | Failed
        [Column("PaymentStatus")]
        public string PaymentStatus { get; set; } = "Pending";

        [Column("PaidDate")]
        public DateTime? PaidDate { get; set; }

        [Column("CreatedDate")]
        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;

        [ForeignKey("DriverId")]
        public Driver? Driver { get; set; }

        [ForeignKey("PlanId")]
        public SubscriptionPlan? Plan { get; set; }
    }
}

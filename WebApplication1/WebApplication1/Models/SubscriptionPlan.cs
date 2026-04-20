using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace VaygoTech.Models
{
    [Table("SubscriptionPlans")]
    public class SubscriptionPlan
    {
        [Key]
        [Column("PlanId")]
        public int PlanId { get; set; }

        // Bike | Auto | Car
        [Column("VehicleType")]
        public string VehicleType { get; set; } = string.Empty;

        [Column("Amount")]
        public decimal Amount { get; set; }

        [Column("DurationInDays")]
        public int DurationInDays { get; set; }

        [Column("IsActive")]
        public bool IsActive { get; set; } = true;
    }
}

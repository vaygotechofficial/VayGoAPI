using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace VaygoTech.Models
{
    [Table("DriverSubscriptions")]
    public class DriverSubscription
    {
        [Key]
        [Column("SubscriptionId")]
        public int SubscriptionId { get; set; }

        [Column("DriverId")]
        public int DriverId { get; set; }

        [Column("PlanId")]
        public int PlanId { get; set; }

        [Column("StartDate")]
        public DateTime StartDate { get; set; }

        [Column("EndDate")]
        public DateTime EndDate { get; set; }

        [Column("IsActive")]
        public bool IsActive { get; set; } = true;

        [ForeignKey("DriverId")]
        public Driver? Driver { get; set; }

        [ForeignKey("PlanId")]
        public SubscriptionPlan? Plan { get; set; }
    }
}

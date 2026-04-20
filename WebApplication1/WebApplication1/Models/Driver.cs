using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace VaygoTech.Models
{
    [Table("Drivers")]
    public class Driver
    {
        [Key]
        [Column("DriverId")]
        public int DriverId { get; set; }

        [Column("FullName")]
        public string FullName { get; set; } = string.Empty;

        [Column("MobileNumber")]
        public string MobileNumber { get; set; } = string.Empty;

        [Column("IsApproved")]
        public bool IsApproved { get; set; } = false;

        // Pending | DocumentsUploaded | Approved | Rejected
        [Column("RegistrationStatus")]
        public string RegistrationStatus { get; set; } = "Pending";

        [Column("SubscriptionExpiryDate")]
        public DateTime? SubscriptionExpiryDate { get; set; }

        [Column("IsOnline")]
        public bool IsOnline { get; set; } = false;

        [Column("RejectionReason")]
        public string? RejectionReason { get; set; }

        [Column("CurrentLat")]
        public decimal? CurrentLat { get; set; }

        [Column("CurrentLong")]
        public decimal? CurrentLong { get; set; }

        [Column("CreatedDate")]
        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
    }
}

using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace VaygoTech.Models
{
    [Table("Rides")]
    public class Ride
    {
        [Key]
        [Column("RideId")]
        public int RideId { get; set; }

        [Column("RideNumber")]
        public string RideNumber { get; set; } = string.Empty;

        [Column("UserId")]
        public int UserId { get; set; }

        [Column("DriverId")]
        public int? DriverId { get; set; }

        [Column("PickupLat")]
        public decimal PickupLat { get; set; }

        [Column("PickupLong")]
        public decimal PickupLong { get; set; }

        [Column("DropLat")]
        public decimal DropLat { get; set; }

        [Column("DropLong")]
        public decimal DropLong { get; set; }

        [Column("PickupAddress")]
        public string? PickupAddress { get; set; }

        [Column("DropAddress")]
        public string? DropAddress { get; set; }

        [Column("EstimatedFare")]
        public decimal? EstimatedFare { get; set; }

        [Column("FinalFare")]
        public decimal? FinalFare { get; set; }

        // Requested | Accepted | Started | Completed | Cancelled
        [Column("RideStatus")]
        public string RideStatus { get; set; } = "Requested";

        [Column("Rating")]
        public int? Rating { get; set; }

        [Column("Feedback")]
        public string? Feedback { get; set; }

        [Column("RequestedTime")]
        public DateTime RequestedTime { get; set; } = DateTime.UtcNow;

        [Column("StartTime")]
        public DateTime? StartTime { get; set; }

        [Column("EndTime")]
        public DateTime? EndTime { get; set; }

        [ForeignKey("UserId")]
        public User? User { get; set; }

        [ForeignKey("DriverId")]
        public Driver? Driver { get; set; }
    }
}

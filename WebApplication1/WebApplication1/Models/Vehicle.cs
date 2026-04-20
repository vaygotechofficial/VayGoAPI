using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace VaygoTech.Models
{
    [Table("Vehicles")]
    public class Vehicle
    {
        [Key]
        [Column("VehicleId")]
        public int VehicleId { get; set; }

        [Column("DriverId")]
        public int DriverId { get; set; }

        // Bike | Auto | Car
        [Column("VehicleType")]
        public string VehicleType { get; set; } = string.Empty;

        [Column("VehicleNumber")]
        public string VehicleNumber { get; set; } = string.Empty;

        [Column("RCUrl")]
        public string? RCUrl { get; set; }

        [Column("InsuranceUrl")]
        public string? InsuranceUrl { get; set; }

        [Column("InsuranceExpiryDate")]
        public DateTime? InsuranceExpiryDate { get; set; }

        [ForeignKey("DriverId")]
        public Driver? Driver { get; set; }
    }
}

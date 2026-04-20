using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace VaygoTech.Models
{
    [Table("DriverKYC")]
    public class DriverKYC
    {
        [Key]
        [Column("KYCId")]
        public int KYCId { get; set; }

        [Column("DriverId")]
        public int DriverId { get; set; }

        [Column("AadhaarMasked")]
        public string? AadhaarMasked { get; set; }

        [Column("AadhaarEncrypted")]
        public string? AadhaarEncrypted { get; set; }

        [Column("DrivingLicenseNumber")]
        public string? DrivingLicenseNumber { get; set; }

        [Column("LicenseExpiryDate")]
        public DateTime? LicenseExpiryDate { get; set; }

        [Column("AadhaarDocUrl")]
        public string? AadhaarDocUrl { get; set; }

        [Column("LicenseDocUrl")]
        public string? LicenseDocUrl { get; set; }

        [Column("AadhaarVerified")]
        public bool AadhaarVerified { get; set; } = false;

        [Column("LicenseVerified")]
        public bool LicenseVerified { get; set; } = false;

        [ForeignKey("DriverId")]
        public Driver? Driver { get; set; }
    }
}

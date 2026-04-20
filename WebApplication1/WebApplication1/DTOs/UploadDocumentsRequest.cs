using System.ComponentModel.DataAnnotations;

namespace VaygoTech.DTOs
{
    public class UploadDocumentsRequest
    {
        // KYC Details
        [Required]
        [RegularExpression(@"^\d{12}$", ErrorMessage = "Aadhaar must be 12 digits")]
        public string AadhaarNumber { get; set; } = string.Empty;

        [Required]
        public string AadhaarDocUrl { get; set; } = string.Empty;

        [Required]
        public string DrivingLicenseNumber { get; set; } = string.Empty;

        [Required]
        public DateTime LicenseExpiryDate { get; set; }

        [Required]
        public string LicenseDocUrl { get; set; } = string.Empty;

        // Vehicle Details
        [Required]
        [RegularExpression(@"^(Bike|Auto|Car)$", ErrorMessage = "VehicleType must be Bike, Auto, or Car")]
        public string VehicleType { get; set; } = string.Empty;

        [Required]
        public string VehicleNumber { get; set; } = string.Empty;

        [Required]
        public string RCUrl { get; set; } = string.Empty;

        [Required]
        public string InsuranceUrl { get; set; } = string.Empty;

        [Required]
        public DateTime InsuranceExpiryDate { get; set; }
    }
}

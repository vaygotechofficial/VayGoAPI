using System.ComponentModel.DataAnnotations;

namespace VaygoTech.DTOs
{
    public class VerifyOtpRequest
    {
        [Required]
        [RegularExpression(@"^\d{10}$", ErrorMessage = "Mobile number must be 10 digits")]
        public string MobileNumber { get; set; } = string.Empty;

        [Required]
        [StringLength(6, MinimumLength = 6, ErrorMessage = "OTP must be 6 digits")]
        public string OtpCode { get; set; } = string.Empty;

        // user | driver
        [Required]
        public string UserType { get; set; } = "user";
    }
}

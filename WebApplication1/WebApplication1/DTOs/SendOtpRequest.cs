using System.ComponentModel.DataAnnotations;

namespace VaygoTech.DTOs
{
    public class SendOtpRequest
    {
        [Required]
        [RegularExpression(@"^\d{10}$", ErrorMessage = "Mobile number must be 10 digits")]
        public string MobileNumber { get; set; } = string.Empty;

        // user | driver
        [Required]
        public string UserType { get; set; } = "user";
    }
}

using System.ComponentModel.DataAnnotations;

namespace VaygoTech.DTOs
{
    public class UpdateProfileRequest
    {
        [Required]
        [StringLength(100)]
        public string FullName { get; set; } = string.Empty;

        [EmailAddress]
        public string? Email { get; set; }
    }
}

using System.ComponentModel.DataAnnotations;

namespace VaygoTech.DTOs
{
    public class RateRideRequest
    {
        [Required]
        [Range(1, 5, ErrorMessage = "Rating must be between 1 and 5")]
        public int Rating { get; set; }

        [StringLength(500)]
        public string? Feedback { get; set; }
    }
}

using System.ComponentModel.DataAnnotations;

namespace VaygoTech.DTOs
{
    public class AcceptRideRequest
    {
        [Required]
        public int RideId { get; set; }
    }
}

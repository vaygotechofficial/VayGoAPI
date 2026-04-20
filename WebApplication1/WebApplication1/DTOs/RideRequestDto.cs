using System.ComponentModel.DataAnnotations;

namespace VaygoTech.DTOs
{
    public class RideRequestDto
    {
        [Required]
        public decimal PickupLat { get; set; }

        [Required]
        public decimal PickupLong { get; set; }

        [Required]
        public decimal DropLat { get; set; }

        [Required]
        public decimal DropLong { get; set; }

        public string? PickupAddress { get; set; }
        public string? DropAddress { get; set; }
    }
}

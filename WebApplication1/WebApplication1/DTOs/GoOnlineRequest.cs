using System.ComponentModel.DataAnnotations;

namespace VaygoTech.DTOs
{
    public class GoOnlineRequest
    {
        [Required]
        public decimal CurrentLat { get; set; }

        [Required]
        public decimal CurrentLong { get; set; }
    }
}

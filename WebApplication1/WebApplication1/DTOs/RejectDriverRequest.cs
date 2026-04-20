using System.ComponentModel.DataAnnotations;

namespace VaygoTech.DTOs
{
    public class RejectDriverRequest
    {
        [Required]
        public int DriverId { get; set; }

        [Required]
        [StringLength(500)]
        public string Reason { get; set; } = string.Empty;
    }
}

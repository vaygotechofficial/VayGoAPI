using System.ComponentModel.DataAnnotations;

namespace VaygoTech.DTOs
{
    public class ApproveDriverRequest
    {
        [Required]
        public int DriverId { get; set; }
    }
}

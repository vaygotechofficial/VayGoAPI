using System.ComponentModel.DataAnnotations;

namespace VaygoTech.DTOs
{
    public class CreateOrderRequest
    {
        [Required]
        public int PlanId { get; set; }
    }
}

using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace VaygoTech.Models
{
    [Table("Users")]
    public class User
    {
        [Key]
        [Column("UserId")]
        public int UserId { get; set; }

        [Column("FullName")]
        public string FullName { get; set; } = string.Empty;

        [Column("MobileNumber")]
        public string MobileNumber { get; set; } = string.Empty;

        [Column("Email")]
        public string? Email { get; set; }

        [Column("IsActive")]
        public bool IsActive { get; set; } = true;

        [Column("IsAdmin")]
        public bool IsAdmin { get; set; } = false;

        [Column("CreatedDate")]
        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
    }
}

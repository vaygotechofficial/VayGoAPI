using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace VaygoTech.Models
{
    [Table("OTPLogs")]
    public class OTPLog
    {
        [Key]
        [Column("OTPId")]
        public int OTPId { get; set; }

        [Column("MobileNumber")]
        public string MobileNumber { get; set; } = string.Empty;

        [Column("OTPCode")]
        public string OTPCode { get; set; } = string.Empty;

        [Column("IsVerified")]
        public bool IsVerified { get; set; } = false;

        [Column("ExpiryTime")]
        public DateTime ExpiryTime { get; set; }

        [Column("CreatedDate")]
        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
    }
}

using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace VaygoTech.Models
{
    [Table("users")]
    public class User
    {
        [Column("id")]
        public int Id { get; set; }          // id
        [Column("name")]
        public string Name { get; set; }     // name
        [Column("email")]
        public string Email { get; set; }    // email
        [Column("phone")]
        public string Phone { get; set; }    // phone
        [Column("password")]
        public string Password { get; set; } // password
        [Column("user_type")]
        public string UserType { get; set; } // rider/driver/admin
        [Column("created_at")]
        public DateTime CreatedAt { get; set; } // created_at
    }
}
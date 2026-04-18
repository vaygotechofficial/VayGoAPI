using System;
using System.ComponentModel.DataAnnotations.Schema;
namespace VaygoTech.Models
{
    public class Ride
    {
        public int RideId { get; set; }
        public int RiderId { get; set; }
        public int? DriverId { get; set; }
        public string PickupLocation { get; set; }
        public string DropLocation { get; set; }
        public string Status { get; set; }
    }
}

using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using VaygoTech.Models;

namespace VaygoTech.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class RiderController : BaseController
    {
        [HttpPost("register")]
        public IActionResult Register(User user)
        {
            user.UserType = "rider";
            return Ok(user);
        }

        [HttpPost("book-ride")]
        public IActionResult AcceptRide(Ride ride)
        {
            ride.Status = "requested";
            return Ok(ride);
        }
    }
}

using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace VaygoTech.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AdminController : BaseController
    {
        [HttpGet("users")]
        public IActionResult GetUsers()
        {
            return Ok("All users");
        }
    }
}

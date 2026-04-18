using Microsoft.AspNetCore.Mvc;
using VaygoTech.Models;

[Route("api/user")]
[ApiController]
public class UserController : BaseController
{
    private readonly UserService _userService;

    public UserController(UserService userService)
    {
        _userService = userService;
    }

    [HttpGet("GetAllUsers")]
    public async Task<IActionResult> GetAll()
    {
        var users = await _userService.GetAllUsers(); 

        return Ok(users);
    }

  
    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var user = await _userService.GetUserById(id);

        if (user == null)
            return NotFound("User not found");

        return Ok(user);
    }
}
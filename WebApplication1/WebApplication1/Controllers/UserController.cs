using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VaygoTech.DTOs;
using VaygoTech.Services;

[Route("api/user")]
public class UserController : BaseController
{
    private readonly UserService _userService;

    public UserController(UserService userService)
    {
        _userService = userService;
    }

    [HttpGet("profile")]
    //[Authorize(Roles = "user,admin")]
    public async Task<IActionResult> GetProfile()
    {
        var profile = await _userService.GetProfileAsync(GetCurrentUserId());
        return profile == null ? NotFound() : Ok(profile);
    }

    [HttpPut("update-profile")]
    //[Authorize(Roles = "user,admin")]
    public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileRequest request)
    {
        var (success, message) = await _userService.UpdateProfileAsync(GetCurrentUserId(), request);
        return success ? Ok(new { message }) : BadRequest(new { message });
    }
}

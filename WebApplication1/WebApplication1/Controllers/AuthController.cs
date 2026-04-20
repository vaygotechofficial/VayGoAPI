using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VaygoTech.DTOs;
using VaygoTech.Services;

[Route("api/auth")]
[ApiController]
[AllowAnonymous]
public class AuthController : ControllerBase
{
    private readonly AuthService _authService;

    public AuthController(AuthService authService)
    {
        _authService = authService;
    }

    /// <summary>
    /// Send OTP to mobile number. userType: user | driver
    /// </summary>
    [HttpPost("send-otp")]
    public async Task<IActionResult> SendOtp([FromBody] SendOtpRequest request)
    {
        var (success, message) = await _authService.SendOtpAsync(request);
        return success ? Ok(new { message }) : BadRequest(new { message });
    }

    /// <summary>
    /// Verify OTP and receive JWT token. userType: user | driver
    /// </summary>
    [HttpPost("verify-otp")]
    public async Task<IActionResult> VerifyOtp([FromBody] VerifyOtpRequest request)
    {
        var (success, token, userData, message) = await _authService.VerifyOtpAsync(request);

        if (!success)
            return BadRequest(new { message });

        return Ok(new { token, userData, message });
    }
}

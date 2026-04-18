using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using VaygoTech.Models;

[Route("api/auth")]
[ApiController]
public class AuthController : BaseController
{
    private readonly UserService _userService;
    private readonly IConfiguration _config;

    public AuthController(UserService userService, IConfiguration config)
    {
        _userService = userService;
        _config = config;
    }

    [AllowAnonymous]
    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginRequest request)
    {
        var user = await _userService.Authenticate(request.Email, request.Password);

        if (user == null)
            return Unauthorized("Invalid email or password");

        var token = GenerateToken(user);

        return Ok(new
        {
            token,
            user.Id,
            user.Name,
            user.Email,
            user.UserType
        });
    }

    private string GenerateToken(User user)
    {
        var keyString = _config["Jwt:Key"];
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(keyString));

        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Role, user.UserType)
        };

        var token = new JwtSecurityToken(
            issuer: _config["Jwt:Issuer"],
            audience: _config["Jwt:Audience"],
            claims: claims,
            expires: DateTime.Now.AddHours(2),
            signingCredentials: creds
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
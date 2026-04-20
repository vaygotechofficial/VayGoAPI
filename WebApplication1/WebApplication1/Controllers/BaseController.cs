using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

//[Authorize]
[ApiController]
public class BaseController : ControllerBase
{
    protected int GetCurrentUserId()
        => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "0");

    protected string GetCurrentRole()
        => User.FindFirstValue(ClaimTypes.Role) ?? string.Empty;
}

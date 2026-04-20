using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VaygoTech.DTOs;
using VaygoTech.Services;

[Route("api/admin")]
//[Authorize(Roles = "admin")]
public class AdminController : BaseController
{
    private readonly AdminService _adminService;

    public AdminController(AdminService adminService)
    {
        _adminService = adminService;
    }

    /// <summary>
    /// Get all drivers pending review (documents uploaded, not yet approved)
    /// </summary>
    [HttpGet("drivers/pending")]
    public async Task<IActionResult> GetPendingDrivers()
    {
        var drivers = await _adminService.GetPendingDriversAsync();
        return Ok(drivers);
    }

    /// <summary>
    /// Approve a driver after reviewing their documents
    /// </summary>
    [HttpPost("driver/approve")]
    public async Task<IActionResult> ApproveDriver([FromBody] ApproveDriverRequest request)
    {
        var (success, message) = await _adminService.ApproveDriverAsync(request.DriverId);
        return success ? Ok(new { message }) : BadRequest(new { message });
    }

    /// <summary>
    /// Reject a driver with a reason
    /// </summary>
    [HttpPost("driver/reject")]
    public async Task<IActionResult> RejectDriver([FromBody] RejectDriverRequest request)
    {
        var (success, message) = await _adminService.RejectDriverAsync(request.DriverId, request.Reason);
        return success ? Ok(new { message }) : BadRequest(new { message });
    }

    /// <summary>
    /// Subscription revenue report grouped by vehicle type
    /// </summary>
    [HttpGet("subscription/report")]
    public async Task<IActionResult> GetSubscriptionReport()
    {
        var report = await _adminService.GetSubscriptionReportAsync();
        return Ok(report);
    }

    /// <summary>
    /// Rides summary report with completion stats
    /// </summary>
    [HttpGet("rides/report")]
    public async Task<IActionResult> GetRidesReport()
    {
        var report = await _adminService.GetRidesReportAsync();
        return Ok(report);
    }

    /// <summary>
    /// Get all users (admin utility)
    /// </summary>
    [HttpGet("users")]
    public async Task<IActionResult> GetAllUsers()
    {
        var userService = HttpContext.RequestServices.GetRequiredService<UserService>();
        var users = await userService.GetAllUsersAsync();
        return Ok(users);
    }
}

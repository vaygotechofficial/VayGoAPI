using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VaygoTech.DTOs;
using VaygoTech.Services;

[Route("api/ride")]
public class RideController : BaseController
{
    private readonly RideService _rideService;

    public RideController(RideService rideService)
    {
        _rideService = rideService;
    }

    /// <summary>
    /// Request a new ride
    /// </summary>
    [HttpPost("request")]
    //[Authorize(Roles = "user")]
    public async Task<IActionResult> RequestRide([FromBody] RideRequestDto request)
    {
        var (success, message, data) = await _rideService.RequestRideAsync(GetCurrentUserId(), request);
        return success ? Ok(new { message, data }) : BadRequest(new { message });
    }

    /// <summary>
    /// Get ride history for the logged-in user
    /// </summary>
    [HttpGet("history")]
    //[Authorize(Roles = "user")]
    public async Task<IActionResult> GetHistory()
    {
        var rides = await _rideService.GetRideHistoryAsync(GetCurrentUserId());
        return Ok(rides);
    }

    /// <summary>
    /// Rate a completed ride
    /// </summary>
    [HttpPost("rate/{rideId:int}")]
    //[Authorize(Roles = "user")]
    public async Task<IActionResult> RateRide(int rideId, [FromBody] RateRideRequest request)
    {
        var (success, message) = await _rideService.RateRideAsync(GetCurrentUserId(), rideId, request);
        return success ? Ok(new { message }) : BadRequest(new { message });
    }
}

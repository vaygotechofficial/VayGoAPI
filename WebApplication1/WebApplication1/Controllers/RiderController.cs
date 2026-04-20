using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VaygoTech.DTOs;
using VaygoTech.Services;

[Route("api/rider")]
public class RiderController : BaseController
{
    private readonly RiderService _riderService;

    public RiderController(RiderService riderService)
    {
        _riderService = riderService;
    }

    /// <summary>
    /// Step 1: Register/update driver profile
    /// </summary>
    [HttpPost("register")]
   // [Authorize(Roles = "driver")]
    public async Task<IActionResult> Register([FromBody] RiderRegisterRequest request)
    {
        var (success, message, data) = await _riderService.RegisterAsync(request);
        return success ? Ok(new { message, data }) : BadRequest(new { message });
    }

    /// <summary>
    /// Step 2: Upload Aadhaar, DL, and Vehicle documents
    /// </summary>
    [HttpPost("upload-documents")]
    //[Authorize(Roles = "driver")]
    public async Task<IActionResult> UploadDocuments([FromBody] UploadDocumentsRequest request)
    {
        var (success, message) = await _riderService.UploadDocumentsAsync(GetCurrentUserId(), request);
        return success ? Ok(new { message }) : BadRequest(new { message });
    }

    /// <summary>
    /// Get driver profile with KYC and vehicle details
    /// </summary>
    [HttpGet("profile")]
    //[Authorize(Roles = "driver")]
    public async Task<IActionResult> GetProfile()
    {
        var profile = await _riderService.GetProfileAsync(GetCurrentUserId());
        return profile == null ? NotFound() : Ok(profile);
    }

    /// <summary>
    /// Go online — requires approved status and active subscription
    /// </summary>
    [HttpPost("go-online")]
   // [Authorize(Roles = "driver")]
    public async Task<IActionResult> GoOnline([FromBody] GoOnlineRequest request)
    {
        var (success, message) = await _riderService.GoOnlineAsync(GetCurrentUserId(), request);
        return success ? Ok(new { message }) : BadRequest(new { message });
    }

    /// <summary>
    /// Go offline
    /// </summary>
    [HttpPost("go-offline")]
   // [Authorize(Roles = "driver")]
    public async Task<IActionResult> GoOffline()
    {
        var (success, message) = await _riderService.GoOfflineAsync(GetCurrentUserId());
        return success ? Ok(new { message }) : BadRequest(new { message });
    }

    /// <summary>
    /// Accept a ride request
    /// </summary>
    [HttpPost("accept-ride")]
   // [Authorize(Roles = "driver")]
    public async Task<IActionResult> AcceptRide([FromBody] AcceptRideRequest request)
    {
        var rideService = HttpContext.RequestServices.GetRequiredService<RideService>();
        var (success, message) = await rideService.AcceptRideAsync(GetCurrentUserId(), request.RideId);
        return success ? Ok(new { message }) : BadRequest(new { message });
    }

    /// <summary>
    /// Start the ride
    /// </summary>
    [HttpPost("start-ride/{rideId:int}")]
   // [Authorize(Roles = "driver")]
    public async Task<IActionResult> StartRide(int rideId)
    {
        var rideService = HttpContext.RequestServices.GetRequiredService<RideService>();
        var (success, message) = await rideService.StartRideAsync(GetCurrentUserId(), rideId);
        return success ? Ok(new { message }) : BadRequest(new { message });
    }

    /// <summary>
    /// End the ride and mark as completed
    /// </summary>
    [HttpPost("end-ride/{rideId:int}")]
    //[Authorize(Roles = "driver")]
    public async Task<IActionResult> EndRide(int rideId)
    {
        var rideService = HttpContext.RequestServices.GetRequiredService<RideService>();
        var (success, message, data) = await rideService.EndRideAsync(GetCurrentUserId(), rideId);
        return success ? Ok(new { message, data }) : BadRequest(new { message });
    }
}

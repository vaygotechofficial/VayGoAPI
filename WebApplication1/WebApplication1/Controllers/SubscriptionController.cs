using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VaygoTech.DTOs;
using VaygoTech.Services;

[Route("api/subscription")]
public class SubscriptionController : BaseController
{
    private readonly SubscriptionService _subscriptionService;

    public SubscriptionController(SubscriptionService subscriptionService)
    {
        _subscriptionService = subscriptionService;
    }

    /// <summary>
    /// Get all active subscription plans (Bike ₹299, Auto ₹399, Car ₹499)
    /// </summary>
    [HttpGet("plans")]
    [AllowAnonymous]
    public async Task<IActionResult> GetPlans()
    {
        var plans = await _subscriptionService.GetPlansAsync();
        return Ok(plans);
    }

    /// <summary>
    /// Create a UPI payment order for a subscription plan
    /// </summary>
    [HttpPost("create-order")]
    //[Authorize(Roles = "driver")]
    public async Task<IActionResult> CreateOrder([FromBody] CreateOrderRequest request)
    {
        var (success, message, data) = await _subscriptionService.CreateOrderAsync(GetCurrentUserId(), request.PlanId);
        return success ? Ok(new { message, data }) : BadRequest(new { message });
    }
}

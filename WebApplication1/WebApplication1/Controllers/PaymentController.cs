using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VaygoTech.DTOs;
using VaygoTech.Services;

[Route("api/payment")]
[ApiController]
public class PaymentController : ControllerBase
{
    private readonly PaymentService _paymentService;

    public PaymentController(PaymentService paymentService)
    {
        _paymentService = paymentService;
    }

    /// <summary>
    /// UPI payment gateway webhook — called by payment provider, not the app
    /// </summary>
    [HttpPost("webhook")]
    [AllowAnonymous]
    public async Task<IActionResult> Webhook([FromBody] WebhookRequest request)
    {
        var (success, message) = await _paymentService.HandleWebhookAsync(request);
        // Always return 200 to the gateway; log failures internally
        return Ok(new { success, message });
    }
}

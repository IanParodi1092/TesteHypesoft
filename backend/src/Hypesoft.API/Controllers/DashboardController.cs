using Hypesoft.Application.DTOs;
using Hypesoft.Application.Queries.Dashboard;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Hypesoft.API.Controllers;

[ApiController]
[Route("api/dashboard")]
[Authorize]
public sealed class DashboardController : ControllerBase
{
    private readonly IMediator _mediator;

    public DashboardController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<ActionResult<DashboardDto>> Get(CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetDashboardQuery(), cancellationToken);
        return Ok(result);
    }
}

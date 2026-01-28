using Hypesoft.Application.Commands.Categories;
using Hypesoft.Application.DTOs;
using Hypesoft.Application.Queries.Categories;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Hypesoft.API.Controllers;

[ApiController]
[Route("api/categories")]
[Authorize]
public sealed class CategoriesController : ControllerBase
{
    private readonly IMediator _mediator;

    public CategoriesController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<CategoryDto>>> List(CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new ListCategoriesQuery(), cancellationToken);
        return Ok(result);
    }

    [HttpPost]
    [Authorize(Policy = "RequireManager")]
    public async Task<ActionResult<CategoryDto>> Create(
        [FromBody] CreateCategoryCommand command,
        CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(command, cancellationToken);
        return CreatedAtAction(nameof(List), new { id = result.Id }, result);
    }

    [HttpDelete("{id}")]
    [Authorize(Policy = "RequireManager")]
    public async Task<IActionResult> Delete(string id, CancellationToken cancellationToken)
    {
        await _mediator.Send(new DeleteCategoryCommand(id), cancellationToken);
        return NoContent();
    }
}

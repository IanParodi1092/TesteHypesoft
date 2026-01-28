using Hypesoft.Application.Commands.Products;
using Hypesoft.Application.DTOs;
using Hypesoft.Application.Queries.Products;
using Hypesoft.Domain.ValueObjects;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Hypesoft.API.Controllers;

[ApiController]
[Route("api/products")]
[Authorize]
public sealed class ProductsController : ControllerBase
{
    private readonly IMediator _mediator;

    public ProductsController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<ProductDto>>> List(
        [FromQuery] string? search,
        [FromQuery] string? categoryId,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        var result = await _mediator.Send(new ListProductsQuery(search, categoryId, page, pageSize), cancellationToken);
        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ProductDto>> GetById(string id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetProductByIdQuery(id), cancellationToken);
        if (result is null)
        {
            return NotFound();
        }

        return Ok(result);
    }

    [HttpGet("low-stock")]
    public async Task<ActionResult<IReadOnlyList<ProductDto>>> LowStock(
        [FromQuery] int threshold = 10,
        CancellationToken cancellationToken = default)
    {
        var result = await _mediator.Send(new ListLowStockProductsQuery(threshold), cancellationToken);
        return Ok(result);
    }

    [HttpPost]
    [Authorize(Policy = "RequireManager")]
    public async Task<ActionResult<ProductDto>> Create(
        [FromBody] CreateProductCommand command,
        CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(command, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }

    [HttpPut("{id}")]
    [Authorize(Policy = "RequireManager")]
    public async Task<ActionResult<ProductDto>> Update(
        string id,
        [FromBody] UpdateProductCommand command,
        CancellationToken cancellationToken)
    {
        if (id != command.Id)
        {
            return BadRequest("O id da rota não corresponde ao corpo.");
        }

        var result = await _mediator.Send(command, cancellationToken);
        return Ok(result);
    }

    [HttpPatch("{id}/stock")]
    [Authorize(Policy = "RequireManager")]
    public async Task<ActionResult<ProductDto>> UpdateStock(
        string id,
        [FromBody] UpdateProductStockCommand command,
        CancellationToken cancellationToken)
    {
        if (id != command.Id)
        {
            return BadRequest("O id da rota não corresponde ao corpo.");
        }

        var result = await _mediator.Send(command, cancellationToken);
        return Ok(result);
    }

    [HttpDelete("{id}")]
    [Authorize(Policy = "RequireManager")]
    public async Task<IActionResult> Delete(string id, CancellationToken cancellationToken)
    {
        await _mediator.Send(new DeleteProductCommand(id), cancellationToken);
        return NoContent();
    }
}

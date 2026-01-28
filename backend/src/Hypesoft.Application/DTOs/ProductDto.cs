namespace Hypesoft.Application.DTOs;

public sealed class ProductDto
{
    public string Id { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public string CategoryId { get; set; } = string.Empty;
    public string? CategoryName { get; set; }
    public int Quantity { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

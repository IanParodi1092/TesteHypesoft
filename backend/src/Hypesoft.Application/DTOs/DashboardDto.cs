namespace Hypesoft.Application.DTOs;

public sealed class DashboardDto
{
    public long TotalProducts { get; set; }
    public decimal TotalStockValue { get; set; }
    public IReadOnlyList<ProductDto> LowStockProducts { get; set; } = Array.Empty<ProductDto>();
    public IReadOnlyList<CategoryCountDto> ProductsByCategory { get; set; } = Array.Empty<CategoryCountDto>();
}

public sealed class CategoryCountDto
{
    public string CategoryId { get; set; } = string.Empty;
    public string CategoryName { get; set; } = string.Empty;
    public int Count { get; set; }
}

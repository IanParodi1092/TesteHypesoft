namespace Hypesoft.Domain.Entities;

public class Product : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public string CategoryId { get; set; } = string.Empty;
    public int Quantity { get; set; }

    public void Touch()
    {
        UpdatedAt = DateTime.UtcNow;
    }
}

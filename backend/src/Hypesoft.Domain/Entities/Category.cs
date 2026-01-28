namespace Hypesoft.Domain.Entities;

public class Category : BaseEntity
{
    public string Name { get; set; } = string.Empty;

    public void Touch()
    {
        UpdatedAt = DateTime.UtcNow;
    }
}

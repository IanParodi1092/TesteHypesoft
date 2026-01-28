namespace Hypesoft.Infrastructure.Configurations;

public sealed class MongoSettings
{
    public string ConnectionString { get; set; } = string.Empty;
    public string DatabaseName { get; set; } = "hypesoft";
    public string ProductsCollection { get; set; } = "products";
    public string CategoriesCollection { get; set; } = "categories";
}

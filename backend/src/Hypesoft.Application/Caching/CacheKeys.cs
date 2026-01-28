namespace Hypesoft.Application.Caching;

public static class CacheKeys
{
    public const string CategoriesAll = "categories:all";
    public const string Dashboard = "dashboard";
    public static string LowStock(int threshold) => $"products:lowstock:{threshold}";
}

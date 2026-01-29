using Hypesoft.Domain.Entities;
using Hypesoft.Infrastructure.Configurations;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using MongoDB.EntityFrameworkCore.Extensions;

namespace Hypesoft.Infrastructure.Data;

public sealed class HypesoftDbContext : DbContext
{
    private readonly MongoSettings _settings;

    public HypesoftDbContext(DbContextOptions<HypesoftDbContext> options, IOptions<MongoSettings> settings)
        : base(options)
    {
        _settings = settings.Value;
    }

    public DbSet<Product> Products => Set<Product>();
    public DbSet<Category> Categories => Set<Category>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Product>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.ToCollection(_settings.ProductsCollection);
        });

        modelBuilder.Entity<Category>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.ToCollection(_settings.CategoriesCollection);
        });

        base.OnModelCreating(modelBuilder);
    }
}
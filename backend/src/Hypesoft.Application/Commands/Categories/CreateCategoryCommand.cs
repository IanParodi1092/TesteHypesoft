using AutoMapper;
using Hypesoft.Application.DTOs;
using Hypesoft.Application.Caching;
using Hypesoft.Domain.Entities;
using Hypesoft.Domain.Repositories;
using MediatR;
using Microsoft.Extensions.Caching.Memory;

namespace Hypesoft.Application.Commands.Categories;

public sealed record CreateCategoryCommand(string Name) : IRequest<CategoryDto>;

public sealed class CreateCategoryCommandHandler : IRequestHandler<CreateCategoryCommand, CategoryDto>
{
    private readonly ICategoryRepository _categoryRepository;
    private readonly IMapper _mapper;
    private readonly IMemoryCache _cache;

    public CreateCategoryCommandHandler(ICategoryRepository categoryRepository, IMapper mapper, IMemoryCache cache)
    {
        _categoryRepository = categoryRepository;
        _mapper = mapper;
        _cache = cache;
    }

    public async Task<CategoryDto> Handle(CreateCategoryCommand request, CancellationToken cancellationToken)
    {
        var category = new Category
        {
            Name = request.Name
        };

        await _categoryRepository.CreateAsync(category, cancellationToken);

        _cache.Remove(CacheKeys.CategoriesAll);
        _cache.Remove(CacheKeys.Dashboard);

        return _mapper.Map<CategoryDto>(category);
    }
}

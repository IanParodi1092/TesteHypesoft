using AutoMapper;
using Hypesoft.Application.DTOs;
using Hypesoft.Domain.Entities;

namespace Hypesoft.Application.Mappings;

public sealed class MappingProfile : Profile
{
    public MappingProfile()
    {
        CreateMap<Product, ProductDto>();
        CreateMap<Category, CategoryDto>();
    }
}

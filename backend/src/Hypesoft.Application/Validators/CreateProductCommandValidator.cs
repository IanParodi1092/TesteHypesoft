using FluentValidation;
using Hypesoft.Application.Commands.Products;

namespace Hypesoft.Application.Validators;

public sealed class CreateProductCommandValidator : AbstractValidator<CreateProductCommand>
{
    public CreateProductCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty()
            .MaximumLength(120);

        RuleFor(x => x.Description)
            .NotEmpty()
            .MaximumLength(1000);

        RuleFor(x => x.Price)
            .GreaterThanOrEqualTo(0);

        RuleFor(x => x.CategoryId)
            .NotEmpty();

        RuleFor(x => x.Quantity)
            .GreaterThanOrEqualTo(0);
    }
}

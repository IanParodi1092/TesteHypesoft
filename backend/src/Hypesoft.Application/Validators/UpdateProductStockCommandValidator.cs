using FluentValidation;
using Hypesoft.Application.Commands.Products;

namespace Hypesoft.Application.Validators;

public sealed class UpdateProductStockCommandValidator : AbstractValidator<UpdateProductStockCommand>
{
    public UpdateProductStockCommandValidator()
    {
        RuleFor(x => x.Id)
            .NotEmpty();

        RuleFor(x => x.Quantity)
            .GreaterThanOrEqualTo(0);
    }
}

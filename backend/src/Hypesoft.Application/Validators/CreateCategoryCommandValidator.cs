using FluentValidation;
using Hypesoft.Application.Commands.Categories;

namespace Hypesoft.Application.Validators;

public sealed class CreateCategoryCommandValidator : AbstractValidator<CreateCategoryCommand>
{
    public CreateCategoryCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty()
            .MaximumLength(80);
    }
}

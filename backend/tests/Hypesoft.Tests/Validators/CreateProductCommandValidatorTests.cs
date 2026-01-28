using FluentAssertions;
using Hypesoft.Application.Commands.Products;
using Hypesoft.Application.Validators;

namespace Hypesoft.Tests.Validators;

public sealed class CreateProductCommandValidatorTests
{
    [Fact]
    public void Should_fail_when_required_fields_missing()
    {
        var validator = new CreateProductCommandValidator();
        var command = new CreateProductCommand(string.Empty, string.Empty, -1, string.Empty, -2);

        var result = validator.Validate(command);

        result.IsValid.Should().BeFalse();
        result.Errors.Should().NotBeEmpty();
    }

    [Fact]
    public void Should_pass_with_valid_values()
    {
        var validator = new CreateProductCommandValidator();
        var command = new CreateProductCommand("Produto", "Descricao", 10.5m, "cat-1", 5);

        var result = validator.Validate(command);

        result.IsValid.Should().BeTrue();
    }
}

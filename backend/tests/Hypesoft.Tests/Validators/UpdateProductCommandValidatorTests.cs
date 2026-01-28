using FluentAssertions;
using Hypesoft.Application.Commands.Products;
using Hypesoft.Application.Validators;

namespace Hypesoft.Tests.Validators;

public sealed class UpdateProductCommandValidatorTests
{
    [Fact]
    public void Should_fail_when_id_missing()
    {
        var validator = new UpdateProductCommandValidator();
        var command = new UpdateProductCommand(string.Empty, "Nome", "Desc", 10m, "cat", 1);

        var result = validator.Validate(command);

        result.IsValid.Should().BeFalse();
    }

    [Fact]
    public void Should_pass_with_valid_values()
    {
        var validator = new UpdateProductCommandValidator();
        var command = new UpdateProductCommand("prod-1", "Nome", "Desc", 10m, "cat", 1);

        var result = validator.Validate(command);

        result.IsValid.Should().BeTrue();
    }
}

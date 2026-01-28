using System.Security.Claims;
using System.Text.Json;
using FluentValidation;
using Hypesoft.Application;
using Hypesoft.Infrastructure;
using Hypesoft.API.Seed;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.IdentityModel.Tokens;
using Scalar.AspNetCore;
using Serilog;
using Serilog.Context;

var builder = WebApplication.CreateBuilder(args);

builder.Host.UseSerilog((context, logger) =>
{
    logger.ReadFrom.Configuration(context.Configuration);
    logger.Enrich.FromLogContext();
    logger.WriteTo.Console();
});

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddOpenApi();

builder.Services.Configure<SeedOptions>(builder.Configuration.GetSection("Seed"));
builder.Services.AddHostedService<SeedDataHostedService>();

builder.Services.AddApplication();
builder.Services.AddInfrastructure(builder.Configuration);

builder.Services.AddMemoryCache();
builder.Services.AddHealthChecks();

builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
    options.AddFixedWindowLimiter("fixed", limiterOptions =>
    {
        limiterOptions.PermitLimit = 100;
        limiterOptions.Window = TimeSpan.FromMinutes(1);
        limiterOptions.QueueProcessingOrder = System.Threading.RateLimiting.QueueProcessingOrder.OldestFirst;
        limiterOptions.QueueLimit = 2;
    });
});

var strictTokenValidation = builder.Configuration.GetValue("Keycloak:ValidateIssuerAudience", !builder.Environment.IsDevelopment());

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = builder.Configuration["Keycloak:Authority"];
        options.Audience = builder.Configuration["Keycloak:Audience"];
        options.RequireHttpsMetadata = builder.Configuration.GetValue("Keycloak:RequireHttpsMetadata", false);

        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = strictTokenValidation,
            ValidateAudience = strictTokenValidation,
            NameClaimType = "preferred_username",
            RoleClaimType = ClaimTypes.Role
        };

        options.Events = new JwtBearerEvents
        {
            OnTokenValidated = context =>
            {
                if (context.Principal?.Identity is ClaimsIdentity identity)
                {
                    var realmAccess = context.Principal.FindFirst("realm_access")?.Value;
                    if (!string.IsNullOrWhiteSpace(realmAccess))
                    {
                        using var document = JsonDocument.Parse(realmAccess);
                        if (document.RootElement.TryGetProperty("roles", out var roles))
                        {
                            foreach (var role in roles.EnumerateArray())
                            {
                                identity.AddClaim(new Claim(ClaimTypes.Role, role.GetString() ?? string.Empty));
                            }
                        }
                    }
                }

                return Task.CompletedTask;
            }
        };
    });

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("RequireManager", policy =>
        policy.RequireRole("Admin", "Manager"));
});

builder.Services.AddCors(options =>
{
    options.AddPolicy("default", policy =>
    {
        policy.AllowAnyOrigin();
        policy.AllowAnyHeader();
        policy.AllowAnyMethod();
    });
});

var app = builder.Build();

app.UseExceptionHandler(errorApp =>
{
    errorApp.Run(async context =>
    {
        var exceptionHandler = context.Features.Get<IExceptionHandlerPathFeature>();
        var exception = exceptionHandler?.Error;

        context.Response.ContentType = "application/problem+json";

        if (exception is ValidationException validationException)
        {
            context.Response.StatusCode = StatusCodes.Status400BadRequest;
            var errors = validationException.Errors
                .GroupBy(error => error.PropertyName)
                .ToDictionary(
                    group => group.Key,
                    group => group.Select(error => error.ErrorMessage).ToArray());

            await context.Response.WriteAsJsonAsync(new
            {
                title = "Falha de validação",
                status = StatusCodes.Status400BadRequest,
                errors
            });
            return;
        }

        context.Response.StatusCode = StatusCodes.Status500InternalServerError;
        await context.Response.WriteAsJsonAsync(new
        {
            title = "Erro inesperado",
            status = StatusCodes.Status500InternalServerError,
            detail = exception?.Message
        });
    });
});


app.UseSerilogRequestLogging();

app.Use(async (context, next) =>
{
    const string headerName = "X-Correlation-ID";
    var correlationId = context.Request.Headers.TryGetValue(headerName, out var headerValue)
        ? headerValue.ToString()
        : Guid.NewGuid().ToString("N");

    context.Response.Headers[headerName] = correlationId;

    using (LogContext.PushProperty("CorrelationId", correlationId))
    {
        await next();
    }
});

app.Use(async (context, next) =>
{
    context.Response.Headers["X-Content-Type-Options"] = "nosniff";
    context.Response.Headers["X-Frame-Options"] = "SAMEORIGIN";
    context.Response.Headers["Referrer-Policy"] = "strict-origin-when-cross-origin";
    context.Response.Headers["Permissions-Policy"] = "geolocation=(), microphone=()";
    await next();
});

if (builder.Configuration.GetValue("UseHttpsRedirection", false))
{
    app.UseHttpsRedirection();
}
app.UseCors("default");
app.UseRateLimiter();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHealthChecks("/health");
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi("/openapi/v1.json");
    app.MapScalarApiReference();
}

app.Run();

public partial class Program { }

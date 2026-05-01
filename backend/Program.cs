using Microsoft.Data.SqlClient;
using Dapper;
using OpenCodeApi.Models;
using System.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAngular",
        policy =>
        {
            policy.WithOrigins("http://localhost:4200")
                  .AllowAnyHeader()
                  .AllowAnyMethod();
        });
});

// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

// Add Dapper Type Handler for DateOnly
SqlMapper.AddTypeHandler(new DateOnlyTypeHandler());

app.UseCors("AllowAngular");

app.UseHttpsRedirection();

const string connectionString = "Server=mssql_stable,1433;Database=master;User Id=sa;Password=Op3nC0de!2026_Secure;TrustServerCertificate=True";

app.MapGet("/weatherforecast", async (ILogger<Program> logger) =>
{
    try
    {
        using var connection = new SqlConnection(connectionString);
        var forecasts = await connection.QueryAsync<WeatherForecast>("SELECT Date, TemperatureC, Summary FROM Forecasts");
        return Results.Ok(forecasts);
    }
    catch (Exception ex)
    {
        logger.LogError(ex, "Error fetching weather forecasts");
        return Results.Problem("Check SQL Connection or Schema mapping.");
    }
})
.WithName("GetWeatherForecast");

app.MapPost("/weatherforecast", async (WeatherForecast forecast, ILogger<Program> logger) =>
{
    try
    {
        using var connection = new SqlConnection(connectionString);
        var sql = "INSERT INTO Forecasts (Date, TemperatureC, Summary) VALUES (@Date, @TemperatureC, @Summary)";
        await connection.ExecuteAsync(sql, forecast);
        return Results.Created("/weatherforecast", forecast);
    }
    catch (Exception ex)
    {
        logger.LogError(ex, "Error adding weather forecast");
        return Results.Problem("Error adding forecast.");
    }
})
.WithName("AddWeatherForecast");

app.Run();

// Dapper Type Handler for DateOnly support
public class DateOnlyTypeHandler : SqlMapper.TypeHandler<DateOnly>
{
    public override void SetValue(IDbDataParameter parameter, DateOnly value)
    {
        parameter.Value = value.ToDateTime(TimeOnly.MinValue);
    }

    public override DateOnly Parse(object value)
    {
        return DateOnly.FromDateTime((DateTime)value);
    }
}


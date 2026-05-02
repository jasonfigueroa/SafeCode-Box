CREATE TABLE Forecasts (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Date DATE NOT NULL,
    TemperatureC INT NOT NULL,
    Summary NVARCHAR(MAX) NULL
);

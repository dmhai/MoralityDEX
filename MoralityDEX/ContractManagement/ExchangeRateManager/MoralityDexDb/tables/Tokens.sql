CREATE TABLE [dbo].[Tokens]
(
	[Id] INT NOT NULL Identity(1,1) PRIMARY KEY, 
    [Symbol] NVARCHAR(50) NOT NULL, 
    [Description] NVARCHAR(500) NULL, 
    [PointPrecision] INT NOT NULL DEFAULT 18, 
    [Active] BIT NOT NULL DEFAULT 1
)

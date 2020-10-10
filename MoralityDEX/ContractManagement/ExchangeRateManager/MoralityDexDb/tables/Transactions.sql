CREATE TABLE [dbo].[Transactions]
(
	[Id] INT NOT NULL Identity(1,1) PRIMARY KEY, 
    [RequestAddress] NVARCHAR(50) NOT NULL, 
    [Symbol] NVARCHAR(20) NOT NULL, 
    [TokenAddress] NVARCHAR(50) NOT NULL,
	[Rate] BIGINT NOT NULL,
    [Tx] NVARCHAR(100) NOT NULL, 
    [DateCompleted] DATETIME NOT NULL DEFAULT GETDATE() 
)

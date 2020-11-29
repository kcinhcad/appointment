CREATE TABLE [dbo].[Appointment](
	[Id]				UNIQUEIDENTIFIER	NOT NULL,
	[CreateDate]		DATETIME			NULL,
	[State]				INT					NULL,
	[TryCount]			INT					NULL,
	[Email]				NVARCHAR(255)		NULL,
	[Phone]				NVARCHAR(255)		NULL,
	[ScheduleCellId]	UNIQUEIDENTIFIER	NULL,
	[CellBegin]			DATETIME			NULL,
	[CellEnd]			DATETIME			NULL,
	CONSTRAINT [PK_Appointment] PRIMARY KEY CLUSTERED ([Id] ASC)
)
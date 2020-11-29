CREATE TABLE [dbo].[Specialist] (
	[Id]				UNIQUEIDENTIFIER	NOT NULL,
	[Name]				NVARCHAR (255)		NULL,
	[AdditionalText]	NVARCHAR (255)		NULL,
	[IsLocal]			BIT					CONSTRAINT [DF_Specialist_IsLocal] DEFAULT (0) NOT NULL,
	[IsPrivate]			BIT					CONSTRAINT [DF_Specialist_IsPrivate] DEFAULT (0) NOT NULL,
	CONSTRAINT [PK_Specialist] PRIMARY KEY CLUSTERED ([Id] ASC)
)

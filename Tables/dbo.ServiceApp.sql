CREATE TABLE [dbo].[ServiceApp](
	[Id]						INT					IDENTITY(1,1) NOT NULL,
	[LpuId]						UNIQUEIDENTIFIER	NULL,
	[DivLpuId]					UNIQUEIDENTIFIER	NULL,
	[TreatRegistryCellsAsFree]	BIT					NOT NULL,
	[NeedFullSync]				BIT					NOT NULL,
	[LastAccess]				DATETIME			NULL,
	[LastFullSync]				DATETIME			NULL,
	CONSTRAINT [PK_ServiceApp] PRIMARY KEY CLUSTERED ([Id] ASC)
)
﻿CREATE TABLE [dbo].[DivLpu](
	[Id]						UNIQUEIDENTIFIER												NOT NULL,
	[Name]						NVARCHAR(255)													NULL,
	[ShortName]					NVARCHAR(255)													NULL,
	[Info]						NVARCHAR(255)													NULL,
	[LpuId]						UNIQUEIDENTIFIER												NULL,
	[IsAppointmented]			BIT CONSTRAINT [DF_DivLpu_IsAppointmented] DEFAULT (1)			NOT NULL,
	[IsAppointmentedSetAdmin]	BIT CONSTRAINT [DF_DivLpu_IsAppointmentedSetAdmin] DEFAULT (0)	NOT NULL,
	[StatusOfAppointment]		TINYINT CONSTRAINT [DF_DivLpu_StatusOfAppointment] DEFAULT (0)	NOT NULL,
	[GeoX]						REAL															NULL,
	[GeoY]						REAL															NULL,
	[NotifyEmails]				VARCHAR(MAX)													NULL,
	[AppointmentUrl]			VARCHAR(MAX)													NULL,
	[AttachAppType]				TINYINT CONSTRAINT [DF_DivLpu_AttachAppType] DEFAULT (0)		NOT NULL,
	[OnlyRegistered]			BIT CONSTRAINT [DF_DivLpu_OnlyRegistered] DEFAULT (0)			NOT NULL,
	[NumberDayEnableApp]		TINYINT CONSTRAINT [DF_DivLpu_NumberDayEnableApp] DEFAULT (1)	NOT NULL,
	[ClinicUrl]					NVARCHAR(255)													NULL,
	[ClinicEmail]				NVARCHAR(255)													NULL,
	[IsAppointmentRequest]		BIT CONSTRAINT [DF_DivLpu_IsAppointmentRequest] DEFAULT (0)		NOT NULL,
	[AppointmentRequestEmail]	NVARCHAR(MAX)													NULL,
	[AppointmentRequestPhone]	NVARCHAR(MAX)													NULL,
	[OrgGroupId]				UNIQUEIDENTIFIER												NULL,
	[Priority]					INT CONSTRAINT [DF_DivLpu_Priority] DEFAULT (0)					NOT NULL,
	[IsHideQueue]				BIT CONSTRAINT [DF_DivLpu_IsHideQueue] DEFAULT (0)				NOT NULL,
	CONSTRAINT [PK_DivLpu] PRIMARY KEY CLUSTERED ([Id] ASC)
)
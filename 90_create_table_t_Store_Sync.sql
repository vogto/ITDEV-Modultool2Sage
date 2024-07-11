USE [test62_help]
GO


CREATE TABLE [MODTO].[t_Store_Sync](
	[lgnr] [decimal](38, 0) NULL,
	[ben] [nvarchar](40) COLLATE Latin1_General_CS_AS_KS_WS NULL,
	[prio] [nvarchar](5) COLLATE Latin1_General_CS_AS_KS_WS NULL,	
	[userneu] [nvarchar](8) COLLATE Latin1_General_CI_AS NULL,
	[datneu] [datetime] NULL,
	[useraen] [nvarchar](8) COLLATE Latin1_General_CI_AS NULL,
	[dataen] [datetime] NULL,
	[rec_status] [smallint] NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
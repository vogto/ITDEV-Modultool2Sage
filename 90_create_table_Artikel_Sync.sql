USE [test62_help]
GO

CREATE TABLE [MODTO].[t_Artikel_Sync](
	[id] [nvarchar](22) COLLATE Latin1_General_CS_AS_KS_WS NULL,
	[ben_de] [nvarchar](40) COLLATE Latin1_General_CS_AS_KS_WS NULL,
	[ben_en] [nvarchar](40) COLLATE Latin1_General_CS_AS_KS_WS NULL,
	[ean] [nvarchar](15) COLLATE Latin1_General_CS_AS_KS_WS NULL,
	[tax] [nvarchar](30) COLLATE Latin1_General_CI_AS NULL,
	[vk_de] [decimal](38, 15) NULL,
	[vk_at] [decimal](38, 15) NULL,
	[vk_ch] [decimal](38, 15) NULL,
	[ve] [int] NULL,
	[inventory_warehouse_total] [int] NULL,
	[inventory_stores_total] [int] NULL,
	[inventory_stores_reference] [int] NULL,
	[disposition_type] [nvarchar](1) COLLATE Latin1_General_CS_AS_KS_WS NULL,
	[next_delivery_quantity] [int] NULL,
	[next_delivery_date] [date] NULL,
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
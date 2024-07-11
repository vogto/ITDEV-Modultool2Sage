create table MODTO.t_ModuleType
(
   rowid int identity(1,1) not null
  ,rec_status int
  ,rat nvarchar(3) collate Latin1_General_CS_AS_KS_WS
  ,datneu datetime
  ,userneu nvarchar(20) collate Latin1_General_CS_AS_KS_WS
  ,dataen datetime
  ,useraen nvarchar(20) collate Latin1_General_CS_AS_KS_WS
  ,id nvarchar(100) collate Latin1_General_CS_AS_KS_WS
  ,description_de nvarchar(40) collate Latin1_General_CS_AS_KS_WS
  ,description_en nvarchar(40) collate Latin1_General_CS_AS_KS_WS
) with(data_compression=page)

create table MODTO.t_ModuleGroup
(
   rowid int identity(1,1) not null
  ,rec_status int
  ,rat nvarchar(3) collate Latin1_General_CS_AS_KS_WS
  ,datneu datetime
  ,userneu nvarchar(20) collate Latin1_General_CS_AS_KS_WS
  ,dataen datetime
  ,useraen nvarchar(20) collate Latin1_General_CS_AS_KS_WS
  ,id nvarchar(100) collate Latin1_General_CS_AS_KS_WS
  ,description_de nvarchar(40) collate Latin1_General_CS_AS_KS_WS
  ,description_en nvarchar(40) collate Latin1_General_CS_AS_KS_WS
) with(data_compression=page)

create table MODTO.t_Module
(
   rowid int identity(1,1) not null
  ,rec_status int
  ,rat nvarchar(3) collate Latin1_General_CS_AS_KS_WS
  ,datneu datetime
  ,userneu nvarchar(20) collate Latin1_General_CS_AS_KS_WS
  ,dataen datetime
  ,useraen nvarchar(20) collate Latin1_General_CS_AS_KS_WS
  ,id decimal(38,0)
  ,description_de nvarchar(40) collate Latin1_General_CS_AS_KS_WS
  ,description_en nvarchar(40) collate Latin1_General_CS_AS_KS_WS
  ,theme_de nvarchar(1000) collate Latin1_General_CS_AS_KS_WS
  ,theme_en nvarchar(1000) collate Latin1_General_CS_AS_KS_WS
  ,is_active smallint
  ,is_seasonal smallint
  ,available_from datetime
  ,available_till datetime
  ,module_type_id nvarchar(100) collate Latin1_General_CS_AS_KS_WS
  ,module_group_id nvarchar(100) collate Latin1_General_CS_AS_KS_WS
  ,created_by nvarchar(70) collate Latin1_General_CS_AS_KS_WS
  ,created_at datetime
  ,updated_by nvarchar(70) collate Latin1_General_CS_AS_KS_WS
  ,updated_at datetime
  ,is_hidden int 
) with(data_compression=page)

create table MODTO.t_Stores
(
   rowid int identity(1,1) not null
  ,rec_status int
  ,rat nvarchar(3) collate Latin1_General_CS_AS_KS_WS
  ,datneu datetime
  ,userneu nvarchar(20) collate Latin1_General_CS_AS_KS_WS
  ,dataen datetime
  ,useraen nvarchar(20) collate Latin1_General_CS_AS_KS_WS
  ,store_id decimal(38,0)
  ,id decimal(38,0)
  ,classificationABC nvarchar(2) collate Latin1_General_CS_AS_KS_WS
) with(data_compression=page)
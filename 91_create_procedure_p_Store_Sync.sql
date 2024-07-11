USE [test62_help]
GO
/****** Object:  StoredProcedure [MODTO].[p_Artikel_Sync]    Script Date: 11.07.2024 07:45:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [MODTO].[p_Store_Sync]
as
begin
  set nocount on

  --Variablen
  declare 
    @user nvarchar(8) = [test62].[dbo].fn_benutzer()
    ,@datum datetime = getdate()
    ,@rc int = 0


  ------------------------------------------------------------------------------------------------------------------------------------
  --Daten löschen
  if ( (select count(*) from [test62_help].[MODTO].[t_Store_Sync]) > 0 )
  begin
    truncate table [test62_help].[MODTO].[t_Store_Sync]
  end


  ------------------------------------------------------------------------------------------------------------------------------------
  --Daten einfügen
  insert into [test62_help].[MODTO].[t_Store_Sync]
  select 
    l900b.lgnr
    ,vk.ben
    --,vkl.name_1
    ,l900b.prio
	  ,@user 
	  ,@datum
	  ,@user 
	  ,@datum
	  ,0
  from  
    [test62].[dbo].l900b (nolock)
    join [test62].[dbo].view_kostenstellen vk on 
      vk.fi_nr=l900b.fi_nr
      and vk.lgnr=l900b.lgnr
    --join [test62].[dbo].view_kunde_lieferant vkl on  --Falls anderer Name
    --  vkl.fi_nr=l900b.fi_nr
    --  and vkl.lgnr=l900b.lgnr
    --  and vkl.satzart=1
  where
    l900b.fi_nr in (1,2,4)
    and l900b.LagerTyp=1
    and 
    (
      convert(date,l900b.datum_schliessung)>=convert(date,getdate())
      or
      l900b.datum_schliessung is null
    )
    
  
  ------------------------------------------------------------------------------------------------------------------------------------

  update [test62_help].[MODTO].[t_Store_Sync] 
    set rec_status=2
  where 
    rec_status=0

  select @rc=count(*) from [test62_help].[MODTO].[t_Store_Sync]

  set nocount off
  return @rc
end


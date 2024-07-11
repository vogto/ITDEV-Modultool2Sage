CREATE procedure [MODTO].[p_Merge_ga980]
as
begin

  set nocount on

  declare @rc int = 0

  declare @tmp as table 
  (
     action_merge nvarchar(20) collate Latin1_General_CS_AS_KS_WS
     ,modultool_typ_id nvarchar(36) collate Latin1_General_CS_AS_KS_WS
  )

  -- delete gelöschte module
  delete ga980
  from ga980
  join [test62_help].[MODTO].[t_ModuleType] mt on 
    mt.id=ga980.modultool_typ_id
  where
    mt.rec_status=2
    and mt.rat='d'


  merge into ga980 as target
  using 
  (
    select
       rec_status
      ,rat
      ,id
      ,userneu
      ,datneu
      ,useraen
      ,dataen
      ,description_de
      ,description_en
    from 
      --[dbstatistik].[butlers62_help].[MODTO].[t_ModuleType]
      [test62_help].[MODTO].[t_ModuleType]
    where
      rec_status=2
  ) as source 
    ( rec_status
      ,rat
      ,id
      ,userneu
      ,datneu
      ,useraen
      ,dataen
      ,description_de
      ,description_en 
    ) on 
    ( target.modultool_typ_id=source.id )
  when  
	  matched     
    and ( target.mod_typ_bez1!=source.description_de ) or ( target.mod_typ_bez2!=source.description_en ) 
    then 
      update set 
        target.mod_typ_bez1=source.description_de
        ,target.mod_typ_bez2=source.description_en
        ,target.useraen=source.useraen
        ,target.dataen=source.dataen
  when  
    not matched     
    then 
      insert ( mod_typ_id, mod_typ_bez1, mod_typ_bez2, dataen, useraen, datneu, userneu, modultool_typ_id )     
      values
      (
        ( select max(isnull(mod_typ_id,1))+1 from ga980 (nolock) )
        ,source.description_de
        ,source.description_en
        ,source.dataen
        ,source.useraen
        ,source.datneu
        ,source.userneu
        ,source.id
      )
    
  OUTPUT    
   $action
   ,inserted.modultool_typ_id
  into @tmp (action_merge,modultool_typ_id);

  --anzahl ob updates inserts 
  set @rc=(select count(action_merge) from @tmp)

  -- Daten aus butlers62_help als erledigt flaggen
  if (@rc>0 )
  begin
    update mt with(updlock,rowlock)
      set mt.rec_status=3       
    from 
      --[dbstatistik].[butlers62_help].[MODTO].[t_ModuleType] mt
      [test62_help].[MODTO].[t_ModuleType] mt
      join @tmp tmp on 
        tmp.modultool_typ_id=mt.id
    where
      mt.rec_status=2
  end


  select     
    count(modultool_typ_id) cnt
  from @tmp tmp

  return

  set nocount on
  return
end

CREATE procedure [MODTO].[p_Merge_ga981]
as
begin

  set nocount on

  declare @rc int = 0

  declare @tmp as table 
  (
     action_merge nvarchar(20) collate Latin1_General_CS_AS_KS_WS
     ,modultool_gr_id nvarchar(36) collate Latin1_General_CS_AS_KS_WS
  )

  -- delete gelöschte module
  delete ga981
  from ga981
  join [test62_help].[MODTO].[t_ModuleGroup] mg on 
    mg.id=ga981.modultool_gr_id
  where
    mg.rec_status=2
    and mg.rat='d'


  merge into ga981 as target
  using 
  (
    select
       rec_status	
      ,rat	
      ,datneu	
      ,userneu	
      ,dataen	
      ,useraen	
      ,id	
      ,description_de	
      ,description_en
    from 
      --[dbstatistik].[butlers62_help].[MODTO].[t_ModuleGroup]
      [test62_help].[MODTO].[t_ModuleGroup]
    where
      rec_status=2
  ) as source 
    (  rec_status
      ,rat
      ,datneu
      ,userneu
      ,dataen
      ,useraen
      ,id
      ,description_de
      ,description_en 
    ) on 
    ( target.modultool_gr_id=source.id )
  when  
	  matched     
    and ( target.mod_gr_bez1!=source.description_de ) or ( target.mod_gr_bez2!=source.description_en ) 
    then 
      update set 
         target.mod_gr_bez1=source.description_de
        ,target.mod_gr_bez2=source.description_en
        ,target.useraen=source.useraen
        ,target.dataen=source.dataen
        ,target.aendnr=isnull(( select max(isnull(ga981.aendnr,1))+1 from ga981 (nolock) where ga981.modultool_gr_id=source.id ),1)
  when  
    not matched     
    then 
      insert ( mod_gruppe, mod_gr_bez1, mod_gr_bez2, dataen, useraen, datneu, userneu, aendnr, modultool_gr_id )     
      values
      (
        ( select max(isnull(mod_gruppe,1))+1 from ga981 (nolock) )
        ,source.description_de
        ,source.description_en
        ,source.dataen
        ,source.useraen
        ,source.datneu
        ,source.userneu
        ,isnull(( select max(isnull(ga981.aendnr,1))+1 from ga981 (nolock) where ga981.modultool_gr_id=source.id ),1)
        ,source.id
      )
    
  OUTPUT    
   $action
   ,inserted.modultool_gr_id
  into @tmp (action_merge,modultool_gr_id);

  --anzahl ob updates inserts 
  set @rc=(select count(action_merge) from @tmp)

  -- Daten aus butlers62_help als erledigt flaggen
  if (@rc>0 )
  begin
    update mg with(updlock,rowlock)
      set mg.rec_status=3       
    from 
      --[dbstatistik].[butlers62_help].[MODTO].[t_ModuleGroup] mg
      [test62_help].[MODTO].[t_ModuleGroup] mg
      join @tmp tmp on 
        tmp.modultool_gr_id=mg.id
    where
      mg.rec_status=2
  end


  select     
    count(modultool_gr_id) cnt
  from @tmp tmp

  return

  set nocount on
  return
end

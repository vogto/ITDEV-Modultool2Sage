--CREATE procedure [MODTO].[p_Merge_ga984]
--as
--begin

--  set nocount on

  declare @rc int = 0

  declare @tmp as table 
  (
     action_merge nvarchar(20) collate Latin1_General_CS_AS_KS_WS
     ,lgnr int 
     ,mod_id int
  )

  -- cursor um gelöschte Module im modultool in sage zu deaktivieren sofern vorhanden
  --declare
  --   @crs_mod_id int
  --  ,@crs_fi_nr int
  --  ,@crs_lgnr int

  --declare crs_mod2lgnr_delete cursor for 
  --  select 
  --     ts.mod_id
  --    ,l900b.fi_nr
  --    ,ts.store_id
  --  from 
  --    [test62_help].[MODTO].[t_Stores] ts (nolock)
  --    join l900b (nolock) on 
  --      l900b.lgnr=ts.store_id
  --  where
  --    ts.rec_status=2
  --    and ts.rat='d'

  --open crs_mod2lgnr_delete
  --fetch next from crs_mod2lgnr_delete into @mod_id,@lgnr    

  --while ( @@FETCH_STATUS=0 )
  --begin
  --  update g with(updlock,rowlock)
  --    set g.zugew=0
  --  from ga984 g 
  --  where
  --    g.fi_nr=@crs_fi_nr
  --    and g.lgnr=@crs_lgnr
  --    and g.mod_id=@crs_mod_id
    
  --  fetch next from crs_mod2lgnr_delete into @mod_id,@lgnr
  --end
  --close crs_mod2lgnr_delete
  --deallocate crs_mod2lgnr_delete

  


  merge into ga984 as target
  using 
  (
    select
       ts.rec_status
      ,ts.rat
      ,ts.datneu
      ,ts.userneu
      ,ts.dataen
      ,ts.useraen
      ,ts.store_id
      ,ts.mod_id
      ,ts.classificationABC
      ,1 as zugew
    from 
      --[dbstatistik].[butlers62_help].[MODTO].[t_Stores]
      [test62_help].[MODTO].[t_Stores] ts
    where
      ts.rec_status=2
      and ts.rat!='d'
  ) as source 
    (  rec_status
      ,rat
      ,datneu
      ,userneu
      ,dataen
      ,useraen
      ,store_id
      ,mod_id
      ,classificationABC
      ,zugew
    ) on 
    ( target.lgnr=source.store_id)
  when  
	  matched 
    and ( target.mod_id=source.mod_id )
    and ( target.zugew=0 )    
    then 
      update set 
         target.zugew=1
  when  
    --sätze in gaa984 auf zugew=0 die nicht in ModulTool Tabelle sind
    not matched by source 
    then 
      update set 
         target.zugew=0
  when  
    not matched by target
    and ( target.mod_id=source.mod_id )
    then 
      insert ( fi_nr,lgnr,mod_id,zugew,dataen,useraen,datneu,userneu )           
      values
      (
         null
        ,source.store_id
        ,source.mod_id
        ,1
        ,source.dataen
        ,source.useraen
        ,source.datneu
        ,source.userneu
      );
  --OUTPUT    
  -- $action
  -- ,inserted.modultool_gr_id
  --into @tmp (action_merge,modultool_gr_id);

  ----anzahl ob updates inserts 
  --set @rc=(select count(action_merge) from @tmp)

  ---- Daten aus butlers62_help als erledigt flaggen
  --if (@rc>0 )
  --begin
  --  update mg with(updlock,rowlock)
  --    set mg.rec_status=3       
  --  from 
  --    --[dbstatistik].[butlers62_help].[MODTO].[t_ModuleGroup] mg
  --    [test62_help].[MODTO].[t_ModuleGroup] mg
  --    join @tmp tmp on 
  --      tmp.modultool_gr_id=mg.id
  --  where
  --    mg.rec_status=2
  --end


  --select     
  --  count(modultool_gr_id) cnt
  --from @tmp tmp

--  return

--  set nocount on
--  return
--end


/*

  merge into ga984 as target
  using 
  (
    select
       ts.rec_status
      ,ts.rat
      ,ts.datneu
      ,ts.userneu
      ,ts.dataen
      ,ts.useraen
      ,ts.store_id
      ,ts.mod_id
      ,ts.classificationABC
      ,1 as zugew
    from 
      --[dbstatistik].[butlers62_help].[MODTO].[t_Stores]
      [test62_help].[MODTO].[t_Stores] ts
    where
      ts.rec_status=3
      and ts.rat!='d'
  ) as source 
    (  rec_status
      ,rat
      ,datneu
      ,userneu
      ,dataen
      ,useraen
      ,store_id
      ,mod_id
      ,classificationABC
      ,zugew
    ) on 
    ( target.lgnr=source.store_id)
  when  
	  matched 
    and ( target.mod_id=source.mod_id )
    and ( target.zugew=0 )    
    then 
      update set 
         target.zugew=1
  when  
    --sätze in gaa984 auf zugew=0 die nicht in ModulTool Tabelle sind
    not matched by source 
    then 
      update set 
         target.zugew=0
  when  
    not matched by target
    and ( target.mod_id=source.mod_id )
    then 
      insert ( fi_nr,lgnr,mod_id,zugew,dataen,useraen,datneu,userneu )           
      values
      (
         null
        ,source.store_id
        ,source.mod_id
        ,1
        ,source.dataen
        ,source.useraen
        ,source.datneu
        ,source.userneu
      );
*/
USE [test62]
GO

CREATE procedure [MODTO].[p_Merge_ga982]
as
begin

  set nocount on

  declare 
    @mod_typ_id                 decimal(38,0)
    ,@mod_gruppe                decimal(38,0)
    ,@setDelete                 int=0
    ,@rc                        int=0
    ,@user                      nvarchar(8) = dbo.fn_Benutzer()
    ,@crs_modid                 int 

  declare @tmp as table 
  (
     action_merge nvarchar(20) collate Latin1_General_CS_AS_KS_WS
     ,modul_id nvarchar(36) collate Latin1_General_CS_AS_KS_WS
  )

  -- delete ob module gelöscht wurde
  select 
    @setDelete=count(*)
  from 
    [test62_help].[MODTO].[t_Module] br62h_module (nolock)    
  where
    br62h_module.rec_status=2
    and br62h_module.rat='d'
  

  merge into ga982 as target
  using 
  (
    select 
       br62h_module.rec_status	
      ,br62h_module.rat	
      ,br62h_module.datneu	
      ,br62h_module.userneu	
      ,br62h_module.dataen	
      ,br62h_module.useraen	
      ,br62h_module.mod_id	
      ,br62h_module.description_de	
      ,br62h_module.description_en	
      ,br62h_module.theme_de	
      ,br62h_module.theme_en	
      ,br62h_module.is_active	
      ,br62h_module.is_seasonal	
      ,br62h_module.available_from	
      ,br62h_module.available_till	
      --,br62h_module.module_type_id
      ,ga980.mod_typ_id as module_type_id
      --,br62h_module.module_group_id	
      ,ga981.mod_gruppe as module_group_id
      ,isnull(b210_create.logname,@user) as created_by
      ,br62h_module.created_at	
      ,isnull(b210_update.logname,@user) as updated_by
      ,br62h_module.updated_at	
      ,br62h_module.is_hidden
    from 
      [test62_help].[MODTO].[t_Module] br62h_module (nolock)
      left join [test62].[dbo].ga980 (nolock) on 
        ga980.modultool_typ_id=br62h_module.module_type_id
      left join [test62].[dbo].ga981 (nolock) on 
        ga981.modultool_gr_id=br62h_module.module_group_id
      left join [test62].[dbo].b210 b210_create (nolock) on 
        b210_create.email=br62h_module.created_by
      left join [test62].[dbo].b210 b210_update (nolock) on 
        b210_update.email=br62h_module.updated_by
    where
      br62h_module.rec_status=2
      and br62h_module.rat!='d'
  ) as source 
    ( rec_status
      ,rat,datneu
      ,userneu
      ,dataen
      ,useraen
      ,mod_id
      ,description_de
      ,description_en
      ,theme_de
      ,theme_en
      ,is_active
      ,is_seasonal
      ,available_from
      ,available_till
      ,module_type_id
      ,module_group_id
      ,created_by
      ,created_at
      ,updated_by
      ,updated_at
      ,is_hidden 
    ) on 
    ( target.mod_id=source.mod_id )
  when  
	  matched 
    and @rc>=0
    and 
    (
      (
           ( isnull(target.mod_bez1,'')         !=  source.description_de ) 
        or ( isnull(target.mod_bez2,'')         !=  source.description_en ) 
        or ( isnull(target.mod_typ_id,0)        !=  source.module_type_id ) 
        or ( isnull(target.mod_status,'0')      !=  source.is_active ) 
        or ( isnull(target.mod_gruppe,0)        !=  source.module_group_id ) 
        or ( target.datvon                      !=  source.available_from ) 
        or ( target.datbis                      !=  source.available_till ) 
        or ( isnull(target.saisonver,'0')       !=  source.is_seasonal ) 
        or ( isnull(target.mod_gvb984_hide,0)   !=  source.is_hidden )
        or ( target.dataen                      !=  source.updated_at ) 
        or ( target.useraen                     !=  source.updated_by ) 
      )
    ) 
    then 
      update set 
         target.mod_bez1        = case when lower(rat)!='d' then source.description_de  end
        ,target.mod_bez2        = case when lower(rat)!='d' then source.description_en  end
        ,target.mod_typ_id      = case when lower(rat)!='d' then source.module_type_id  end
        ,target.mod_status      = case when lower(rat)!='d' then source.is_active       end
        ,target.mod_gruppe      = case when lower(rat)!='d' then source.module_group_id end
        ,target.datvon          = case when lower(rat)!='d' then source.available_from  end
        ,target.datbis          = case when lower(rat)!='d' then source.available_till  end
        ,target.saisonver       = case when lower(rat)!='d' then source.is_seasonal     end
        ,target.mod_gvb984_hide = case when lower(rat)!='d' then source.is_hidden       end
        ,target.dataen          = case when lower(rat)!='d' then source.updated_at      end
        ,target.useraen         = case when lower(rat)!='d' then source.updated_by      end
  when  
    not matched 
    and @rc>=0
    then 
      insert 
      ( 
         mod_id
        ,mod_bez1
        ,mod_bez2
        ,mod_typ_id
        ,mod_status
        ,dataen
        ,useraen
        ,datneu
        ,userneu
        ,mod_gruppe
        ,mod_saison
        ,mod_thema
        ,datvon
        ,datbis
        ,saisonver	
        ,mod_path	
        ,mod_gvb984_hide
      )
      values
      (
         source.mod_id
        ,source.description_de
        ,source.description_en
        ,source.module_type_id
        ,source.is_active
        ,source.dataen
        ,source.useraen
        ,source.datneu
        ,source.userneu
        ,source.module_group_id
        ,'0'
        ,''
        ,source.available_from
        ,source.available_till
        ,source.is_seasonal
        ,''
        ,source.is_hidden      
      ) 
  OUTPUT    
   $action
   ,inserted.mod_id
  into @tmp (action_merge,modul_id);
  

  --anzahl ob updates inserts 
  set @rc=(select count(action_merge) from @tmp)

  -- Daten aus butlers62_help als erledigt flaggen
  if (@rc>0 )
  begin
    update m with(updlock,rowlock)
      set m.rec_status=3       
    from 
      --[dbstatistik].[butlers62_help].[MODTO].[t_ModuleGroup] mg
      [test62_help].[MODTO].[t_Module] m
      join @tmp tmp on 
        tmp.modul_id=m.mod_id
    where
      m.rec_status=2
      and m.rat!='d'
  end

  --daten für ein Modul löschen
  if ( @rc>=0 and @setDelete>=1 )
  begin 
    declare crs_del cursor for 
      select distinct ga982.mod_id
      from ga982 (nolock)
      join [test62_help].[MODTO].[t_Module] br62h_module on 
        br62h_module.mod_id=ga982.mod_id
      where
        br62h_module.rec_status=2
        and br62h_module.rat='d'

    open crs_del
    fetch next from crs_del into @crs_modid

    while @@FETCH_STATUS=0
    begin       
      delete from ga98210 where mod_id=@crs_modid
      delete from but.ga98210_prio where mod_id=@crs_modid
      delete from ga984 where mod_id=@crs_modid
      delete from ga982 where mod_id=@crs_modid
      update [test62_help].[MODTO].[t_Module] set rec_status=3 where mod_id=@crs_modid

      fetch next from crs_del into @crs_modid
    end

    close crs_del
    deallocate crs_del
  end

  --Ausgabe
  select     
    count(modul_id) cnt
  from @tmp tmp

  set nocount on
  return
end
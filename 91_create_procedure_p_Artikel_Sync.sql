USE [test62_help]
GO
/****** Object:  StoredProcedure [MODTO].[p_Artikel_Sync]    Script Date: 11.07.2024 07:19:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [MODTO].[p_Artikel_Sync]
as
begin
  set nocount on

  --Variablen
  declare 
    @user nvarchar(8) = [test62].[dbo].fn_benutzer()
    ,@datum datetime = getdate()
    ,@rc int = 0

  
  ------------------------------------------------------------------------------------------------------------------------------------
  --Hilftabellen
  create table #i 
  (
    identnr nvarchar(22) collate Latin1_General_CS_AS_KS_WS
    ,ben_de nvarchar(40) collate Latin1_General_CS_AS_KS_WS
    ,ben_en nvarchar(40) collate Latin1_General_CS_AS_KS_WS
    ,ean nvarchar(15) collate Latin1_General_CS_AS_KS_WS
    ,steuercode nvarchar(5) collate Latin1_General_CS_AS_KS_WS
    ,da nvarchar(2) collate Latin1_General_CS_AS_KS_WS
    ,ve int 
  )
  create table #vk_best
  (
    identnr nvarchar(22) collate Latin1_General_CS_AS_KS_WS
    ,de_vk decimal(38,15)
    ,at_vk decimal(38,15)
    ,ch_vk decimal(38,15)
    ,bzl int
    ,b289 int
  )
  create table #best_all
  (
    identnr nvarchar(22) collate Latin1_General_CS_AS_KS_WS
    ,b int  
  )
  create table #ek_best
  (
    identnr nvarchar(22) collate Latin1_General_CS_AS_KS_WS
    ,menge_bes int  
    ,offen int
    ,vorr_Verfuegbar date
    ,rn int
  )

  ------------------------------------------------------------------------------------------------------------------------------------
  -- Artikel holen
  insert into #i
  select 
    g000.identnr as 'identnr'
    ,g000.ben as 'ben_de'
    ,g003.zutext as 'ben_en'
    ,g040.ean as 'ean'
    ,g030.steuercode as 'steuercode'
    ,g020.da as 'da'
    ,g040.ve as 've'
  from 
    [test62].[dbo].g000 (nolock)
    join [test62].[dbo].g020 (nolock) on 
      g020.fi_nr=g000.fi_nr
      and g020.identnr=g000.identnr
      and g020.lgnr=0
    join [test62].[dbo].g003 (nolock) on 
      g003.fi_nr=g000.fi_nr
      and g003.identnr=g000.identnr
      and g003.lang_ext='en_gb'
    join [test62].[dbo].g040 (nolock) on 
      g040.fi_nr=g000.fi_nr
      and g040.identnr=g000.identnr
    join [test62].[dbo].g030 (nolock) on 
      g030.fi_nr=g000.fi_nr
      and g030.identnr=g000.identnr
  where
    g000.fi_nr=1
    and 
    (
      g000.identnr between '10000000' and '69000000'
      or
      left(g000.identnr,2) in ('99'/*,'71'*/)
    )  
  create nonclustered index i1 on #i (identnr)


  ------------------------------------------------------------------------------------------------------------------------------------
  --vkpreise holen  
  insert into #vk_best
  select 
    g.identnr
    ,vkEUR.vkpreis_rabattiert
    ,vkAT.vkpreis_rabattiert
    ,vkCHF.vkpreis_rabattiert
    ,bZL.DispositiverBestand
    ,b289.DispositiverBestand
  from 
    #i g
    outer apply [test62].[but].vkpreis_aktuell(1,0,'K0',g.identnr,null) vkEUR
    outer apply [test62].[but].vkpreis_aktuell(4,0,'K1',g.identnr,null) vkAT
    outer apply [test62].[but].vkpreis_aktuell(1,1,'K0',g.identnr,null) vkCHF
    outer apply [test62].[but].f_Bestand(1,0,g.identnr) bZL
    outer apply [test62].[but].f_Bestand(1,100289,g.identnr) b289
  create nonclustered index i2 on #vk_best (identnr)


  ------------------------------------------------------------------------------------------------------------------------------------
  --bestand komplett holen
  insert into #best_all
  select 
    l020.identnr
    ,sum(lamenge) lamenge
  from 
    [test62].[dbo].l020 (nolock)
    join [test62].[dbo].l900b (nolock) on 
      l900b.fi_nr=l020.fi_nr 
      and l900b.lgnr=l020.lgnr
  where 
    l900b.fi_nr in (1,2,4) 
    and l900b.LagerTyp=1
    and isnull(l020.lamenge,0)>0
  group by 
    l020.identnr
  create nonclustered index i3 on #best_all (identnr)


  ------------------------------------------------------------------------------------------------------------------------------------
  --offene ek best holen
  insert into #ek_best
  select 
    identnr
    ,menge_bes
    ,offen
    ,vorr_Verfuegbar
    ,ROW_NUMBER() Over (Partition by identnr order by vorr_Verfuegbar) rn
  from 
    [test62].[dbo].view_offene_einkaufsbest_detail voek
  order by 
    voek.vorr_Verfuegbar
  create nonclustered index i4 on #ek_best (identnr)


  ------------------------------------------------------------------------------------------------------------------------------------
  --Daten löschen
  if ( (select count(*) from [test62_help].[MODTO].[t_Artikel_Sync]) > 0 )
  begin
    truncate table [test62_help].[MODTO].[t_Artikel_Sync]
  end


  ------------------------------------------------------------------------------------------------------------------------------------
  --Daten einfügen
  insert into [test62_help].[MODTO].[t_Artikel_Sync]
  select 
    g.identnr as 'id'
    ,g.ben_de as 'ben_de'
    ,g.ben_en as 'ben_en'
    ,g.ean as 'ean'
    ,convert(nvarchar,case 
      when vsa.steuer=19 then 'Voll'
      when vsa.steuer=7 then 'Red.'
      when vsa.steuer=0 then 'Keine'
     end) as 'tax'
    ,convert(decimal(38,2),round(isnull(vk_best.de_vk,0),2)) as 'vk_de'
    ,convert(decimal(38,2),round(isnull(isnull(vk_best.at_vk,vk_best.de_vk),0),2)) as 'vk_at'
    ,convert(decimal(38,2),round(isnull(vk_best.ch_vk,0),2)) as 'vk_ch'
    ,convert(int,g.ve) as 've'
    ,convert(int,isnull(vk_best.bzl,0)) as 'inventory_warehouse_total'
    ,convert(int,isnull(best_all.b,0)) as 'inventory_stores_total'
    ,convert(int,isnull(vk_best.b289,0)) as 'inventory_stores_reference'
    ,g.da as 'disposition_type'
    ,ek_best.menge_bes as 'next_delivery_quantity'
    ,ek_best.vorr_Verfuegbar as 'next_delivery_date'
    ,@user
    ,@datum
    ,@user
    ,@datum
    ,0
  from 
    #i g (nolock)
    join [test62].[dbo].view_steuer_aktuell vsa on 
      vsa.fi_nr=1
      and vsa.land=0 
      and vsa.inlausl=0
      and vsa.steuercode=g.steuercode
    left join #vk_best vk_best on 
      vk_best.identnr=g.identnr
    left join #ek_best ek_best on 
      ek_best.identnr=g.identnr
      and ek_best.rn=1
    left join #best_all best_all on 
      best_all.identnr=g.identnr
  where
    ( 
      (isnull(best_all.b,0) + isnull(vk_best.bzl,0) + isnull(ek_best.offen,0)) > 0 --ZL Bestand+OffeneBest+FilBestand > 0
      or
      g.identnr like '99%'
    )
    
    
  
  ------------------------------------------------------------------------------------------------------------------------------------
  --hilfstabellen löschen
  drop table #i
  drop table #vk_best
  drop table #best_all
  drop table #ek_best

  update [test62_help].[MODTO].[t_Artikel_Sync] 
    set rec_status=2
  where 
    rec_status=0

  select @rc=count(*) from [test62_help].[MODTO].[t_Artikel_Sync]

  set nocount off
  return @rc
end


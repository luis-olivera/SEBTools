pro L8_KsKr_R3
  ;;LST de Rivalland para R3
  close, /all
  
  ;out_ps = [100.,100.]

  K_max = 1.2; --> Kcb y Ke. kmax de SSEBop para llevar EF al max Kc en la zona
  MIN_MAX = [0.14, 0.93];[0.15, 0.93]

  dir='D:\CESBIO\Maroc\Spatial\Landsat\'
  cd,dir
  pat='LST-R3\2016\';     'C:\CESBIO\IsardSAT\L8\';'C:\Data\FONDEF\L8\';'C:\Data\LANDSAT8\';+string(strcompress(year,/remove_all))+'\'
  met = ['Stefan' ,'Regresion' , 'Regresion_dev','Regresion_dev0.5']
  
  year=2016
  ;  DEM=read_tiff('C:\CESBIO\IsardSAT\ASTER GED\ASTGDEM_AE.tif',geotiff=g_tags)
  ;  slope=read_tiff('C:\CESBIO\IsardSAT\ASTER GED\ASTGDEM_AE_topo_.tif')
  ;  slope=slope[0,*,*]

  file_LST = file_search(pat + '*' + '\*tst.tif');  file_search('LST\LST_' +string(strcompress(year,/remove_all))+ '*_SC_eAST.tif')
  file_NDVI = file_search(pat + '*' + '\*ndvi.tif'); file_search('NDVI\NDVI_' +string(strcompress(year,/remove_all))+ '*.tif')
  file_QA = file_search(pat + 'L7mask_cloud\*_cloud_3.tif');(pat + 'LE7*' + '\*Mask.tif');
  file_L8QA = file_search(pat + '*' + '\*BQA.tif');  file_search('BQA\BQA_' +string(strcompress(year,/remove_all))+ '*.tif')
  file_L7mask = file_search(pat + 'L7mask_6\*Mask.tif');(pat + 'LE7*' + '\*Mask.tif');
  ;file_QA = [file_L8QA, file_L7mask]
  
  DOY=make_array(n_elements(file_LST),/integer)
;  L8_sort=make_array(n_elements(file_L8QA),/integer)
;  L7_sort=make_array(n_elements(file_L7mask),/integer)
  
  for i=0,n_elements(file_LST)-1 do begin
    DOY[i]=fix(strmid(file_LST[i],18,3, /REVERSE_OFFSET))
    ;    if i lt n_elements(file_L8QA) then L8_sort[i]=fix(strmid(file_L8QA[i],18,3, /REVERSE_OFFSET))
    ;    if i lt n_elements(file_L7mask) then L7_sort[i]=fix(strmid(file_L7mask[i],24,3, /REVERSE_OFFSET))
  end
  sort=sort(DOY)
  
  IMA = read_tiff(file_LST[0],geotiff=g_tags)
  ss=size(IMA)
  ss=ss[1:2]
  undefine, IMA
  cut = 399

for pp=2,2 do begin  ;fv=[()/()]^pp
  for mm=0, (n_elements(met)-1) do begin
    
    outdir = dir + 'Results\Fvg'+string(strcompress(pp,/remove_all)) + '\' + met[mm] + '\'
    
    openw, 1, outdir + 'Tends_LST-Fvg_' + string(strcompress(year,/remove_all)) + '.txt'
    printf, 1,'Doy','Ts_min','Ts_max','Tv_min','Tv_max', format="(a12, 4a7)"
    
    for i=0,n_elements(file_LST)-1 do begin
    
      ;date = (strmid(file_NDVI[sort[i]],13,10, /REVERSE_OFFSET))
      date = long(year*1000. + DOY[sort[i]])
      
      QA = float(read_tiff(file_QA[sort[i]]))
      QA = QA[0:cut,*]
      sensor = strsplit(file_LST[sort[i]],'\',/EXTRACT)
      sensor = strmid(sensor[-1], 2, 1)
;      if sensor eq 8 then $
;        pix = where(QA gt 23000 or QA eq 0) $; 322 AND QA ne 386); AND QA ne 324 AND QA ne 388)
;      else $
        pix = where(QA ne 0)
        
      QA[pix] = !values.F_NAN
      ;QA = congrid(QA,ss[0], ss[1],/center,cubic=-0.5);,/center,/interp
      ;QA[where(DEM gt 450 OR slope gt 10)] = !values.F_NAN
      
      LST = read_tiff(file_LST[sort[i]])
      LST=(LST[0:cut,*])/100.
      LST[where(finite(QA, /NAN) or LST eq 0)] = !values.F_NAN
      NDVI = read_tiff(file_NDVI[sort[i]])
      NDVI = (NDVI[0:cut,*])/1000.
      ;NDVI = CONGRID(NDVI, ss[0], ss[1],/center,cubic=-0.5);/center,/interp);
      NDVI[where(finite(QA, /NAN) or NDVI lt 0)] = !values.F_NAN
      NDVI[where(NDVI le MIN_MAX[0])] = MIN_MAX[0]
      NDVI[where(NDVI ge MIN_MAX[1])] = MIN_MAX[1]
      Fvg = ((NDVI - MIN_MAX[0])/(MIN_MAX[1] - MIN_MAX[0]))^pp
      ;Fvg_ENDMBmax = mean(Fvg,/nan) ;-->default
      
      outplot = outdir + 'Poligone_6\Ext\'
      if met[mm] eq 'Stefan' then $
        LSTend = Tends_Fvg_IMA(LST, Fvg);Fvg_ENDMBmax=0.6);, Tair=280.0
      if met[mm] eq 'Regresion' then $
        LSTend = Tends_Fvg_IMA_regresion(LST, Fvg, /plot, date=date, outplot=outplot)
      if met[mm] eq 'Regresion_dev' then $
        LSTend = Tends_Fvg_IMA_regresion(LST, Fvg, /dev, /plot, date=date, outplot=outplot);--> +-stddev, guardar plot con date en el nom
      if met[mm] eq 'Regresion_dev0.5' then $
        LSTend = Tends_Fvg_IMA_regresion(LST, Fvg, /dev, /plot, f_dev=0.5, date=date, outplot=outplot);--> +-0.5stddev
        
      Ts_min = LSTend[0]
      Ts_max = LSTend[1]
      Tv_min = LSTend[2]
      Tv_max = LSTend[3]
      
      Ts_Tvg_Z = Partition_TsTv_z1z3TDVI_IMA(LST, Fvg, Ts_min, Ts_max, Tv_min, Tv_max)
      Ts = Ts_Tvg_Z[*,*,0]
      Tv = Ts_Tvg_Z[*,*,1]
      
      Ks = (Tv_max - Tv)/(Tv_max - Tv_min)
      Kr = (Ts_max - Ts)/(Ts_max - Ts_min)
      if Tv_max eq Tv_min then Ks = Kr
        Kcb_fv = K_max*fvg
        Ke_fv = K_max*(1. - fvg)*Kr
      
      printf, 1, date, LSTend, format="(a12, 4f7.2)"
      
      ;;GRAFICAR POLIGONE
      P= plot(fvg(where(finite(fvg))), LST(where(finite(fvg))), '*',xrange=[0,1], xtitle="Fractional green vegetation cover [-]", ytitle="Surface Temperature [K]");yrange=[290,330],
      p2= plot([0, 1], [Ts_max, Tv_max],'r2',/overplot); color=2
      p3= plot([0, 1], [Ts_min, Tv_min],'b2',/overplot); color=4
      p.Save, outdir + 'Poligone_6\LST_Fvg_' + (strcompress(date,/remove_all)) + '_.png', BORDER=10, RESOLUTION=100
      p.close
      
      write_tiff, outdir + 'TvTs\Tv_' + string(strcompress(date,/remove_all)) + '.tif', Tv, /float, geotiff=g_tags
      write_tiff, outdir + 'TvTs\Ts_' + string(strcompress(date,/remove_all)) + '.tif', Ts, /float, geotiff=g_tags
      write_tiff, outdir + 'KsKr\Ks_' + string(strcompress(date,/remove_all)) + '.tif', Ks, /float, geotiff=g_tags
      write_tiff, outdir + 'KsKr\Kr_' + string(strcompress(date,/remove_all)) + '.tif', Kr, /float, geotiff=g_tags
      write_tiff, outdir + 'TvTs\Zona_LST-Fv_' + string(strcompress(date,/remove_all)) + '.tif', Ts_Tvg_Z[*,*,2], /short, geotiff=g_tags
      write_tiff, dir + 'Results\Fvg'+string(strcompress(pp,/remove_all))+'\Fvg\Fvg_' + string(strcompress(date,/remove_all)) + '.tif', Fvg, /float, geotiff=g_tags      
        write_tiff, outdir + 'KcbKe_fv\Kcb_' + string(strcompress(date,/remove_all)) + '.tif', Kcb_fv, /float, geotiff=g_tags
        write_tiff, outdir + 'KcbKe_fv\Ke_' + string(strcompress(date,/remove_all)) + '.tif', Ke_fv, /float, geotiff=g_tags

      
    endfor
    close,1
    
  endfor ; mm --> metodos de Tends

endfor ; pp -->fv=[]^pp
   
end
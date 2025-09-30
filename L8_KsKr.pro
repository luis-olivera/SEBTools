pro L8_KsKr
  ;;Split Window y Single Channel (Tb10)
  ;;
  ;;Obtiene LST de Landsat8 con Split Window--> T_BRILLO (Tb10-Tb11) - NDVI - W(MOD05)
  ;;NDVI y T_BRILLO a partir de LANDSAT8_rad_subset.pro
  close, /all
  
  out_ps = [100.,100.]
  MIN_MAX = [0.15, 0.93]
  
  met = ['Stefan' ,'Regresion' , 'Regresion_dev','Regresion_dev0.5']

  pat='D:\CESBIO\IsardSAT\L8\';'C:\Data\FONDEF\L8\';'C:\Data\LANDSAT8\';+string(strcompress(year,/remove_all))+'\'
  cd,pat
  
  dims = 150
  xy_ini = [230,20]
  xy_fin = [230,20] + dims - 1
  
  DEM=read_tiff('D:\CESBIO\IsardSAT\ASTER GED\ASTGDEM_AE.tif',geotiff=g_tags)
  slope=read_tiff('D:\CESBIO\IsardSAT\ASTER GED\ASTGDEM_AE_topo_.tif')
  slope=slope[0,*,*]
    DEM=DEM[xy_ini[0]: xy_fin[0] , xy_ini[1]: xy_fin[1]]
    slope=slope[0, xy_ini[0]: xy_fin[0] , xy_ini[1]: xy_fin[1]]

    g_tags.MODELTIEPOINTTAG[3] = g_tags.MODELTIEPOINTTAG[3] + 100*xy_ini[0]
    g_tags.MODELTIEPOINTTAG[4] = g_tags.MODELTIEPOINTTAG[4] - 100*xy_ini[1]


for mm=0, (n_elements(met)-1) do begin
  outdir = 'Results_15x15km\' + met[mm] + '\'  
  
  for year=2015,2016 do begin
    file_LST = file_search('LST\LST_' +string(strcompress(year,/remove_all))+ '*_SC_eAST.tif')
    file_NDVI = file_search('NDVI\NDVI_' +string(strcompress(year,/remove_all))+ '*.tif')
    file_QA = file_search('BQA\BQA_' +string(strcompress(year,/remove_all))+ '*.tif')
    
    IMA = read_tiff(file_LST[0],geotiff=g_tags_)
      ;IMA = IMA[xy_ini[0]: xy_fin[0] , xy_ini[1]: xy_fin[1]]
    ss=size(IMA)
    ss=ss[1:2]
    
    openw, 1, outdir + '\Tends_LST-Fvg_' + string(strcompress(year,/remove_all)) + '.txt'
    printf, 1,'Date','Ts_min','Ts_max','Tv_min','Tv_max', format="(a12, 4a7)"
    
    for i=0,n_elements(file_LST)-1 do begin
      
      date = (strmid(file_NDVI[i],13,10, /REVERSE_OFFSET))
      
      QA = float(read_tiff(file_QA[i]))
      pix = where(QA ne 322 AND QA ne 386); AND QA ne 324 AND QA ne 388)
      QA[pix] = !values.F_NAN
      QA = congrid(QA,ss[0], ss[1],/center,cubic=-0.5);,/center,/interp
        QA = QA[xy_ini[0]: xy_fin[0] , xy_ini[1]: xy_fin[1]]
      QA[where(DEM gt 450 OR slope gt 10)] = !values.F_NAN
      
      LST = read_tiff(file_LST[i])
        LST = LST[xy_ini[0]: xy_fin[0] , xy_ini[1]: xy_fin[1]]
      LST[where(finite(QA, /NAN))] = !values.F_NAN
      NDVI = read_tiff(file_NDVI[i])
      NDVI = CONGRID(NDVI, ss[0], ss[1],/center,cubic=-0.5);/center,/interp);
        NDVI = NDVI[xy_ini[0]: xy_fin[0] , xy_ini[1]: xy_fin[1]]
      NDVI[where(finite(QA, /NAN))] = !values.F_NAN
      NDVI[where(NDVI le MIN_MAX[0])] = MIN_MAX[0]
      NDVI[where(NDVI ge MIN_MAX[1])] = MIN_MAX[1]
      Fvg = ((NDVI - MIN_MAX[0])/(MIN_MAX[1] - MIN_MAX[0]));^2
      
      ;LSTend = Tends_Fvg_IMA(LST, Fvg,Fvg_ENDMBmax=0.6);, Tair=280.0
      outplot = outdir + 'Poligone\Ext\'
      if met[mm] eq 'Stefan' then $
        LSTend = Tends_Fvg_IMA(LST, Fvg,Fvg_ENDMBmax=0.6,Fvg_ENDMBmin=0.2);, Tair=280.0
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
      
      printf, 1, date, LSTend, format="(a12, 4f7.2)"
      
      ;;GRAFICAR POLIGONE
      P= plot(fvg(where(finite(fvg))), LST(where(finite(fvg))), '*',xrange=[0,1], xtitle="Fractional green vegetation cover [-]", ytitle="Surface Temperature [K]")
      ;yrange=[290,330]
      p2= plot([0, 1], [Ts_max, Tv_max],'r2',/overplot); color=2
      p3= plot([0, 1], [Ts_min, Tv_min],'b2',/overplot); color=4
      p.Save, outdir + '\Poligone\LST_Fvg_' + (strcompress(date,/remove_all)) + '_DEM450_slop10.png', BORDER=10, RESOLUTION=100
      p.close
      
      write_tiff, outdir + '\TvTs\Tv_' + string(strcompress(date,/remove_all)) + '.tif', Tv, /float, geotiff=g_tags
      write_tiff, outdir + '\TvTs\Ts_' + string(strcompress(date,/remove_all)) + '.tif', Ts, /float, geotiff=g_tags
      write_tiff, outdir + '\KsKr\Ks_' + string(strcompress(date,/remove_all)) + '.tif', Ks, /float, geotiff=g_tags
      write_tiff, outdir + '\KsKr\Kr_' + string(strcompress(date,/remove_all)) + '.tif', Kr, /float, geotiff=g_tags
      write_tiff, outdir + '\TvTs\Zona_LST-Fv_' + string(strcompress(date,/remove_all)) + '.tif', Ts_Tvg_Z[*,*,2], /short, geotiff=g_tags
      write_tiff, 'Results_15x15km\Fvg\Fvg_' + string(strcompress(date,/remove_all)) + '.tif', Fvg, /float, geotiff=g_tags
      
    endfor
    close,1
  endfor
endfor; metodo de LSTend

end
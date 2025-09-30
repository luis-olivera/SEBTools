pro L7L8_KsKr_corALB_area
  ;;LST de Single-Channel by using soil emissivity from ASTER GED
  ;;Outputs: Fvg - Tv/Ts - Ks/Kr - Kcb/Ke
  ;;Tv/Ts : f(Tends,LST,fvg)
  ;;Ks/Kr : f(Tends,Tv/Ts)
  ;;Kcb = fvg*K_max
  ;;Ke = K_max(1 - fvg)Kr
  close, /all

  K_max = 1.2; --> Kcb y Ke. kmax de SSEBop para llevar EF al max Kc en la zona
  MIN_MAX = [0.14, 0.93];[0.15, 0.93]
  Min_data = 0.4; % (en No relativo) de datos disponibles para correr el modelo
  alpha_1 = [0.1, 0.2]  ; [alb_s, alb_v]_min
  alpha_2 = [0.3, 0.3]  ; [alb_s, alb_v]_max
  
  ;Landsat = ['L7','L8']
  BQ_clear_L8 = [322, 386]  ;834: Clear terrain, low confidence cloud, high confidence cirrus
  ;898: Clear terrain, medium confidence cloud, high confidence cirrus                 1346: terrain occluded
  BQ_water_L8 = BQ_clear_L8 + 2
  BQ_clear_L7 = [66, 130]
  BQ_water_L7 = BQ_clear_L7 + 2

  Hra_obj = '1100'
  area = 'R3';'Chichaoua';'Bour';'Sidi_rahal';'Labferrer';'AB34';'IsardSAT';
  met = ['EBsolveg','EBsolveg\TvminTa','Regresion','Regresion_dev','Regresion_dev0.5','Stefan']

  if area eq 'R3' OR area eq 'Bour' OR area eq 'Chichaoua' OR area eq 'Sidi_rahal' $
    then region='Maroc' $
  else region='Catalunya'

  pat='D:\CESBIO\Region\' + region + '\Area\' + area +'\'
  cd,pat

  if area eq 'R3' then manip='Meteo_2016_ble';'R3_Gravitaire_2015-2016'
  ;pat_meteo_day = pat + 'Insitu\'+ manip + '\climat_R3_day_2016.csv'

  FILE_MKDIR, 'Results\';+ Landsat +'\
  FILE_MKDIR, 'Results\Fvg1\Fvg\';'L7\Fvg\Fvg1', 'L7\Fvg\Fvg2', 'L8\Fvg\Fvg1', 'L8\Fvg\Fvg2'

  pat_meteo = pat + 'Insitu\'+ manip + '\Meteo\meteo_'+Hra_obj+'.txt'
  meteo = read_ascii(pat_meteo);DOY Heure RG Tair HR Vv Ts-verticale-(2m)
  Ta = meteo.FIELD1[2,*] ;[K]

  for pp=1,1 do begin  ;fv=[()/()]^pp
    for mm=2, 2+0*(n_elements(met)-1) do begin

;      ;path_Tends = pat + 'Insitu\'+ manip + '\Results\EBsolveg\TvminTa\TvTs_fc\TVDI_fc\LSTcor_alb0.100_emis0.957_z0m0.0010_albvg0.20_cg0\TsTv_Tends_EB_mo_1100.txt'
;      path_Tends_1 = pat + 'Insitu\'+ manip + '\Results\' + met[mm] +'\TvTs_fc\TVDI_fc\LSTcor_alb0.100_emis0.957_z0m0.0010_albvg0.20\TsTv_Tends_EB_mo_1100.txt'
;      path_Tends_2 = pat + 'Insitu\'+ manip + '\Results\' + met[mm] +'\TvTs_fc\TVDI_fc\LSTcor_alb0.300_emis0.957_z0m0.0010_albvg0.30\TsTv_Tends_EB_mo_1100.txt'
      path_Tends_1 = pat + 'Insitu\'+ manip + '\Results\' + met[0] +'\Tends_rss\alb0.100_emis0.957_z0m0.0010_albvg0.20\Tends_EB_mo_'+Hra_obj+'.txt'
      path_Tends_2 = pat + 'Insitu\'+ manip + '\Results\' + met[0] +'\Tends_rss\alb0.300_emis0.957_z0m0.0010_albvg0.30\Tends_EB_mo_'+Hra_obj+'.txt'
      Tends_1 = read_ascii(path_Tends_1, count= na)
      Tends_2 = read_ascii(path_Tends_2, count= na)
      
      
      outdir = 'Results\Fvg'+ string(strcompress(pp,/remove_all)) + '\TVDI_fc\' + met[mm] + '\Cor_alb\';v2\
      FILE_MKDIR, outdir+'Tends'
      FILE_MKDIR, outdir+'Tv',outdir+'Ts',outdir+'Ks',outdir+'Kr',outdir+'Kcb_fv',outdir+'Ke_fv',outdir+'Ke_fc';,outdir+'Zona_pol'

      for year=2016,2016 do begin
        YR = string(strcompress(year,/remove_all))
        file_LST = file_search('L*' + '\LST\LST_' + YR + '*.tif'); + Landsat
        file_NDVI = file_search('L*' + '\NDVI\NDVI_' + YR + '*.tif'); + Landsat
        file_QA = file_search('L*' + '\BQA\BQA_' + YR + '*.tif')
        file_alb = file_search('L*' + '\Albedo\ALB_weiss_' + YR + '*.tif')
        file_fvg = file_search('Results\Fvg' + string(strcompress(pp,/remove_all)) + '\Fvg\Fvg_' + '*.tif')
        file_fc = file_search('Results\Fvg' + string(strcompress(pp,/remove_all)) + '\Fc\Fc_' + '*.tif')

        YYYYMMDD=make_array(n_elements(file_LST),/string)

        for i=0,n_elements(file_NDVI)-1 do begin
          aux = strsplit(file_NDVI[i],'._',/EXTRACT); (strmid(file_NDVI[sort[i]],13,10, /REVERSE_OFFSET))
          YYYYMMDD[i] = aux[-2]
        endfor
        YYYYDOY = date2YYYYDOY(YYYYMMDD, delimiter='-')

        sort=sort(YYYYDOY)

        LST = read_tiff(file_LST[0])
        ss=n_elements(LST)

        openw, 1, outdir + 'Tends_LST-Fvg_' + YR + '.txt'
        printf, 1,'Doy','Landsat', 'Ts_min','Ts_max','Tv_min','Tv_max', format="(2a8, 4a7)"

        for i=0,n_elements(file_fc)-1 do begin
          date = string(strcompress(YYYYDOY[sort[i]],/remove_all))
          doy = fix(date - year*1000.)

          if doy gt Tends_1.FIELD1[0,-1] then break

          QA = float(read_tiff(file_QA[sort[i]]))
          ;QA = QA[0:cut,*]

          sensor = strsplit(file_LST[sort[i]],'\',/EXTRACT)
          sensor = sensor[0]; strmid(sensor[-1], 2, 1)
          if sensor eq 'L8' then BQ_clear = BQ_clear_L8 else BQ_clear = BQ_clear_L7
          pix=QA*0
          for qq=0,n_elements(BQ_clear)-1 do begin
            pix[where(QA eq BQ_clear[qq] OR QA eq BQ_clear[qq]+2)] = 1
          endfor
          pix = where(pix ne 1)
          ;          if sensor eq 'L8' then $
          ;            pix = where(QA gt 23000 or QA eq 0) $; 322 AND QA ne 386); AND QA ne 324 AND QA ne 388)
          ;          else $
          ;          pix = where(QA ne 0)

          ;QA = congrid(QA,ss[0], ss[1],/center,cubic=-0.5);,/center,/interp
          ;QA[where(DEM gt 450 OR slope gt 10)] = !values.F_NAN

          QA[pix] = !values.F_NAN
;          NDVI = read_tiff(file_NDVI[sort[i]])
;          ;NDVI = (NDVI[0:cut,*])/1000.
;          ;NDVI = CONGRID(NDVI, ss[0], ss[1],/center,cubic=-0.5);/center,/interp);
;          NDVI[where(finite(QA, /NAN) or NDVI lt 0)] = !values.F_NAN
;          NDVI[where(NDVI le MIN_MAX[0])] = MIN_MAX[0]
;          NDVI[where(NDVI ge MIN_MAX[1])] = MIN_MAX[1]
;          Fvg = ((NDVI - MIN_MAX[0])/(MIN_MAX[1] - MIN_MAX[0]))^pp
;          ;Fvg_ENDMBmax = mean(Fvg,/nan) ;-->default
          
          Fvg = read_tiff(file_fc[i])

          if n_elements(pix) gt Min_data*ss then begin
            Tv[*,*] = !values.F_NAN
            Ts=Tv
            Ks=Tv
            Kr=Tv
            ;Zona[*,*]=0
            LSTend[*]=!values.F_NAN
            LSTend_1[*]=!values.F_NAN
            LSTend_2[*]=!values.F_NAN
            ;CONTINUE
          endif else begin

            LST = read_tiff(file_LST[sort[i]], geotiff=g_tags)
            ;LST=(LST[0:cut,*])/100.
            LST[where(finite(QA, /NAN) or LST eq 0)] = !values.F_NAN
            
            Alb = read_tiff(file_alb[sort[i]])
            Alb[where(finite(QA, /NAN) or LST eq 0)] = !values.F_NAN

            outplot = outdir + 'Poligone\Ext\'
            FILE_MKDIR, outplot
            if met[mm] eq 'Stefan' then $
              LSTend = Tends_Fvg_IMA(LST, Fvg);Fvg_ENDMBmax=0.6);, Tair=280.0
            if met[mm] eq 'Regresion' then $
              LSTend = Tends_Fvg_IMA_regresion(LST, Fvg, date=date, outplot=outplot);, /plot
            if met[mm] eq 'Regresion_dev' then $
              LSTend = Tends_Fvg_IMA_regresion(LST, Fvg, /dev, date=date, outplot=outplot);, /plot--> +-stddev, guardar plot con date en el nom
            if met[mm] eq 'Regresion_dev0.5' then $
              LSTend = Tends_Fvg_IMA_regresion(LST, Fvg, /dev, f_dev=0.5, date=date, outplot=outplot);, /plot--> +-0.5stddev
            if met[mm] eq 'EBsolveg\TvminTa' OR met[mm] eq 'EBsolveg' then begin
              
              Tend_reg = Tends_Fvg_IMA_regresion(LST, Fvg, date=date, outplot=outplot);, /plot
            endif
            
            
            ;;LSTend de EB
            LSTend_1 = Tends_1.FIELD1[1:5,doy-1]
            LSTend_2 = Tends_2.FIELD1[1:5,doy-1]
            if finite(LSTend_1[2]) eq 0 then LSTend_1[2]=Ta[doy-1]
            if finite(LSTend_2[2]) eq 0 then LSTend_2[2]=Ta[doy-1]
            
            LSTend_EB = mean([[LSTend_1],[LSTend_2]],dimension=2) ; Ts -->alb_s=0.2 : mean(alpha_1)
            LSTend_EB[2:3] = LSTend_1[2:3]                        ; Tv -->alb_vg=0.2  :: alpha_2[0]
            
            Tendcor = Tendcor_alb(LST, alb, LSTend_1, LSTend_2, alpha_1, alpha_2)
            Ts_min = Tendcor[*,*,0]
            Ts_max = Tendcor[*,*,1]
            Tv_min = Tendcor[*,*,2]
            Tv_max = Tendcor[*,*,3]

            ;            Ts_min = min([LSTend[0], Tend_reg[0]], /nan)
            ;            Ts_max = max([LSTend[1], Tend_reg[1]], /nan)
            ;            Tv_min = min([LSTend[2], Tend_reg[2]], /nan)
            ;            Tv_max = max([LSTend[3], Tend_reg[3]], /nan)

            
            Ts_Tvg_Z = Partition_TsTv_TVDI_fc_IMA(LST, Fvg, Ts_min, Ts_max, Tv_min, Tv_max)
            Ts = Ts_Tvg_Z[*,*,0]
            Tv = Ts_Tvg_Z[*,*,1]
            ;Zona = Ts_Tvg_Z[*,*,2]

            Ks = (Tv_max - Tv)/(Tv_max - Tv_min)
            Kr = (Ts_max - Ts)/(Ts_max - Ts_min)
            ;if Tv_max eq Tv_min then Ks = Kr
            Ks(where(Tv_max eq Tv_min)) = Kr(where(Tv_max eq Tv_min))
            Fvgreen = read_tiff(file_Fvg[i])
            Kcb_fv = K_max*Fvgreen
            Ke_fv = K_max*(1. - Fvgreen)*Kr
            undefine, Fvgreen 
            Ke_fc = K_max*(1. - fvg)*Kr
            
            
            LSTend = [mean(Ts_min,/nan), mean(Ts_max,/nan), mean(Tv_min,/nan),  mean(Tv_max,/nan)]
            
            ;;GRAFICAR POLIGONE
;            P= plot(fvg(where(finite(fvg))), LST(where(finite(fvg))), '*', xrange=[0,1], $
;              xtitle="Fractional green vegetation cover [-]", ytitle="Surface Temperature [K]");yrange=[290,330],
;            p2= plot(fvg(where(finite(fvg))), Ts_min(where(finite(fvg))),'bo',/overplot, NAME='Ts_min')
;            p3= plot(fvg(where(finite(fvg))), Ts_max(where(finite(fvg))),'ro',/overplot, NAME='Ts_ma')
;            p4= plot(fvg(where(finite(fvg))), Tv_min(where(finite(fvg))),'go',/overplot, NAME='Tv_min')
;            p5= plot(fvg(where(finite(fvg))), Tv_max(where(finite(fvg))),'mo',/overplot, NAME='Tv_max')
;            
;;            p2= plot([0, 1], [LSTend[1], LSTend[3]],'r2',/overplot, NAME='Energy Balance'); color=2
;;            p3= plot([0, 1], [LSTend[0], LSTend[2]],'b2',/overplot); color=4
;;            p4= plot([0, 1], [Tend_reg[1], Tend_reg[3]],'r2--',/overplot, NAME='Imaged-based'); color=2
;;            p5= plot([0, 1], [Tend_reg[0], Tend_reg[2]],'b2--',/overplot); color=4
;            leg = LEGEND(TARGET=[p2,p4], POSITION=[0.9,0.9])
;            p.Save, outdir + 'Poligone\LST_Fvg_' + date + '.png', BORDER=10, RESOLUTION=100
;            p.close

          endelse
          
          printf, 1, date, sensor, LSTend, format="(2a8, 4f7.2)"
          
          write_tiff, outdir + 'Tv\Tv_' + date + '_'+Hra_obj+'.tif', Tv, /float, geotiff=g_tags
          write_tiff, outdir + 'Ts\Ts_' + date + '_'+Hra_obj+'.tif', Ts, /float, geotiff=g_tags
          write_tiff, outdir + 'Ks\Ks_' + date + '_'+Hra_obj+'.tif', Ks, /float, geotiff=g_tags
          write_tiff, outdir + 'Kr\Kr_' + date + '_'+Hra_obj+'.tif', Kr, /float, geotiff=g_tags
          ;write_tiff, outdir + 'Zona_pol\Zona_LST-Fv_' + date + '.tif', Zona, /short, geotiff=g_tags
          ;write_tiff, pat + sensor + '\Fvg\Fvg'+string(strcompress(pp,/remove_all))+'\Fvg_' + date + '.tif', Fvg, /float, geotiff=g_tags
          write_tiff, outdir + 'Kcb_fv\Kcb_' + date + '.tif', Kcb_fv, /float, geotiff=g_tags
          write_tiff, outdir + 'Ke_fv\Ke_' + date + '.tif', Ke_fv, /float, geotiff=g_tags
          write_tiff, outdir + 'Ke_fc\Ke_' + date + '.tif', Ke_fc, /float, geotiff=g_tags
          write_tiff, outdir + 'Tends\Tends_' + date + '_'+Hra_obj+'.tif', Tendcor, /float, geotiff=g_tags
;          write_tiff, outdir + 'EF\EF_' + date + '_'+Hra_obj+'.tif', EFcor, /float, geotiff=g_tags
;          write_tiff, 'Results\Fvg'+ string(strcompress(pp,/remove_all)) + '\TVDI_fc\' + met[mm] + $
;            '\EF\EF_' + date + '_'+Hra_obj+'.tif', EF, /float, geotiff=g_tags
          
        endfor ; date
        close,1

      endfor ;Year

    endfor ; mm --> metodos de Tends

  endfor  ; pp -->fv=[]^pp


end
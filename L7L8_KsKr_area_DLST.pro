pro L7L8_KsKr_area_DLST
  ;;LST de Single-Channel by using soil emissivity from ASTER GED
  ;;Outputs: Fvg - Tv/Ts - Ks/Kr - Kcb/Ke
  ;;Tv/Ts : f(Tends,LST,fvg)
  ;;Ks/Kr : f(Tends,Tv/Ts)
  ;;Kcb = fvg*K_max
  ;;Ke = K_max(1 - fvg)Kr
  close, /all
  
  ;Select hour of Meteo data to use. If and EB method is used in met =[....] to constraint the Temperatures endmembers
  Hra_obj = '1130'
  
  Ndays = 4
  ;Selet Area
  area = 'R3';'Chichaoua';'Bour'; 'Sidi_rahal';'Labferrer';'AB34';'IsardSAT';
  
  ;Seect the period
  yr_ini=2015
  yr_end=2016
  
  ;Ta_seuilCloud: Ta - Ta_seuilCloud is the LST below which is filter and considered as Cloud
  DELTA_Ta_seuilCloud=1.5
  if area eq 'Chichaoua' then DELTA_Ta_seuilCloud=0 ;LST<Ta:cloud
  
  ;Define the begining and end of the period to estimate accordging to the area
  if area eq 'Bour' then begin
    date_i = '1001';MMDD semaille EC1-2: 26/11/2016 25/11/2017
    date_f = '0601';MMDD
  endif
  if area eq 'Chichaoua' then begin
    date_i = '1115';MMDD
    date_f = '0515';MMDD
  end
  if area eq 'R3' then begin
    date_i = '1231';MMDD semaille Gravitaire:22/12/2015 GAG: 11/12/2015
    date_f = '0531';MMDD 
  endif
  
  ;Select method of LST Partitioning 
  Partition = 'TSEB';'TSEB_EF';'TVDI_fc';'z1z3TVDI_v2';
  
  ;Select fractional Veget Cover: Total (Fc) / Green (Fvg)
  fcover = 'Fvg';'Fc';
  
  ;Methods to constraint  the endmembers Temperatures
  met = ['EBsolveg','EBsolveg\TvminTa','Regresion','Regresion_dev0.5','Stefan','Regresion_dev']
  
  ;Set Tvmin_Ta=1 if we want use Tvmin=Ta --> met='EBsolveg\TvminTa'. Otherwise Tvmin is from EB --> met='EBsolveg'
  Tvmin_Ta = 1
  
  ;Select if a combination ('comb\') of EB and contextual method is used
  combine = '';'comb\';
  
  ;Define Region according to the Area
  if area eq 'R3' OR area eq 'Bour' OR area eq 'Chichaoua' OR area eq 'Sidi_rahal' $
    then region='Maroc' $
    else region='Catalunya'
  
  ;Define the input folder according to the Area and use it as working directory
  pat='D:\CESBIO\Region\' + region + '\Area\' + area +'\'
  cd,pat
  
  ;Define the K_max used to estimate Kcb=Kmax*Fvg and Ke=Kr(1-Fvg)K_max // Ke(Fvg) better estimated than Ke(Fc)
  K_max = 1.2; -->de SSEBop para llevar EF al max Kc en la zona
  
  ;Select minimum threshold of available data to apply the method: relative
  Min_data = 0.4
  
  ;Landsat = ['L7','L8']
  
  ;Select where apply the method according to thegood data of BQA of L7/L8
  BQ_clear_L8 = [322, 386]  ;834: Clear terrain, low confidence cloud, high confidence cirrus
  ;898: Clear terrain, medium confidence cloud, high confidence cirrus                 1346: terrain occluded
  BQ_water_L8 = BQ_clear_L8 + 2
  BQ_clear_L7 = [66, 130]
  BQ_water_L7 = BQ_clear_L7 + 2
  
  ;Create the Main Output Folders inside of pat
  FILE_MKDIR, 'Results\';+ Landsat +'\
  FILE_MKDIR, 'L7\Fvg\Fvg1', 'L8\Fvg\Fvg1';, 'L7\Fvg\Fvg2', 'L8\Fvg\Fvg2'

  ;Select the exponential factor pp that was used to estimate the Fvg: fv=[()/()]^pp
  for pp=1,1 do begin
    p_=string(strcompress(pp,/remove_all))
    
    ;Select the methods to estimate the Tendmembers: met=[....]
    for mm=2, 2+0*(n_elements(met)-1) do begin
      
      ;Create the specific Output folder according to every sub-method
      outdir = 'Results\Fvg'+p_+'\'+Partition+'\'+fcover+'_DLST' + string(strcompress(Ndays,/remove_all)) +'days\'+combine+met[mm]+'\';_Fvg\;v2\
      FILE_MKDIR, outdir
      
      ;Loop for every year/season to apply the method
      for year=yr_ini,yr_end-1 do begin
          yr_i = year
          yr_f = yr_i+1
          YR_i = string(strcompress(yr_i,/remove_all))
          YR = string(strcompress(yr_f,/remove_all))
          
          ;Define the initial and final date of the season 
          YYYYDOY_ini = date2YYYYDOY(YR_i + date_i)
          YYYYDOY_fin = date2YYYYDOY(YR + date_f)
          
          ;Define the folder of the in situ data of the campaign
          yr_manip = YR_i + '-' + YR;'2014-2015'
          if area eq 'R3' then yr_manip = YR ;'2016'
          manip='Meteo_'+ yr_manip
          
          ;Create the specific Output folder for every output Product
          FILE_MKDIR, outdir+'Tv\'+YR,outdir+'Ts\'+YR,outdir+'Ks\'+YR,outdir+'Kr\'+YR,outdir+'Kcb_fv\'+YR,$
            outdir+'Ke_fv\'+YR,outdir+'Ke_fc\'+YR,outdir+'EF\'+YR;,outdir+'Zona_pol'
          
          ;If a mask of land cover is used
;          maskblesol = read_tiff('Mask_Ble_solnu_' + yr_manip + '.tif')
          
          ;Read the Meteo data --> Ta
          pat_meteo = pat + 'Insitu\'+ manip + '\Meteo\meteo_'+Hra_obj+'.txt'
          meteo = read_ascii(pat_meteo);YearDOY RG Tair Vv HR
          Ta = meteo.FIELD1[2,*] ;[K]
          
          ;Read the Tendmembers of all saison for the EB method met[0,1], Hra_obj, alb_soil=0.1, emis_soil=0.957, z0m=0.001, alb_vg=0.2: Tends_EB
          path_Tends = pat + 'Insitu\'+ manip + '\Results\' + met[0] +'\Tends\alb0.100_emis0.957_z0m0.0010_albvg0.20\Tends_EB_mo_'+Hra_obj+'.txt';met[mm]
          Tends_EB = read_ascii(path_Tends, count= na); [Tsmin,Tsmax,Tvmin,Tvmax]
          
          if Tvmin_Ta eq 1 then Tends_EB.FIELD1[3,*]=Ta
          
          ;Create the vector of Tendmember for every date of Landsat
          LSTend_EB = make_array(4,/float)
        
          ;Read all the filenames of Products: LST, NDVI, BQA, Fvg/Fc
          file_LST = file_search('L*' + '\LST\LST_' + '*.tif');('L*' + '\LST\' + YR + '\LST_*.tif');('L*' + '\LST\LST_' + YR + '*.tif')
          file_NDVI = file_search('L*' + '\NDVI\NDVI_*.tif');('L*' + '\NDVI\' + YR + '\NDVI_*.tif');('L*' + '\NDVI\NDVI_' + YR + '*.tif')
          file_QA = file_search('L*' + '\BQA\BQA_*.tif');('L*' + '\BQA\' + YR + '\BQA_*.tif');('L*' + '\BQA\BQA_' + YR + '*.tif')
          file_fcover = file_search('Results\Fvg' + p_ + '\'+fcover+'\'+YR+'\*.tif');('Results\Fvg' + p_ + '\'+fcover+'\'+fcover+'_' + '*.tif')
          file_fvg = file_search('Results\Fvg' + p_ + '\Fvg\'+YR+'\*.tif');('Results\Fvg' + p_ + '\Fvg\Fvg_' + '*.tif')
          file_fc = file_search('Results\Fvg' + p_ + '\Fc\'+YR+'\*.tif')
          
          file_DLST = file_search('D:\CESBIO\Region\Maroc\Area\R3\Results\DLST\LST_P1\LST_P1_' + YR + '*.tif')
          file_fvg_D = 'D:\CESBIO\Region\Maroc\Area\R3\Results\Fvg1\DFvg\Fvg_2016006_2016150_4days.tif'
            
          ;Read all the dates available by product in YYYYMMDD and convert to YYYYDOY
          YYYYMMDD=make_array(n_elements(file_LST),/string)
          for i=0,n_elements(file_NDVI)-1 do begin
            aux = strsplit(file_NDVI[i],'._',/EXTRACT); (strmid(file_NDVI[sort[i]],13,10, /REVERSE_OFFSET))
            YYYYMMDD[i] = aux[-2]
          endfor
          YYYYDOY = date2YYYYDOY(YYYYMMDD, delimiter='-')
          
          ;Filter all the products according to the dates of the season between: YYYYDOY_ini-YYYYDOY_fin 
            pix=where(YYYYDOY ge YYYYDOY_ini[0] AND YYYYDOY lt YYYYDOY_fin[0])
            YYYYDOY = YYYYDOY[pix]
            file_LST = file_LST[pix]
            file_NDVI = file_NDVI[pix]
            file_QA = file_QA[pix]
          sort=sort(YYYYDOY)
          
          ;Create YYYYDOY for DLST data
          aux = strsplit(file_fvg_D,'._',/EXTRACT) 
          Ndays_fv = fix(strmid(aux[-2],0,1))
          YYYYDOY_fvg_D = indgen((long(aux[-3]) - long(aux[-4]) )/Ndays_fv + 1)*Ndays_fv + long(aux[-4])
          YYYYDOY_out = indgen((long(aux[-3]) - long(aux[-4]) )/Ndays + 1)*Ndays + long(aux[-4])
          
          ;Read all the dates available by product in YYYYMMDD and convert to YYYYDOY
          YYYYDOY_DLST=make_array(n_elements(file_DLST),/long)
          for i=0,n_elements(file_DLST)-1 do begin
            aux = strsplit(file_DLST[i],'._',/EXTRACT); (strmid(file_NDVI[sort[i]],13,10, /REVERSE_OFFSET))
            YYYYDOY_DLST[i] = long(aux[-2])
          endfor
          
          ;Read all the dates available by Fvg in YYYYMMDD and convert to YYYYDOY
          YYYYDOY_fv=make_array(n_elements(file_fcover),/long)
          for i=0,n_elements(file_fcover)-1 do begin
            aux = strsplit(file_fcover[i],'._',/EXTRACT); (strmid(file_NDVI[sort[i]],13,10, /REVERSE_OFFSET))
            YYYYDOY_fv[i] = long(aux[-2])
          endfor
          
          ;Filter all the products according to the dates of the season between: YYYYDOY_ini-YYYYDOY_fin
          pix=where(YYYYDOY_DLST ge YYYYDOY_out[0] AND YYYYDOY_DLST le YYYYDOY_out[-1])
          YYYYDOY_DLST = YYYYDOY_DLST[pix]
          file_DLST = file_DLST[pix]
          
          ;Open fv interpolated
          fv_D = read_tiff(file_fvg_D, geotiff=g_tags)
          
          if n_elements(file_LST) ne n_elements(file_NDVI) OR n_elements(file_LST) ne n_elements(file_QA) OR $
            n_elements(file_LST) ne n_elements(file_fvg)  OR n_elements(file_LST) ne n_elements(file_fc) then $
            message, 'The number of different variables should be equals'
            
          ;Read the dimensions of the image in ss
          LST = read_tiff(file_LST[0])
          ss = size(LST) ;ss=n_elements(LST)
          ss = ss[1:2]
          
          ;Create the file .txt to save the Tendmembers/date by using the contextual, EB and combined methods: 1,3,2
          openw, 1, outdir + 'Tends_LST-Fvg_' + YR + '_context.txt'
          openw, 3, outdir + 'Tends_LST-Fvg_' + YR + '_extremes.txt'
          printf, 1,'Doy','Landsat', 'Ts_min','Ts_max','Tv_min','Tv_max', format="(2a8, 4a7)"
          printf, 3,'Doy','Landsat', 'Ts_min','Ts_max','Tv_min','Tv_max', format="(2a8, 4a7)"
            openw, 2, outdir + 'Tends_LST-Fvg_' + YR + '_EB.txt'
            printf, 2,'Doy','Landsat', 'Ts_min','Ts_max','Tv_min','Tv_max', format="(2a8, 4a7)"
          
          ;Apply the method to every date  
          for i=0,n_elements(YYYYDOY_out)-1 do begin
            
            ;Read the date of the image
            date = string(strcompress(YYYYDOY_out[i],/remove_all))
            doy = YYYYDOY_out[i]      ;fix(date - year*1000.)
            
            ;if doy gt Tends_EB.FIELD1[0,-1] then break
            
            ;;If the date exists in Landsat overpass dates
            k = where(YYYYDOY eq YYYYDOY_out[i])
            if k ge 0 then begin
              
              ;Read the BQA to the Mask
              QA = float(read_tiff(file_QA[k]))
              
              ;Read the sensor (L7,L8) and use the BQA values to the mask
              sensor = strsplit(file_LST[k],'\',/EXTRACT)
              sensor = sensor[0]; strmid(sensor[-1], 2, 1)
              if sensor eq 'L8' then BQ_clear = BQ_clear_L8 else BQ_clear = BQ_clear_L7
              pix=QA*0
              for qq=0,n_elements(BQ_clear)-1 do begin
                pix[where(QA eq BQ_clear[qq] OR QA eq BQ_clear[qq]+2)] = 1
              endfor
              pix = where(pix ne 1)
              QA[pix] = !values.F_NAN
              
              ;Select Tendmember in LSTend_EB of the EB method for the specific date(doy)
              pix = where(doy eq Tends_EB.FIELD1[0,*])
              if pix ne -1 then LSTend_EB = Tends_EB.FIELD1[1:4,pix] $
              else LSTend_EB[*] = !values.F_NAN
              if finite(LSTend_EB[2]) eq 0 then LSTend_EB[2]=Ta[pix]
              
              ;Read the LST. Filter every data with BQA and with value<seuilCloud (Ta-1.5)
              LST = read_tiff(file_LST[k], geotiff=g_tags)
              seuilCloud = LSTend_EB[2] - DELTA_Ta_seuilCloud
              LST[where(finite(QA, /NAN))] = !values.F_NAN
              LST[where(LST lt seuilCloud)] = !values.F_NAN
              
              ;Read the Fract veget cover
              k = where(YYYYDOY_fv eq YYYYDOY_out[i])
              Fvg = read_tiff(file_fcover[k])
              
            ;;If the date exists in Landsat overpass dates
            ;;Open DLST and fv interpolated
            endif else begin
               
               ;Open DLST and fv interpolated
               Fvg = fv_D[ i*Ndays/Ndays_fv , *, *]
               k = where(YYYYDOY_DLST eq YYYYDOY_out[i])
               LST = read_tiff(file_DLST[k], geotiff=g_tags)
              
            endelse
            
            
            pix = where(finite(LST,/NAN) or LST lt 273)
            LST[pix] = !values.F_NAN
            ;If there are not the minimun data according to Min_data: All product = NAN
            if n_elements(pix) gt Min_data*ss[0]*ss[1] then begin
              Tv[*,*] = !values.F_NAN
              Ts=Tv
              Ks=Tv
              Kr=Tv
              EF=Tv
              ;Zona[*,*]=0
              LSTend[*]=!values.F_NAN
              ;CONTINUE
            endif else begin
            
              

              

              ;Create the Output folder to save the plot
              outplot = outdir + 'Poligone\'
              FILE_MKDIR, outplot
              
              ;Contraint the Tendmember according to different methods met by using the space LST-Fcover
              if met[mm] eq 'Stefan' then $
                LSTend = Tends_Fvg_IMA(LST, Fvg);Fvg_ENDMBmax=0.6);, Tair=280.0: ;Default Fvg_ENDMBmax=mean(Fvg,/nan) 
              if met[mm] eq 'Regresion' then $
                LSTend = Tends_Fvg_IMA_regresion(LST, Fvg, date=date, outplot=outplot, bin_x=0.01);/plot_, 
              if met[mm] eq 'Regresion_dev' then $
                LSTend = Tends_Fvg_IMA_regresion(LST, Fvg, /dev, date=date, outplot=outplot, bin_x=0.01);/plot_, --> +-stddev
              if met[mm] eq 'Regresion_dev0.5' then $
                LSTend = Tends_Fvg_IMA_regresion(LST, Fvg, /dev, f_dev=0.5, date=date, outplot=outplot, bin_x=0.01); --> +-0.5stddev
              if met[mm] eq 'EBsolveg\TvminTa' OR met[mm] eq 'EBsolveg' then begin
                LSTend = LSTend_EB
                Tend_reg = Tends_Fvg_IMA_regresion(LST, Fvg, date=date, outplot=outplot);, /plot
              endif
              
              ;Extract every Tendmember in a variable: Ts_min,Ts_max,Tv_min,Tv_max,
              Ts_min = LSTend[0]
              Ts_max = LSTend[1]
              Tv_min = LSTend[2]
              Tv_max = LSTend[3]
              
              ;If a conbination between the contextual and EB method is used: Select the extreme Tendmember 
              if combine eq 'comb\' then begin
                Ts_min = min([LSTend[0], LSTend_EB[0]], /nan)
                Ts_max = max([LSTend[1], LSTend_EB[1]], /nan)
                Tv_min = min([LSTend[2], LSTend_EB[2]], /nan)
                Tv_max = max([LSTend[3], LSTend_EB[3]], /nan)
              endif
              
              ;If one Tend could not be estimated: All product = NAN 
              if n_elements(where(finite(LSTend))) lt 4 then begin
                Tv = make_array(ss,/float)
                Tv[*,*] = !values.F_NAN
                Ts=Tv
                Ks=Tv
                Kr=Tv
                EF=Tv
                ;Zona[*,*]=0
                LSTend[*]=!values.F_NAN
                ;CONTINUE
              endif else begin
              
                ;Partitioning LST method: 'TVDI_fc' / 'z1z3TVDI_v2' to estimate Ts and Tv
                if Partition eq 'TSEB' then begin
                  Ts_Tvg_Z = Partition_TsTv_TSEB_IMA(LST, Fvg, Ts_min, Ts_max, Tv_min, Tv_max)
                endif else begin
                  if Partition eq 'TSEB_EF' then begin
                      Ts_Tvg_Z = Partition_TsTv_TSEB_IMA(LST, Fvg, Ts_min, Ts_max, Tv_min, Tv_max)
                      TsTv = Partition_TsTv_TDVI_IMA(LST, Fvg, Ts_min, Ts_max, Tv_min, Tv_max)
                      Ts_Tvg_Z[*,*,0] = mean( [[[Ts_Tvg_Z[*,*,0]]],[[TsTv[*,*,0]]]] ,DIMENSION=3)
                      Ts_Tvg_Z[*,*,1] = mean( [[[Ts_Tvg_Z[*,*,1]]],[[TsTv[*,*,1]]]] ,DIMENSION=3)
                  endif else begin 
                      if Partition eq 'TVDI_fc' then $
                        ;Ts_Tvg_Z = Partition_TsTv_z1z3TVDI_IMA_z2Ks1(LST, Fvg, Ts_min, Ts_max, Tv_min, Tv_max)
                        Ts_Tvg_Z = Partition_TsTv_TVDI_fc_IMA(LST, Fvg, Ts_min, Ts_max, Tv_min, Tv_max) $
                      else Ts_Tvg_Z = Partition_TsTv_z1z3TVDI_IMA_v2(LST, Fvg, Ts_min, Ts_max, Tv_min, Tv_max)
                  endelse
                endelse
                
                Ts = Ts_Tvg_Z[*,*,0]
                Tv = Ts_Tvg_Z[*,*,1]
                ;Zona = Ts_Tvg_Z[*,*,2]
                
                ;Estimate Ks/Kr
                Ks = (Tv_max - Tv)/(Tv_max - Tv_min)
                Kr = (Ts_max - Ts)/(Ts_max - Ts_min)
                
                ;If Tv_max=Tv_min Ks will be undefined --> Use Ks=Kr
                if Tv_max eq Tv_min then Ks = Kr
                
                ;Estimate TVDI and EF
                TDVI = f_tvdi(Fvg, LST, [Ts_min, Ts_max, Tv_min, Tv_max])
                EF = 1 - TDVI
                
                ;;PLOT POLIGONE in space LST-Fcover
;                P= plot(fvg(where(finite(fvg))), LST(where(finite(fvg))), '*', xrange=[0,1], $
;                  xtitle="Fractional vegetation cover [-]", ytitle="Surface Temperature [K]");yrange=[290,330],
;                p2= plot([0, 1], [LSTend[1], LSTend[3]],'r2',/overplot, NAME='Imaged-based')
;                p3= plot([0, 1], [LSTend[0], LSTend[2]],'b2',/overplot); color=4
;                p4= plot([0, 1], [LSTend_EB[1], LSTend_EB[3]],'r2--',/overplot, NAME='Energy Balance')
;                p5= plot([0, 1], [LSTend_EB[0], LSTend_EB[2]],'b2--',/overplot); color=4
;                leg = LEGEND(TARGET=[p2,p4], POSITION=[0.9,0.9])
;                ;P.yrange=[floor(min(LST(where(finite(fvg))))/10)*10,ceil(max(LST(where(finite(fvg))))/10)*10]
;                P.yrange=[floor(min([LSTend[2], LSTend_EB[2]], /nan)/5)*5 , ceil(max([LSTend[1], LSTend_EB[1]], /nan)/5)*5]
;                
;                ;Save the plot
;                p.Save, outdir + 'Poligone\LST_'+fcover+'_' + date + '_' + Hra_obj + '.png', BORDER=10, RESOLUTION=150
;                p.close
              
              endelse; if all Tend were estimated
            endelse;si no hay data suficientes
            
            ;Estimate Kcb and Ke from Fvg
            Fvgreen = Fvg; read_tiff(file_Fvg[i])
            Kcb_fv = K_max*Fvgreen
            Ke_fv = K_max*(1. - Fvgreen)*Kr
            undefine, Fvgreen
            
            ;Estimate Ke from Fc
;            Fc = read_tiff(file_fc[i])
;            Ke_fc = K_max*(1. - Fc)*Kr
            
            ;Save the Tend by date
            printf, 1, date, sensor, LSTend, format="(2a8, 4f7.2)"
            printf, 3, date, sensor, [Ts_min, Ts_max, Tv_min, Tv_max], format="(2a8, 4f7.2)"
              printf, 2, date, sensor, LSTend_EB, format="(2a8, 4f7.2)"
            
            ;Save all Product          
            write_tiff, outdir + 'Tv\' + YR + '\Tv_' + date + '_'+Hra_obj+'.tif', Tv, /float, geotiff=g_tags
            write_tiff, outdir + 'Ts\' + YR + '\Ts_' + date + '_'+Hra_obj+'.tif', Ts, /float, geotiff=g_tags
            write_tiff, outdir + 'Ks\' + YR + '\Ks_' + date + '_'+Hra_obj+'.tif', Ks, /float, geotiff=g_tags
            write_tiff, outdir + 'Kr\' + YR + '\Kr_' + date + '_'+Hra_obj+'.tif', Kr, /float, geotiff=g_tags
            write_tiff, outdir + 'Kcb_fv\' + YR + '\Kcb_' + date + '.tif', Kcb_fv, /float, geotiff=g_tags
            write_tiff, outdir + 'Ke_fv\' + YR + '\Ke_' + date + '.tif', Ke_fv, /float, geotiff=g_tags
;            write_tiff, outdir + 'Ke_fc\' + YR + '\Ke_' + date + '.tif', Ke_fc, /float, geotiff=g_tags
            write_tiff, outdir + 'EF\' + YR + '\EF_' + date + '_'+Hra_obj+'.tif', EF, /float, geotiff=g_tags
            ;write_tiff, outdir + 'Zona_pol\Zona_LST-Fv_' + date + '.tif', Zona, /short, geotiff=g_tags
            ;write_tiff, pat + sensor + '\Fvg\Fvg'+p_+'\Fvg_' + date + '.tif', Fvg, /float, geotiff=g_tags
            
          endfor ; date
          close,/all
        
      endfor ;Year
      
    endfor ; mm --> metodos de Tends
    
  endfor  ; pp -->fv=[]^pp
   
end


;Function of contextual TVDI from LST-Fcover and Tend
function f_tvdi, Fvg, LST, Tend_reg
  ;;CONTEXTUAL
  Ts_min = Tend_reg[0]
  Ts_max = Tend_reg[1]
  Tv_min = Tend_reg[2]
  Tv_max = Tend_reg[3]
  Th = Ts_max - (Ts_max - Tv_max)*Fvg ;T en limite AD DRY
  Tj = Ts_min - (Ts_min - Tv_min)*Fvg ;T en limite BC WET
  TVDI = (LST - Tj)/(Th - Tj)
  TVDI[where(TVDI lt 0)] = 0.
  TVDI[where(TVDI gt 1)] = 1
  
  return, TVDI
end
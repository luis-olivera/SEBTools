pro Fvg2fc
  ;;fvg --> fc
;;Fc solo en zona de MASK (ble+sol_nu)
  close, /all
  
  MIN_MAX = [0.14, 0.93];[0.15, 0.93]
  area = 'Chichaoua';'R3';'Bour';'Sidi_rahal';'Labferrer';'AB34';'IsardSAT';
  if area eq 'Bour' then begin
    date_i = '1001';MMDD
    date_f = '0601';MMDD
  endif
  if area eq 'Chichaoua' then begin
    date_i = '1115';MMDD
    date_f = '0515';MMDD
  end
  if area eq 'R3' then begin
    date_i = '1231';MMDD
    date_f = '0531';MMDD
  endif
    
  yr_i0=2016
  yr_f0=2017
  
  BQ_clear_L8 = [322, 386]  ;834: Clear terrain, low confidence cloud, high confidence cirrus
  ;898: Clear terrain, medium confidence cloud, high confidence cirrus                 1346: terrain occluded
  BQ_water_L8 = BQ_clear_L8 + 2
  BQ_clear_L7 = [66, 130]
  BQ_water_L7 = BQ_clear_L7 + 2
  
  if area eq 'R3' OR area eq 'Bour' OR area eq 'Chichaoua' OR area eq 'Sidi_rahal' $
    then region='Maroc' $
  else region='Catalunya'

  pat='D:\CESBIO\Region\' + region + '\Area\' + area +'\';'
  cd,pat
  
  fv_seuil = 0;0.2;0.4
  
  for pp=1,1 do begin  ;fv=[()/()]^pp
    p_ = string(strcompress(pp,/remove_all))
;    outdir = 'Results\Fvg'+ string(strcompress(pp,/remove_all)) + '\Fc\'
;    FILE_MKDIR, outdir, 'Results\Fvg'+ p_ + '\Fvg\'

    for year=yr_i0,yr_f0 do begin
      yr_i = year;
      yr_f = yr_i+1;
      YR_i = string(strcompress(yr_i,/remove_all))
      YR = string(strcompress(yr_f,/remove_all))
      YYYYDOY_ini = date2YYYYDOY(YR_i + date_i)
      YYYYDOY_fin = date2YYYYDOY(YR + date_f)
      yr_manip = YR_i + '-' + YR 
      if area eq 'R3' then yr_manip = YR 
      maskblesol = read_tiff('Mask_Ble_solnu_' + yr_manip + '.tif')
                
      outdir = 'Results\Fvg'+ string(strcompress(pp,/remove_all)) + '\Fc\' + YR + '\'
      FILE_MKDIR, outdir, 'Results\Fvg'+ p_ + '\Fvg\' + YR + '\'
      
      ;file_fvg = file_search('L*' + '\NDVI\NDVI_' + YR + '*.tif')
      ;file_fvg = file_search('L*' + '\NDVI\' + YR + '\NDVI_*.tif')
      file_fvg = file_search('L*' + '\NDVI\NDVI_*.tif')
      file_bqa = file_search('L*' + '\BQA\' + 'BQA_*.tif')
;      file_fvg = file_search('Results\Fvg' + string(strcompress(pp,/remove_all)) + '\Fvg\Fvg_' + '*.tif')

      YYYYMMDD=make_array(n_elements(file_fvg),/string)
        
        for i=0,n_elements(file_fvg)-1 do begin
          aux = strsplit(file_fvg[i],'._',/EXTRACT); (strmid(file_NDVI[sort[i]],13,10, /REVERSE_OFFSET))
          YYYYMMDD[i] = aux[-2]
        endfor
        YYYYDOY = date2YYYYDOY(YYYYMMDD, delimiter='-')
        
          pix=where(YYYYDOY ge YYYYDOY_ini[0] AND YYYYDOY lt YYYYDOY_fin[0]);sin [0] no funcionaba
          YYYYDOY = YYYYDOY[pix]
          file_fvg = file_fvg[pix]
          file_bqa = file_bqa[pix]
          
        sort=sort(YYYYDOY)
        YYYYDOY = YYYYDOY[sort]
        
      
      ss = size(read_tiff(file_fvg[0]))
      ss = ss[1:2] 
      
      ;n_ima = n_elements(where(YYYYDOY le year*1000.+doy_f ))
      n_ima = n_elements(YYYYDOY)
      
      Fvg_serie = make_array([ss,n_ima], /float)

      for i=0, n_ima-1 do begin
        NDVI = read_tiff(file_fvg[sort[i]], geotiff=g_tags)
        BQA = qa2nan(file_bqa[sort[i]], BQ_clear_L8, BQ_clear_L7)
        
        NDVI[where(finite(BQA) eq 0)] = !values.F_NAN
        Fvg_serie[*,*,i] = ndvi2fvg(NDVI, MIN_MAX, pp)
      endfor
      
      Fc_serie = Fvg_serie
      for col=0, ss[0]-1 do begin
        for fil=0, ss[1]-1 do begin
          
          if KEYWORD_SET(maskblesol) AND maskblesol[col,fil] eq 0 then begin
            Fc_serie[col,fil,*] = Fvg_serie[col,fil,*]
          endif else begin
            
            fv_max = max(Fvg_serie[col,fil,*],/nan)
            if fv_max gt fv_seuil then begin
              pix = min(where(Fvg_serie[col,fil,*] eq fv_max))
              Fc_serie[col,fil,pix:n_ima-1] = fv_max
            endif
            
          endelse
                 
        endfor
      endfor
;      Fc_serie(where(finite(Fvg_serie) eq 0))=!values.F_NAN
      
      for i=0, n_ima-1 do begin
        date = string(strcompress(YYYYDOY[i],/remove_all))
        path_out = outdir + 'Fc_' + date + '.tif'
        write_tiff, path_out, Fc_serie[*,*,i], /float, geotiff=g_tags
        path_out = 'Results\Fvg' + p_ + '\Fvg\' + YR + '\Fvg_' + date + '.tif'
          ;path_out = 'Results\Fvg' + p_ + '\Fvg\Fvg_' + date + '.tif'
        write_tiff, path_out , Fvg_serie[*,*,i], /float, geotiff=g_tags
      endfor


    endfor ;Year
  endfor  ; pp -->fv=[]^pp


end

function ndvi2fvg, NDVI, MIN_MAX, pp
  NDVI[where(NDVI le MIN_MAX[0])] = MIN_MAX[0]
  NDVI[where(NDVI ge MIN_MAX[1])] = MIN_MAX[1]
  Fvg = ((NDVI - MIN_MAX[0])/(MIN_MAX[1] - MIN_MAX[0]))^pp
  
  return, Fvg
end


function qa2nan, file_bqa, BQ_clear_L8, BQ_clear_L7
  bqa = read_tiff(file_bqa)
  sensor = strsplit(file_bqa,'\',/EXTRACT)
  sensor = sensor[0]; strmid(sensor[-1], 2, 1)
  if sensor eq 'L8' then BQ_clear = BQ_clear_L8 else BQ_clear = BQ_clear_L7
  pix=bqa*0
  for qq=0,n_elements(BQ_clear)-1 do begin
    pix[where(bqa eq BQ_clear[qq] OR bqa eq BQ_clear[qq]+2) ] = 1
  endfor
  pix=float(pix)
  pix[where(pix ne 1)] = !values.F_NAN  
  
  return, pix
end
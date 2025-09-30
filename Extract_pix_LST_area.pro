pro Extract_pix_LST_area
  close,/all
  
;  Landsat = 'L7'
  area = 'Bour';'R3';'Sidi_rahal';'Chichaoua';'Labferrer';'AB34';'IsardSAT';
  
  ;Select hour of Meteo data to use. If and EB method is used in met =[....] to constraint the Temperatures endmembers
  Hra_obj = '1130'
  
  ;Seect the period
  yr_ini=2014
  yr_end=2018
  
  ;Define the begining and end of the period to estimate accordging to the area
  if area eq 'Bour' then begin
    date_i = '1231';'1001';MMDD semaille EC1-2: 26/11/2016 25/11/2017
    date_f = '1231';'0601';MMDD
    Px = [339,352]-1  ; [339,353]
  endif
  if area eq 'Chichaoua' then begin
    date_i = '1115';MMDD
    date_f = '0515';MMDD
    Px = [[209,102],[200,101]]-1  ;[209,103]
  end
  if area eq 'R3' then begin
    date_i = '1231';MMDD semaille Gravitaire:22/12/2015 GAG: 11/12/2015
    date_f = '0531';MMDD
    Px = [[180,337],[192,284]]-1  ;Ble [gravitaire,GaG] 100m: [[54,102],[58,86]] emis_soil_L8=[0.9748, 0.9743] //  emis_soil_L7=[0.9766, 0.9762]
    ;// B123(2003)100m: [74,61] emis_soil_L8=0.9694 // emis_soil_L7=0.9723
  endif
  
  if area eq 'R3' OR area eq 'Bour' OR area eq 'Chichaoua' OR area eq 'Sidi_rahal' $
    then region='Maroc' $
    else region='Catalunya'
  
  ;Define the input folder according to the Area and use it as working directory
  pat='D:\CESBIO\Region\' + region + '\Area\' + area +'\'
  cd,pat
;  FILE_MKDIR, 'Results\';+ Landsat +'\
  
  ;;;****************************ARREGLAR SENSOR******************************
  
;  pat='D:\CESBIO\Maroc\Spatial\Landsat\'
;  cd,pat
  partition = 'TVDI_fc\';''
  ;EB = 'EBsolveg\TvminTa\';''
  met = ['EBsolveg\TvminTa\','Regresion' , 'Regresion_dev','Regresion_dev0.5', 'Stefan']
  
  for pp=1,1 do begin  ;fv=[()/()]^pp
    p_=string(strcompress(pp,/remove_all))
    
    for mm=1, 1 + 0*(n_elements(met)-1) do begin
      
      outdir = 'Results\Fvg'+string(strcompress(pp,/remove_all)) + '\' + partition + 'Fc\' + met[mm] + '\';v2\
      
      for year=yr_ini,yr_end-1 do begin
        
        YR_i = string(strcompress(year,/remove_all))
        YR = string(strcompress(year+1,/remove_all))
        
        ;Define the initial and final date of the season
        YYYYDOY_ini = date2YYYYDOY(YR_i + date_i)
        YYYYDOY_fin = date2YYYYDOY(YR + date_f)
        
        file_LST = file_search('L*' + '\LST\LST_' + '*.tif');('L*' + '\LST\LST_' + YR + '*.tif'); + Landsat
        file_alb = file_search('L*' + '\Albedo\ALB_weiss_' + '*.tif');('Results\Albedo\ALB_weiss_' + YR + '*.tif')
        file_QA = file_search('L*' + '\BQA\BQA_*.tif');
        file_NDVI = file_search('L*' + '\NDVI\NDVI_' + '*.tif');
        
        ;Read all the dates available by product in YYYYMMDD and convert to YYYYDOY
        YYYYMMDD=make_array(n_elements(file_alb),/string)
        for i=0,n_elements(file_alb)-1 do begin
          aux = strsplit(file_alb[i],'._',/EXTRACT); (strmid(file_NDVI[sort[i]],13,10, /REVERSE_OFFSET))
          YYYYMMDD[i] = aux[-2]
        endfor
        YYYYDOY = date2YYYYDOY(YYYYMMDD, delimiter='-')
        
        ;Filter all the products according to the dates of the season between: YYYYDOY_ini-YYYYDOY_fin
        pix=where(YYYYDOY ge YYYYDOY_ini[0] AND YYYYDOY lt YYYYDOY_fin[0])
        YYYYDOY = YYYYDOY[pix]
        file_LST = file_LST[pix]
        file_alb = file_alb[pix]
        file_QA = file_QA[pix]
        file_NDVI = file_NDVI[pix]
        sort=sort(YYYYDOY)
        
        if n_elements(file_LST) ne n_elements(file_alb) OR n_elements(file_LST) ne n_elements(file_QA) $
          OR n_elements(file_LST) ne n_elements(file_NDVI) then $
          message, 'The number of different variables should be equals'

;        sort = file_basename(file_LST)
;        sort = sort(sort)
    
        for j=0, (n_elements(Px)/2-1) do begin
    ;      openw, 1, 'Variables_L8_reg_' + string(strcompress(year,/remove_all)) + '_P' + string(strcompress(j,/remove_all)) + '.csv'
    ;      printf, 1,'Date','LST','Tv','Ts','Fvg','Ks','Kr','Zona', format=fmt1
          
          dates=make_array(n_elements(file_LST),/integer)
          sensor=make_array(n_elements(file_LST),/integer)
          Px_serie= make_array([4,n_elements(file_LST)],/float);9
          alb=make_array(n_elements(file_LST),/float)
          
          for i=0, n_elements(file_LST)-1 do begin
            A1=read_tiff(file_LST[sort[i]])
            A2=read_tiff(file_NDVI[sort[i]])
            A3=read_tiff(file_alb[sort[i]])
            A4=read_tiff(file_QA[sort[i]])

            ss=size(A2)
            A1 = (A1[0:ss[1]-1, *]);/100.
            AA = [[[A1]], [[A2]], [[A3]], [[A4]]];, [[A9]]]
            
            dates(i)=(YYYYDOY[sort[i]]) - (YYYYDOY[sort[i]])/1000*1000
            sensor(i) = fix(strmid(file_LST[sort[i]],1,1))
            col=Px[0,j]
            fil=Px[1,j]
            ;Px_serie(*,i)=transpose(mean(mean(AA[col-1:col+1,fil-1:fil+1,*],dimension=1,/nan),dimension=1))
            Px_serie(*,i)=transpose(mean(mean(AA[col,fil,*],dimension=1,/nan),dimension=1))
    ;        if dates(i) eq 302 then begin
    ;          print, (AA[col-1:col+1,fil-1:fil+1,*])
    ;        endif
    ;        date = (strmid(file_Fvg[i],13,10, /REVERSE_OFFSET))       
    ;        printf, 1, date, transpose(AA[Px[0,j],Px[1,j],*]), format=fmt2
            
            ;;ALBEDO
            A=read_tiff(file_alb[sort[i]])
            alb(i)=A[col,fil]
            laraja=0
          endfor
    ;      close,1
        
        header=['Sensor', 'DOY','LST','NDVI','Alb','QA'];,'Zona']
        path_out = outdir + 'LST_' + YR + '_P' + string(strcompress(j+1,/remove_all)) + '.csv'
        write_csv, path_out, [transpose(sensor),transpose(dates),Px_serie],header=header
        close, /all
        endfor
        
      endfor  
     endfor ; mm --> metodos de Tends
endfor ; pp -->fv=[]^pp

  print, 'soy la raja'
  
end
pro Extract_plot_area
  close,/all
  
  ;  Landsat = 'L7'
  area = 'R3';'Sidi_rahal';'Bour';'Chichaoua';'Labferrer';'AB34';'IsardSAT';
  
  if area eq 'R3' OR area eq 'Bour' OR area eq 'Chichaoua' OR area eq 'Sidi_rahal' $
    then region='Maroc' $
  else region='Catalunya'
  
  pat='D:\CESBIO\Region\' + region + '\Area\' + area +'\'
  cd,pat
  
  if area eq 'R3' then $
    mask_plot = read_tiff(['Mask_Ble_Grav_GaG_2016_ptit.tif']);
  
  
  ;;;****************************ARREGLAR MASK por AREA******************************
  
  partition = 'TVDI_fc\';''
  ;EB = 'EBsolveg\TvminTa\';''
  met = ['EBsolveg\TvminTa\','Regresion' , 'Regresion_dev','Regresion_dev0.5', 'Stefan']
  
  for pp=1,1 do begin  ;fv=[()/()]^pp
    for mm=0, (n_elements(met)-1) do begin
    
      outdir = 'Results\Fvg'+string(strcompress(pp,/remove_all)) + '\' + partition + met[mm] + '\';v2\
      
      for year=2016,2016 do begin
        YR = string(strcompress(year,/remove_all))
        file_LST = file_search('L*' + '\LST\LST_' + YR + '*.tif'); + Landsat
        file_Tv = file_search(outdir + 'Tv\Tv_' + YR + '*.tif')
        file_Ts = file_search(outdir + 'Ts\Ts_' + YR + '*.tif')
        file_Fvg = file_search('L*' + '\Fvg\Fvg'+string(strcompress(pp,/remove_all)) + '\Fvg_' + YR + '*.tif')
        file_Ks = file_search(outdir + 'Ks\Ks_' + YR + '*.tif')
        file_Kr = file_search(outdir + 'Kr\Kr_' + YR + '*.tif')
        file_Zona = file_search(outdir + 'Zona_pol\Zona_LST-Fv_' + YR + '*.tif')
        file_Kcb = file_search(outdir + 'Kcb_fv\Kcb_' + YR + '*.tif')
        file_Ke = file_search(outdir + 'Ke_fv\Ke_' + YR + '*.tif')
        ;file_alb = file_search('Results\Albedo\ALB_weiss_' + YR + '*.tif')
        file_alb = file_search('L*' + '\Albedo\ALB_bsaibes_' + YR + '*.tif')
        
        ;    fmt1="(a13, 6a8, a5)"
        ;    fmt2="(a13, 3f8.2, 3f8.3, I5)"
        
        Px = [[180,337],[192,284]]-1  ;Ble [gravitaire,GaG] 100m: [[54,102],[58,86]] emis_soil_L8=[0.9748, 0.9743] //  emis_soil_L7=[00.9766, 0.9762]
        ;// B123(2003)100m: [74,61] emis_soil_L8=0.9694 // emis_soil_L7=0.9723
        
        sort = file_basename(file_LST)
        sort = sort(sort)
        file_Tv = file_alb
        for j=0, (n_elements(Px)/2-1) do begin
          ;      openw, 1, 'Variables_L8_reg_' + string(strcompress(year,/remove_all)) + '_P' + string(strcompress(j,/remove_all)) + '.csv'
          ;      printf, 1,'Date','LST','Tv','Ts','Fvg','Ks','Kr','Zona', format=fmt1
          
          dates=make_array(n_elements(file_Tv),/integer)
          sensor=make_array(n_elements(file_Tv),/integer)
          Px_serie= make_array([8,n_elements(file_Tv)],/float);9
          alb=make_array(n_elements(file_Tv),/float)
          
          for i=0, n_elements(file_Tv)-1 do begin
;            A1=read_tiff(file_LST[sort[i]])
;            A2=read_tiff(file_Tv[i])
;            A3=read_tiff(file_Ts[i])
;            A4=read_tiff(file_Fvg[sort[i]])
;            A5=read_tiff(file_Ks[i])
;            A6=read_tiff(file_Kr[i])
;            A7=read_tiff(file_Kcb[i])
;            A8=read_tiff(file_Ke[i])
;            ;A9=read_tiff(file_Zona[i])
;            ss=size(A2)
;            A1 = (A1[0:ss[1]-1, *]);/100.
;            AA = [[[A1]], [[A2]], [[A3]], [[A4]], [[A5]], [[A6]], [[A7]], [[A8]]];, [[A9]]]
            
            dates(i)=(strmid(file_Fvg[sort[i]],6,3, /REVERSE_OFFSET));dates(i)=long(strmid(file_Fvg[i],10,7, /REVERSE_OFFSET))
            sensor(i) = fix(strmid(file_LST[sort[i]],1,1))
            col=Px[0,j]
            fil=Px[1,j]
;            ;Px_serie(*,i)=transpose(mean(mean(AA[col-1:col+1,fil-1:fil+1,*],dimension=1,/nan),dimension=1))
;            Px_serie(*,i)=transpose(mean(mean(AA[col,fil,*],dimension=1,/nan),dimension=1))
;            ;        if dates(i) eq 302 then begin
;            ;          print, (AA[col-1:col+1,fil-1:fil+1,*])
;            ;        endif
;            ;        date = (strmid(file_Fvg[i],13,10, /REVERSE_OFFSET))
;            ;        printf, 1, date, transpose(AA[Px[0,j],Px[1,j],*]), format=fmt2
;            
            ;;ALBEDO
            A=read_tiff(file_alb[sort[i]])
            alb(i)=A[col,fil]
            ;print, file_alb[sort[i]]
            laraja=0
          endfor
          ;      close,1
          
;          header=['Sensor', 'DOY','LST','Tv','Ts','Fvg','Ks','Kr','Kcb','Ke'];,'Zona']
;          path_out = outdir + 'Variables_' + YR + '_P' + string(strcompress(j+1,/remove_all)) + '.csv'
;          write_csv, path_out, [transpose(sensor),transpose(dates),Px_serie],header=header
          
          header=['Sensor', 'DOY','Alb']
          ;path_out = 'Results\Albedo_' + YR + '_P' + string(strcompress(j+1,/remove_all)) + '.csv'
          path_out = 'Results\Albedo_bsaibes_' + YR + '_P' + string(strcompress(j+1,/remove_all)) + '.csv'
          write_csv, path_out,[transpose(sensor),transpose(dates),transpose(alb)],header=header
          close, /all
        endfor
        
      endfor
    endfor ; mm --> metodos de Tends
  endfor ; pp -->fv=[]^pp
  
  print, 'soy la raja'
  
end
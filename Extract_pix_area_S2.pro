pro Extract_pix_area_S2
  close,/all
  
  pat='D:\CESBIO\Labferrer\S2\Level2A\'
  region = 'Maroc'
  area = 'R3';'Raimat'
  pat='D:\CESBIO\Region\' + region + '\Data\S2\';'D:\CESBIO\Labferrer\';'C:\CESBIO\IsardSAT\L8\'
  pat_out = 'D:\CESBIO\Region\' + region + '\Area\' + area + '\S2\NDVI\'
  outdir = pat_out
  
  for pp=1,1 do begin  ;fv=[()/()]^pp
  
    ;outdir = 'Results\Fvg'+string(strcompress(pp,/remove_all)) + '\' + met[mm] + '\';v2\
    
    for year=2016,2016 do begin
      YR = string(strcompress(year,/remove_all))
      file_LST = file_search(pat_out + '\NDVI_' + YR + '*.tif')
      file_LST = file_search(pat_out + '\NDVI_' + '*.tif')
      A1 = read_tiff(file_LST[0])
      ss=size(A1)
      DIMS_RES=ss[1:2]
      
      
      Px = [[180,337],[192,284]]-1  ;Ble [gravitaire,GaG] 100m: [[54,102],[58,86]] emis_soil_L8=[0.9748, 0.9743] //  emis_soil_L7=[00.9766, 0.9762]
      ;// B123(2003)100m: [74,61] emis_soil_L8=0.9694 // emis_soil_L7=0.9723
      
      
      for j=0, (n_elements(Px)/2-1) do begin
        ;      openw, 1, 'Variables_L8_reg_' + string(strcompress(year,/remove_all)) + '_P' + string(strcompress(j,/remove_all)) + '.csv'
        ;      printf, 1,'Date','LST','Tv','Ts','Fvg','Ks','Kr','Zona', format=fmt1
        
        dates=make_array(n_elements(file_LST),/long)
        sensor=make_array(n_elements(file_LST),/integer)
        Px_serie= make_array([n_elements(file_LST)],/float)
        
        for i=0, n_elements(file_LST)-1 do begin
          A1=read_tiff(file_LST[i])
          
          AA = CONGRID(A1, round(DIMS_RES[0]*10./30), round(DIMS_RES[1]*10./30), CUBIC=-0.5, /center)
          
;          ss=size(A2)
;          A1 = (A1[0:ss[1]-1, *]);/100.
;          AA = [[[A1]]];, [[A2]], [[A3]], [[A4]], [[A5]], [[A6]], [[A7]], [[A8]], [[A9]]]
          
          aux=(strsplit(file_LST[i],'_', /extract));dates(i)=long(strmid(file_Fvg[i],10,7, /REVERSE_OFFSET))
          dates(i)= long(date2YYYYDOY(aux[1]))
          ;dates(i)= fix(date2YYYYDOY(aux[1]) - year*1000)
          
          
          col=Px[0,j]
          fil=Px[1,j]
          ;Px_serie(*,i)=transpose(mean(mean(AA[col-1:col+1,fil-1:fil+1,*],dimension=1,/nan),dimension=1))
          Px_serie(i)=AA[col,fil];transpose(mean(mean(AA[col,fil,*],dimension=1,/nan),dimension=1))
          ;        if dates(i) eq 302 then begin
          ;          print, (AA[col-1:col+1,fil-1:fil+1,*])
          ;        endif
          ;        date = (strmid(file_Fvg[i],13,10, /REVERSE_OFFSET))
          ;        printf, 1, date, transpose(AA[Px[0,j],Px[1,j],*]), format=fmt2
          
          laraja=0
        endfor
        ;      close,1
        
        header=['Sensor', 'DOY','LST','Tv','Ts','Fvg','Ks','Kr','Kcb','Ke','Zona']
        header=['DOY','NDVI']
        path_out = outdir + 'Variables_' + YR + '_P' + string(strcompress(j+1,/remove_all)) + '.csv'
        path_out = outdir + 'Variables_P' + string(strcompress(j+1,/remove_all)) + '.csv'
        write_csv, path_out, [transpose(dates),transpose(Px_serie)],header=header
        close, /all
      endfor
    endfor
    
  endfor ; pp -->fv=[]^pp
  
  print, 'soy la raja'
  
end
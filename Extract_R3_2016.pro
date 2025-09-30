pro Extract_R3_2016
  close,/all
  
  pat='D:\CESBIO\Maroc\Spatial\Landsat\'
  cd,pat  
  met = ['Stefan' ,'Regresion' , 'Regresion_dev','Regresion_dev0.5']
  
  for pp=1,1 do begin  ;fv=[()/()]^pp
    for mm=0, (n_elements(met)-1) do begin
    
      outdir = 'Results\Fvg'+string(strcompress(pp,/remove_all)) + '\' + met[mm] + '\'
      
  for year=2016,2016 do begin
    file_LST = file_search('LST-R3\' + string(strcompress(year,/remove_all)) + '\*' + '\*tst.tif')
    file_Tv = file_search(outdir + 'TvTs\Tv_' + string(strcompress(year,/remove_all)) + '*.tif')
    file_Ts = file_search(outdir + 'TvTs\Ts_' + string(strcompress(year,/remove_all)) + '*.tif')
    file_Fvg = file_search('Results\Fvg'+string(strcompress(pp,/remove_all))+'\Fvg\Fvg_' +string(strcompress(year,/remove_all))+ '*.tif')
    file_Ks = file_search(outdir + 'KsKr\Ks_' + string(strcompress(year,/remove_all)) + '*.tif')
    file_Kr = file_search(outdir + 'KsKr\Kr_' + string(strcompress(year,/remove_all)) + '*.tif')
    file_Zona = file_search(outdir + 'TvTs\Zona_LST-Fv_' + string(strcompress(year,/remove_all)) + '*.tif')
    file_Kcb = file_search(outdir + 'KcbKe_fv\Kcb_' + string(strcompress(year,/remove_all)) + '*.tif')
    file_Ke = file_search(outdir + 'KcbKe_fv\Ke_' + string(strcompress(year,/remove_all)) + '*.tif')
    
;    fmt1="(a13, 6a8, a5)"
;    fmt2="(a13, 3f8.2, 3f8.3, I5)"

    Px = [[180,338],[192,284]]-1  ;Ble [gravitaire,GaG]
    
    DOY=make_array(n_elements(file_LST),/integer)
    for i=0,n_elements(file_LST)-1 do begin
      DOY[i]=fix(strmid(file_LST[i],18,3, /REVERSE_OFFSET))
    end
    sort=sort(DOY)
      
    for j=0, (n_elements(Px)/2-1) do begin
;      openw, 1, 'Variables_L8_reg_' + string(strcompress(year,/remove_all)) + '_P' + string(strcompress(j,/remove_all)) + '.csv'
;      printf, 1,'Date','LST','Tv','Ts','Fvg','Ks','Kr','Zona', format=fmt1
      
      dates=make_array(n_elements(file_LST),/integer)
      sensor=make_array(n_elements(file_LST),/integer)
      Px_serie= make_array([9,n_elements(file_LST)],/float)
      
      for i=0, n_elements(file_LST)-1 do begin
        A1=read_tiff(file_LST[sort[i]])
        A2=read_tiff(file_Tv[i])
        A3=read_tiff(file_Ts[i])
        A4=read_tiff(file_Fvg[i])
        A5=read_tiff(file_Ks[i])
        A6=read_tiff(file_Kr[i])
        A7=read_tiff(file_Kcb[i])
        A8=read_tiff(file_Ke[i])
        A9=read_tiff(file_Zona[i])
        ss=size(A2)
        A1 = (A1[0:ss[1]-1, *])/100.
        AA = [[[A1]], [[A2]], [[A3]], [[A4]], [[A5]], [[A6]], [[A7]], [[A8]], [[A9]]]
        
        dates(i)=(strmid(file_Fvg[i],6,3, /REVERSE_OFFSET));dates(i)=long(strmid(file_Fvg[i],10,7, /REVERSE_OFFSET))
        sensor(i) = strmid(file_basename(file_LST[sort[i]]),2,1)
        col=Px[0,j]
        fil=Px[1,j]
        Px_serie(*,i)=transpose(mean(mean(AA[col-1:col+1,fil-1:fil+1,*],dimension=1,/nan),dimension=1))
;        if dates(i) eq 302 then begin
;          print, (AA[col-1:col+1,fil-1:fil+1,*])
;        endif
;        date = (strmid(file_Fvg[i],13,10, /REVERSE_OFFSET))       
;        printf, 1, date, transpose(AA[Px[0,j],Px[1,j],*]), format=fmt2
        
        laraja=0
      endfor
;      close,1
    
    header=['Sensor', 'DOY','LST','Tv','Ts','Fvg','Ks','Kr','Kcb','Ke','Zona']
    path_out = outdir + 'Variables_' + string(strcompress(year,/remove_all)) + '_P' + string(strcompress(j+1,/remove_all)) + '_cloud.csv'
    write_csv, path_out, [transpose(sensor),transpose(dates),Px_serie],header=header
    close, /all
    endfor
  endfor

     endfor ; mm --> metodos de Tends
endfor ; pp -->fv=[]^pp

  print, 'soy la raja'
  
end
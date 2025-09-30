pro Extract_Foradada
  close,/all
  
  pat='D:\CESBIO\IsardSAT\L8\'
  cd,pat
  met = ['Stefan' ,'Regresion' , 'Regresion_dev','Regresion_dev0.5']
    dims = 150
    xy_ini = [230,20]
    xy_fin = [230,20] + dims - 1
    
for mm=0, (n_elements(met)-1) do begin
  outdir = 'Results_15x15km\' + met[mm] + '\'

  for year=2015,2016 do begin
    file_LST = file_search('LST\LST_' +string(strcompress(year,/remove_all))+ '*_SC_eAST.tif')
    file_Tv = file_search(outdir + 'TvTs\Tv_' + string(strcompress(year,/remove_all)) + '*.tif')
    file_Ts = file_search(outdir + 'TvTs\Ts_' + string(strcompress(year,/remove_all)) + '*.tif')
    file_Fvg = file_search('Results_15x15km\Fvg\Fvg_' +string(strcompress(year,/remove_all))+ '*.tif')
    file_Ks = file_search(outdir + 'KsKr\Ks_' + string(strcompress(year,/remove_all)) + '*.tif')
    file_Kr = file_search(outdir + 'KsKr\Kr_' + string(strcompress(year,/remove_all)) + '*.tif')
    file_Zona = file_search(outdir + 'TvTs\Zona_LST-Fv_' + string(strcompress(year,/remove_all)) + '*.tif')

    fmt1="(a12, ',', 6(a8, :, ', '),a5)"
    fmt2="(a12, ',', 3(f8.2, :, ', '), 3(f8.3, :, ', '), I5)"

;    Px = [[287,46],[290,47],[286,45],[288,47],[288,48]]-1
     Px = [[349,140],[286,45],[287,46],[288,47],[288,48]]-1  ;[Agramunt,P1,P2,P3,P4] comunicacion Mireia
       Px[0,*] =   Px[0,*] - 230   ;-[230,20]
       Px[1,*] =   Px[1,*] - 20
       
    for j=0, (n_elements(Px)/2-1) do begin
      openw, 1, outdir + 'Variables_L8_' + string(strcompress(year,/remove_all)) + '_P' + string(strcompress(j,/remove_all)) + '.csv'
      printf, 1,'Date','LST','Tv','Ts','Fvg','Ks','Kr','Zona', format=fmt1
      
      dates=make_array(n_elements(file_LST),/string)
      Px_serie= make_array([7,n_elements(file_LST)],/float)
      
      for i=0, n_elements(file_LST)-1 do begin
        A1=read_tiff(file_LST[i])
          A1 = A1[xy_ini[0]: xy_fin[0] , xy_ini[1]: xy_fin[1]]
        A2=read_tiff(file_Tv[i])
        A3=read_tiff(file_Ts[i])
        A4=read_tiff(file_Fvg[i])
        A5=read_tiff(file_Ks[i])
        A6=read_tiff(file_Kr[i])
        A7=read_tiff(file_Zona[i])
        AA = [[[A1]], [[A2]], [[A3]], [[A4]], [[A5]], [[A6]], [[A7]]]
        
;        dates(i)=(strmid(file_Fvg[i],13,10, /REVERSE_OFFSET))
;        Px_serie(*,i)=transpose(AA[Px[0,j],Px[1,j],*,*])
        
        date = (strmid(file_Fvg[i],13,10, /REVERSE_OFFSET))       
        printf, 1, date, transpose(AA[Px[0,j],Px[1,j],*]), format=fmt2
        
        laraja=0
      endfor
      close,1
;      header=['Date','LST','Tv','Ts','Fvg','Ks','Kr','Zona']
;      path_out= outdir + 'Variables_L8_' + string(strcompress(year,/remove_all)) + '_P' + string(strcompress(j,/remove_all)) + '.csv'
;      write_csv, path_out, [transpose(dates),Px_serie],header=header
    endfor

    close, /all
  endfor
endfor
   
  print, 'soy la raja'
  
end
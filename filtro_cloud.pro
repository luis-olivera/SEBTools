pro filtro_cloud
close,/all

Nv = 6 ;Nro vecinos cercanos a aumentar clasif de nubes
Nv_ = 3 ;Nro vecinos cercanos a aumentar clasif de nubes en QA band L7/L8
dir='D:\CESBIO\Maroc\Spatial\Landsat\'
cd,dir
pat='LST-R3\2016\'
outdir = pat + 'L7mask_cloud\'
Tseuil = 285 ;LST< --> cloud

sesor = ['LE7','LC8']
for s=0,1 do begin
  for year=2016,2016 do begin
  
    file_LST = file_search(pat + sesor[s] + '*' + '\*tst.tif');  file_search('LST\LST_' +string(strcompress(year,/remove_all))+ '*_SC_eAST.tif')
    file_NDVI = file_search(pat + sesor[s] + '*' + '\*ndvi.tif'); file_search('NDVI\NDVI_' +string(strcompress(year,/remove_all))+ '*.tif')
    if sesor[s] eq 'LE7' then $ 
      file_QA = file_search(pat + sesor[s] + '*' + '\*Mask.tif') $
    else $
      file_QA = file_search(pat + sesor[s] + '*' + '\*BQA.tif');(pat + 'LE7*' + '\*Mask.tif');
    
    file_B4=file_search(pat + sesor[s] + '*' + '\*_B3.tif')
    file_B5=file_search(pat + sesor[s] + '*' + '\*_B4.tif')
    nfile=n_elements(file_B4)
    
    
    
    for i=0,nfile-1 do begin
      mask = read_tiff(file_QA[i], geotiff=g_tags)
      ss=size(mask)
      ss=ss[1:2]
      b4=float(read_tiff(file_B4[i]))/100
      b5=float(read_tiff(file_B5[i]))/100
      b10=read_tiff(file_LST[i], geotiff=gtag)
      b10 = b10/100.
      b10[where(b10 lt 273)]=!values.F_NAN
      b4[where(b4 eq 0)]=!values.F_NAN
      b5[where(b5 eq 0)]=!values.F_NAN
      ;    b4 = CONGRID(b4, 730, 540, /CENTER, CUBIC=-0.5)
      ;    b5 = CONGRID(b5, 730, 540, /CENTER, CUBIC=-0.5)
      
      ;DATE = (strmid(file_B4[i],13,10, /REVERSE_OFFSET))
      
      ;    nsvi=make_array(dims,/float,/nozero)
      ;    b56=make_array(dims,/float,/nozero)
      ;    ratio43=b5/b4
      ;    ratio42=make_array(dims,/float,/nozero)
      ;    ratio45=make_array(dims,/float,/nozero)
      
      ;nieve
      ;    b3=ref[2,*,*]; Filtro1
      ;    b6=ref[5,*,*]; Filtro3
      ;    nsvi=(ref[1,*,*]-ref[4,*,*])/(ref[1,*,*]+ref[4,*,*]) ;filtro 2
      ;    b56=(1-ref[4,*,*])/b6  ;filtro4
      ratio43=b5/b4 ;filtro5
      ;    ratio42=ref[3,*,*]/ref[1,*,*] ;filtro6
      ;    ratio45=ref[3,*,*]/ref[4,*,*] ;filtro7
      ;    print,'a1'
      cloud=(b4 gt 0.3)*(b10 lt Tseuil)*(ratio43 lt 2.0);*(nsvi gt -0.25)*(nsvi lt 0.7)*(b56 lt 225)*(ratio42 lt 2.16248)*(ratio45 gt 1)
      ;    cloud=(b3 gt 0.08)*(nsvi gt -0.25)*(nsvi lt 0.7)*(b6 lt 300)*(b56 lt 225)*(ratio43 lt 2.35)*(ratio42 lt 2.16248)*(ratio45 gt 1)
      
      ;; Agrandar Nubes destectadas en este CODE (cloud)
      Clase2 = make_array(ss,/byte)
      For col=Nv, (ss[0]-Nv-1) do begin
        For fil=Nv, (ss[1]-Nv-1) do begin
          If cloud[col,fil] eq 1 then Clase2[col-Nv:col+Nv, fil-Nv:fil+Nv] = 1
        Endfor
      Endfor
      
     ;; Agrandar Nubes destectadas por SENSOR (mask)
      if sesor[s] eq 'LE7' then $
        Clase = (mask eq 8) AND (finite(b10) eq 1) $
      else $
        Clase = (mask gt 23000)
        
      Clase3 = make_array(ss,/byte)
      For col=Nv_, (ss[0]-Nv_-1) do begin
        For fil=Nv_, (ss[1]-Nv_-1) do begin
          If Clase[col,fil] eq 1 then Clase3[col-Nv_:col+Nv_, fil-Nv_:fil+Nv_] = 1
        Endfor
      Endfor
      
      
      if sesor[s] eq 'LE7' then $
        cloud = (cloud eq 1) OR (Clase2 eq 1) OR (Clase3 eq 1) OR (mask ne 0) $
        else $
        cloud = (cloud eq 1) OR (Clase2 eq 1) OR (Clase3 eq 1) OR  (mask gt 23000 or mask eq 0)
          
      ;cloud=(b3 gt 0.08)*(b56 lt 0.0029)*(ratio43 lt 2.8)*(ratio42 Gt 0.9)*(ratio45 gt 0.8)
      ;    print,'a2'
      ;print,size(ref),size(b6)
      filename = strsplit(file_basename(file_QA[i]), '-',/extract)
      filename = [filename[0] + '_cloud_'+ strcompress(Nv_,/remove_all)+'.tif' ]
      write_tiff, outdir + filename,cloud,geotiff=gtag
      ;;    write_tiff,pat+'NSVI_2012.tif',NSVI,/FLOAT,geotiff=gtag
      ;;    write_tiff,pat+'B56_2012.tif',B56,/FLOAT,geotiff=gtag
      ;;    write_tiff,pat+'RATIO42_2012.tif',RATIO42,/FLOAT,geotiff=gtag
      ;    write_tiff,pat+'RATIO43\RATIO43_'+ (strcompress(date,/remove_all)) + '.tif',RATIO43,/FLOAT,geotiff=gtag
      ;;    write_tiff,pat+'RATIO45_2012.tif',RATIO45,/FLOAT,geotiff=gtag
    endfor
  endfor

endfor

print,'fin'

end
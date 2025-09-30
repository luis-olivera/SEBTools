Pro Grow_nVecinos
  ;;Clasifica Imagen y luego clasifica vecinos cercanos
  ;AGRANDA en Nv vecinos en XY las areas detectadas igual a X numero
  ;ej: nubes detectadas en L7 = 8 en _FinalMask.tif
  close, /all
  Nv = 6 ;Nro vecinos cercanos
  umb = 2
  dir='D:\CESBIO\Maroc\Spatial\Landsat\'
  cd,dir
  pat='LST-R3\2016\'
  outdir = pat + 'L7mask_6\'
  file_L7mask = file_search(pat + 'LE7*' + '\*Mask.tif');
  for ii=0,n_elements(file_L7mask)-1 do begin
    IMA = read_tiff(file_L7mask[ii], geotiff=g_tags)
    ;IMA = IMA[0,*,*]
    ss=size(IMA)
    ss=ss[1:2]
    ;umb = 0.1
    Clase = (IMA ge umb)
    pix = where(Clase eq 1)
    ;tvscl, (clase)
    Clase2 = make_array(ss,/byte)
    For i=Nv, (ss[0]-Nv-1) do begin
      For j=Nv, (ss[1]-Nv-1) do begin
        If Clase[i,j] eq 1 then Clase2[i-Nv:i+Nv, j-Nv:j+Nv] = 1
      Endfor
    Endfor
    Clase = (IMA ne 0) OR (Clase2 eq 1);OR (clase eq 1)
    path_out = outdir + file_basename(file_L7mask[ii])
    WRITE_TIFF, path_out, Clase, geotiff=g_tags
    laraja=0
  endfor
  

End
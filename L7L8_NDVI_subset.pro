pro L7L8_NDVI_subset
  ;;NDVI de Sentinel-2 Level2A
  close, /all
  
  
  Landsat = 'L7'
  pat='D:\CESBIO\Labferrer\' + landsat + '\
  var='LST';'NDVI';
  cd,pat
  pat_out = var + '\Raimat\' ;'C:\Data\FONDEF\L8\'
  FILE_MKDIR, pat_out
  Xmap = 291315; 790820; 790827.5534 ; 30N de 31N: 291315 de L8 (L8_clip_maiz1.tif) y usadas en Sentinel2
  Ymap = 4615905; 4618770; 4618767.0330; 30N de 31N: 4615905
  
  if var eq 'NDVI' then RES = 30.
  if var eq 'LST' then RES = 100.
  
  extension = [15*30, 30*30]
  
  ;IMA = read_tiff(file_B4[0], geotiff=g_tags_)
  ;ss = size(IMA)
  DIMS_RES = extension/RES; round([ss[1]*g_tags_.MODELPIXELSCALETAG[0], ss[2]*g_tags_.MODELPIXELSCALETAG[1]] / RES)
  ;product = ['FRE','SRE']
  
  for p=0,1 do begin
    file_B4 = file_search(pat + var + '\*.tif')
    ;file_B8 = file_search(pat + 'LST' + '\*' + product[p] + '_B8.tif')
    
    XY_ini=make_array(2,/integer)
    
    for i=0,n_elements(file_B4)-1 do begin
;      date = strsplit(file_B4[i], '_-',/extract);(meta[20], '=',/extract)
;      date = date[1]
      B_4 = read_tiff(file_B4[i], geotiff=g_tags)
      ss=size(B_4)
      
      XY_ini[0] = round(abs(Xmap - g_tags.MODELTIEPOINTTAG[3]) / g_tags.MODELPIXELSCALETAG[0])
      XY_ini[1] = round(abs(Ymap - g_tags.MODELTIEPOINTTAG[4]) / g_tags.MODELPIXELSCALETAG[1])
      
      g_tags.MODELTIEPOINTTAG[3:4]=[Xmap,Ymap]
      
      ;      BQA = read_tiff(file_BQA[i])
      ;      BQA = float(BQA[XY_ini[0] : XY_ini[0] + DIMS_RES[0]-1, XY_ini[1] : XY_ini[1] + DIMS_RES[1]-1])
      ;      BQA[where(BQA eq 0)]=!VALUES.F_NAN
      ;      path_BQA = pat_out +'BQA\BQA_' + (strcompress(date,/remove_all)) + '.tif'
      ;      WRITE_TIFF, path_BQA, BQA,/short, geotiff=g_tags
      
      B_4 = float(B_4[XY_ini[0] : XY_ini[0] + DIMS_RES[0]-1, XY_ini[1] : XY_ini[1] + DIMS_RES[1]-1])
      B_4[where(B_4 eq 0)]=!VALUES.F_NAN
;      B_8 = read_tiff(file_B8[i])
;      B_8 = float(B_8[XY_ini[0] : XY_ini[0] + DIMS_RES[0]-1, XY_ini[1] : XY_ini[1] + DIMS_RES[1]-1])
;      B_8[where(B_8 eq 0)]=!VALUES.F_NAN
;      
;      NDVI = (B_8 - B_4) / (B_8 + B_4)
      path_NDVI = pat_out + file_basename(file_B4[i])
      WRITE_TIFF, path_NDVI, B_4,/float, geotiff=g_tags
    endfor
    laraja=0
  endfor
end
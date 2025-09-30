Pro ascii2image

  area = 'Yaqui'
  region='Mexico'
  year=2008
  
  ncols=160
  nrows=100
  
  pat='D:\CESBIO\Region\' + region + '\Area\' + area +'\'
  cd,pat
  outdir = 'ASTERimages\'
  FILE_MKDIR, outdir
  IMA=read_tiff('ASTER\formato_tif.tif', geotiff=g_tags)
  IMA=read_tiff('GRIDS\extract_parcel.tif', geotiff=g_tags)
  ;plot_1 = where(IMA eq 1) ;ind para ascii y matriz
  
  file_alb = file_search('ASTER\alpha' + '*.txt')
  file_lst = file_search('ASTER\aster' + '*.txt')
  file_fvg = file_search('ASTER\fc' + '*.txt')
  file_emi = file_search('ASTER\emi' + '*.txt')
  
  year = year + make_array(n_elements(file_alb),/integer)
  
  aux = (strsplit(file_alb, '._', /extract))
  aux = aux.ToArray()
  aux = aux[*,-2]
  year[where(aux eq '30dec')] = 2007
  month_name = strmid(aux, 2,3,/REVERSE_OFFSET)
  day = fix(strmid(aux, 0,2))
  YYYYDOY = daymonth2DOY(day, month_name, year)
  sort = sort([YYYYDOY])
  
  for i=0,n_elements(file_alb)-1 do begin
    date = string(strcompress(YYYYDOY[sort[i]],/remove_all))
    alb = READ_ASCII(file_alb[sort[i]], count= nalb)
    lst = READ_ASCII(file_lst[sort[i]], count= nlst)
    fvg = READ_ASCII(file_fvg[sort[i]], count= nfvg)
    emi = READ_ASCII(file_emi[sort[i]], count= nfvg)
    
    alb=alb.(0)
    lst=lst.(0)
    fvg=fvg.(0)
    emi=emi.(0)
    
    alb = REFORM(alb,ncols,nrows)
    lst = REFORM(lst,ncols,nrows)
    fvg = REFORM(fvg,ncols,nrows)
    emi = REFORM(emi,ncols,nrows)
    write_tiff, outdir + 'alb_' + date + '.tif', alb, /float, geotiff=g_tags
    write_tiff, outdir + 'lst_' + date + '.tif', lst, /float, geotiff=g_tags
    write_tiff, outdir + 'fvg_' + date + '.tif', fvg, /float, geotiff=g_tags
    write_tiff, outdir + 'emi_' + date + '.tif', emi, /float, geotiff=g_tags
    
  endfor

  
end

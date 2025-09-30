Pro Partition_albedo
  
  area = 'Yaqui'
  region='Mexico'
  year=2008
  
  ncols=160
  nrows=100
  xllcorner=599937.60711932
  yllcorner=3011850.9865908
  cellsize=100
  NODATA_value=-9999
  
  pat='D:\CESBIO\Region\' + region + '\Area\' + area +'\'
  cd,pat
   
  file_alb = file_search('ASTER\alpha' + '*.txt')
  file_lst = file_search('ASTER\aster' + '*.txt')
  file_fvg = file_search('ASTER\fc' + '*.txt')
  file_emi = file_search('ASTER\emi' + '*.txt')

  aux = (strsplit(file_alb, '._', /extract))
  aux = aux.ToArray()
  aux = aux[*,-2]
  month_name = strmid(aux, 2,3,/REVERSE_OFFSET)
  day = fix(strmid(aux, 0,2))
  DOY = daymonth2DOY(day, month_name, year)
  sort = sort([DOY])
  
  for i=0,n_elements(file_alb) do begin
    alb = READ_ASCII(file_alb[i], count= nalb)
    lst = READ_ASCII(file_lst[i], count= nlst)
    fvg = READ_ASCII(file_fvg[i], count= nfvg)
    emi = READ_ASCII(file_emi[i], count= nfvg)
    ;print, nx,ny, nz
  
    alb=alb.(0)
    lst=lst.(0)
    fvg=fvg.(0)
    emi=emi.(0)
    ;pix = where(yy le 373.15 and yy gt 273.15)   ;;; 323.15 PARA ROERINK;; sin límite para Perc5
    ;y=yy[pix]
    ;xx=[[a.(0)[pix]],[b.(0)[pix]]]
  end
end
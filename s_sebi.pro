Pro s_sebi

  area = 'Yaqui'
  region='Mexico'
  year=2008
  
  ncols=160
  nrows=100
  NO_value=-9999
  
  cg = 0.32        ;G/Rn del suelo (Fvg=0)
  cg_vg = 0.05     ;// G/Rn de la vegetation (Fvg=1)
  SIGMA = 5.67e-8; // Stefan-Boltzmann ct [W/m^2/K^4]
  
  pat='D:\CESBIO\Region\' + region + '\Area\' + area +'\'
  cd,pat
  outdir = 'Results\SSEBI\Rnsim\'
  FILE_MKDIR, outdir
  IMA=read_tiff('GRIDS\extract_parcel.tif', geotiff=g_tags)
  ;plot_1 = where(IMA eq 1) ;ind para ascii y matriz
  
  manip='METEO'
  Hra_obj = '1130'
  pat_meteo = manip + '\meteo_' + Hra_obj + '.csv'
  
  meteo = read_csv(pat_meteo, count= na);Diames Tair HR Vv Rg
  doy = meteo.FIELD1
  Ta = meteo.FIELD2 + 273.16 ; meteo[1,*] + 273.16 ;[K]
  rha = meteo.FIELD3; meteo[2,*]
  ;ua = meteo.FIELD4; meteo[3,*]
  Rg = meteo.FIELD5; meteo[4,*]
  
  
  file_alb = file_search('ASTERimages\alb' + '*.tif')
  file_lst = file_search('ASTERimages\lst' + '*.tif')
  file_fvg = file_search('ASTERimages\fvg' + '*.tif')
  file_emi = file_search('ASTERimages\emi' + '*.tif')
  

  for i=0,n_elements(file_alb)-1 do begin
    date = strsplit(file_alb[i],'._',/EXTRACT)
    date=date[-2]
    alb = read_tiff(file_alb[i])
    lst = read_tiff(file_lst[i])
    fvg = read_tiff(file_fvg[i])
    emi = read_tiff(file_emi[i])
    
    coef_min_max = Tends_alb_IMA_regresion(LST, alb, /plot_, date=date, outplot=outdir, bin_x=0.01,alb_ENDMBmin=1,alb_ENDMBmax=min(alb))
    coef_maxli = coef_min_max[0,*]
    coef_minli = coef_min_max[1,*]
    
;    Tk = (coef_minli[0] + coef_minli[1]*alb)
;    Ti = (coef_maxli[0] + coef_maxli[1]*alb)
;    EF = (Ti - LST) / (Ti - Tk)
;    EF[where((LST - Ti) gt 0)] = 0.
;    EF[where((LST - Tk) lt 0)] = 1
;    
;    Rn = Rn(LST, alb, emi, ta[i], rg[i], rha[i], SIGMA)
;    cg = 0.05 + (1 - EF)*(0.32 - 0.05)
;    G = Rn*cg
;    
;    ET = EF*(Rn - G)
;    
;    write_tiff, outdir + 'EF_' + date + '_'+Hra_obj+ '.tif', EF, /float, geotiff=g_tags
;    ;write_tiff, outdir + 'Rn_' + date + '_'+Hra_obj+ '.tif', Rn, /float, geotiff=g_tags
;    write_tiff, outdir + 'G_' + date + '_'+Hra_obj+ '.tif', G, /float, geotiff=g_tags
;    write_tiff, outdir + 'ET_' + date + '_'+Hra_obj+ '.tif', ET, /float, geotiff=g_tags
    
    ;;GRAFICAR POLIGONES
;    p = plot_seb1s(alb, fvg, LST, a_s, a_vg, a_vs, Tends_1, Tends_2)
;    p.Save, outdir + 'LST_alb_fvg_' + date + '_'+Hra_obj+'.png', BORDER=10, RESOLUTION=150
;    p.close
    
    
  endfor
  
  
end


function Rn, LST, alb, epsilon, ta, rg, rha, SIGMA
  ;Estimating Net Radiation (W/m2)
  ea = esstar(ta)*rha/100
  Ratm = longwave(ea,ta,SIGMA)
  Rn = ((1. - alb)*rg + epsilon*(Ratm - sigma*(LST^4)))
  return, Rn
end


Function esstar, t
  ;Estimating saturation vapor pressure (Pa)
  esout = 611*exp(17.3*(t-273.15)/(t+237.3-273.15)); en Pa */
  return, esout
end

Function longwave, ea, ta, SIGMA
  ;Estimating longwave radiation (W/m2) as in Brutsaert, 1975
  epsa = 1.24*(ea/(100*ta))^0.143 ;-->ea:[Pa] ta:[K];   0.553*(ea/100)^0.143;   --> ea:[Pa]
  ldown = epsa*SIGMA*(ta^4); = 1.24*(ea/ta)^0.143 * ta^4. * SB
  return, ldown
end
Pro seb1s

  area = 'Yaqui'
  region='Mexico'
  ;year=2008
  
  ncols=160
  nrows=100
  NO_value=-9999
  
  cg_s = 0.32        ;G/Rn del suelo (Fvg=0)
  cg_vg = 0.05     ;// G/Rn de la vegetation (Fvg=1)
  SIGMA = 5.67e-8; // Stefan-Boltzmann ct [W/m^2/K^4]
  
  Fvg_ENDMBmin=0.5
  Fvg_ENDMBmax=0.5
  a_vg = 0.19
  a_vs = 0.39
  
  submet = ['WDI','SSEBI_OM']
  lstcor = ['', 'cor']; 
  combine = ['_comb', '']; //Combinar LST-alb / LST-fvg para Tends usados en modelos WDI y SSEBI
  
  pat='D:\CESBIO\Region\' + region + '\Area\' + area +'\'
  cd,pat
  
  
  ;;//Methods and variables to simulate T_endmembers
  EB='EBsolveg\';'EBsolveg\TvminTa\';''
  rss_met=['','_rss','_s92inf']     ;Soil resistance:[Sellers92, 0-infinite, S92-infinite]
  Cg_met='';'_cgOM13';             ;metodo de G/Rn en funcion de fv o EF (Merlin13)
  
  ;;//Image-based method to simulate T_endmembers
  met_Tends_image = ['Regresion','Regresion_dev0.5','Stefan']
  
  
  for ee=0,(n_elements(EB)-1) do begin
    for mm=0,(n_elements(met_Tends_image)-1) do begin
    for rr=0,(n_elements(rss_met)-1) do begin;rss
            
    path_EB = EB + 'Tends' + rss_met[rr] + '\' + met_Tends_image[mm] + Cg_met + '\'

    for ll=0,(n_elements(lstcor)-1) do begin 
    for cc=0,(n_elements(combine)-1) do begin
      
      
    ;Fvg_ENDMBmin,max=0.5 or Fvg_ENDMBmin=mean(Fvg)
    if KEYWORD_SET(Fvg_ENDMBmin) then begin
      outdir = 'Results\' + path_EB + 'SEB1S' + lstcor[ll] + '\Rnsim\Tmin_seuil0.5\';cor
      outdir_iv = 'Results\' + path_EB + 'WDI' + lstcor[ll] + combine[cc] + '\Rnsim\Tmin_seuil0.5\';cor
      outdir_sebiOM = 'Results\' + path_EB + 'SSEBI_OM' + lstcor[ll] + combine[cc] + '\Rnsim\Tmin_seuil0.5\';cor
    endif else begin
      outdir = 'Results\' + path_EB + 'SEB1S' + lstcor[ll] + '\Rnsim\Tmin\'
      outdir_iv = 'Results\' + path_EB + 'WDI' + lstcor[ll] + combine[cc] + '\Rnsim\Tmin\'
      outdir_sebiOM = 'Results\' + path_EB + 'SSEBI_OM' + lstcor[ll] + combine[cc] + '\Rnsim\Tmin\'
    endelse
    
;    ;; a_vg=0.19 si no, mean(albedo_vg at Tmin)=0.18 --> Same results
;    if KEYWORD_SET(a_vg) then outdir = 'Results\SEB1S' + lstcor[ll] + '\Rnsim\Tmin_seuil0.5_OM\';cor
;    if KEYWORD_SET(a_vg) then outdir_iv = 'Results\WDI' + lstcor[ll] + combine[cc] + '\Rnsim\Tmin_seuil0.5_OM\';cor
;    if KEYWORD_SET(a_vg) then outdir_sebiOM = 'Results\SSEBI_OM' + lstcor[ll] + combine[cc] + '\Rnsim\Tmin_seuil0.5_OM\';cor
      
    FILE_MKDIR, outdir, outdir_iv, outdir_sebiOM
    IMA=read_tiff('extract_parcel.tif', geotiff=g_tags)
    ;plot_1 = where(IMA eq 1) ;ind para ascii y matriz
    
    manip='METEO'
    Hra_obj = '1100'
    pat_meteo = manip + '\meteo_' + Hra_obj + '.csv'
    
    meteo = read_csv(pat_meteo, count= na);Diames Tair HR Vv Rg
    doy = meteo.FIELD1
    Ta = meteo.FIELD2 + 273.15 ; meteo[1,*] + 273.16 ;[K]
    rha = meteo.FIELD3; meteo[2,*]
    ;ua = meteo.FIELD4; meteo[3,*]
    Rg = meteo.FIELD5; meteo[4,*]
    
    file_alb = file_search('ASTERimages\alb' + '*.tif')
    file_lst = file_search('ASTERimages\lst' + '*.tif')
    file_fvg = file_search('ASTERimages\fvg' + '*.tif')
    file_emi = file_search('ASTERimages\emi' + '*.tif')
    
    
    if lstcor[ll] eq 'cor' then file_lst = file_search('Results\' + path_EB + 'Cor_alb2_1130\LST\lst' + '*.tif')
    
    as_avg_avs = ALB_endmembers(file_alb, file_LST, NO_value=NO_value)
    if KEYWORD_SET(a_vg) eq 0 then begin
      a_vg = mean(as_avg_avs[1,*]);0.18 Merlin dice: 0.19 
      a_vs = max(as_avg_avs[2,*]);0.39
    endif
    
    
    for i=0,n_elements(file_alb)-1 do begin
      date = strsplit(file_alb[i],'._',/EXTRACT)
      date=date[-2]
      alb = read_tiff(file_alb[i])
      lst = read_tiff(file_lst[i])
      fvg = read_tiff(file_fvg[i])
      emi = read_tiff(file_emi[i])
      
      a_s = as_avg_avs[0,i]      ;a_s2 = mean(as_avg_avs[3,*]) ;alb[LSTmax]
      
      if KEYWORD_SET(Fvg_ENDMBmin) then begin
        Tends_fv = Tends_Fvg_IMA(LST, fvg,Fvg_ENDMBmin=Fvg_ENDMBmin,Fvg_ENDMBmax=Fvg_ENDMBmax);, Tair=Tair
        Tends_alb = Tends_alb_IMA(LST, fvg, alb, a_s, a_vg, a_vs, Fvg_ENDMBmin=Fvg_ENDMBmin)
      endif else begin
        Tends_fv = Tends_Fvg_IMA(LST, fvg);, Tair=Tair
        Tends_alb = Tends_alb_IMA(LST, fvg, alb, a_s, a_vg, a_vs)
      endelse
      
      Tends = mean([[Tends_alb],[Tends_fv]],dimension=2)
      
      EF = EF_seb1s(LST, alb, a_s, a_vg, a_vs, Tends[0],Tends[1], Tends[2],Tends[3])
      
      Rn = Rn(LST + 273.15, alb, emi, ta[i], rg[i], rha[i], SIGMA)
      cg = cg_vg + (1 - fvg)*(cg_s - cg_vg)
      cg_ef = cg_vg + (1 - EF)*(cg_s - cg_vg)
      
      G = Rn*cg
      G_ef = Rn*cg_ef
      
      ET = EF*(Rn - G)
      H = (1 - EF)*(Rn - G)
      
      ET_gef = EF*(Rn - G_ef)
      H_gef = (1 - EF)*(Rn - G_ef)
      
      write_tiff, outdir + 'EF_' + date + '_'+Hra_obj+ '.tif', EF, /float, geotiff=g_tags
      write_tiff, outdir + 'Rn_' + date + '_'+Hra_obj+ '.tif', Rn, /float, geotiff=g_tags
      write_tiff, outdir + 'G_' + date + '_'+Hra_obj+ '.tif', G, /float, geotiff=g_tags
      write_tiff, outdir + 'LE_' + date + '_'+Hra_obj+ '.tif', ET, /float, geotiff=g_tags
      write_tiff, outdir + 'H_' + date + '_'+Hra_obj+ '.tif', H, /float, geotiff=g_tags
      
  
      write_tiff, outdir + 'G_ef_' + date + '_'+Hra_obj+ '.tif', G_ef, /float, geotiff=g_tags
      write_tiff, outdir + 'LE_gef_' + date + '_'+Hra_obj+ '.tif', ET_gef, /float, geotiff=g_tags
      write_tiff, outdir + 'H_gef_' + date + '_'+Hra_obj+ '.tif', H_gef, /float, geotiff=g_tags
      
      ;;GRAFICAR POLIGONES
  ;    p = plot_seb1s(alb, fvg, LST, a_s, a_vg, a_vs, Tends_alb, Tends_fv) 
  ;    p.Save, outdir + 'LST_alb_fvg_' + date + '_'+Hra_obj+'.png', BORDER=10, RESOLUTION=150
  ;    p.close
      
      
      for j=0,1 do begin
        if submet[j] eq 'WDI' then begin
          if combine[cc] eq '' then TDVI = f_tvdi(Fvg, LST, Tends_fv) $
            else TDVI = f_tvdi(Fvg, LST, Tends)
          EF = 1 - TDVI
          outdir_sub = outdir_iv
        endif else begin
          if combine[cc] eq '' then EF = f_ef_ssebi(alb, LST, Tends_alb, a_s, a_vg, a_vs) $
            else EF = f_ef_ssebi(alb, LST, Tends, a_s, a_vg, a_vs)
          outdir_sub = outdir_sebiOM
        endelse
  
        ET = EF*(Rn - G)
        H = (1 - EF)*(Rn - G)
          ET_gef = EF*(Rn - G_ef)
          H_gef = (1 - EF)*(Rn - G_ef)
        
        write_tiff, outdir_sub + 'Rn_' + date + '_'+Hra_obj+ '.tif', Rn, /float, geotiff=g_tags
        write_tiff, outdir_sub + 'G_' + date + '_'+Hra_obj+ '.tif', G, /float, geotiff=g_tags
        write_tiff, outdir_sub + 'EF_' + date + '_'+Hra_obj+ '.tif', EF, /float, geotiff=g_tags
        write_tiff, outdir_sub + 'LE_' + date + '_'+Hra_obj+ '.tif', ET, /float, geotiff=g_tags
        write_tiff, outdir_sub + 'H_' + date + '_'+Hra_obj+ '.tif', H, /float, geotiff=g_tags
          write_tiff, outdir_sub + 'G_ef_' + date + '_'+Hra_obj+ '.tif', G_ef, /float, geotiff=g_tags
          write_tiff, outdir_sub + 'LE_gef_' + date + '_'+Hra_obj+ '.tif', ET_gef, /float, geotiff=g_tags
          write_tiff, outdir_sub + 'H_gef_' + date + '_'+Hra_obj+ '.tif', H_gef, /float, geotiff=g_tags
      endfor; submet
  
    endfor; image
  
  endfor; lstcor
  endfor; combine
  endfor; rss_met
  endfor; met_Tends_ima
  endfor; EB_method

end



function EF_seb1s, LST, alb, a_s, a_vg, a_vs, Ts_min, Ts_max, Tv_min, Tv_max
  TO = Tv_min - ((a_vg - a_s)/(a_vs - a_vg)) * (Tv_max - Tv_min)      ;[a_s,T0]: Intersection AB-CD (BareSoil-FullCover) in alb-LST
  ;;Slopes in alb-LST
  a_OJ = (LST - TO)/(alb - a_s)                                       ;[alb,LST] -> J
  a_BC = (Tv_min - Ts_min)/(a_vg - a_s)                               ;BC: "Wet surface"
  a_AD = (Tv_max - Ts_max)/(a_vs - a_s)                               ;AD: "Dry surface"
  ;;Point that cross the wet edge at K (ak , Tk)
  ak = a_s + (Ts_min - TO)/(a_OJ - a_BC)
  Tk = Ts_min + a_BC*(aK - a_s)
  ;;Point that cross the dry edge at I (ai , Ti)
  ai = a_s + (Ts_max - TO)/(a_OJ - a_AD)
  Ti = Ts_max + a_AD*(ai - a_s)
  ;;EF
  EF = ( ((alb - ai)^2 + (LST - Ti)^2) / ((ak - ai)^2 + (Tk - Ti)^2) )^0.5
  EF[where((LST - Ti) gt 0)] = 0.
  EF[where((LST - Tk) lt 0)] = 1
  
  return, EF
end


function f_tvdi, Fvg, LST, Tend_reg
  ;;CONTEXTUAL
  Ts_min = Tend_reg[0]
  Ts_max = Tend_reg[1]
  Tv_min = Tend_reg[2]
  Tv_max = Tend_reg[3]
  Th = Ts_max - (Ts_max - Tv_max)*Fvg ;T en limite AD DRY
  Tj = Ts_min - (Ts_min - Tv_min)*Fvg ;T en limite BC WET
  TVDI = (LST - Tj)/(Th - Tj)
  
  return, TVDI
end

function f_ef_ssebi, alb, LST, Tend_reg, a_s, a_vg, a_vs
  
  slope = (Tend_reg[3] - Tend_reg[1]) / (a_vs - a_s)
  b = Tend_reg[1] - slope*a_s
  coef_maxli = [b, slope]
  
  slope = (Tend_reg[3] - Tend_reg[2]) / (a_vs - a_vg)
  b = Tend_reg[2] - slope*a_vg
  coef_minli = [b, slope]
  
  Tk = (coef_minli[0] + coef_minli[1]*alb)
  Ti = (coef_maxli[0] + coef_maxli[1]*alb)
  EF = (Ti - LST) / (Ti - Tk)
  EF[where((LST - Ti) gt 0)] = 0.
  EF[where((LST - Tk) lt 0)] = 1
  
  return, EF
end


function plot_seb1s, alb, fvg, LST, a_s, a_vg, a_vs, Tends_alb, Tends_fv
  
  Tends = mean([[Tends_alb],[Tends_fv]],dimension=2)
  w = WINDOW(DIMENSIONS=[1200,500])
  P= plot(alb(where(finite(LST))), LST(where(finite(LST))), '*', xrange=[0,0.4], $
    xtitle="Surface Albedo [-]", ytitle="Surface Temperature [°C]", /CURRENT, LAYOUT=[2,1,1])
  p2= plot([a_s, a_vs], [Tends[1], Tends[3]],'r2',/overplot, NAME='Dry edge')
  p3= plot([a_s, a_vg], [Tends[0], Tends[2]],'b2',/overplot, NAME='Wet edge')
  p2= plot([a_s, a_s], [Tends[0], Tends[1]],'k2',/overplot)
  p3= plot([a_vg, a_vs], [Tends[2], Tends[3]],'k2',/overplot)
  
  p2= plot([a_s, a_vs], [Tends_alb[1], Tends_alb[3]],'r2--',/overplot, NAME='Dry edge')
  p3= plot([a_s, a_vg], [Tends_alb[0], Tends_alb[2]],'b2--',/overplot, NAME='Wet edge')
  p2= plot([a_s, a_s], [Tends_alb[0], Tends_alb[1]],'k2--',/overplot)
  p3= plot([a_vg, a_vs], [Tends_alb[2], Tends_alb[3]],'k2--',/overplot)
  ;leg = LEGEND(TARGET=[p2,p3], POSITION=[0.9,0.9])
  
  P_= plot(fvg(where(finite(LST))), LST(where(finite(LST))), '*', xrange=[0,1], $
    xtitle="Fractional green vegetation cover [-]", /CURRENT, LAYOUT=[2,1,2]);, ytitle="Surface Temperature [°C]"
  p2= plot([0, 1], [Tends[1], Tends[3]],'r2',/overplot)
  p3= plot([0, 1], [Tends[0], Tends[2]],'b2',/overplot)
  
  p2= plot([0, 1], [Tends_fv[1], Tends_fv[3]],'r2--',/overplot)
  p3= plot([0, 1], [Tends_fv[0], Tends_fv[2]],'b2--',/overplot)
  
  return, P
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
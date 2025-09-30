Pro Sim_Tveg_max_min_Cg

  close, /all
  outdir = 'D:\CESBIO\Simulation\Tends_cg\'
  FILE_mkdir, outdir
  
  rss = 'S92'   ;'0inf';
  rs = 'M94'
  rs = 'M94x'  ;extremos del medio [100-1000]
  rs = 'M94n'  ;extremos de Moran 1994 [25-1500]
  epsilon = 0.985       ;    // setting a value for the vegetation emissivity
  z0m = 0.1             ;//  roughness length [m]
  h = 0.8               ;// vegetation height
  
  SIGMA = 5.67e-8; // Stefan-Boltzmann ct [W/m^2/K^4]
  cg = 0.05;0.32         ;0.315// G/Rn del suelo (Fvg=0)
  zr = 6;3           ;// height of data acquisition [m]
  Rg =  670           ;mean(Rg[10-14]) en bloc123 R3 2003
  Ta = 293.16 ;[K]    ;mean(Tmin,Tmax)=16 en bloc123 R3 2003
  rha= 60             ;mean(RHmin,RHmax) en bloc123 R3 2003
  ua = 2.5            ;mean(uz) en bloc123 R3 2003
  
  NDVImax = 0.93
  NDVImin = 0.14
  NDVIvs = 0.25
  
  rc_min = 25  ;// Moran 1994
  rc_max = 1500  ;// Moran 1994
  rss_min = exp(3)  ;// RSS Sellers */
  rss_max = exp(8)  ;// RSS Sellers */
  
  if rs eq 'M94x' then begin;// Moran 1994
    rc_min = 100
    rc_max = 1000
  endif
  
  if rss eq '0inf' then begin
    rss_min = 0.;
    rss_max = 10.e7;
  endif
  
  
  h = 0.8               ;// vegetation height
  alpha = indgen(30)/100.+0.1 ;alpbedo_soil = [0.05-0.39]
  Tvmin_eb = make_array(3,n_elements(alpha),/float)
  Tvmax_eb = Tvmin_eb
  
  for aa=0,n_elements(alpha)-1 do begin
    Tvmin_eb[*,aa] = EB_veg_mo_cg( epsilon, alpha[aa], NDVImax, zr, h, rc_min, ta, ua, rg, rha, SIGMA)
    Tvmax_eb[*,aa] = EB_veg_mo_cg( epsilon, alpha[aa], NDVIvs, zr, h, rc_max, ta, ua, rg, rha, SIGMA)
  endfor
  p=plot(alpha,Tvmin_eb[0,*],'b*',xrange=[0,0.4],yrange=[290,310], $
    xtitle="Albedo [-]", ytitle="Temperature [K]", NAME='Tv_min')
  p2= plot(alpha,Tvmax_eb[0,*],'r*',/overplot, NAME='Tv_max'); color=2
  p.Save, outdir + 'Tv-Albedo_MeanMeteoR3_h0.8m_rss_' + rs + '.png', BORDER=10, RESOLUTION=150
  slope_alb =  [(Tvmin_eb[0,-1] - Tvmin_eb[0,0])/(alpha[-1] - alpha[0]) , (Tvmax_eb[0,-1] - Tvmax_eb[0,0]) / (alpha[-1] - alpha[0])]
  
  
  alpha = 0.20
  
  h = indgen(25)/10.+0.1 ;alpbedo_soil = [0.05-0.34]
  Tsmin_eb = make_array(3,n_elements(alpha),/float)
  Tsmax_eb = Tsmin_eb
  for aa=0,n_elements(h)-1 do begin
    Tvmin_eb[*,aa] = EB_veg_mo_cg( epsilon, alpha, NDVImax, zr, h[aa], rc_min, ta, ua, rg, rha, SIGMA)
    Tvmax_eb[*,aa] = EB_veg_mo_cg( epsilon, alpha, NDVIvs, zr, h[aa], rc_max, ta, ua, rg, rha, SIGMA)
  endfor
  p=plot(h,Tvmin_eb[0,*],'b*',xrange=[0,2.5],yrange=[290,310], $
    xtitle="Height vegetation [m]", ytitle="Temperature [K]")
  p2= plot(h,Tvmax_eb[0,*],'r*',/overplot); color=2
  p.Save, outdir + 'Tv-heightVeg_MeanMeteoR3_alb0.2_rss_' + rs + '.png', BORDER=10, RESOLUTION=150
  slope_h =  [(Tvmin_eb[0,-1] - Tvmin_eb[0,0])/(h[-1] - h[0]) , (Tvmax_eb[0,-1] - Tvmax_eb[0,0]) / (h[-1] - h[0])]
  
  
  h = 0.8               ;// vegetation height
  alpha = indgen(35)/100.+0.05 ;alpbedo_soil = [0.05-0.39]
  Tvmin_eb = make_array(3,n_elements(alpha),/float)
  Tvmax_eb = Tvmin_eb
  Tsmin_eb = Tvmin_eb
  Tsmax_eb = Tvmin_eb
  for aa=0,n_elements(alpha)-1 do begin
    Tvmin_eb[*,aa] = EB_veg_mo_cg( epsilon, alpha[aa], NDVImax, zr, h, rc_min, ta, ua, rg, rha, SIGMA)
    Tvmax_eb[*,aa] = EB_veg_mo_cg( epsilon, alpha[aa], NDVIvs, zr, h, rc_max, ta, ua, rg, rha, SIGMA)
    Tsmin_eb[*,aa] = EB_soil_mo_cg( 0.957, alpha[aa], NDVImin, zr, 0.001, rss_min, ta, ua, rg, rha, SIGMA)
    Tsmax_eb[*,aa] = EB_soil_mo_cg( 0.957, alpha[aa], NDVImin, zr, 0.001, rss_max, ta, ua, rg, rha, SIGMA)
  endfor
  p=plot(alpha,Tvmin_eb[0,*],'b*',xrange=[0,0.4],yrange=[290,320], $
    xtitle="Albedo [-]", ytitle="Temperature [K]", NAME='Tv_min')
  p2= plot(alpha,Tvmax_eb[0,*],'r*',/overplot, NAME='Tv_max'); color=2
  p3= plot(alpha,Tsmin_eb[0,*],'bo',/overplot, NAME='Ts_min'); color=2
  p4= plot(alpha,Tsmax_eb[0,*],'ro',/overplot, NAME='Ts_max'); color=2
  
  leg = LEGEND(TARGET=[p,p2,p3,p4], POSITION=[0.11,318],/DATA, /AUTO_TEXT_COLOR,ORIENTATION=1,Shadow=0)
  p.Save, outdir + 'TvTs-Albedo_MeanMeteoR3_h0.8m_rss_' + rss + '_'+ rs + '.png', BORDER=10, RESOLUTION=150
  
  
  ;;PLOT Cg 
  cgs_min = make_array(n_elements(alpha),/float)
  cgs_max = cgs_min
  cgv_max = cgs_min
  cgv_min = cgs_min
  for aa=0,n_elements(alpha)-1 do begin
    cgs_min[aa] = G_Rn(alpha[aa], Tsmin_eb[0,aa], NDVImin)
    cgs_max[aa] = G_Rn(alpha[aa], Tsmax_eb[0,aa], NDVImin)
    cgv_min[aa] = G_Rn(alpha[aa], Tvmin_eb[0,aa], NDVImax)
    cgv_max[aa] = G_Rn(alpha[aa], Tvmax_eb[0,aa], NDVIvs)
  end
  p=plot(alpha,cgv_min,'b*',xrange=[0,0.4],yrange=[0,0.5], $
    xtitle="Albedo [-]", ytitle="G/Rn [-]", NAME='Cg_v_min')
  p2= plot(alpha,cgv_max,'r*',/overplot, NAME='Cg_v_max')
  p3= plot(alpha,cgs_min,'bo',/overplot, NAME='Cg_s_min')
  p4= plot(alpha,cgs_max,'ro',/overplot, NAME='Cg_s_max')
  leg = LEGEND(TARGET=[p,p2,p3,p4], POSITION=[0.4,0.8],ORIENTATION=1,Shadow=0)
  p.Save, outdir + 'Cg-Alb-T_MeanMeteoR3_h0.8m_rss_' + rss + '_'+ rs + '.png', BORDER=10, RESOLUTION=150
  
  
  ;;PLOT Tends-Cg
  h = 0.8               ;// vegetation height
  alpha = 0.20
  cg = indgen(26)/50.   ;cg = [0.0-0.5]
  Tvmin_eb = make_array(3,n_elements(cg),/float)
  Tvmax_eb = Tvmin_eb
  Tsmin_eb = Tvmin_eb
  Tsmax_eb = Tvmin_eb
  for aa=0,n_elements(cg)-1 do begin
    Tvmin_eb[*,aa] = EB_veg_mo( epsilon, alpha, cg[aa], zr, h, rc_min, ta, ua, rg, rha, SIGMA)
    Tvmax_eb[*,aa] = EB_veg_mo( epsilon, alpha, cg[aa], zr, h, rc_max, ta, ua, rg, rha, SIGMA)
    Tsmin_eb[*,aa] = EB_soil_mo( 0.957, alpha, cg[aa], zr, 0.001, rss_min, ta, ua, rg, rha, SIGMA)
    Tsmax_eb[*,aa] = EB_soil_mo( 0.957, alpha, cg[aa], zr, 0.001, rss_max, ta, ua, rg, rha, SIGMA)
  endfor
  p=plot(cg,Tvmin_eb[0,*],'b*',xrange=[0,0.5],yrange=[290,320], $
    xtitle="G/Rn [-]", ytitle="Temperature [K]", NAME='Tv_min')
  p2= plot(cg,Tvmax_eb[0,*],'r*',/overplot, NAME='Tv_max'); color=2
  p3= plot(cg,Tsmin_eb[0,*],'bo',/overplot, NAME='Ts_min'); color=2
  p4= plot(cg,Tsmax_eb[0,*],'ro',/overplot, NAME='Ts_max'); color=2
  leg = LEGEND(TARGET=[p,p2,p3,p4], POSITION=[0.35,0.85], ORIENTATION=1,Shadow=0)
  p.Save, outdir + 'TvTs-Cg_MeanMeteoR3_h0.8m_rss_' + rss + '_'+ rs + '.png', BORDER=10, RESOLUTION=150
  
;  ;;********COMAPARACION CON DERIVADA
;  Ts=mean(Tvmax_eb[0,*])
;  rah = mean(Tvmax_eb[1,*],/nan)
;  Deriv_alb_Ts = der_alb_T(Ts, rah, rc_max, epsilon, Rg, cg)
;  Slope_Tvmax = 1/Deriv_alb_Ts
;  
;  Ts=mean(Tvmin_eb[0,*])
;  rah = mean(Tvmin_eb[1,*],/nan)
;  Deriv_alb_Ts = der_alb_T(Ts, rah, rc_min, epsilon, Rg, cg)
;  Slope_Tvmin = 1/Deriv_alb_Ts
;  
;  DeltaTv = [ Tvmin_eb[0,0] - Tvmin_eb[0,-1], Tvmax_eb[0,0] - Tvmax_eb[0,-1]]
;  print, "Slope Sim Tv_min/Tvmax :", DeltaTv/[alpha[0] - alpha[-1], alpha[0] - alpha[-1]]
;  Tvmin_der = Tvmin_eb[0,0] + Slope_Tvmin*(alpha[-1] - alpha[0])
;  Tvmax_der = Tvmax_eb[0,0] + Slope_Tvmax*(alpha[-1] - alpha[0])
;  print, "Derivada-Simulado: Tvmin", Tvmin_der - Tvmin_eb[0,-1]
;  print, "Derivada-Simulado: Tvmax", Tvmax_der - Tvmax_eb[0,-1]
;  
;  
;  Ts=mean(Tsmax_eb[0,0])
;  rah = mean(Tsmax_eb[1,*],/nan)
;  Deriv_alb_Ts = der_alb_T(Ts, rah, rss_max, 0.957, Rg, 0.32)
;  Slope_Tsmax = 1/Deriv_alb_Ts
;  
;  Ts=mean(Tsmin_eb[0,0])
;  rah = mean(Tsmin_eb[1,*],/nan)
;  Deriv_alb_Ts = der_alb_T(Ts, rah, rss_min, 0.957, Rg, 0.32)
;  Slope_Tsmin = 1/Deriv_alb_Ts
;  
;  DeltaTs = [ Tsmin_eb[0,0] - Tsmin_eb[0,-1], Tsmax_eb[0,0] - Tsmax_eb[0,-1]]
;  print, "Slope Sim Ts_min/Tvmax :",DeltaTs/[alpha[0] - alpha[-1], alpha[0] - alpha[-1]]
;  Tsmin_der = Tsmin_eb[0,0] + Slope_Tsmin*(alpha[-1] - alpha[0])
;  Tsmax_der = Tsmax_eb[0,0] + Slope_Tsmax*(alpha[-1] - alpha[0])
;  print, "Derivada-Simulado: Tsmin", Tsmin_der - Tsmin_eb[0,-1]
;  print, "Derivada-Simulado: Tsmax", Tsmax_der - Tsmax_eb[0,-1]
;  
;  ;//PLOT Tends simulados y derivados
;  p=plot(alpha,Tsmin_eb[0,*],'b*',xrange=[0,0.4],yrange=[290,320], $
;    xtitle="Albedo [-]", ytitle="Temperature [K]", NAME='Tsmin_EB')
;  p2= plot(alpha,Tsmax_eb[0,*],'r*',/overplot, NAME='Tsmax_EB'); color=2
;  p3= plot([alpha[0],alpha[-1]] , [Tsmin_eb[0,0], Tsmin_der ],'b-',/overplot, NAME="Tsmin_deriv"); $\delta
;  p4= plot([alpha[0],alpha[-1]] , [Tsmax_eb[0,0], Tsmax_der ],'r-',/overplot, NAME='Tsmax_deriv'); color=2
;  leg = LEGEND(TARGET=[p,p2,p3,p4], POSITION=[0.89,0.85],Shadow=0);,/DATA,ORIENTATION=1
;  p.Save, outdir + 'Ts-Albedo_MeanMeteoR3_emis0.957_rss_' + rss + '_Sim_Deriv.png', BORDER=10, RESOLUTION=150
;  
;  p=plot(alpha,Tvmin_eb[0,*],'b*',xrange=[0,0.4],yrange=[290,310], $
;    xtitle="Albedo [-]", ytitle="Temperature [K]", NAME='Tvmin_EB')
;  p2= plot(alpha,Tvmax_eb[0,*],'r*',/overplot, NAME='Tvmax_EB'); color=2
;  p3= plot([alpha[0],alpha[-1]] , [Tvmin_eb[0,0], Tvmin_der ],'b-',/overplot, NAME="Tvmin_deriv"); $\delta
;  p4= plot([alpha[0],alpha[-1]] , [Tvmax_eb[0,0], Tvmax_der ],'r-',/overplot, NAME='Tvmax_deriv'); color=2
;  leg = LEGEND(TARGET=[p,p2,p3,p4], POSITION=[0.89,0.85],Shadow=0);,/DATA,ORIENTATION=1
;  p.Save, outdir + 'Tv-Albedo_MeanMeteoR3_h0.8m_rss_' + rs + '_Sim_Deriv.png', BORDER=10, RESOLUTION=150
;  
;  
;  ;;PLOT de Slopes segun Simulaciones
;  for i=0,n_elements(alpha)-2 do begin
;    DeltaTs = [ Tsmin_eb[0,i+1] - Tsmin_eb[0,i], Tsmax_eb[0,i+1] - Tsmax_eb[0,i]]
;    print, "Slope Sim Tsmin/Tsmax (Delta_alb:0.34):",DeltaTs/[alpha[i+1] - alpha[i], alpha[i+1] - alpha[i]]
;    ;  DeltaTv = [ Tvmin_eb[0,i+1] - Tvmin_eb[0,i], Tvmax_eb[0,i+1] - Tvmax_eb[0,i]]
;    ;  print, "Slope Sim Tvmin/Tvmax (Delta_alb:0.34):",DeltaTv/[alpha[i+1] - alpha[i], alpha[i+1] - alpha[i]]
;  endfor
  laraja=0
  
  
  
  
  
end

;Function esstar, t
;  ;/*===========================================
;  ;Estimating saturation vapor pressure (Pa)
;  ;=============================================*/
;  esout = 611*exp(17.27*(t-273.15)/(t+237.3-273.15)); en Pa */
;  return, esout
;end
;
;Function der_alb_T, Ts, rah, rc_min, epsilon, Rg, cg
;  SIGMA = 5.67e-8   ; // Stefan-Boltzmann ct [W/m^2/K^4]
;  RHOCP = 1186.0    ; // rho cp air
;  GAMMA = 67.0      ; // psychrometric ct
;  Deriv_e_Ts = 17.27*237.3*esstar(Ts)/((Ts - 35.85)^2)
;  derivada = - (RHOCP*(1/rah + Deriv_e_Ts/(GAMMA*(rc_min + rah))) + 4*SIGMA*epsilon*(Ts^3)*(1 - cg) ) / (Rg*(1 - cg))
;  ;  derivada_ = - (RHOCP*(1/rah) + 4*SIGMA*epsilon*(Ts^3)*(1 - cg) ) / (Rg*(1 - cg))                                       ;-->LE=0
;  ;  derivada = - (RHOCP*(Deriv_e_Ts/(GAMMA*(rc_min + rah))) + 4*SIGMA*epsilon*(Ts^3)*(1 - cg) ) / (Rg*(1 - cg))            ;-->H=0
;  return, derivada
;end

Function G_Rn, alpha, Ts, NDVI
  ;;Module to estimate Cg
  ;c1 = 0.32*alb + 0.62*alb^2               ;;alb: hemispherical surface reflectance (daytime-representative value)
  c1 = 0.0038*alpha + 0.0074*alpha^2           ;Bastiaanssen 2000
  Factor1 = c1*(Ts-273.16)/alpha
  Factor2 = 1 - 0.978*NDVI^4
  ;Factor2 = 1 - 0.98*NDVI^4               ;Bastiaanssen 2000
  cg = Factor1*Factor2
  return, cg; [cg,c1,Factor1,Factor2]
end
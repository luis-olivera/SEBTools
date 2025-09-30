Pro Sim_Tsoil_max_min

  close, /all
  outdir = 'D:\CESBIO\Simulation\Tends\'
  
  rss = 'S92'   ;'0inf'; 'S92'   ;
  epsilon = 0.957;    0.96;   // setting a value for the emissivity
  z0m = 0.001     ;// soil roughness [m]
  
  SIGMA = 5.67e-8; // Stefan-Boltzmann ct [W/m^2/K^4]
  cg = 0.32         ;0.315// G/Rn del suelo (Fvg=0)
  zr = 6;3           ;// height of data acquisition [m]
  Rg =  670           ;mean(Rg[10-14]) en bloc123 R3 2003
  Ta = 293.16 ;[K]    ;mean(Tmin,Tmax)=16 en bloc123 R3 2003
  rha= 60             ;mean(RHmin,RHmax) en bloc123 R3 2003
  ua = 2.5            ;mean(uz) en bloc123 R3 2003
  
  if rss eq 'S92' then begin
    rss_min = exp(3)  ;// RSS Sellers */
    rss_max = exp(8)  ;// RSS Sellers */
  endif else begin
    rss_min = 0.;
    rss_max = 10.e7;
  endelse
  
  
  alpha = indgen(30)/100.+0.05 ;alpbedo_soil = [0.05-0.34]
  Tsmin_eb = make_array(3,n_elements(alpha),/float)
  Tsmax_eb = Tsmin_eb

  for aa=0,n_elements(alpha)-1 do begin
    Tsmin_eb[*,aa] = EB_soil_mo( epsilon, alpha[aa], cg, zr, z0m, rss_min, ta, ua, rg, rha, SIGMA)
    Tsmax_eb[*,aa] = EB_soil_mo( epsilon, alpha[aa], cg, zr, z0m, rss_max, ta, ua, rg, rha, SIGMA)
  endfor
  p=plot(alpha,Tsmin_eb[0,*],'b*',xrange=[0,0.4],yrange=[290,315], $
    xtitle="Albedo [-]", ytitle="Temperature [K]")
  p2= plot(alpha,Tsmax_eb[0,*],'r*',/overplot); color=2
  p.Save, outdir + 'Ts-Albedo_MeanMeteoR3_emis0.957_rss_' + rss + '.png', BORDER=10, RESOLUTION=150
  laraja=0
  
  alpha = 0.15
  epsilon = indgen(10)/100.+0.9
  Tsmin_eb = make_array(3,n_elements(epsilon),/float)
  Tsmax_eb = Tsmin_eb 
  for aa=0,n_elements(epsilon)-1 do begin
    Tsmin_eb[*,aa] = EB_soil_mo( epsilon[aa], alpha, cg, zr, z0m, rss_min, ta, ua, rg, rha, SIGMA)
    Tsmax_eb[*,aa] = EB_soil_mo( epsilon[aa], alpha, cg, zr, z0m, rss_max, ta, ua, rg, rha, SIGMA)
  endfor
  p=plot(epsilon,Tsmin_eb[0,*],'b*',xrange=[0.9,1],yrange=[290,315], $
    xtitle="Emissivity [-]", ytitle="Temperature [K]")
  p2= plot(epsilon,Tsmax_eb[0,*],'r*',/overplot); color=2)
  p.Save, outdir + 'Ts-emissivity_MeanMeteoR3_alb0.15_rss_' + rss + '.png', BORDER=10, RESOLUTION=150
  
  alpha = 0.15
  epsilon = 0.957
  z0m = (indgen(20)/10000.)*5 + 0.0005
  Tsmin_eb = make_array(3,n_elements(z0m),/float)
  Tsmax_eb = Tsmin_eb
  for aa=0,n_elements(z0m)-1 do begin
    Tsmin_eb[*,aa] = EB_soil_mo( epsilon, alpha, cg, zr, z0m[aa], rss_min, ta, ua, rg, rha, SIGMA)
    Tsmax_eb[*,aa] = EB_soil_mo( epsilon, alpha, cg, zr, z0m[aa], rss_max, ta, ua, rg, rha, SIGMA)
  endfor
  p=plot(z0m,Tsmin_eb[0,*],'b*',xrange=[0,0.01],yrange=[290,315], $
    xtitle="z0m [m]", ytitle="Temperature [K]")
  p2= plot(z0m,Tsmax_eb[0,*],'r*',/overplot); color=2)
  p.Save, outdir + 'Ts-z0m_MeanMeteoR3_alb0.15_rss_' + rss + '.png', BORDER=10, RESOLUTION=150
  
  
  z0m = 0.001
  ta = indgen(30) + 283.16
  Tsmin_eb = make_array(3,n_elements(ta),/float)
  Tsmax_eb = Tsmin_eb
  for aa=0,n_elements(ta)-1 do begin
    Tsmin_eb[*,aa] = EB_soil_mo( epsilon, alpha, cg, zr, z0m, rss_min, ta[aa], ua, rg, rha, SIGMA)
    Tsmax_eb[*,aa] = EB_soil_mo( epsilon, alpha, cg, zr, z0m, rss_max, ta[aa], ua, rg, rha, SIGMA)
  endfor
  p=plot(ta,Tsmin_eb[0,*],'b*',xrange=[280,315],yrange=[280,335], $
    xtitle="Air Temperature [K]", ytitle="Temperature [K]")
  p2= plot(ta,Tsmax_eb[0,*],'r*',/overplot); color=2
  p.Save, outdir + 'Ts-Ta_MeanMeteoR3_alb0.15_emis0.957_rss_' + rss + '.png', BORDER=10, RESOLUTION=150
  laraja=0


end
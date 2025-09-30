pro Tends_EBsoilveg_mo_inst_yaqui
  close, /all
  ;  EB_soil_mo
  RESOLVE_ROUTINE, 'EB_soil_mo', /IS_FUNCTION

  ;RESOLVE_ALL, RESOLVE_FUNCTION='EB_soil_mo';

  ;  color_8
  manip='METEO';'R3_Gravitaire_2015-2016'
  root = 'D:\CESBIO\Region\Mexico\Area\Yaqui\'
  path = root +  'Results' + '\'; + manip + '\'
  Hra_obj = '1130'
  pat_meteo = root + manip + '\meteo_' + Hra_obj + '.csv'
  
  
  ;;//Ctes --> EB
  EB='EBsolveg\';'EBsolveg\TvminTa\';''
  rss_met=['','_rss','_s92inf']
  Cg_met=['','_cgOM13']       ;metodo de G/Rn en funcion de fv o EF (Merlin13)

  alpha_veg = [0.2,  0.3]
  h = 0.8                   ;// vegetation height --> z0m_veg = 0.1
  alpha_sol = [0.1,  0.3]   ;0.2;       // set a constant value for the albedo ->VARIA/escena
  epsilon = 0.96            ;// setting a value for the emissivity
  z0m = [0.001, 0.0005]     ;// soil roughness [m]: roughness length for momentum transfer: donde el viento desaparece (z0m+d)
  cg = 0.32         ;0.315// G/Rn del suelo (Fvg=0)
  cg_vg = 0.05           ;// G/Rn de la vegetation (Fvg=1)
  SIGMA = 5.67e-8; // Stefan-Boltzmann ct [W/m^2/K^4]
  
  zr = 10.0           ;// height of data acquisition [m]
  ;  epsilon_s = 0.957; 0.975
  ;  epsilon_v = 0.99


  for cc=1,1 do begin
    if cg_met[cc] eq '' then begin
      ;G/Rn del suelo segun f(fvg)
      cg_smin = cg         ;(fvg=0)
      cg_smax = cg
      cg_vmin = cg_vg      ;(fvg=1)
      cg_vmax = cg_vg
    endif else begin 
      ;G/Rn del suelo segun Merlin 2013 (SEB-1S) y f(EF)
      cg_smin = cg_vg         ;(EF=1)
      cg_vmin = cg_vg
      cg_smax = cg           ;(EF=0)
      cg_vmax = cg
    endelse
    
    for rr=0,(n_elements(rss_met)-1) do begin;rss_met
    
      ;meteo = read_ascii(pat_meteo);Diames Tair HR Vv Rg
      meteo = read_csv(pat_meteo, count= na);Diames Tair HR Vv Rg
      doy=meteo.FIELD1
      Ta = meteo.FIELD2 + 273.16 ; meteo[1,*] + 273.16 ;[K]
      rha = meteo.FIELD3; meteo[2,*]
      ua = meteo.FIELD4; meteo[3,*]
      Rg = meteo.FIELD5; meteo[4,*]
      
      if size(doy,/type) eq 7 then begin
        doy = date2YYYYDOY(doy,delimiter='-', format='DDMMYYYY' )
        ;doy = doy - 1000*(doy/1000)
      endif
      
      
      for aa=0,n_elements(alpha_sol)-1 do begin;alpha_sol
        for zz=0,0 do begin;z0m
        
          outdir = path + EB + 'Tends'+  rss_met[rr] + '\' + 'alb' + string(alpha_sol[aa], FORMAT='(F0.2)') + $
            '_emis' + string(epsilon, FORMAT='(F0.3)') + '_z0m' +  string(z0m[zz], FORMAT='(F0.4)') + '_albvg' + $
            string(alpha_veg[aa], FORMAT='(F0.2)') + cg_met[cc] + '\'
          FILE_MKDIR, outdir
          ;FILE_MKDIR, root + manip + '\Meteo\
          
          if rss_met[rr] eq '_rss' then begin
            rss_min = 0.;
            rss_max = 10.e7;
          endif else begin
            rss_min = exp(3)  ;   // RSS Sellers */
            if rss_met[rr] eq '_s92inf' then $
              rss_max = 10.e7 $
            else rss_max = exp(8)  ;   // RSS Sellers */
          endelse
          
          
          for k=0, n_elements(Hra_obj)-1 do begin
            path_out= outdir + '\Tends_EB_mo_' + string(Hra_obj[k], FORMAT='(I04)') + '.txt'
            
            openw, 1, path_out
            
            
            For i=0, na-1 do begin
            
              Tsmin_eb = EB_soil_mo( epsilon, alpha_sol[aa], cg_smin, zr, z0m[zz], rss_min, ta[i], ua[i], rg[i], rha[i], SIGMA)
              Tsmax_eb = EB_soil_mo( epsilon, alpha_sol[aa], cg_smax, zr, z0m[zz], rss_max, ta[i], ua[i], rg[i], rha[i], SIGMA)
              stab_min = Tsmin_eb[2]
              stab_max = Tsmax_eb[2]
              Tsmin_eb = Tsmin_eb[0]
              Tsmax_eb = Tsmax_eb[0]
              if EB eq 'EBsolveg\' OR EB eq 'EBsolveg\TvminTa\' then begin
                Tvmax_eb = EB_veg_mo(epsilon, alpha_veg[aa], cg_vmax, zr,h, 1500, ta[i], ua[i], rg[i], rha[i], SIGMA)
                stab_max_v = Tvmax_eb[2]
                Tvmax_eb = Tvmax_eb[0]
                if EB eq 'EBsolveg\TvminTa\' then begin
                  Tvmin_eb = ta[i]
                  stab_min_v = 0
                endif else begin
                  Tvmin_eb = EB_veg_mo( 0.985, alpha_veg[aa], cg_vmin, zr, h, 25, ta[i], ua[i], rg[i], rha[i], SIGMA)
                  stab_min_v = Tvmin_eb[2]
                  Tvmin_eb = Tvmin_eb[0]
                endelse
              endif; else begin
              ;                Tvmax_eb = Tsmax_eb - (Tsmin_eb-Tvmin_eb);
              ;                Tvmin_eb = ta[i];
              ;              endelse
              
              
              printf, 1, doy[i], Tsmin_eb, Tsmax_eb, Tvmin_eb, Tvmax_eb, $
                stab_min, stab_max_v, stab_min_v, stab_max, format='(I8, 4f8.2, 4f9.2)'
                
            endfor ;j=doy
            close, /all
          endfor ;k=Hra_obj
          
        endfor;z0m
      endfor;alpha_sol
      
    endfor;rss_met
  endfor;cg_met

  print, 'LISTO'

end
pro Tends_EBsoil_mo_inst_Partition
  close, /all
  ;  EB_soil_mo
  ;  Partition_TsTv
  RESOLVE_ROUTINE, 'EB_soil_mo', /IS_FUNCTION
  ;RESOLVE_ALL, RESOLVE_FUNCTION='EB_soil_mo';,'Partition_TsTv']
  
;  color_8
  root = 'D:\CESBIO\Region\Maroc\Area\R3\Insitu\'
  path = root + 'Results\'
  pat_meteo_day = root + 'Meteo_2003_ble\meteobloc123.txt'
  ;'C:\Maroc\Meteo_flux\Meteo_promedio_2012.txt';'C:\Maroc\Meteo_flux\Meteo_Blé_2012.txt';'C:\Maroc\Meteo_flux\Meteo_Betterave_2012.txt'
  
  ;;//Ctes --> EB
  Tdat=['LSTcor_','']
  rss_met=['','_rss']
  EB='EBsolveg\TvminTa\';'EBsolveg\';''
  partition=['TVDI_fc','2_Zones','TVDIz1z3_v2','TVDIz1z3','','TVDI']
  fv=['fc', 'fvg']      ;//Los dos a partir de NDVI. fc queda cte luego del maximo
  
  hr_i=10
  hr_f=14
  alpha_veg = 0.2
  h = 0.8               ;// vegetation height --> z0m_veg = 0.1
  alpha_min = [0.124,  0.07];    0.2;       // set a constant value for the albedo ->VARIA/escena  
  epsilon = 0.957;    0.96;   // setting a value for the emissivity
  z0m = [0.001, 0.0005]     ;// soil roughness [m]: roughness length for momentum transfer: donde el viento desaparece (z0m+d)
  
  SIGMA = 5.67e-8; // Stefan-Boltzmann ct [W/m^2/K^4]
  cg = 0.32         ;0.315// G/Rn del suelo (Fvg=0)
  zr = 6;3           ;// height of data acquisition [m]
  ;  epsilon_s = 0.957; 0.975
  ;  epsilon_v = 0.99

  ;;METEO --> MEDIAS entre [11-11.5] hrs y Ble-Betterave
  ;;;;DAILY
  meteo_day = read_ascii(pat_meteo_day, count= na);[Date Heure Dua EDUa  Hr  Tair  SW_up SW_dwn  LW_up LW_dwn  LW_Brsrt  LW  Ts  Rg  Ua3 Ua9 Pluie]
  doy_day = meteo_day.FIELD01[1,*]
  RHmin = meteo_day.FIELD01[6,*]
  RHmax = meteo_day.FIELD01[7,*]
  Ta_day = meteo_day.FIELD01[19,*] + 273.16 ;[K]
  Rg_day =  meteo_day.FIELD01[2,*]
  ua_day = meteo_day.FIELD01[8,*]
  LST_day = meteo_day.FIELD01[18,*] + 273.16 ;[K]
  NDVI = meteo_day.FIELD01[12,*]
  rha_day = (RHmin+RHmax)/2
  
  
  for ff=0,1 do begin
  for rr=0,n_elements(rss_met)-1 do begin;rss_met
    
    for tt=0,1 do begin; n_elements(Tdat)-1; Tdat
      
      ;;;;Instantanean
      if Tdat[tt] eq 'LSTcor_' then $
        pat_meteo = root + 'R3_Gravitaire_2002-2003\climat-R3_30min_LSTcor.csv' $ ;LST de Tb apogee
      else $
        pat_meteo = root + 'R3_Gravitaire_2002-2003\climat-R3_30min.csv'         ;Tb medido del apogee (dato bruto)
        
      meteo = read_csv(pat_meteo, count= na_ins, HEADER=HEADER);DOY Heure RG Tair HR Vv Ts-verticale-(2m)
      doy=meteo.FIELD1
      Hr=meteo.FIELD2
      Rg =  meteo.FIELD3
      Ta = meteo.FIELD4 + 273.16 ;[K]
      rha=meteo.FIELD5
      ua = meteo.FIELD6       ;NECESARIO USAR ua a 2 m?????????????
      LST = float(meteo.FIELD7) + 273.16 ;[K]

      for pp=0,0 do begin;n_elements(partition)-1; partition
        for aa=0,n_elements(alpha_min)-1 do begin;alpha_min
         for zz=0,0 do begin;z0m 
          
          path_out = path + EB + 'TvTs_'+  fv[ff] + rss_met[rr] + '\' + partition[pp] + '\' + Tdat[tt] + 'alb' + string(alpha_min[aa], FORMAT='(F0.3)') + $
             '_emis' + string(epsilon, FORMAT='(F0.3)') + '_z0m' +  string(z0m[zz], FORMAT='(F0.4)') + '_albvg' + string(alpha_veg, FORMAT='(F0.2)') +'\'
          FILE_MKDIR, path_out
          
          if rss_met[rr] eq '_rss' then begin
            rss_min = 0.;
            rss_max = 10.e7;
          endif else begin
            rss_min = exp(3)  ;   // RSS Sellers */
            rss_max = exp(8)  ;   // RSS Sellers */
          endelse
          
          ;;//Ctes --> SEB-1S
          NDVImin = 0.14   ;????   0.13     ;;Merlin et al. 2014 = 0.18 ó 0.15 en 2013
          NDVImax = 0.93     ;????   0.88     ;;Merlin et al. 2013 SEB1S = 0.18 - 0.93
          Fveg = (NDVI - NDVImin)/(NDVImax - NDVImin)
          Fvg_ENDMB = 0.5
          Fvg_ENDMBmin = Fvg_ENDMB
          Fvg_ENDMBmax = Fvg_ENDMB
          if fv[ff] eq 'fc' then begin
            xx=where(Fveg eq max(Fveg))
            Fveg(xx:n_elements(Fveg)-1)=max(Fveg)
          endif
          
          
          Hra_obj = (indgen((hr_f - hr_i)*2+1)/2. + hr_i)*100
          Hra_obj[where( Hra_obj MOD 100 eq 50)] = (Hra_obj[where( Hra_obj MOD 100 eq 50)] - 20)
          Hra_obj = fix(Hra_obj)
          ;Hra_obj = [0900,0930,1000,1030,1100,1130,1200,1230,1300,1330,1400];
          
          all = make_array([8+2,na,n_elements(Hra_obj)],/float)
          M = make_array([6,na,n_elements(Hra_obj)],/float)
          
          for k=0, n_elements(Hra_obj)-1 do begin
            path_out= path + EB + 'TvTs_' + fv[ff] + rss_met[rr] + '\' + partition[pp] + '\' + Tdat[tt] + 'alb' + string(alpha_min[aa], FORMAT='(F0.3)') + $
              '_emis' + string(epsilon, FORMAT='(F0.3)') + '_z0m' +  string(z0m[zz], FORMAT='(F0.4)') + '_albvg' + string(alpha_veg, FORMAT='(F0.2)') + $
              '\TsTv_Tends_EB_mo_' +string(Hra_obj[k], FORMAT='(I04)') + '.txt'
              
            path_meteo= root + 'Meteo_2003_ble\meteobloc123_' +string(Hra_obj[k], FORMAT='(I04)') + '.txt'
            openw, 1, path_out
            openw, 2, path_meteo
            
            pix=where(Hr eq Hra_obj[k] , N_inst)
            ;;instantaneo
            
            For j=0, na-1 do begin
              ;;;;;// [Tsmax, Tsmin] --> EB data
              jj = where(doy[pix] eq doy_day[j], nj)
              if nj eq 1 then begin
                i=pix[jj]
                Tsmin_eb = EB_soil_mo( epsilon, alpha_min[aa], cg, zr, z0m[zz], rss_min, ta[i], ua[i], rg[i], rha[i], SIGMA)
                Tsmax_eb = EB_soil_mo( epsilon, alpha_min[aa], cg, zr, z0m[zz], rss_max, ta[i], ua[i], rg[i], rha[i], SIGMA)
                  stab_min = Tsmin_eb[2]
                  stab_max = Tsmax_eb[2]
                Tsmin_eb = Tsmin_eb[0]
                Tsmax_eb = Tsmax_eb[0]
                if EB eq 'EBsolveg\' OR EB eq 'EBsolveg\TvminTa\' then begin        
                  Tvmax_eb = EB_veg_mo(epsilon, alpha_veg, cg, zr,h, 1500, ta[i], ua[i], rg[i], rha[i], SIGMA)
                  Tvmax_eb = Tvmax_eb[0]
                  if EB eq 'EBsolveg\TvminTa\' then begin
                    Tvmin_eb = ta[i]
                  endif else begin
                    Tvmin_eb = EB_veg_mo( 0.985, alpha_veg, cg, zr, h, rss_min, ta[i], ua[i], rg[i], rha[i], SIGMA)
                    Tvmin_eb = Tvmin_eb[0]
                  endelse
                endif else begin
                  Tvmax_eb = Tsmax_eb - (Tsmin_eb-Tvmin_eb);
                  Tvmin_eb = ta[i];
                endelse
                
;                if finite(Tsmin_eb) eq 0 OR finite(Tsmax_eb) eq 0 then begin
;                  a=0
;                endif
                
                if (LST[i] le 273.16 or finite(LST[i]) eq 0) then LST[i]=(Tsmin_eb+Tsmax_eb)/2
;                if i eq 64 then begin
;                  a=0
;                endif
                
                if finite(Tsmin_eb) eq 1 and finite(Tsmax_eb) eq 1 then begin
                  if partition[pp] eq '' then TsTv = Partition_TsTv(LST[i], Fveg[j], Tsmin_eb, Tsmax_eb, Tvmin_eb, Tvmax_eb)
                  if partition[pp] eq 'TVDI_fc' then TsTv = Partition_TsTv_TVDI_fc(LST[i], Fveg[j], Tsmin_eb, Tsmax_eb, Tvmin_eb, Tvmax_eb)
                  if partition[pp] eq '2_Zones' then TsTv = Partition_TsTv_2zones(LST[i], Fveg[j], Tsmin_eb, Tsmax_eb, Tvmin_eb, Tvmax_eb)
                  if partition[pp] eq 'TVDIz1z3' then TsTv = Partition_TsTv_z1z3TVDI(LST[i], Fveg[j], Tsmin_eb, Tsmax_eb, Tvmin_eb, Tvmax_eb)
                  if partition[pp] eq 'TVDIz1z3_v2' then TsTv = Partition_TsTv_z1z3TVDI_v2(LST[i], Fveg[j], Tsmin_eb, Tsmax_eb, Tvmin_eb, Tvmax_eb)
                  if partition[pp] eq 'TVDI' then TsTv = Partition_TsTv_TDVI(LST[i], Fveg[j], Tsmin_eb, Tsmax_eb, Tvmin_eb, Tvmax_eb)
                endif else begin
                  TsTv = [!values.f_nan,!values.f_nan,!values.f_nan]
                endelse
                ;print, [LST[i], Fveg[j],TsTv[2]]
                printf, 1, doy[i], Tsmin_eb, Tsmax_eb, Tvmin_eb, Tvmax_eb, TsTv[0], TsTv[1], TsTv[2], stab_min, stab_max, format='(I5, 6f8.2, f5.0, 2f9.2)'
                printf, 2, doy[i], rg[i], ta[i], ua[i], rha[i],LST[i], format='(I5, 5f8.2)'
                all[*,j,k] = [doy[i], Tsmin_eb, Tsmax_eb, Tvmin_eb, Tvmax_eb, TsTv[0], TsTv[1], TsTv[2], stab_min, stab_max]
                M[*,j,k] = [doy[i], rg[i], ta[i], ua[i], rha[i],LST[i]]
              endif   
            endfor ;j=doy
            close, /all
          endfor ;k=Hra_obj
          
          path_out= path + EB + 'TvTs_' + fv[ff] + rss_met[rr] + '\' + partition[pp] + '\' + Tdat[tt] + 'alb' + string(alpha_min[aa], FORMAT='(F0.3)') + $
            '_emis' + string(epsilon, FORMAT='(F0.3)') + '_z0m' +  string(z0m[zz], FORMAT='(F0.4)')  + '_albvg' + string(alpha_veg, FORMAT='(F0.2)') + $
            '\TsTv_Tends_EB_mo_mean' + string(hr_i, FORMAT='(I02)') + string(hr_f, FORMAT='(I02)') + '.txt'
          path_meteo= root + 'Meteo_2003_ble\meteobloc123_mean' + string(hr_i, FORMAT='(I02)') + string(hr_f, FORMAT='(I02)') + '.txt'
          openw, 1, path_out
          openw, 2, path_meteo
          for j=0, na-1 do begin
            if finite(Min(all[7,j,*],/NAN)) eq 1 then begin
              distfreq = Histogram(all[7,j,*], MIN=Min(all[7,j,*],/NAN),/NAN)
              maxfreq= Max(distfreq)
              mode = max(Where(distfreq EQ maxfreq) + Min(all[7,j,*],/NAN))
            endif else begin
              mode = !values.F_nan
            end           
            printf,1, all[0,j,0], mean(all[1,j,*],/nan),mean(all[2,j,*],/nan),mean(all[3,j,*],/nan),mean(all[4,j,*],/nan),$
              mean(all[5,j,*],/nan),mean(all[6,j,*],/nan),mode, mean(all[8,j,*],/nan),mean(all[9,j,*],/nan), format='(I5, 6f8.2, f5.0, 2f9.2)'
            printf, 2, M[0,j,0], mean(M[1,j,*]),mean(M[2,j,*]),mean(M[3,j,*]),mean(M[4,j,*]),mean(M[5,j,*]), format='(I5, 5f8.2)'            
          endfor
          close,/all
          
        endfor;z0m
        endfor;alpha_min
      endfor;partition
    endfor;rss_met
  endfor;Tdat
  endfor;fv
  
  print, 'LISTO'
  
end


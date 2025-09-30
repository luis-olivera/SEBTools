pro Tends_EBsoil_mo
  close, /all
;  EB_soil_mo
;  Partition_TsTv
  RESOLVE_ROUTINE, 'EB_soil_mo', /IS_FUNCTION
  ;RESOLVE_ALL, RESOLVE_FUNCTION='EB_soil_mo';,'Partition_TsTv']
  
  color_8
  
  path = 'C:\CESBIO\Maroc\Results\'
  pat_meteo_day = 'D:\CESBIO\Maroc\Meteo_2003_ble\meteobloc123.txt';'C:\Maroc\Meteo_flux\Meteo_promedio_2012.txt';'C:\Maroc\Meteo_flux\Meteo_Blé_2012.txt';'C:\Maroc\Meteo_flux\Meteo_Betterave_2012.txt'
  pat_meteo = 'D:\CESBIO\Maroc\R3_Gravitaire_2002-2003\climat-R3_30min.csv'
  
  ;;//Ctes --> EB
  SIGMA = 5.67e-8; // Stefan-Boltzmann ct [W/m^2/K^4]
  epsilon_s = 0.975
  epsilon_v = 0.99
  alpha_min = 0.07 ;0.2   ;// set a constant value for the albedo ->VARIA/escena
  epsilon = 0.96    ;// setting a value for the emissivity
  cg = 0.32         ;// G/Rn del suelo (Fvg=0)
  z0m = 0.001       ;// soil roughness [m]
  zr = 6;3           ;// height of data acquisition [m]
  rss_min = exp(3)  ;// RSS Sellers */
  rss_max = exp(8)  ;// RSS Sellers */
  
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
  
;;;;Instantanean
  meteo = read_csv(pat_meteo, count= na_ins, HEADER=HEADER);DOY Heure RG Tair HR Vv Ts-verticale-(2m)  
  doy=meteo.FIELD1
  Hr=meteo.FIELD2
  Rg =  meteo.FIELD3
  Ta = meteo.FIELD4 + 273.16 ;[K]
  rha=meteo.FIELD5
  ua = meteo.FIELD6
  LST = float(meteo.FIELD7) + 273.16 ;[K]
  
  
;  jour=M(:,2);  Rs=M(:,3);  Tmin=M(:,4); Tmax=M(:,5);  RHmin=M(:,7);   RHmax=M(:,8); uz=M(:,9);
;  h=M(:,10);Pp=M(:,11); irrig=M(:,12);NDVI=M(:,13);Rnmes=M(:,16);Tsmes=M(:,17);Fc=M(:,18);
;  ETrmes=M(:,15);RH=(RHmin+RHmax)/2;Ts=M(:,19);Ta=M(:,20);
  
  ;;//Ctes --> SEB-1S
  NDVImin = 0.14   ;????   0.13     ;;Merlin et al. 2014 = 0.18 ó 0.15 en 2013
  NDVImax = 0.93     ;????   0.88     ;;Merlin et al. 2013 SEB1S = 0.18 - 0.93
  Fveg = (NDVI - NDVImin)/(NDVImax - NDVImin)
  Fvg_ENDMB = 0.5
  Fvg_ENDMBmin = Fvg_ENDMB
  Fvg_ENDMBmax = Fvg_ENDMB
  
  Hra_obj = [1100,1130,1200,1230,1300,1330,1400]
  
  for k=0, n_elements(Hra_obj)-1 do begin
    path_out= path + 'TsTv_Tends_EB_mo_' +string(Hra_obj[k], FORMAT='(I04)') + '.txt'
    openw, 1, path_out

    pix=where(Hr eq Hra_obj[k] , N_inst)
    ;;instantaneo    
    
    For j=0, na-1 do begin
      ;;;;;// [Tsmax, Tsmin] --> EB data
      jj = where(doy[pix] eq doy_day[j], nj)
      if nj eq 1 then begin
        i=pix[jj]
        Tsmin_eb = EB_soil_mo( epsilon, alpha_min, cg, zr, z0m, rss_min, ta[i], ua[i], rg[i], rha[i], SIGMA)
        Tsmax_eb = EB_soil_mo( epsilon, alpha_min, cg, zr, z0m, rss_max, ta[i], ua[i], rg[i], rha[i], SIGMA)
        Tsmin_eb = Tsmin_eb[0]
        Tsmax_eb = Tsmax_eb[0]
        Tvmin_eb = ta[i];
        Tvmax_eb = Tsmax_eb - (Tsmin_eb-Tvmin_eb);
        
        if finite(Tsmin_eb) eq 0 OR finite(Tsmax_eb) eq 0 then begin
          a=0
        endif
        
        if (LST[i] le 273.16 or finite(LST[i]) eq 0) then LST[i]=(Tsmin_eb+Tsmax_eb)/2
        if i eq 64 then begin
          a=0
        endif
        
        if finite(Tsmin_eb) eq 1 and finite(Tsmax_eb) eq 1 then $
          TsTv = Partition_TsTv(LST[i], Fveg[i], Tsmin_eb, Tsmax_eb, Tvmin_eb, Tvmax_eb) $
          else $
          TsTv = [!values.f_nan,!values.f_nan,!values.f_nan]
        
        printf, 1, doy[i], Tsmin_eb, Tsmax_eb, Tvmin_eb, Tvmax_eb, TsTv[0], TsTv[1], TsTv[2], format='(I5, 6f8.2, f5.0)'
        ;LSTend_EB[*,i] = [Tsmin_eb, Tsmax_eb, Tvmin_eb, Tvmax_eb]
      endif
      
    endfor ;j=doy
    close,1
  endfor ;k=Hra_obj
  close, /all
  print, 'LISTO'
  
end


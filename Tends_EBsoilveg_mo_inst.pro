pro Tends_EBsoilveg_mo_inst
  close, /all
  ;  EB_soil_mo
  RESOLVE_ROUTINE, 'EB_soil_mo', /IS_FUNCTION

  ;RESOLVE_ALL, RESOLVE_FUNCTION='EB_soil_mo';
  
  
  area = 'Chichaoua';'Bour';'R3';'Sidi_rahal';'Labferrer';'AB34';'IsardSAT';
  yr_manip = '2017-2018';'2016';
  
  if area eq 'R3' OR area eq 'Bour' OR area eq 'Chichaoua' OR area eq 'Sidi_rahal' $
    then region='Maroc' $
  else region='Catalunya'
  
  manip='Meteo_'+ yr_manip
  
;  if area eq 'R3' then manip='Meteo_2016_ble';'R3_Gravitaire_2015-2016' 
  
  root = 'D:\CESBIO\Region\' + region + '\Area\' + area +'\Insitu\'; 'D:\CESBIO\Region\Maroc\Area\R3\Insitu\'
  path = root + manip + '\Results' + '\'
  pat_meteo_day = root + manip + '\climat_' + area + '_day_' + yr_manip + '_Rs.csv'


  ;;//Ctes --> EB
  EB='EBsolveg\';'''EBsolveg\TvminTa\';
  rss_met=['','_rss','_s92inf']

  hr_i=10
  hr_f=14
  alpha_veg = [0.2,  0.3]
  h = 0.8               ;// vegetation height --> z0m_veg = 0.1
  alpha_min = [0.1,  0.3];    0.2;       // set a constant value for the albedo ->VARIA/escena
  epsilon = 0.957;    0.96;   // setting a value for the emissivity
  z0m = [0.001, 0.0005]     ;// soil roughness [m]: roughness length for momentum transfer: donde el viento desaparece (z0m+d)

  SIGMA = 5.67e-8; // Stefan-Boltzmann ct [W/m^2/K^4]
  cg = 0.32         ;0.315// G/Rn del suelo (Fvg=0)
  cg_vg = 0.05           ;// G/Rn de la vegetation (Fvg=1)
  zr = 2.0;3           ;// height of data acquisition [m]
  ;  epsilon_s = 0.957; 0.975
  ;  epsilon_v = 0.99

  ;;DAILY
  meteo_day = read_csv(pat_meteo_day, count= na, HEADER=HEADER);
  doy_day = meteo_day.FIELD01
  
  for rr=0,(n_elements(rss_met)-1) do begin;rss_met
  ;;Instantanean
;    if Tdat[tt] eq 'LSTcor_' then $
;      pat_meteo = root + manip + '\climat-R3_30min_LSTcor.csv' $ ;LST de Tb apogee
;    else $
      pat_meteo = root + manip + '\climat_' + area + '_30min_'+yr_manip+'_Rs.csv';

    meteo = read_csv(pat_meteo, count= na_ins, N_TABLE_HEADER=1);HEADER=HEADER);DOY Heure RG Tair HR Vv Ts-verticale-(2m)
    doy=meteo.FIELD1
    Hr=meteo.FIELD2
    Ta = meteo.FIELD3 + 273.16 ;[K]
    rha=meteo.FIELD4
    ua = meteo.FIELD5       ;NECESARIO USAR ua a 2 m?????????????
    Rg =  meteo.FIELD6
    
    if size(doy,/type) eq 7 then begin
      doy = date2YYYYDOY(doy,delimiter='/', format='DDMMYYYY' )
      doy = doy; - 1000*(doy/1000)
    endif
    
    if size(Hr,/type) eq 7 then begin
      Hr = strsplit(Hr,':',/extract)
      Hr=Hr.toarray()
      Hr = 100*Hr[*,0] + Hr[*,1]
    endif

    for aa=0,n_elements(alpha_min)-1 do begin;alpha_min
      for zz=0,0 do begin;z0m

        outdir = path + EB + 'Tends'+  rss_met[rr] + '\' + 'alb' + string(alpha_min[aa], FORMAT='(F0.3)') + $
          '_emis' + string(epsilon, FORMAT='(F0.3)') + '_z0m' +  string(z0m[zz], FORMAT='(F0.4)') + '_albvg' + string(alpha_veg[aa], FORMAT='(F0.2)') +'\'
        FILE_MKDIR, outdir
        FILE_MKDIR, root + manip + '\Meteo\'

        if rss_met[rr] eq '_rss' then begin
          rss_min = 0.;
          rss_max = 10.e7;
        endif else begin
          rss_min = exp(3)  ;   // RSS Sellers */
          if rss_met[rr] eq '_s92inf' then $
          rss_max = 10.e7 $
          else rss_max = exp(8)  ;   // RSS Sellers */
        endelse


        Hra_obj = (indgen((hr_f - hr_i)*2+1)/2. + hr_i)*100
        Hra_obj[where( Hra_obj MOD 100 eq 50)] = (Hra_obj[where( Hra_obj MOD 100 eq 50)] - 20)
        Hra_obj = fix(Hra_obj)

        all = make_array([7,na,n_elements(Hra_obj)],/float)
        M = make_array([5,na,n_elements(Hra_obj)],/float)

        for k=0, n_elements(Hra_obj)-1 do begin
          path_out= outdir + '\Tends_EB_mo_' +string(Hra_obj[k], FORMAT='(I04)') + '.txt'

          path_meteo= root + manip + '\Meteo\meteo_' +string(Hra_obj[k], FORMAT='(I04)') + '.txt'
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
                Tvmax_eb = EB_veg_mo(epsilon, alpha_veg[aa], cg_vg, zr,h, 1500, ta[i], ua[i], rg[i], rha[i], SIGMA)
                Tvmax_eb = Tvmax_eb[0]
                if EB eq 'EBsolveg\TvminTa\' then begin
                  Tvmin_eb = ta[i]
                endif else begin
                  Tvmin_eb = EB_veg_mo( 0.985, alpha_veg[aa], cg_vg, zr, h, rss_min, ta[i], ua[i], rg[i], rha[i], SIGMA)
                  Tvmin_eb = Tvmin_eb[0]
                endelse
              endif else begin
                Tvmax_eb = Tsmax_eb - (Tsmin_eb-Tvmin_eb);
                Tvmin_eb = ta[i];
              endelse


              printf, 1, doy[i], Tsmin_eb, Tsmax_eb, Tvmin_eb, Tvmax_eb, stab_min, stab_max, format='(I8, 4f8.2, 2f9.2)'
              printf, 2, doy[i], rg[i], ta[i], ua[i], rha[i], format='(I8, 4f8.2)'
              all[*,j,k] = [doy[i], Tsmin_eb, Tsmax_eb, Tvmin_eb, Tvmax_eb, stab_min, stab_max]
              M[*,j,k] = [doy[i], rg[i], ta[i], ua[i], rha[i]]
            endif
          endfor ;j=doy
          close, /all
        endfor ;k=Hra_obj

;;MEAN
        path_out= outdir + '\Tends_EB_mo_mean' + string(hr_i, FORMAT='(I02)') + string(hr_f, FORMAT='(I02)') + '.txt'
        path_meteo= root + manip + '\meteo_'+area+'_'+yr_manip+'_mean' + string(hr_i, FORMAT='(I02)') + string(hr_f, FORMAT='(I02)') + '.txt'
        openw, 1, path_out
        openw, 2, path_meteo
        for j=0, na-1 do begin
          printf,1, all[0,j,0], mean(all[1,j,*],/nan),mean(all[2,j,*],/nan),mean(all[3,j,*],/nan),mean(all[4,j,*],/nan),$
            mean(all[5,j,*],/nan),mean(all[6,j,*],/nan), format='(I8, 4f8.2, 2f9.2)'
          printf, 2, M[0,j,0], mean(M[1,j,*]),mean(M[2,j,*]),mean(M[3,j,*]),mean(M[4,j,*]), format='(I8, 4f8.2)'
        endfor
        close,/all

      endfor;z0m
    endfor;alpha_min

  endfor;rss_met

  print, 'LISTO'

end


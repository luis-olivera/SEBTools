Function ALB_endmembers, file_alb, file_LST, NO_value=NO_value
  ;;;Estimating ALBEDO ENDMENBERS (a_s, a_vg, a_vs) following Merlin 2013 (SEB-1S)
  ;alpha_s = min(alpha) at the satellite overpass / (a_vs = 0.09 +-0.01)
  ;alpha_vg = temporal mean (alpha) corresponding to Tmin / (a_vg = 0.19 +-0.03)
  ;alpha_vs = max(alpha) for the entire season / (a_vs = 0.39 +-0.07)
  ;alpha_s2 = alpha at maximum LST
  
  ;Porc=0.1
  ;alb_agua = 0.06
  a_vs_all = make_array([n_elements(file_LST)],/float)  ;--> a_vs
  a_vg_all = a_vs_all                                   ;--> a_vg
  a_s_all = a_vs_all                                    ;--> a_vg
  a_s2_all = a_vs_all                                    ;--> a_vg
  
  for i = 0, (n_elements(file_LST)-1) do begin
    
    type = strsplit(file_alb[i],'.',/EXTRACT)
    type = type[-1]
    if type eq 'tif' then begin
      alb = read_tiff(file_alb[i])
      lst = read_tiff(file_lst[i])
    endif
    if type eq 'txt' then begin
      alb = READ_ASCII(file_alb[sort[i]], count= nalb)
      lst = READ_ASCII(file_lst[sort[i]], count= nlst)
      alb=alb.(0)
      lst=lst.(0)
    endif
    
    pix = where(LST ne NO_value AND alb ne NO_value, n, complement=NANs)
    a_s2_all[i] = min(alb[where(LST eq max(LST[pix]))])
    a_s_all[i] = min(alb[pix])
    a_vg_all[i] = max(alb[where(LST eq min(LST[pix]))])
    a_vs_all[i] = max(alb[pix])
    ;    a_vs_all[i] = alb[pix( (SORT(alb[pix]) ) ((100-Porc) * N_ELEMENTS(alb[pix]) / 100) )]
    ;print, min(LST[pix])
    
  endfor
  return, transpose([[a_s_all], [a_vg_all], [a_vs_all], [a_s2_all]])
  
end
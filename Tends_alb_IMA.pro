function Tends_alb_IMA, LST, Fvg, alb, a_s, a_vg, a_vs, Tair=Tair,Fvg_ENDMBmin=Fvg_ENDMBmin
  ;;Estimating TEMPERATURE ENDMENBERS using LST-alb space and fvg (Ts_max, Ts_min, Tv_max, Tv_min)
  ;;Folowing: Merlin (2013) / Stefan et al. (2015)
  
  
  if n_elements(Tair) eq 0 then Tair=min(LST, /NAN)
  if n_elements(Fvg_ENDMBmin) eq 0 then Fvg_ENDMBmin=mean(Fvg,/nan)
  
  ;;T-Fvg - "Dry surface": Tmax (Ts_max_2, Tv_max_2)
  pix = where(alb gt a_vg, npix)     ;Fvg > Fvg_ENDMB
  ; if npix gt 0 then begin
  b = max(LST,/nan)
  slope = (LST[pix] - b) / (alb[pix] - a_s)
  Ts_max = b
  Tv_max = b + (a_vs - a_s)*max(slope)
  ;  endif else begin
  ;    Tv_max_2 = min(LST)
  ;  endelse
  Tv_max=min([Tv_max,Ts_max])
  
  ;;T-Fvg - "Wet surface": Tmin (Ts_min, Tv_min)
  Tv_min = Tair
  ;if max(Fvg[where(LST eq Tv_min)]) gt Fvg_ENDMBmin then begin        ;;;If Tmin correspond to vegetation
  pix = where(Fvg lt Fvg_ENDMBmin  AND alb lt a_vg, npix)
  if npix gt 0 then begin
    slope = (Tv_min - LST[pix]) / (a_vg - alb[pix])
    b = Tv_min - (a_vg - a_s)*max(slope)
    Ts_min = b
    ;Tv_min = b + 1.*slope   ;Tv_min = min(LST, /NAN)
  endif else begin
    Ts_min = Tv_min
  endelse
  Ts_min=max([Ts_min,Tv_min])
  Tv_max=max([Tv_min,Tv_max])
  
  Return, LSTend = [Ts_min, Ts_max, Tv_min, Tv_max]
END
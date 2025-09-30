function Tends_Fvg, LST, Fveg, Tair=Tair
  ;;Estimating TEMPERATURE ENDMENBERS using LST-Fvg space (Ts_max, Ts_min, Tv_max, Tv_min)
  ;;Folowing Stefan et al. (2015)
  
;  ;;T-alb - "Dry surface": Tmax (Ts_max_1, Tv_max_1)
;  pix = where(alb gt a_vg , n)   ; alb > a_vg
;  if npix gt 0 then begin
;    slope = (LST[pix] - max(LST)) / (alb[pix] - a_s)
;    b = max(LST) - max(slope)*a_s
;  endif
;  Ts_max_1 = max(LST)
;  Tv_max_1 = b + a_vs*max(slope)
;  
;  ;;T-alb - "Wet surface": Tmin (Ts_min_1, Tv_min_1)
;  pix = where(Fveg lt Fvg_ENDMB  AND  alb lt a_vg , npix)    ;Fveg < Fvg_ENDMB  &  alb < a_vg
;  if npix gt 0 then begin
;    slope = (LST[pix] - min(LST)) / (alb[pix] - a_vg)
;    b = min(LST) - max(slope)*a_vg
;    Ts_min_1 = b + a_s*slope
;    Tv_min_1 = b + a_vg*slope   ;Tv_min_1 = min(LST, /NAN)
;  endif else begin
;    Tv_min_1 = min(LST)
;    Ts_min_1 = Tv_min_1
;  endelse
;  
  ;;Alternativa
  ;  Tv_min_2 = min(LST[where(finite(LST) eq 1  and  finite(Fveg) eq 1 and alb ge alb_agua )])      ;and alb ge 0.2 solo para eliminar el pivote ....minimum T
  ;  Ts_min_2 = min(LST[where(finite(LST) eq 1  and  finite(Fveg) eq 1 and Fveg eq 0 )])    ;minimum T at minimum fvg,  ::NO sirve siempre
  
  if n_elements(Tair) eq 0 then Tair=min(LST, /NAN)
  
  Fvg_ENDMBmax = mean(Fveg,/nan)
  Fvg_ENDMBmin = Fvg_ENDMBmax
  ;;T-Fveg - "Dry surface": Tmax (Ts_max_2, Tv_max_2)
  pix = where(Fveg gt Fvg_ENDMBmax , npix)     ;Fveg > Fvg_ENDMB
 ; if npix gt 0 then begin
    slope = (LST[pix] - max(LST,/nan)) / (Fveg[pix] - 0)
    b = max(LST,/nan)
    ;Ts_max_2 = b
    Ts_max_2 = max(LST,/nan)
    Tv_max_2 = b + 1.*max(slope)   ;Tv_min_1 = min(LST, /NAN)
;  endif else begin
;    Ts_max_2 = max(LST)
;    Tv_max_2 = min(LST)
;  endelse
    Tv_max_2=min([Tv_max_2,Ts_max_2])
    
  ;;T-Fveg - "Wet surface": Tmin (Ts_min_2, Tv_min_2)
  Tv_min_2 = Tair
  ;if max(Fveg[where(LST eq Tv_min_2)]) gt Fvg_ENDMBmin then begin        ;;;If Tmin correspond to vegetation
    pix = where(Fveg lt Fvg_ENDMBmin  , npix)     ;Fveg < Fvg_ENDMB
    if npix gt 0 then begin
      slope = (Tv_min_2 - LST[pix]) / (1. - Fveg[pix])
      b = Tv_min_2 - max(slope)*1.
      Ts_min_2 = b
      ;Tv_min_2 = b + 1.*slope   ;Tv_min_1 = min(LST, /NAN)
    endif else begin
      Ts_min_2 = Tv_min_2
    endelse
 ; endif else begin
 ;   Ts_min_2 = Tv_min_2
 ; endelse
  Ts_min_2=max([Ts_min_2,Tv_min_2])
  
  ;;Alternative
  ;  Tv_min_2 = min(LST[where(finite(LST) eq 1  AND  finite(Fveg) eq 1 and alb ge 0.2 )])      ;and alb ge 0.2 solo para eliminar el pivote ....minimum T
  ;  Ts_min_2 = min(LST[where(finite(LST) eq 1  AND  finite(Fveg) eq 1 and Fveg eq 0 )])    ;minimum T at minimum fvg,  ::NO sirve siempre
  
  Return, LSTend = [Ts_min_2, Ts_max_2, Tv_min_2, Tv_max_2]
END


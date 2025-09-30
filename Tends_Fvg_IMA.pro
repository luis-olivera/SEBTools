function Tends_Fvg_IMA, LST, Fvg, Tair=Tair,Fvg_ENDMBmin=Fvg_ENDMBmin,Fvg_ENDMBmax=Fvg_ENDMBmax
  ;;Estimating TEMPERATURE ENDMENBERS using LST-Fvg space (Ts_max, Ts_min, Tv_max, Tv_min)
  ;;Folowing: Merlin (2013) / Stefan et al. (2015)


  if n_elements(Tair) eq 0 then Tair=min(LST, /NAN)
  if n_elements(Fvg_ENDMBmax) eq 0 then Fvg_ENDMBmax=mean(Fvg,/nan)
  if n_elements(Fvg_ENDMBmin) eq 0 then Fvg_ENDMBmin=mean(Fvg,/nan)

  ;;T-Fvg - "Dry surface": Tmax (Ts_max_2, Tv_max_2)
  pix = where(Fvg gt Fvg_ENDMBmax , npix)     ;Fvg > Fvg_ENDMB
 ; if npix gt 0 then begin
    b = max(LST,/nan)
    slope = (LST[pix] - b) / (Fvg[pix] - 0)
    Ts_max_2 = b
    Tv_max_2 = b + 1.*max(slope)   ;Tv_min_1 = min(LST, /NAN)
;  endif else begin
;    Tv_max_2 = min(LST)
;  endelse
    Tv_max_2=min([Tv_max_2,Ts_max_2])
    
  ;;T-Fvg - "Wet surface": Tmin (Ts_min_2, Tv_min_2)
  Tv_min_2 = Tair
  ;if max(Fvg[where(LST eq Tv_min_2)]) gt Fvg_ENDMBmin then begin        ;;;If Tmin correspond to vegetation
    pix = where(Fvg lt Fvg_ENDMBmin  , npix)     ;Fvg < Fvg_ENDMB
    if npix gt 0 then begin
      slope = (Tv_min_2 - LST[pix]) / (1. - Fvg[pix])
      b = Tv_min_2 - max(slope)*1.
      Ts_min_2 = b
      ;Tv_min_2 = b + 1.*slope   ;Tv_min_1 = min(LST, /NAN)
    endif else begin
      Ts_min_2 = Tv_min_2
    endelse
  Ts_min_2=max([Ts_min_2,Tv_min_2])
  Tv_max_2=max([Tv_min_2,Tv_max_2])
  
  Return, LSTend = [Ts_min_2, Ts_max_2, Tv_min_2, Tv_max_2]
END


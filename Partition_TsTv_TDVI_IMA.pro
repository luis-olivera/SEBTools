Function Partition_TsTv_TDVI_IMA, LST, Fveg, Ts_min, Ts_max, Tv_min, Tv_max
  ;;SPATIAL
  ;**Particionar LST en Ts y Tv a partir del espacio T-Fveg y T_endmembers: Tsmin, Tsmax, Tvmin, Tvmax
  ;Usando metodo TVDI
  ;;LST = Ts(1 - Fveg) + TvFveg
  
  ss=size(Ts_min)
  
  Th = Ts_max - (Ts_max - Tv_max)*Fveg ;T en limite AD DRY
  Tj = Ts_min - (Ts_min - Tv_min)*Fveg ;T en limite BC WET
  Tv = Tv_min + (Tv_max - Tv_min)*(LST - Tj)/(Th - Tj) ; uso proporcion IJ/HJ siendo I pto (Fveg,LST)
  Ts = Ts_min + (Ts_max - Ts_min)*(LST - Tj)/(Th - Tj) ; = (LST - Tvg*Fveg)/(1 - Fveg)
  
  if ss[0] eq 0 then begin
    Ts(where(Ts gt Ts_max)) = Ts_max
    Ts(where(Ts lt Ts_min)) = Ts_min
    Tv(where(Tv gt Tv_max)) = Tv_max
    Tv(where(Tv lt Tv_min)) = Tv_min
  endif else begin
    Ts(where(Ts gt Ts_max)) = Ts_max(where(Ts gt Ts_max))
    Ts(where(Ts lt Ts_min)) = Ts_min(where(Ts lt Ts_min))
    Tv(where(Tv gt Tv_max)) = Tv_max(where(Tv gt Tv_max))
    Tv(where(Tv lt Tv_min)) = Tv_min(where(Tv lt Tv_min))    
  endelse
  
  
  Ts(where(LST gt Ts_max and Fveg lt 0.05)) = LST(where(LST gt Ts_max and Fveg lt 0.05))
  
  
  return, [[[Ts]],[[Tv]]]
  
end
Function Partition_TsTv_TVDI_fc, LST, Fveg, Ts_min, Ts_max, Tv_min, Tv_max
  ;;NIVEL IN SITU
  ;;Particionar LST en Ts y Tv a partir del espacio T-Fveg y T_endmembers: Tsmin, Tsmax, Tvmin, Tvmax
  ;Estimar Ts_TVDI a partir de TDVI (Ks=Kr)
  ;Tv de la proyeccion de Ts_TVDI en Fveg=1
  compile_opt strictarr 
  
  TsTv = Partition_TsTv_TDVI(LST, Fveg, Ts_min, Ts_max, Tv_min, Tv_max) 
  Ts_TVDI= TsTv[0]
  
  Ts = Ts_max - (Ts_max - Ts_TVDI)*(1 - Fveg)
  
  if Fveg ne 0 then begin
    slope = (LST - Ts) / (Fveg)
    Tv = Ts + slope   ; Ts + slope * 1
  endif else begin
    Tv = Tv_min
  endelse
  
  Tv = max([Tv,Tv_min])
  Tv = min([Tv,Tv_max])
  
  return, [Ts,Tv,0]
  
end



Function Partition_TsTv_TDVI, LST, Fveg, Ts_min, Ts_max, Tv_min, Tv_max
  ;;**Particionar LST en Ts y Tv a partir del espacio T-Fveg y T_endmembers: Tsmin, Tsmax, Tvmin, Tvmax
  ;Usando metodo TVDI
  ;;LST = Ts(1 - Fveg) + TvFveg

  Th = Ts_max - (Ts_max - Tv_max)*Fveg ;T en limite AD DRY
  Tj = Ts_min - (Ts_min - Tv_min)*Fveg ;T en limite BC WET
  Tvg = Tv_min + (Tv_max - Tv_min)*(LST - Tj)/(Th - Tj) ; uso proporcion IJ/HJ siendo I pto (Fveg,LST)
  Ts = Ts_min + (Ts_max - Ts_min)*(LST - Tj)/(Th - Tj) ; = (LST - Tvg*Fveg)/(1 - Fveg)

  Ts = min([Ts,Ts_max])
  Ts = max([Ts,Ts_min])

  if LST ge Ts_max and Fveg lt 0.05 then Ts=LST

  return, [Ts,Tvg,0]

end
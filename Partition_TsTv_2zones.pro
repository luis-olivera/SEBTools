Function Partition_TsTv_2zones, LST, Fveg, Ts_min, Ts_max, Tv_min, Tv_max
  ;;NIVEL IN SITU
  ;;Particionar LST en Ts y Tv a partir del espacio T-Fveg y T_endmembers: Tsmin, Tsmax, Tvmin, Tvmax
  ;Divide el poligono en 2 zonas por la diagonal AC
  ;Zona_1: Tv = Tv_min (C)  // Ts linealmente al borde Bare Soil (AB)
  ;Zona_2: Ts = Ts_max (A)   // Tv linealmente al borde Full-cover vegetation (CD)

  ;;Det. LST de Fveg en las Diagonales del T-Fveg space
  Diag_AC = Ts_max + (Tv_min - Ts_max)*Fveg
  
  ;;Z1 UNstressed
  if (LST le Diag_AC) or Fveg eq 0 then begin
    Tv = Tv_min
    slope = (Tv_min - LST)/(1 - Fveg)
    Ts = LST - Fveg*slope
    Ts = max([Ts,Ts_min])
    Z=1
  endif
  
  ;;Z2 Stressed
  if (LST gt Diag_AC) and Fveg ne 0 then begin
    Ts = Ts_max
    slope = (LST - Ts_max)/Fveg
    Tv = slope + Ts_max
    Tv = min([Tv,Tv_max])
    z=2
  endif

  return, [Ts,Tv,Z]
  
end
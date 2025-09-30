Function Partition_TsTv_z1z3TVDI, LST, Fveg, Ts_min, Ts_max, Tv_min, Tv_max
  ;;NIVEL IN SITU
  ;;;;ERROR--> use Tvg_max=Tv_min en Z2 --> Tv=Tvmin en toda Z2 -->Ks=1
  ;;;ERROR--> Ts en Z1 con TVDI
  ;;**Particionar LST en Ts y Tv a partir del espacio T-Fveg y T_endmembers: Tsmin, Tsmax, Tvmin, Tvmax
  ;Usando TVDI en Zona 1 y 3 del poligono
  ;TVDI es usado solo en: Zona 1 para Tv / Zona 3 para Ts --> LST != Ts(1 - Fveg) + TvFveg
  ;;LST = Ts(1 - Fveg) + TvFveg
  
  ;;****Det. TVEG (Tvg) en T-Fveg
  ;;Det. LST de Fveg en las Diagonales del T-Fveg space
  Diag_BD = Ts_min + (Tv_max - Ts_min)*Fveg
  Diag_AC = Ts_max + (Tv_min - Ts_max)*Fveg
  
  ;;ZONA_A Z1
  if (LST ge Diag_BD  and  LST le Diag_AC) or Fveg eq 0 then begin
    ;Tvg = (Tv_max + Tv_min)/2.                 ;Moran, Merlin
    Th = Ts_max - (Ts_max - Tv_max)*Fveg ;T en limite AD DRY
    Tj = Ts_min - (Ts_min - Tv_min)*Fveg ;T en limite BC WET
    Tvg = Tv_min + (Tv_max - Tv_min)*(LST - Tj)/(Th - Tj) ; uso proporcion IJ/HJ siendo I pto (Fveg,LST)
    Z=1
    Ts = Ts_min + (Ts_max - Ts_min)*(LST - Tj)/(Th - Tj) ; = (LST - Tvg*Fveg)/(1 - Fveg)f
  endif
  
  ;;ZONA_B Z4
  if (LST gt Diag_BD  and  LST gt Diag_AC) and Fveg ne 0 then begin
    coef_min_ZB = LINFIT( [ 0 , Fveg ]  ,  [ Ts_max , LST ] )
    Tvg_min = coef_min_ZB[0] + coef_min_ZB[1] * 1
    Tvg_min = min([Tvg_min,Tv_max])
    Tvg_min = max([Tvg_min,Tv_min])
    Tvg = (Tv_max + Tvg_min)/2.
    Z=4
    Ts = (LST - Tvg*Fveg)/(1 - Fveg)
  endif
  
  ;;ZONA_C Z2
  if (LST lt Diag_BD  and  LST lt Diag_AC) then begin
    coef_max_ZC = LINFIT( [ Fveg , 1 ]  ,  [ LST , Tv_min ] )
    Tvg_max = coef_max_ZC[0] + coef_max_ZC[1] * 1
    Tvg_max = min([Tvg_max,Tv_max])
    Tvg_max = max([Tvg_max,Tv_min])
    Tvg = (Tv_min + Tvg_max)/2.
    Z=2
    Ts = (LST - Tvg*Fveg)/(1 - Fveg)
  endif
  
  ;;ZONA_D Z3
  if (LST le Diag_BD  and  LST ge Diag_AC) then begin
    coef_min_ZD = LINFIT( [ 0 , Fveg ]  ,  [ Ts_max , LST ] )
    coef_max_ZD = LINFIT( [ 0 , Fveg ]  ,  [ Ts_min , LST ] )
    Tvg_min = coef_min_ZD[0] + coef_min_ZD[1] * 1
    Tvg_max = coef_max_ZD[0] + coef_max_ZD[1] * 1
    Tvg_min = min([Tvg_min,Tv_max])
    Tvg_min = max([Tvg_min,Tv_min])
    Tvg_max = min([Tvg_max,Tv_max])
    Tvg_max = max([Tvg_max,Tv_min])
    Tvg = (Tvg_min + Tvg_max)/2
    Z=3
    Ts_ = (LST - Tvg*Fveg)/(1 - Fveg)
    Th = Ts_max - (Ts_max - Tv_max)*Fveg ;T en limite AD DRY
    Tj = Ts_min - (Ts_min - Tv_min)*Fveg ;T en limite BC WET
    Tvg = Tv_min + (Tv_max - Tv_min)*(LST - Tj)/(Th - Tj) ; uso proporcion IJ/HJ siendo I pto (Fveg,LST)
    Ts = Ts_min + (Ts_max - Ts_min)*(LST - Tj)/(Th - Tj)
    ;print, [Tvg_ - Tvg,Ts_-Ts]
    Z=3
  endif
  
  ;Ts = (LST - Tvg*Fveg)/(1 - Fveg)
  ;Ts = ((LST^4. - Tvg^4.*Fveg)/(1 - Fveg))^0.25

;; Fijar Ts entre Tsmax,min
;  Ts = min([Ts,Ts_max])
;  Ts = max([Ts,Ts_min])
;  if LST ge Ts_max and Fveg lt 0.05 then Ts=LST
  
  if finite(Tvg) eq 0 then begin
    a=0
  endif
  
  return, [Ts,Tvg,Z]
  
end
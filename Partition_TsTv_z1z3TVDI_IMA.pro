Function Partition_TsTv_z1z3TVDI_IMA, LST, Fveg, Ts_min, Ts_max, Tv_min, Tv_max
  ;;NIVEL SPATIAL
  ;;ERROR--> use Tvg_max=Tv_min en Z2 --> Tv=Tvmin en toda Z2 -->Ks=1
  ;;;ERROR--> Ts en Z1 con TVDI / Tv en Z3 con TVDI
  ;;NIVEL SPATIAL
  ;;**Particionar LST en Ts y Tv a partir del espacio T-Fveg y T_endmembers: Tsmin, Tsmax, Tvmin, Tvmax
  ;Usando TVDI en Zona 1 y 3 del poligono
  ;;LST = Ts(1 - Fveg) + TvFveg
  
  ;;****Det. TVEG (Tvg) en T-Fveg
  ;;Det. LST de Fveg en las Diagonales del T-Fveg space
  Diag_BD = Ts_min + (Tv_max - Ts_min)*Fveg
  Diag_AC = Ts_max + (Tv_min - Ts_max)*Fveg
  
  ;;PARA IMAGEN
  ss=size(LST)
  Ts = make_array(ss[1:2],/float)
  Ts[where(finite(LST,/NAN) OR finite(Fveg,/NAN))]=!values.F_NAN
  Tvg = Ts
  Z= Ts
  
  pix_A = where(LST ge Diag_BD  and  LST le Diag_AC , npix_A)  ;Z1
  pix_B = where(LST gt Diag_BD  and  LST gt Diag_AC , npix_B)  ;Z4
  pix_C = where(LST lt Diag_BD  and  LST lt Diag_AC , npix_C)  ;Z2
  pix_D = where(LST le Diag_BD  and  LST ge Diag_AC , npix_D)  ;Z3
  
  ;;ZONA_A Z1
;  if (LST ge Diag_BD  and  LST le Diag_AC) then begin
  if npix_A ge 1 then begin  
    ;Tvg = (Tv_max + Tv_min)/2.                 ;Moran, Merlin
    Th = Ts_max - (Ts_max - Tv_max)*Fveg[pix_A] ;T en limite AD DRY
    Tj = Ts_min - (Ts_min - Tv_min)*Fveg[pix_A] ;T en limite BC WET
    Tvg[pix_A] = Tv_min + (Tv_max - Tv_min)*(LST[pix_A] - Tj)/(Th - Tj) ; uso proporcion IJ/HJ siendo I pto (Fveg,LST)
    Z[pix_A]=1
    Ts[pix_A] = Ts_min + (Ts_max - Ts_min)*(LST[pix_A] - Tj)/(Th - Tj) ; = (LST - Tvg*Fveg)/(1 - Fveg)f
  endif
  
  ;;ZONA_B Z4
;  if (LST gt Diag_BD  and  LST gt Diag_AC)  then begin
  if npix_B ge 1 then begin  
;    coef_min_ZB = LINFIT( [ 0 , Fveg ]  ,  [ Ts_max , LST ] )
;    Tvg_min = coef_min_ZB[0] + coef_min_ZB[1] * 1
;    Tvg_min = min([Tvg_min,Tv_max])
;    Tvg_min = max([Tvg_min,Tv_min])
    
    slope = (LST[pix_B] - Ts_max) / (Fveg[pix_B])
    b = Ts_max
    Tvg_min = b + slope * 1
    Tvg_min[where(Tvg_min ge Tv_max)] = Tv_max
    Tvg_min[where(Tvg_min le Tv_min)] = Tv_min
    
    Tvg[pix_B] = (Tv_max + Tvg_min)/2.
    Z[pix_B]=4
    Ts[pix_B] = (LST[pix_B] - Tvg[pix_B]*Fveg[pix_B])/(1 - Fveg[pix_B])
  endif
  
  ;;ZONA_C Z2
;  if (LST lt Diag_BD  and  LST lt Diag_AC) then begin
  if npix_C ge 1 then begin  

;      slope = (Tv_min - LST[pix_C]) / (1 - Fveg[pix_C])
;      b = LST[pix_C] - slope*Fveg[pix_C]
;      Tvg_max = b + slope*1.
;      Tvg_max[where(Tvg_max ge Tv_max)] = Tv_max
;      Tvg_max[where(Tvg_max le Tv_min)] = Tv_min
    Tvg_max = Tv_min; = 4 lines anteriores 
    Tvg[pix_C] = (Tv_min + Tvg_max)/2.
    Z[pix_C]=2
    Ts[pix_C] = (LST[pix_C] - Tvg[pix_C]*Fveg[pix_C])/(1 - Fveg[pix_C])
  endif
  
  ;;ZONA_D Z3
  ;if (LST le Diag_BD  and  LST ge Diag_AC) then begin
  if npix_D ge 1 then begin  
;    coef_min_ZD = LINFIT( [ 0 , Fveg ]  ,  [ Ts_max , LST ] )
;    coef_max_ZD = LINFIT( [ 0 , Fveg ]  ,  [ Ts_min , LST ] )
;    Tvg_min = coef_min_ZD[0] + coef_min_ZD[1] * 1
;    Tvg_max = coef_max_ZD[0] + coef_max_ZD[1] * 1
;    Tvg_min = min([Tvg_min,Tv_max])
;    Tvg_min = max([Tvg_min,Tv_min])
;    Tvg_max = min([Tvg_max,Tv_max])
;    Tvg_max = max([Tvg_max,Tv_min])
;    
;      slope_max = (LST[npix_D] - Ts_min) / (Fveg[npix_D])
;      b_max = Ts_min
;      slope_min = (LST[npix_D] - Ts_max) / (Fveg[npix_D])
;      b_min = Ts_max
;      Tvg_min = b_min + slope_min * 1
;      Tvg_max = b_max + slope_max * 1
;      Tvg_min[where(Tvg_min ge Tvmax)] = Tv_max
;      Tvg_min[where(Tvg_min le Tvmin)] = Tv_min
;      Tvg_max[where(Tvg_max ge Tvmax)] = Tv_max
;      Tvg_max[where(Tvg_max le Tvmin)] = Tv_min
;      Tvg = (Tvg_min + Tvg_max)/2
;      Ts_ = (LST[npix_D] - Tvg*Fveg[npix_D])/(1 - Fveg[npix_D])

    Th = Ts_max - (Ts_max - Tv_max)*Fveg[pix_D] ;T en limite AD DRY
    Tj = Ts_min - (Ts_min - Tv_min)*Fveg[pix_D] ;T en limite BC WET
    Tvg[pix_D] = Tv_min + (Tv_max - Tv_min)*(LST[pix_D] - Tj)/(Th - Tj) ; uso proporcion IJ/HJ siendo I pto (Fveg,LST)
    Ts[pix_D] = Ts_min + (Ts_max - Ts_min)*(LST[pix_D] - Tj)/(Th - Tj)
    ;print, [Tvg_ - Tvg,Ts_-Ts]
    Z[pix_D]=3
  endif
  
  ;Ts = (LST - Tvg*Fveg)/(1 - Fveg)
  ;Ts = ((LST^4. - Tvg^4.*Fveg)/(1 - Fveg))^0.25
  
;  Ts = min([Ts,Ts_max])
;  Ts = max([Ts,Ts_min])
  Ts[where(Ts ge Ts_max)]=Ts_max
  Ts[where(Ts le Ts_min)]=Ts_min
  
;  if LST ge Ts_max and Fveg lt 0.05 then Ts=LST
;  Ts[where(LST ge Ts_max and Fveg lt 0.05)]=LST
  
;  if finite(Tvg) eq 0 then begin
;    a=0
;  endif
  
  return, [[[Ts]],[[Tvg]],[[Z]]]
  
end
Function Partition_TsTv_TSEB_IMA, LST, Fveg, Ts_min, Ts_max, Tv_min, Tv_max
  ;;NIVEL SPATIAL
  ;;Particionar LST en Ts y Tv a partir del espacio T-Fveg y T_endmembers: Tsmin, Tsmax, Tvmin, Tvmax
  ;Estimar Ts_TVDI a partir de TDVI (Ks=Kr). Then Kr(ts) = Kr(ts_tvdi)*(1-fc)
  ;Tv de la proyeccion de Ts en Fveg=1
  
  ss=size(Ts_min)
  Tv = LST
  Tv[where(finite(LST))] = Tv_min
  Ts = (LST - Fveg*Tv)/(1 - Fveg) 
  pix = where(Ts gt Ts_max)
  Ts[pix] = Ts_max
  
  Tv[pix] = (LST[pix] - (1 - Fveg[pix])*Ts[pix])/Fveg[pix]
  
  Ts(where(Ts lt Ts_min)) = Ts_min
  Tv(where(Tv gt Tv_max)) = Tv_max

  return, [[[Ts]],[[Tv]]]
  
end
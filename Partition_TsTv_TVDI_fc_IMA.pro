Function Partition_TsTv_TVDI_fc_IMA, LST, Fveg, Ts_min, Ts_max, Tv_min, Tv_max
  ;;NIVEL SPATIAL
  ;;Particionar LST en Ts y Tv a partir del espacio T-Fveg y T_endmembers: Tsmin, Tsmax, Tvmin, Tvmax
  ;Estimar Ts_TVDI a partir de TDVI (Ks=Kr). Then Kr(ts) = Kr(ts_tvdi)*(1-fc)
  ;Tv de la proyeccion de Ts en Fveg=1
  
  ss=size(Ts_min)
  
  TsTv = Partition_TsTv_TDVI_IMA(LST, Fveg, Ts_min, Ts_max, Tv_min, Tv_max)
  Ts_TVDI= TsTv[*,*,0]
  Tv = TsTv[*,*,1]
  Tv[*,*]=0
  
  Ts = Ts_max - (Ts_max - Ts_TVDI)*(1 - Fveg) ; = Ts_TVDI*(1 - Fveg) + Ts_max*Fveg 
  if ss[0] eq 0 then $
    Ts(where(Ts lt Ts_min)) = Ts_min $
  else $
    Ts(where(Ts lt Ts_min)) = Ts_min(where(Ts lt Ts_min))

  pix = where(Fveg ne 0, COMPLEMENT=pixFvg_0)
  slope = (LST[pix] - Ts[pix]) / (Fveg[pix])
  Tv[pix] = Ts[pix] + slope
  
  if ss[0] eq 0 then begin
    Tv[pixFvg_0] = Tv_min

    Tv(where(Tv gt Tv_max)) = Tv_max
    Tv(where(Tv lt Tv_min)) = Tv_min
  endif else begin
    Tv[pixFvg_0] = Tv_min[pixFvg_0]
    Tv(where(Tv gt Tv_max)) = Tv_max(where(Tv gt Tv_max))
    Tv(where(Tv lt Tv_min)) = Tv_min(where(Tv lt Tv_min))
  endelse

  return, [[[Ts]],[[Tv]]]
  
end
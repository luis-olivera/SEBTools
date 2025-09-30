Function Tendcor_alb, LST, alb, LSTend_1, LSTend_2, alpha_1, alpha_2
  ;Correct Tends a partir de derivadas parciales d_Tends/d_alb
  ;d_Tends/d_alb: (LSTend_2 - LSTend_1) / (alpha_2 - alpha_1)
  ;LSTend_i : [Ts_min, Ts_max, Tv_min, Tv_max]_i
  ;alpha_i : [alpha_s , alpha_v]_i
  ;OUTPUT : Imagenes de Tends
  
  alb_sim = mean([alpha_1[0], alpha_2[0]])
  
  LSTend_EB = mean([[LSTend_1],[LSTend_2]],dimension=2) ; Ts -->alb_s=0.2 : mean(alpha_1)
  LSTend_EB[2:3] = LSTend_1[2:3]                        ; Tv -->alb_vg=0.2  :: alpha_2[0]
  
  ;;Derivadas parciales d_(Ts,v,min,max)/d_alpha
  deriv_parc = d_tends(LSTend_1, LSTend_2, alpha_1, alpha_2)
  d_Ts_min =  deriv_parc[0]
  d_Ts_max =  deriv_parc[1]
  d_Tv_min =  deriv_parc[2]
  d_Tv_max =  deriv_parc[3]
  
  ;;Tends corregido por su respectiva Derivada parcial d_(Ts,v,min,max)/d_alpha
  Ts_min = LSTend_EB[0] - d_Ts_min*(alb - alb_sim); IMAGEN
  Ts_max = LSTend_EB[1] - d_Ts_max*(alb - alb_sim)
  Tv_min = LSTend_EB[2] - d_Tv_min*(alb - alb_sim); IMAGEN
  Tv_max = LSTend_EB[3] - d_Tv_max*(alb - alb_sim)
  
  
  return, [[[Ts_min]],[[Ts_max]],[[Tv_min]],[[Tv_max]]]
  
end


function d_tends, LSTend_1, LSTend_2, alpha_1, alpha_2
  Ts_min_1 = LSTend_1[0]
  Ts_max_1 = LSTend_1[1]
  Tv_min_1 = LSTend_1[2]
  Tv_max_1 = LSTend_1[3]
  Ts_min_2 = LSTend_2[0]
  Ts_max_2 = LSTend_2[1]
  Tv_min_2 = LSTend_2[2]
  Tv_max_2 = LSTend_2[3]
  
  d_Ts_min = (Ts_min_2 - Ts_min_1)/(alpha_2(0) - alpha_1(0));
  d_Ts_max = (Ts_max_2 - Ts_max_1)/(alpha_2(0) - alpha_1(0));
  d_Tv_min = (Tv_min_2 - Tv_min_1)/(alpha_2(1) - alpha_1(1));
  d_Tv_max = (Tv_max_2 - Tv_max_1)/(alpha_2(1) - alpha_1(1));
  
  return, [d_Ts_min, d_Ts_max, d_Tv_min, d_Tv_max]
end
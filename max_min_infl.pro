Function max_min_infl, X, Y, NDEGREE
  ;;output: [Maximo, Minimo, PtoInflexion]
  coef = POLY_FIT(X, Y, NDEGREE); POLY_FIT(mean_clasALB[palb], mean_clasLST[palb], 3)
  
  ;;Polinomio 2do orden
  if (NDEGREE eq 2) then begin
    X_ext1 = - coef[1]/(2*coef[2])     ;1ª derivada=0 : max LST(alb)
    X_ext2 = -9999
    X_inf = X_ext2
  endif
  ;;Polinomio 3er orden
  if (NDEGREE eq 3) then begin
    X_inf = - coef[2]/(3*coef[3])     ;2ª derivada=0 : punto de inflexion LST(alb) (Bastiaanssen,98)
    X_ext2 = (- coef[2] + sqrt(abs(coef[2]^2 - 3*coef[1]*coef[3])))/(3*coef[3])     ;1ª derivada=0: MIN
    X_ext1 = (- coef[2] - sqrt(abs(coef[2]^2 - 3*coef[1]*coef[3])))/(3*coef[3])     ;1ª derivada=0: MAX
  endif
  
  X_umb = fltarr(3)
  X_umb = [X_ext1,X_ext2,X_inf]
  ;  Y_umb = fltarr(3)
  ;  Y_umb = coef[0] + coef[1]*X_umb  + coef[2]*(X_umb^2)  + coef[3]*(X_umb^3)
  
  Return, X_umb
end
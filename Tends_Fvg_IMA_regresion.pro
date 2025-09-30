Function Tends_Fvg_IMA_regresion, LST, Fvg, Tair=Tair, dev=dev, f_dev=f_dev, plot_=plot_, date=date, outplot=outplot, class=class, bin_x=bin_x
  ;;Estimating TEMPERATURE ENDMENBERS using LST-Fvg space (Ts_max, Ts_min, Tv_max, Tv_min)
  ;;Tends are estimated by means of the regressions of mins and maxs LST by classes of Fvg
  ;;Folowing Stefan et al. (2015)

  pix = where(finite(LST) eq 1 AND finite(Fvg) eq 1,n, Complement=pixNAN)   ;;n = cantidad de pixeles
  
  
  ;if n gt 100 then begin
    x=Fvg[pix]
    y=LST[pix]
    
    ;;S-SEBI
    X_i=0.0   ;0.01 el menor Fvg considerado, menor al m�n; considera sobre 0.05
    if KEYWORD_SET(class) eq 0 then class=1000    ;clases de Fvg
    
    ;if n lt 1000 then class=500    ;clases de albedo
    if KEYWORD_SET(bin_x) eq 0 then bin_x=1./class    ;ancho de clase de albedo ->0.01
    
    min_clasY=fltarr(class)  ;matriz para guardar los min/max (5%clase)
    max_clasY=fltarr(class)
    mean_clasX=fltarr(class)
    ;LSTmin = Ta   ;min(LST,/nan)
    
    for i=0, class-1 do begin   ;i=nro clase
      clasi=X_i+(bin_x*i)   ;
      clasf=X_i+(bin_x*(i+1)) ;(clasi, clasf) rango para c/clase
      ;subindices de matriz albedo qe est�n dentro de clase
      pclas=where(x ge clasi and x lt clasf,npix)
      if npix ge 1 then begin   ;si clase tiene mas de ..5(subcuencas).. pares
        min_clasY[i]=min(y[pclas])
        max_clasY[i]=max(y[pclas])
        mean_clasX[i]=mean(x[pclas])    ;media de todos albedos por c/clase [pclas] considerarlos todos
      endif
    endfor
    
    pix=where(min_clasY ne 0,npix); pix=where(min_clasY ne 0 and mean_clasX le (0.5*alb_umb+0.5*alb_ext),npix)  ;pares para la recta con régimen Evaporativo (LETmax)
    
    if KEYWORD_SET(dev) then begin
      if n_elements(f_dev) eq 0 then f_dev=1 else f_dev=f_dev
      dev_min=f_dev*STDDEV(min_clasY[pix])     ;Desv Std de todos los minimos
      dev_max=f_dev*STDDEV(max_clasY[pix])
    endif else begin
      dev_min=0
      dev_max=0
    endelse

    ;;coeficientes de la recta LSTmin y LSTmax
;    coef_minli=LINFIT(mean_clasX[pix], min_clasY[pix])
;    coef_maxli=LINFIT(mean_clasX[pix], max_clasY[pix])
      coef_minli=LINFIT(mean_clasX[pix], min_clasY[pix])
      coef_maxli=LINFIT(mean_clasX[pix], max_clasY[pix])
;    if coef_minli[1] le 0 then  coef_minli = [mean(min_clasY[pix]), 0]
;    if coef_maxli[1] ge 0 then  coef_maxli = [mean(max_clasY[pix]), 0]
    ;fit_minli=coef_minli[0] + coef_minli[1]*x - 1.*dev_min
    ;fit_maxli=coef_maxli[0] + coef_maxli[1]*x + 1.*dev_max
     
    Ts_min=coef_minli[0] - dev_min
    Tv_min=coef_minli[0] + coef_minli[1]*1. - dev_min
    Ts_max=coef_maxli[0] + dev_max
    Tv_max=coef_maxli[0] + coef_maxli[1]*1. + dev_max
    if Tv_min gt Ts_min then Tv_min=Ts_min
    if Ts_max lt Tv_max then Ts_max=Tv_max
    Tv_max=max([Tv_min,Tv_max])
    
    if n_elements(Tair) ne 0 then begin 
      Tv_min_2=Tair
      Ts_min_2=Tair - coef_minli[1]*1.
    endif

  ;;GRAFICAR POLIGONE  
  if KEYWORD_SET(plot_) then begin
    P= plot(fvg(where(finite(fvg))), LST(where(finite(fvg))), '*', xrange = [0,1], $
      xtitle="Fractional vegetation cover [-]", ytitle="Surface Temperature [K]");yrange=[290,330],
    p2= plot([0, 1], [Ts_max, Tv_max],'r2',/overplot); color=2
    p3= plot([0, 1], [Ts_min, Tv_min],'b2',/overplot); color=4
    p4= plot(mean_clasX[pix], min_clasY[pix],'ob',/overplot)
    p5= plot(mean_clasX[pix], max_clasY[pix],'or',/overplot)
    p.Save, outplot + 'LST_Fc_' + date + '_' + string(strcompress(bin_x,/remove_all),FORMAT='(F0.3)') + '.png', BORDER=10, RESOLUTION=150
    ;p.Save, 'LST_Fvg_dev_' + date + '_DEM450_slop10.png', BORDER=10, RESOLUTION=100
    p.close
  endif
  
  Return, LSTend = [Ts_min, Ts_max, Tv_min, Tv_max]
  close,/all
  
end

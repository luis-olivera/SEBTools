Function Tends_alb_IMA_regresion, LST, alb, Tair=Tair, dev=dev, f_dev=f_dev, plot_=plot_, date=date, outplot=outplot, class=class, bin_x=bin_x,$
                                  alb_ENDMBmin=alb_ENDMBmin,alb_ENDMBmax=alb_ENDMBmax
  ;;Estimating TEMPERATURE ENDMENBERS using LST-alb space (Ts_max, Ts_min, Tv_max, Tv_min)
  ;;Tends are estimated by means of the regressions of mins and maxs LST by classes of alb
  ;;from S-SEBI
  
  pix = where(finite(LST) eq 1 AND finite(alb) eq 1,n, Complement=pixNAN)   ;;n = cantidad de pixeles  
  
  ;if n gt 100 then begin
  x=alb[pix]
  y=LST[pix]
  
  
  ;;S-SEBI
  X_i=min(x)   ;0.01 el menor alb considerado, menor al m�n; considera sobre 0.05
  if KEYWORD_SET(class) eq 0 then class=(max(x) - min(x))/bin_x   ;clases de alb
  
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
  
  
  ;;Defining the seuil (alb_ENDMBmin/max) where estimating the regression line
  pix=where(min_clasY ne 0)
  NDEGREE = 3
  X_umb = max_min_infl(mean_clasX[pix], max_clasY[pix], NDEGREE);[Max,Min,Infl]
  print, "max_min_infl 3er LSTmax", X_umb
  if KEYWORD_SET(alb_ENDMBmax) eq 0 then begin
    alb_ENDMBmax = X_umb[0]
  endif
  
  X_umb = max_min_infl(mean_clasX[pix], min_clasY[pix], NDEGREE);[Max,Min,Infl]
  print, "max_min_infl 3er LSTmin", X_umb
  if KEYWORD_SET(alb_ENDMBmin) eq 0 then begin
    alb_ENDMBmin = X_umb[2]
  endif
    
  
  pix=where(min_clasY ne 0 AND mean_clasX le alb_ENDMBmin,npix); pix=where(min_clasY ne 0 and mean_clasX le (0.5*alb_umb+0.5*alb_ext),npix)  ;pares para la recta con régimen Evaporativo (LETmax)
  pix_max = where(mean_clasX ge alb_ENDMBmax,npix)
  
  if KEYWORD_SET(dev) then begin
    if n_elements(f_dev) eq 0 then f_dev=1 else f_dev=f_dev
    dev_min=f_dev*STDDEV(min_clasY[pix])     ;Desv Std de todos los minimos
    dev_max=f_dev*STDDEV(max_clasY[pix_max])
  endif else begin
    dev_min=0
    dev_max=0
  endelse
  
  ;;coeficientes de la recta LSTmin y LSTmax
  coef_minli=LINFIT(mean_clasX[pix], min_clasY[pix])
  coef_maxli=LINFIT(mean_clasX[pix_max], max_clasY[pix_max])
  
  minli=coef_minli[0] + coef_minli[1]*[min(x),max(x)] - dev_min
  maxli=coef_maxli[0] + coef_maxli[1]*[min(x),max(x)] + dev_max
  
  ;;GRAFICAR POLIGONE
  if KEYWORD_SET(plot_) then begin
    P= plot(x, y, '*', xrange = [0,0.4], $
      xtitle="Surface Albedo [-]", ytitle="Surface Temperature [°C]");yrange=[290,330],
    p4= plot(mean_clasX[pix], min_clasY[pix],'ob',/overplot)
    p5= plot(mean_clasX[pix_max], max_clasY[pix_max],'or',/overplot)
    p2= plot([min(x),max(x)], maxli,'r2',/overplot)
    p3= plot([min(x),max(x)], minli,'b2',/overplot)
    p.Save, outplot + 'LST_alb_' + date + '_' + string(strcompress(bin_x,/remove_all),FORMAT='(F0.3)') + '_ext.png', BORDER=10, RESOLUTION=150
    ;p.Save, 'LST_alb_dev_' + date + '_DEM450_slop10.png', BORDER=10, RESOLUTION=100
    p.close
  endif
  
  Return, LSTend = [[coef_minli], [coef_maxli]]
  close,/all
  
end

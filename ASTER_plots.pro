pro ASTER_plots
  ;;PLOTS
  ;LST-Fvg
  ;LST-Albedo
  ;Fvg-Albedo
  ;Albedo-Emissivity
  close, /all

  
  area = 'Yaqui'
  region='Mexico'
  year=2008
  
  ncols=160
  nrows=100
  xllcorner=599937.60711932
  yllcorner=3011850.9865908
  cellsize=100
  NODATA_value=-9999
  
  Hra_obj = '1130'
  pat='D:\CESBIO\Region\' + region + '\Area\' + area +'\'
  cd,pat
  path = 'Results' + '\'
  
  alpha_1 = [0.1, 0.2]
  alpha_2 = [0.3, 0.3]
  
  met = ['EBsolveg','EBsolveg\TvminTa','Regresion','Regresion_dev','Regresion_dev0.5','Stefan']
  rss=['','_rss','_s92inf']
  
  file_alb = file_search('ASTER\alpha' + '*.txt')
  file_lst = file_search('ASTER\aster' + '*.txt')
  file_fvg = file_search('ASTER\fc' + '*.txt')
  file_emi = file_search('ASTER\emi' + '*.txt')
  
  year = year + make_array(n_elements(file_alb),/integer)
  
  aux = (strsplit(file_alb, '._', /extract))
  aux = aux.ToArray()
  aux = aux[*,-2]
  year[where(aux eq '30dec')] = 2007
  month_name = strmid(aux, 2,3,/REVERSE_OFFSET)
  day = fix(strmid(aux, 0,2))
  YYYYDOY = daymonth2DOY(day, month_name, year)
  sort = sort([YYYYDOY])
  
  for mm=0,1 + 0*(n_elements(met)-1) do begin
    
    for rr=0,(n_elements(rss)-1) do begin;rss
      
      outdir = 'Results\Plots\'
      FILE_MKDIR, outdir+'LST-Fvg',outdir+'Fvg-Albedo',outdir+'Albedo-Emissivity'
      path_lstalb = 'Results\'+met[mm]+'\Tends'+rss[rr]+'\LST-Albedo\'
      FILE_MKDIR,path_lstalb

      path_Tends_1 = 'Results\'+met[mm]+'\Tends'+rss[rr]+'\alb0.10_emis0.960_z0m0.0010_albvg0.20\Tends_EB_mo_'+Hra_obj+'.txt'
      path_Tends_2 = 'Results\'+met[mm]+'\Tends'+rss[rr]+'\alb0.30_emis0.960_z0m0.0010_albvg0.30\Tends_EB_mo_'+Hra_obj+'.txt'
      Tends_1 = read_ascii(path_Tends_1, count= na)
      Tends_2 = read_ascii(path_Tends_2, count= na)

      for i=0,n_elements(file_alb)-1 do begin
        date = string(strcompress(YYYYDOY[sort[i]],/remove_all))
        alb = READ_ASCII(file_alb[sort[i]], count= nalb)
        lst = READ_ASCII(file_lst[sort[i]], count= nlst)
        fvg = READ_ASCII(file_fvg[sort[i]], count= nfvg)
        emi = READ_ASCII(file_emi[sort[i]], count= nfvg)
        ;print, nx,ny, nz

        alb=alb.(0)
        lst=lst.(0)
        fvg=fvg.(0)
        emissivity=emi.(0)

        fc=fvg ; --> MODIFICAR!!!!

;        ;;LSTend
;        if met[mm] eq 'Stefan' then $
;          LSTend = Tends_Fvg_IMA(LST, fc);Fvg_ENDMBmax=0.6);, Tair=280.0
;        if met[mm] eq 'Regresion' then $
;          LSTend = Tends_Fvg_IMA_regresion(LST, fc, date=date, outplot=outplot);, /plot
;        if met[mm] eq 'Regresion_dev' then $
;          LSTend = Tends_Fvg_IMA_regresion(LST, fc, /dev, date=date, outplot=outplot);, /plot--> +-stddev, guardar plot con date en el nom
;        if met[mm] eq 'Regresion_dev0.5' then $
;          LSTend = Tends_Fvg_IMA_regresion(LST, fc, /dev, f_dev=0.5, date=date, outplot=outplot);, /plot--> +-0.5stddev
;        if met[mm] eq 'EBsolveg\TvminTa' OR met[mm] eq 'EBsolveg' then begin
;          LSTend_1 = Tends_1.FIELD1[1:5,i]
;          LSTend_2 = Tends_2.FIELD1[1:5,i]
;          ;LSTend = Tends_Fvg_IMA_regresion(LST, fc, date=date, outplot=outplot);, /plot
;          LSTend = Tends_Fvg_IMA_regresion(LST, fc, /dev, f_dev=0.5, date=date, outplot=outplot)
;        endif
;
;        LSTcor = LSTcor_alb(lst, alb, fc, LSTend, LSTend_1, LSTend_2, alpha_1, alpha_2)
;        
;        LSTend_cor = Tends_Fvg_IMA_regresion(LSTcor, fc, /dev, f_dev=0.5, date=date, outplot=outplot)
;        
;        LSTend_EB = mean([[LSTend_1],[LSTend_2]],dimension=2) ; Ts -->alb_s=0.2
;        LSTend_EB[2:3] = LSTend_1[2:3]                        ; Tv -->alb_vg=0.2
        
        veg=where(fc gt 0.8);NDVI=0.78
        sol=where(fc lt 0.05);NDVI=0.18  fvg(ndvi)=0.1(0.22)

        ;;GRAFICAR POLIGONE
;;        P= plot(fvg[NoNaN], LST[NoNaN], '*', xrange=[0,1], $
;;          xtitle="Fractional green vegetation cover [-]", ytitle="Surface Temperature [K]");yrange=[290,330],
;;        p.Save, outdir + 'LST-Fvg\LST_Fvg_' + date + '.png', BORDER=10, RESOLUTION=100
;;        p.close
        
        P= plot(Alb, LST, '*', xrange=[0,0.4], $
          xtitle="Surface Albedo [-]", ytitle="Surface Temperature [K]");yrange=[290,330],
        p2= plot(Alb[sol],LST[sol],'mo',/overplot, NAME='fvg<0.05')
        if n_elements(veg) gt 1 then $
          p3= plot(Alb[veg],LST[veg],'go',/overplot, NAME='fvg>0.8')


        Tsmax_alb01 = Tends_1.FIELD1[2,i] - 273.15
        Tsmax_alb03 = Tends_2.FIELD1[2,i] - 273.15
        p4= plot([alpha_1[0], alpha_2[0]], [Tsmax_alb01, Tsmax_alb03],'r2-',/overplot, NAME='Tsmax_alb'); color=2
        leg = LEGEND(TARGET=[p2,p3,p4], POSITION=[0.9,0.9])

        p.Save, path_lstalb + 'LST_Alb_' + date + '_'+Hra_obj + '.png', BORDER=10, RESOLUTION=100
        p.close
        
;        P= plot(Alb, fvg, '*', xrange=[0,0.5], yrange=[0,1], $
;          xtitle="Surface Albedo [-]", ytitle="Fractional green vegetation cover [-]");yrange=[290,330],
;        p.Save, outdir + 'Fvg-Albedo\Fvg_Alb_' + date + '.png', BORDER=10, RESOLUTION=100
;        p.close
;;        P= plot(Alb, emis_soil, '*', xrange=[0,0.5], yrange=[0.95,1], $
;;          xtitle="Surface Albedo [-]", ytitle="Soil Emissivity [-]");yrange=[290,330],
;;        p.Save, outdir + 'Albedo-Emissivity\Alb_emissoil_' + date + '.png', BORDER=10, RESOLUTION=100
;;        p.close
;        P= plot(Alb, emissivity, '*', xrange=[0,0.5], yrange=[0.90,1], $
;          xtitle="Surface Albedo [-]", ytitle="Surface Emissivity [-]");yrange=[290,330],
;        if n_elements(veg) gt 1 then $
;          p3= plot(Alb[veg],emissivity[veg],'go',/overplot); color=2)
;        p2= plot(Alb[sol],emissivity[sol],'mo',/overplot); color=2)
;        p.Save, outdir + 'Albedo-Emissivity\Alb_emissivity_' + date + '.png', BORDER=10, RESOLUTION=100
;        p.close
        

      endfor;n_image
      
    endfor;rss   
    
    
  endfor;met
  
end
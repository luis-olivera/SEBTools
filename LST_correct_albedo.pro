Pro LST_correct_albedo
  
  area = 'Yaqui'
  region='Mexico'
  year=2008
  
  ncols=160
  nrows=100
  
  pat='D:\CESBIO\Region\' + region + '\Area\' + area +'\'
  cd,pat
  
  IMA=read_tiff('ASTER\formato_tif.tif', geotiff=g_tags)
  
  
  Hra_obj = '1130'
  alpha_1 = [0.1, 0.2]  ;alpha_i : [alpha_s , alpha_v]_i
  alpha_2 = [0.3, 0.3]
  
  bin_x = 0.01
  EB = ['EBsolveg','EBsolveg\TvminTa']
  met = ['Regresion','Regresion_dev0.5','Stefan'];,'Regresion_dev'
  comb = 'Combined';''  ;to combine EB/contextual method
  Cg_met=['','_cgOM13']
  
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
  
  for cc=0,0 do begin
    for ee=0,(n_elements(EB)-1) do begin
      for mm=0,(n_elements(met)-1) do begin
      
        for rr=0,(n_elements(rss)-1) do begin;rss
        
          root = 'Results\' + EB[ee] + '\Tends'+rss[rr]+ '\'
          outdir = root + met[mm] + Cg_met[cc] + '\Cor_alb2_'+Hra_obj+'\';v2\
          FILE_MKDIR, outdir+'Poligone', outdir+'LST'
          
          path_Tends_1 = root + '\alb0.10_emis0.960_z0m0.0010_albvg0.20'+Cg_met[cc]+'\Tends_EB_mo_'+Hra_obj+'.txt'    ;Tend for soil albedo
          path_Tends_2 = root + '\alb0.30_emis0.960_z0m0.0010_albvg0.30'+Cg_met[cc]+'\Tends_EB_mo_'+Hra_obj+'.txt'    ;Tend for senescent veget albedo
          Tends_1 = read_ascii(path_Tends_1, count= na)
          Tends_2 = read_ascii(path_Tends_2, count= na)
          
          for i=0,n_elements(file_alb)-1 do begin
            date = string(strcompress(YYYYDOY[sort[i]],/remove_all))
            alb = READ_ASCII(file_alb[sort[i]], count= nalb)
            lst = READ_ASCII(file_lst[sort[i]], count= nlst)
            fvg = READ_ASCII(file_fvg[sort[i]], count= nfvg)
            emi = READ_ASCII(file_emi[sort[i]], count= nfvg)

            alb=alb.(0)
            lst=lst.(0)
            fvg=fvg.(0)
            emi=emi.(0)
            
            fc=fvg ; --> MODIFICAR!!!!
            
            ;;LSTend
            outplot = outdir + 'Poligone\Ext\'
            FILE_MKDIR, outplot
            ;if EB[ee] eq 'EBsolveg\TvminTa' OR met[mm] eq 'EBsolveg' then begin
            LSTend_1 = Tends_1.FIELD1[1:5,i]
            LSTend_2 = Tends_2.FIELD1[1:5,i]
            ;LSTend = Tends_Fvg_IMA_regresion(LST, fc, date=date, outplot=outplot);, /plot
            ;LSTend = Tends_Fvg_IMA_regresion(LST, fc, /dev, f_dev=0.5, date=date, outplot=outplot)
            ;endif
            
            if met[mm] eq 'Stefan' then $
              LSTend = Tends_Fvg_IMA(LST, fc);Fvg_ENDMBmax=0.6);, Tair=280.0
            if met[mm] eq 'Regresion' then $
              LSTend = Tends_Fvg_IMA_regresion(LST, fc, date=date, outplot=outplot, bin_x=bin_x);, /plot_
            if met[mm] eq 'Regresion_dev' then $
              LSTend = Tends_Fvg_IMA_regresion(LST, fc, /dev, date=date, outplot=outplot, bin_x=bin_x);, /plot_ --> +-stddev, guardar plot con date en el nom
            if met[mm] eq 'Regresion_dev0.5' then $
              LSTend = Tends_Fvg_IMA_regresion(LST, fc, /dev, f_dev=0.5, date=date, outplot=outplot, bin_x=bin_x);, /plot --> +-0.5stddev
              
            ;          if comb eq 'Combined' then begin
            ;            LSTend_1([0,2]) = min([[LSTend_1([0,2])],[LSTend([0,2])]], DIMENSION=2)
            ;            LSTend_1([1,3]) = max([[LSTend_1([1,3])],[LSTend([1,3])]], DIMENSION=2)
            ;          endif
            
            
            LSTcor = LSTcor_alb(lst, alb, fc, LSTend, LSTend_1, LSTend_2, alpha_1, alpha_2)
;            write_tiff, outdir + 'LST\lst_' + date + '.tif', REFORM(LSTcor,ncols,nrows), /float, geotiff=g_tags
            
            
            if met[mm] eq 'Stefan' then $
              LSTend_cor = Tends_Fvg_IMA(LSTcor, fc);Fvg_ENDMBmax=0.6);, Tair=280.0
            if met[mm] eq 'Regresion' then $
              LSTend_cor = Tends_Fvg_IMA_regresion(LSTcor, fc, date=date, outplot=outplot, bin_x=bin_x)
            if met[mm] eq 'Regresion_dev' then $
              LSTend_cor = Tends_Fvg_IMA_regresion(LSTcor, fc, /dev, date=date, outplot=outplot, bin_x=bin_x);, /plot--> +-stddev, guardar plot con date en el nom
            if met[mm] eq 'Regresion_dev0.5' then $
              LSTend_cor = Tends_Fvg_IMA_regresion(LSTcor, fc, /dev, f_dev=0.5, date=date, outplot=outplot, bin_x=bin_x);, /plot--> +-0.5stddev
              
            LSTend_EB = mean([[LSTend_1],[LSTend_2]],dimension=2) ; Ts -->alb_s=0.2
            LSTend_EB[2:3] = LSTend_1[2:3]                        ; Tv -->alb_vg=0.2
            
            ;;GRAFICAR POLIGONE EB
            LSTend_EB = LSTend_EB - 273.16
            p = plot_Tend_EB(fc, LST, LSTcor, LSTend, LSTend_cor, LSTend_EB)
            p.Save, outdir + 'Poligone\LST_fvg_' + date + '_' + string(strcompress(bin_x,/remove_all),FORMAT='(F0.3)') + '.png', BORDER=10, RESOLUTION=150
            p.close
            
          endfor;n_image          
        endfor;rss        
      endfor;met
    endfor;EB
  endfor;met_Cg
  
  
  
end


function plot_Tend_EB, fvg, LST, LSTcor, LSTend, LSTend_cor, LSTend_EB

  w = WINDOW(DIMENSIONS=[1200,500])
  P= plot(fvg(where(finite(fvg))), LST(where(finite(fvg))), '*', xrange=[0,1], $
    xtitle="Fractional vegetation cover [-]", ytitle="Surface Temperature [K]", $
    TITLE='ASTER LST', /CURRENT, LAYOUT=[2,1,1])
  p2= plot([0, 1], [LSTend_EB[1], LSTend_EB[3]],'r2',/overplot, NAME='Energy Balance'); color=2
  p3= plot([0, 1], [LSTend_EB[0], LSTend_EB[2]],'r2',/overplot); color=4
  p4= plot([0, 1], [LSTend[1], LSTend[3]],'b2--',/overplot, NAME='Image-based'); color=2
  p5= plot([0, 1], [LSTend[0], LSTend[2]],'b2--',/overplot); color=4
  leg = LEGEND(TARGET=[p2,p4], POSITION=[0.9,0.9])

  P_= plot(fvg(where(finite(fvg))), LSTcor(where(finite(fvg))), '*', xrange=[0,1], $
    xtitle="Fractional vegetation cover [-]", ytitle="Surface Temperature [K]", $
    TITLE='Normalized ASTER LST', /CURRENT, LAYOUT=[2,1,2])
  p2= plot([0, 1], [LSTend_EB[1], LSTend_EB[3]],'r2',/overplot, NAME='Energy Balance'); color=2
  p3= plot([0, 1], [LSTend_EB[0], LSTend_EB[2]],'r2',/overplot); color=4
  p4= plot([0, 1], [LSTend_cor[1], LSTend_cor[3]],'b2--',/overplot, NAME='Image-based'); color=2
  p5= plot([0, 1], [LSTend_cor[0], LSTend_cor[2]],'b2--',/overplot); color=4

  return, p
end

function coeffs_FAO2kc_LST_IV, Ts_min, Ts_max, Tv_min, Tv_max, fvg, K_max, fc=fc

  Ks = (Tv_max - Tv)/(Tv_max - Tv_min)
  Kr = (Ts_max - Ts)/(Ts_max - Ts_min)
  if Tv_max eq Tv_min then Ks = Kr
  Kcb_fv = K_max*fvg
  Ke_fv = K_max*(1. - fvg)*Kr
  if KEYWORD_SET(fc) then $
    Ke_fc = K_max*(1. - fc)*Kr

  if KEYWORD_SET(fc) then $
    return, [[[Ks]],[[Kr]],[[Kcb_fv]],[[Ke_fv]], [[Ke_fc]]] $
    else return, [[[Ks]],[[Kr]],[[Kcb_fv]],[[Ke_fv]]]
      
end
Function EB_soil_mo_cg, epsilon, alpha, NDVI, zr, z0m, rss, ta, ua, rg, rha, SIGMA
  ;*flag, *tsoil, *evaporation, *conduction, *sensible, *radiation, *rah_out
  ;  /*===================================================================================
  ;  Script for the implementation of an energy budget for bare soil in the estimation of
  ;  temperature endmembers (Tsmax, Tsmin) as well as associated fluxes - secondary output
  ;  Takes into account the Monin Obukhov length when computing the aerodynamic resistance
  ;
  ;  ===================================================================================*/
  ;      /*========================================================================
  ;      Initialize Ts = Ta and run a loop to estimate Ts (and associated fluxes)
  ;      at equilibrium i.e. f(Ts) = 0; Rss from Sellers et al. 1992; implement the
  ;      iterative computation of Rah using the MO length within the energy budget
  ;      soil (bare soil)
  ;      ==========================================================================*/
  ;
  ;energy_budget_soil_rss_mo(epsilon, alpha, cg, zr, z0m, rss, ta, ua, rg, rha, *flag, *tsoil, *evaporation, *conduction, *sensible, *radiation, *rah_out)
  ;   // x1, xz0m expressions found in Long 2012; x as in Kolskov 2006
  ;   // psi - stability correction factors: psih for heat transport and psim for momentum flux
  
  compile_opt strictarr
  
  RHOCP = 1186.0;  // rho cp air
  CP = 1005
  GRAVITY = 9.81;  // gravity acceleration
  GAMMA = 67.0;  // psychrometric ct
  KARMAN = 0.41; // von Karman ct (value provided by Long 2012)
  L = 2.5e6;   // water heat capacity (capacitate caloriferica)
  
  DELTAT = 0.001;  // Ts accuracy
  NITER_T = 90; // number of iterations considered for running the loop on Ts minimization
  NITER_H = 90
  NITER_rah = 90
  EPST = 0.01; // Temperature accuracy
  EPSF = 0.1;  // Sensible heat H accuracy
  
  ;     /* local variables*/
  d = 0;  // zero plane displacement (0 for bare soils)
  alg = alog((zr-d)/z0m);  // appears in the computation of wind speed (wind speed log profile)-->nat log: base-e
  z0h = z0m   ;0.1*z0m
  alg_h = alog((zr-d)/z0h);
  
  ;    /* initialization */ Ta:[K]
  ;  ta = ta + 273.15;
  ts1 = ta;
  n_ts = 0;
  niter = 0;
  
  ;;;// Loop on Ts
  fts=999
  while ( abs(fts) gt EPST ) do begin ;AND n_ts lt NITER_T
    h_mo = 1;
    le_mo = 1;
    ts = ts1;
    
    ;;;// computing rah iteratively using MO formula
    ;;;// Loop on H
    h_mo0=999
    n_hmo = 0
    while (abs(h_mo0 - h_mo) gt EPSF) do begin
      h_mo0 = h_mo;
      ;;;// Loop on U
      nra = 0;
      psim = 0;
      psim0 = 999
      while (abs(psim0 - psim) gt 0.001 AND nra lt NITER_rah) do begin
        nra = nra+1 ;nra += 1;
        psim0 = psim;
        ustar = (ua * KARMAN) / (alg - psim)                        ; Bastiaanssen 2000 (Eq 9) psim=psim(z_{sur-d},L)  // psim(z0m,L)--> despreciable
        evap = le_mo/L;
        h_mo_br = h_mo + 0.61*CP*ta*evap                            ; // H as expressed in Brutsaert 1982
        ;ta--> Tp: mean air potential temperature
        lmo = -RHOCP * ta *(ustar^3) / (KARMAN * GRAVITY * h_mo_br) ; // as implemented in Kolskov 2006 valid for other papers as well
        x = (1 - 16*(zr-d)/lmo)^0.25;
        psih = 2 * alog( (1+(x^2)) / 2);
        psim = psih/2 + 2*alog( (1+x)/2) - 2*atan(x) + 0.5*!PI      ;Bastiaanssen 1995 (2.80)
        ;;For stability conditions:
        ;psim = -5*(zr-d)/lmo                                           ;Bastiaanssen 19995 (2.82)
      endwhile
      
      if (nra eq NITER_rah) then print,("Reached maximum number of iterations for computing the wind speed");
      
      ;// Resistance
      ;rah = (alg - psih)/(KARMAN * ustar)
      rah = (alg_h - psih)/(KARMAN * ustar); // Bastiaanssen 2000
      
      Fluxes_ts = energy_fluxes_rss(ts, epsilon, alpha, NDVI, zr, z0m, rss, ta, ua, rg, rha, rah, SIGMA, RHOCP, GAMMA);(ET,G,H,Rn)
      ;print, Fluxes_ts
      h_mo = Fluxes_ts[2];sensible_ts;
      le_mo = Fluxes_ts[0];evaporation_ts;
      
      n_hmo = n_hmo + 1
      if (n_hmo eq NITER_H) then break
      
    endwhile;(fabs(h_mo0 - h_mo) > EPSF);
    
    ;;    // Computing energy fluxes
    Fluxes_ts = energy_fluxes_rss(ts, epsilon, alpha, NDVI, zr, z0m, rss, ta, ua, rg, rha, rah, SIGMA, RHOCP, GAMMA);(ET,G,H,Rn)
    evaporation = Fluxes_ts[0]
    conduction = Fluxes_ts[1]
    sensible = Fluxes_ts[2]
    radiation = Fluxes_ts[3]
    ;;    // Computing cost function
    fts = (radiation - conduction - evaporation - sensible)^2
    ;    // Computing derivative of cost function
    dfts = derivative_fts_rss(ts, epsilon, alpha, NDVI, zr, z0m, rss, ta, ua, rg, rha, rah, SIGMA, RHOCP, GAMMA, DELTAT);
    ;    // Finding the zero of f(ts): Newton's method
    ts1 = ts - fts/dfts;
    n_ts = n_ts + 1;
    
    if (n_ts eq NITER_T) then break;
    
  endwhile; ( fabs(fts) > EPST );
  tsoil = ts1; - 273.15;
  
  FLUXES_ts = energy_fluxes_rss( ts1, epsilon, alpha, NDVI, zr, z0m, rss, ta, ua, rg, rha, rah, SIGMA, RHOCP, GAMMA);
  
  evaporation = FLUXES_ts[0]
  conduction = FLUXES_ts[1]
  sensible = FLUXES_ts[2]
  radiation = FLUXES_ts[3]
  
  rah_out = rah;
  stability = zr/lmo
  
  if finite(Tsoil) eq 0 then begin
    a=0
  endif
  
  Return, [Tsoil, Rah_out, stability]
  
end

Function energy_fluxes_rss, ts, epsilon, alpha, NDVI, zr, z0m, rss, ta, ua, rg, rha, rah, SIGMA, RHOCP, GAMMA
  ;*evaporation, *conduction, *sensible, *radiation
  ;    /*=============================================================================================
  ;    Energy budget with Rss from Sellers et al., 1992, and for a given surface soil temperature
  ;    ===============================================================================================*/
  cg = G_Rn(alpha, Ts, NDVI)
  
  ea = esstar(ta)*rha/100;
  ldown = longwave(ea,ta,SIGMA);
  radiation = ( 1-alpha )*rg + epsilon*( ldown-SIGMA*(ts^4) );  // setting a value for the emissivity epsilon_avg = 0.96;
  conduction = cg*( radiation );
  sensible = RHOCP*( ts-ta )/(rah);
  evaporation = ( RHOCP/GAMMA )*( esstar(ts) - ea )/( rss + rah );
  Flux = [evaporation, conduction, sensible, radiation]
  return, Flux
  
end


Function cost_function, evaporation, conduction, sensible, radiation
  ;/*=============================
  ;Cost function = function (Ts)
  ;===============================*/
  return, fts = (radiation - conduction - evaporation - sensible)^2
End


Function derivative_fts_rss, ts, epsilon, alpha, NDVI, zr, z0m, rss, ta, ua, rg, rha, rah, SIGMA, RHOCP, GAMMA, DELTAT
  ;/*=============================================================================
  ;Derivative of the cost function df(Ts) / dTs for Rss from Sellers et al., 1992
  ;===============================================================================*/
  Flux_ts = energy_fluxes_rss( ts, epsilon, alpha, NDVI, zr, z0m, rss, ta, ua, rg, rha, rah, SIGMA, RHOCP, GAMMA);
  
  fts = cost_function(Flux_ts[0], Flux_ts[1], Flux_ts[2], Flux_ts[3]);
  
  Flux_DELTAT = energy_fluxes_rss( ts + DELTAT, epsilon, alpha, NDVI, zr, z0m, rss, ta, ua, rg, rha, rah, SIGMA, RHOCP, GAMMA);
  
  fts_delta = cost_function(Flux_DELTAT[0], Flux_DELTAT[1], Flux_DELTAT[2], Flux_DELTAT[3]);
  
  deriv = (fts_delta - fts)/DELTAT;
  
  return, deriv;
end


Function esstar, t
  ;/*===========================================
  ;Estimating saturation vapor pressure (Pa)
  ;=============================================*/
  esout = 611*exp(17.3*(t-273.15)/(t+237.3-273.15)); en Pa */
  return, esout
end

Function longwave, ea, ta, SIGMA
  ;/*========================================================
  ;Estimating longwave radiation (W/m2) as in Brutsaert, 1975
  ;==========================================================*/
  epsa = 1.24*(ea/(100*ta))^0.143 ;-->ea:[Pa] ta:[K]; 0.553*(ea/100)^0.143; --> ea:[Pa]
  ldown = epsa*SIGMA*(ta^4); = 1.24*(ea/ta)^0.143 * ta^4. * SB
  return, ldown
end

Function G_Rn, alpha, Ts, NDVI
  ;;Module to estimate Cg
  ;c1 = 0.32*alb + 0.62*alb^2               ;;alb: hemispherical surface reflectance (daytime-representative value)
  c1 = 0.0038*alb + 0.0074*alb^2           ;Bastiaanssen 2000
  Factor1 = c1*(Ts-273.15)/alb
  Factor2 = 1 - 0.978*NDVI^4
  ;Factor2 = 1 - 0.98*NDVI^4               ;Bastiaanssen 2000
  cg = Factor1*Factor2
  return, cg; [cg,c1,Factor1,Factor2]
end
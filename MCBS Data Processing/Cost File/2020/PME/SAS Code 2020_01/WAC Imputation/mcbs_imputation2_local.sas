libname drugs "Y:\Share\SMAG\MCBS\MCBS PM\AWP Imputation\2020";

/*WAC 3 in PM documentation*/
/*Note: download sas dataset FDB_NDC_BASE_20XX and MCBS_NDC_PRICES_FDB_20XX after running program mcbs_imputation1_server.sas*/

/*merge on NDC prices and "WAC"(estimated AWP) info to the FDB file provided by Maggie*/;
proc sql;
   create table drugs as 
   select a.*,
          b.TOT_SCRIPTS,
          b.UNIT_COST_AVG_TRIMMED,
          b.MEAN_UNIT_PRICE,
          c.WAC_UNIT_PRICE
   from drugs.fdb_with_last_years_WAC_merged a left join drugs.MCBS_NDC_PRICES_FDB_2020 b 
                                                  on a.ndc=b.ndc
                                               left join drugs.FDB_NDC_BASE_2020 c 
                                                  on a.ndc=c.ndc;
quit;

data drugs;
   set drugs;
   if WAC_UNIT_PRICE=0 then WAC_UNIT_PRICE=.; else WAC_UNIT_PRICE=WAC_UNIT_PRICE;/*a couple of records with WAC_UNIT_PRICE=0, not too many*/
   if WAC_UNIT_PRICE=. then missing_price=1; else missing_price=0;
   if WAC_UNIT_PRICE ne . then wac_factor=UNIT_COST_AVG_TRIMMED/WAC_UNIT_PRICE;
   if TOT_SCRIPTS=. then TOT_SCRIPTS=0;
run;

proc sort data=drugs;
   by descending missing_price descending TOT_SCRIPTS;
run;

proc freq data=drugs; 
   weight TOT_SCRIPTS; 
   table missing_price;
run;

/*create summary level AWP factors at increasing levels of granularity*/;
%macro WAC_FACTOR (LABEL, CLASSVARS);
proc summary data=drugs nway;
   class &CLASSVARS.;
   freq TOT_SCRIPTS;
   output out=&LABEL
   mean(wac_factor)=WAC_FACTOR_&label.
   mean(WAC_UNIT_PRICE)=WAC_BB_&label.;
run;
%mend;

%WAC_FACTOR(ALL, );
%WAC_FACTOR(GTC, GTC);
%WAC_FACTOR(ETC, GTC ETC_ID);
%WAC_FACTOR(GNN, GTC ETC_ID GNN);
%WAC_FACTOR(BN , GTC ETC_ID GNN BN);
%WAC_FACTOR(GSN, GTC ETC_ID GNN BN GCN_SEQNO);
%WAC_FACTOR(NDC, GTC ETC_ID GNN BN GCN_SEQNO NDC);

data drugs;
   set drugs; 
   alldummy=1;
run;

data all;
   set all;
   alldummy=1;
run;

proc sql;
   create table drugs_factors as
   select drugs.*,
          ALL.WAC_FACTOR_ALL,
          GTC.WAC_FACTOR_GTC,
          ETC.WAC_FACTOR_ETC,
          GNN.WAC_FACTOR_GNN,
          BN.WAC_FACTOR_BN,
          GSN.WAC_FACTOR_GSN,
          NDC.WAC_FACTOR_NDC,
          ALL.WAC_BB_ALL,
          GTC.WAC_BB_GTC,
          ETC.WAC_BB_ETC,
          GNN.WAC_BB_GNN,
          BN.WAC_BB_BN,
          GSN.WAC_BB_GSN,
          NDC.WAC_BB_NDC
   from drugs left join all 
                 on drugs.alldummy=ALL.alldummy
              left join GTC 
                 on drugs.GTC=GTC.GTC
              left join ETC 
                 on drugs.GTC=ETC.GTC and drugs.ETC_ID=ETC.ETC_ID
              left join GNN 
                 on drugs.GTC=GNN.GTC and drugs.ETC_ID=GNN.ETC_ID and drugs.GNN=GNN.GNN
              left join BN 
                 on drugs.GTC=BN.GTC and drugs.ETC_ID=BN.ETC_ID and drugs.GNN=BN.GNN and drugs.BN=BN.BN
              left join GSN 
                 on drugs.GTC=GSN.GTC and drugs.ETC_ID=GSN.ETC_ID and drugs.GNN=GSN.GNN and drugs.BN=GSN.BN and drugs.GCN_SEQNO=GSN.GCN_SEQNO
              left join NDC 
                 on drugs.GTC=NDC.GTC and drugs.ETC_ID=NDC.ETC_ID and drugs.GNN=NDC.GNN and drugs.BN=NDC.BN and drugs.GCN_SEQNO=NDC.GCN_SEQNO and drugs.NDC=NDC.NDC;
quit;

data drugs_impute_prices;
   set drugs_factors;
   if WAC_FACTOR_NDC=0 then WAC_FACTOR_NDC=.; else WAC_FACTOR_NDC=WAC_FACTOR_NDC;
   if WAC_FACTOR_GSN=0 then WAC_FACTOR_GSN=.; else WAC_FACTOR_GSN=WAC_FACTOR_GSN;
   if WAC_FACTOR_BN=0 then WAC_FACTOR_BN=.; else WAC_FACTOR_BN=WAC_FACTOR_BN;
   if WAC_FACTOR_GNN=0 then WAC_FACTOR_GNN=.; else WAC_FACTOR_GNN=WAC_FACTOR_GNN;
   if WAC_FACTOR_ETC=0 then WAC_FACTOR_ETC=.; else WAC_FACTOR_ETC=WAC_FACTOR_ETC;
   *factor imputed;
   if WAC_FACTOR_NDC ne . then factorimputed_price=UNIT_COST_AVG_TRIMMED/WAC_FACTOR_NDC;
      else if WAC_FACTOR_GSN ne . then factorimputed_price=UNIT_COST_AVG_TRIMMED/WAC_FACTOR_GSN;
         else if WAC_FACTOR_BN  ne . then factorimputed_price=UNIT_COST_AVG_TRIMMED/WAC_FACTOR_BN;
            else if WAC_FACTOR_GNN ne . then factorimputed_price=UNIT_COST_AVG_TRIMMED/WAC_FACTOR_GNN;
               else if WAC_FACTOR_ETC ne . then factorimputed_price=UNIT_COST_AVG_TRIMMED/WAC_FACTOR_ETC;
                  else if WAC_FACTOR_GTC ne . then factorimputed_price=UNIT_COST_AVG_TRIMMED/WAC_FACTOR_GTC;
                     else if WAC_FACTOR_ALL ne . then factorimputed_price=UNIT_COST_AVG_TRIMMED/WAC_FACTOR_ALL;
   *wac imputed;
   if WAC_BB_NDC ne . then WACimputed_price=WAC_BB_NDC;
      else if WAC_BB_GSN ne . then WACimputed_price=WAC_BB_GSN;
         else if WAC_BB_BN  ne . then WACimputed_price=WAC_BB_BN;
            else if WAC_BB_GNN ne . then WACimputed_price=WAC_BB_GNN;
               else if WAC_BB_ETC ne . then WACimputed_price=WAC_BB_ETC;
                  else if WAC_BB_GTC ne . then WACimputed_price=WAC_BB_GTC;
                     else if WAC_BB_ALL ne . then WACimputed_price=WAC_BB_ALL;

   if WAC_UNIT_PRICE ne . then do; 
                             price=WAC_UNIT_PRICE;
                             imputed='NO';
                          end;
      else if factorimputed_price ne . then do; 
                                          price=factorimputed_price;
                                          imputed='MC';
                                       end;
         else if WACimputed_price ne . then do; 
                                          price=WACimputed_price;
                                          imputed='BB';
                                       end;
run;

data drugs.FDB_WAC_imputed_2020(keep=NDC price imputed);
   set drugs_impute_prices;
run;

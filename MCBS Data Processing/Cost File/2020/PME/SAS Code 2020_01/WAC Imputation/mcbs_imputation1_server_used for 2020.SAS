/*Note: upload pmedname_fdb_20 to CCW in the work library before running this program*/;

%let YEAR=2020;
%let bgdate=20210331; 

/*2020 raw data: NDC and ingredient cost*/;
proc sql;
   create table claims_&year(compress=yes) as
   select NDC,
          INGRDNT_CST_PD_AMT/QTY_DSPNSD_NUM as UNIT_PRICE_RAW,
		  (case
              when DAYS_SUPLY_NUM <= 34 then 1
                 else (DAYS_SUPLY_NUM/30)  
           end) as TOT_SCRIPTS_CNT /*30 days equivalent method*/
   from GVCLM18.PTD_EVENT_&YEAR /*this is the folder name*/
   order by NDC;/*pre-sort the data for proc means later*/
quit;

/*replace "outlier prices" with median or weighted mean*/;
*MEAN, MEDIAN, 5TH AND 95TH PERCENTILES by NDC;
proc means data=claims_&year;
   by NDC;
   var UNIT_PRICE_RAW;
   output out=PRICE_STAT_&YEAR(drop=_TYPE_
                               rename=(_FREQ_=TOT_SCRIPTS))
   mean=MEAN_UNIT_PRICE
   median=MEDIAN_UNIT_PRICE
   p5=P5_UNIT_PRICE
   p95=P95_UNIT_PRICE;
run;

/*weighted MEAN by NDC*/;
proc means mean std n data=claims_&year;
   var UNIT_PRICE_RAW;
   by NDC;
   weight TOT_SCRIPTS_CNT;
   output out=WEIGHTED_MEAN_&year mean=WEIGHTED_MEAN_UNIT_PRICE n=TOT_SCRIPTS;
run;

proc sql;
   create table NDC_PRICES_&YEAR as
   select distinct PDE.NDC,
          STATS.TOT_SCRIPTS, /*regular total fills*/
		  STATS.MEAN_UNIT_PRICE,
          avg(case 
                 when ((PDE.UNIT_PRICE_RAW < STATS.P5_UNIT_PRICE) or (PDE.UNIT_PRICE_RAW > STATS.P95_UNIT_PRICE)) then STATS.MEDIAN_UNIT_PRICE
                    else PDE.UNIT_PRICE_RAW
		      end) as UNIT_COST_AVG_TRIMMED,
		  sum(PDE.TOT_SCRIPTS_CNT) as TOT_SCRIPTS30, /*total fills based on 30 days equivalent method*/
		  STATS2.WEIGHTED_MEAN_UNIT_PRICE,
		  avg(case 
                 when ((PDE.UNIT_PRICE_RAW < STATS.P5_UNIT_PRICE) or (PDE.UNIT_PRICE_RAW > STATS.P95_UNIT_PRICE)) then STATS2.WEIGHTED_MEAN_UNIT_PRICE
                    else PDE.UNIT_PRICE_RAW
		      end) as UNIT_COST_AVG_TRIMMED2
   from CLAIMS_&YEAR PDE left join PRICE_STAT_&YEAR STATS
	                        on PDE.NDC=STATS.NDC
					     left join WEIGHTED_MEAN_&year STATS2
						    on PDE.NDC=STATS2.NDC
   group by PDE.NDC 
   order by PDE.NDC;
quit;;

/*select FDB descriptive variables*/;
proc sql;
   create table fdb_&year as 
   select a.NDC, 
          a.BN, /*Brand Name*/
          a.GNN, /*USAN Generic Name - Short Version*/
          a.GCN_SEQNO, /*Generic Code Number Sequence Number*/
          a.STR, /*Drug Strength Description*/
          a.GCDF, /*Dosage Form Code (2 character)*/
          a.GCRT2, /*Route of Administration Code (2-character)*/
          a.GTC, /*Therapeutic Class Code, Generic*/
          a.GTC_DESC, /*Therapeutic Class Code Description, Generic*/
          a.TC, /*Therapeutic Class Code, Standard*/
          a.TC_DESC, /*Therapeutic Class Code Description, Generic*/
          b.etc_id, /*ETC ID-a unique identifier that represents a unique therapeutic classification*/
          b.etc_name, /*ETC Name-a descriptive name for a therapeutic classification */
          c.bg_ind /*Final Assigned Brand/Generic Indicator (B=Brand, BG=Branded Generic, G=Generic, UNK = Unknown)*/
   from partd.ndc_base_&year a left join partd.etc_&year b 
                                  on a.gcn_seqno=b.gcn_seqno
                               left join partd.idr_bg_ind_&bgdate c 
                                  on a.NDC=c.NDC 
   where b.etc_common_use_ind='1'
   group by a.NDC
   order by a.NDC;
quit;

/*testing if there's any dups;
proc sql;
   create table test as 
   select distinct NDC,
                   count(NDC) as NDC_CT
   from fdb_&year
   group by NDC
   having NDC_CT gt 1
   order by NDC;
quit;
*/;

/*merge on FDB info to price file*/;
proc sql;
   create table MCBS_NDC_PRICES_FDB_&year as 
   select a.*,
          b.*
   from NDC_PRICES_&YEAR a left join fdb_&year b
                              on a.NDC=b.NDC;
quit;

/*match stats*/;
proc sql;
   select sum(case when GNN is null then TOT_SCRIPTS else 0 end) format=comma20. as nonmatch,
          sum(TOT_SCRIPTS) format=comma20. as total,
          sum(case when GNN is null then TOT_SCRIPTS else 0 end)/sum(TOT_SCRIPTS) format=percent20.4 as nonmatch_pct
   from MCBS_NDC_PRICES_FDB_&year;
quit;

/*retrieve FDB WAC info*/;
proc sql;
   create table FDB_WAC_UNIT_&YEAR as
   select distinct NDC,
                   NPT_PRICEX as WAC_UNIT_PRICE, 
                   NPT_DATEC
   from PARTD.PRICING_&YEAR
   where NPT_TYPE='09' /*09=Wholesale Acquisition Cost Unit Price*/
   group by NDC,NPT_DATEC
   order by NDC,NPT_DATEC;
quit;

/*get the most recent WAC info based on NDC Price Table - Effective Date*/;
data FDB_WAC_UNIT_&YEAR(drop=NPT_DATEC);
   set FDB_WAC_UNIT_&YEAR;
   by NDC NPT_DATEC;
   if last.NDC then output;
run;

/*merge NDC base and pmedname_fdb_20*/;
proc sql;
   create table FDB_NDC_BASE1_&YEAR as
   select distinct a.NDC,
                   a.BN,
				   a.GNN,
				   a.GCN_SEQNO,
                   a.STR, 
                   a.GCDF,
                   a.GCDF_DESC,
                   a.GCRT2,
                   a.GCRT_DESC,
				   b.pmform_fdb_desc as MCBS_FORM 				 
   from PARTD.NDC_BASE_&YEAR a left join MMU834SL.pmedname_fdb_20 b /*Change to PL000000 due to the Cloud??*/
                                  on a.BN=b.BN
									 and a.GNN=b.GNN
									 and a.STR=b.STR							 
   order by a.NDC,
            a.BN,
		    a.GNN,
			a.GCN_SEQNO,
            a.STR, 
            a.GCDF,
            a.GCDF_DESC,
            a.GCRT2,
            a.GCRT_DESC,
			b.pmform_fdb_desc;
quit;

/*===1===BN + GNN + STR + MCBS_FORM*/;
proc sql;
   create table BN_GNN_STR_MCBS_FORM(compress=yes) as 
   select distinct BN, 
                   GNN,
                   STR, 
                   MCBS_FORM
   from FDB_NDC_BASE1_&YEAR
   order by  BN, 
             GNN,
             STR,
             MCBS_FORM;
quit;

data BN_GNN_STR_MCBS_FORM(compress=yes);
   set BN_GNN_STR_MCBS_FORM;
   BN_GNN_STR_MCBS_FORM=compress('grp'||_N_+0);
run;

/*===2===BN + GNN + STR*/;
proc sql;
   create table BN_GNN_STR(compress=yes) as 
   select distinct BN, 
                   GNN,
                   STR
   from FDB_NDC_BASE1_&YEAR
   order by  BN, 
             GNN,
             STR;
quit;

data BN_GNN_STR(compress=yes);
   set BN_GNN_STR;
   BN_GNN_STR=compress('grp'||_N_+0);
run;

/*===3===GNN + STR + MCBS_FORM*/;
proc sql;
   create table GNN_STR_MCBS_FORM(compress=yes) as 
   select distinct GNN,
                   STR, 
                   MCBS_FORM
   from FDB_NDC_BASE1_&YEAR
   order by  GNN,
             STR,
             MCBS_FORM;
quit;

data GNN_STR_MCBS_FORM(compress=yes);
   set GNN_STR_MCBS_FORM;
   GNN_STR_MCBS_FORM=compress('grp'||_N_+0);
run;

/*===4===GNN + STR*/;
proc sql;
   create table GNN_STR(compress=yes) as 
   select distinct GNN,
                   STR
   from FDB_NDC_BASE1_&YEAR
   order by  GNN,
             STR;
quit;

data GNN_STR(compress=yes);
   set GNN_STR;
   GNN_STR=compress('grp'||_N_+0);
run;

/*NDC base*/
proc sql;
   /*merge with WAC unit price and claims (weight)*/
   create table FDB_NDC_BASE2_&YEAR(compress=yes) as
   select a.*,
          b.WAC_UNIT_PRICE,
		  c.TOT_SCRIPTS_CNT
   from FDB_NDC_BASE1_&YEAR a left join FDB_WAC_UNIT_&YEAR b
                                 on a.NDC=b.NDC
							  left join claims_&year c
							     on a.NDC=c.NDC;

   /*merge with the BN + GNN + STR + MCBS_FORM flag*/
   create table FDB_NDC_BASE31_&YEAR(compress=yes) as
   select a.*,
          b.BN_GNN_STR_MCBS_FORM
   from FDB_NDC_BASE2_&YEAR a left join BN_GNN_STR_MCBS_FORM b
                                 on a.BN=b.BN
								 and a.GNN=b.GNN
						         and a.STR=b.STR
							     and a.MCBS_FORM=b.MCBS_FORM;

   /*merge with the BN + GNN + STR flag*/
   create table FDB_NDC_BASE32_&YEAR(compress=yes) as
   select a.*,
          b.BN_GNN_STR
   from FDB_NDC_BASE31_&YEAR a left join BN_GNN_STR b
                                  on a.BN=b.BN
								  and a.GNN=b.GNN
								  and a.STR=b.STR;
quit;

proc datasets lib=work; 
delete claims_&year FDB_NDC_BASE1_&YEAR FDB_NDC_BASE2_&YEAR FDB_NDC_BASE31_&YEAR; 
run;

proc sql;
   /*merge with the GNN + STR + MCBS_FORM flag*/
   create table FDB_NDC_BASE33_&YEAR(compress=yes) as
   select a.*,
          b.GNN_STR_MCBS_FORM
   from FDB_NDC_BASE32_&YEAR a left join GNN_STR_MCBS_FORM b
                                  on a.GNN=b.GNN
								  and a.STR=b.STR
								  and a.MCBS_FORM=b.MCBS_FORM;

   /*merge with the GNN + STR flag*/
   create table FDB_NDC_BASE34_&YEAR(compress=yes) as
   select distinct a.NDC,
                   a.BN,
                   a.GNN,
                   a.GCN_SEQNO,
                   a.STR,
                   a.GCDF,
                   a.GCDF_DESC,
                   a.GCRT2,
                   a.GCRT_DESC,
                   a.MCBS_FORM,
                   a.WAC_UNIT_PRICE,
                   a.TOT_SCRIPTS_CNT,
                   a.BN_GNN_STR_MCBS_FORM,
                   a.BN_GNN_STR,
                   a.GNN_STR_MCBS_FORM,
                   b.GNN_STR
   from FDB_NDC_BASE33_&YEAR a left join GNN_STR b
                                  on a.GNN=b.GNN
								  and a.STR=b.STR;
quit;

/*BN + GNN + STR + MCBS_FORM*/;
proc sql;
   create table FDB_NDC_BASE41_&YEAR(compress=yes) as
   select distinct BN_GNN_STR_MCBS_FORM, 
                   TOT_SCRIPTS_CNT,
		           WAC_UNIT_PRICE as WAC_UNIT_PRICE_4VARs
   from FDB_NDC_BASE34_&YEAR 
   where  BN_GNN_STR_MCBS_FORM ne '' and WAC_UNIT_PRICE not in (., 0) and TOT_SCRIPTS_CNT ne .
   group by BN_GNN_STR_MCBS_FORM, 
            TOT_SCRIPTS_CNT,
		    WAC_UNIT_PRICE
   order by BN_GNN_STR_MCBS_FORM, 
            TOT_SCRIPTS_CNT,
		    WAC_UNIT_PRICE;
quit;

data FDB_NDC_BASE41_&YEAR;
   set FDB_NDC_BASE41_&YEAR;
   by BN_GNN_STR_MCBS_FORM TOT_SCRIPTS_CNT;
   if last.BN_GNN_STR_MCBS_FORM then output;
run;

/*BN + GNN + STR*/;
proc sql;
   create table FDB_NDC_BASE42_&YEAR(compress=yes) as
   select distinct BN_GNN_STR, 
                   TOT_SCRIPTS_CNT,
		           WAC_UNIT_PRICE as WAC_UNIT_PRICE_3VARs1
   from FDB_NDC_BASE34_&YEAR 
   where BN_GNN_STR ne '' and WAC_UNIT_PRICE not in (., 0) and TOT_SCRIPTS_CNT ne .
   group by BN_GNN_STR, 
            TOT_SCRIPTS_CNT,
		    WAC_UNIT_PRICE
   order by BN_GNN_STR, 
            TOT_SCRIPTS_CNT,
		    WAC_UNIT_PRICE;
quit;

data FDB_NDC_BASE42_&YEAR;
   set FDB_NDC_BASE42_&YEAR;
   by BN_GNN_STR TOT_SCRIPTS_CNT;
   if last.BN_GNN_STR then output;
run;

/*GNN + STR + MCBS_FORM*/;
proc sql;
   create table FDB_NDC_BASE43_&YEAR as
   select distinct GNN_STR_MCBS_FORM, 
                   TOT_SCRIPTS_CNT,
		           WAC_UNIT_PRICE as WAC_UNIT_PRICE_3VARs2
   from FDB_NDC_BASE34_&YEAR 
   where GNN_STR_MCBS_FORM ne '' and WAC_UNIT_PRICE not in (., 0) and TOT_SCRIPTS_CNT ne .
   group by GNN_STR_MCBS_FORM, 
            TOT_SCRIPTS_CNT,
		    WAC_UNIT_PRICE
   order by GNN_STR_MCBS_FORM, 
            TOT_SCRIPTS_CNT,
		    WAC_UNIT_PRICE;
quit;

data FDB_NDC_BASE43_&YEAR;
   set FDB_NDC_BASE43_&YEAR;
   by GNN_STR_MCBS_FORM TOT_SCRIPTS_CNT;
   if last.GNN_STR_MCBS_FORM then output;
run;

/*GNN + STR*/;
proc sql;
   create table FDB_NDC_BASE44_&YEAR as
   select distinct GNN_STR, 
                   TOT_SCRIPTS_CNT,
		           WAC_UNIT_PRICE as WAC_UNIT_PRICE_2VARs
   from FDB_NDC_BASE34_&YEAR 
   where GNN_STR ne '' and WAC_UNIT_PRICE not in (., 0) and TOT_SCRIPTS_CNT ne .
   group by GNN_STR, 
            TOT_SCRIPTS_CNT,
		    WAC_UNIT_PRICE
   order by GNN_STR, 
            TOT_SCRIPTS_CNT,
		    WAC_UNIT_PRICE;
quit;

data FDB_NDC_BASE44_&YEAR;
   set FDB_NDC_BASE44_&YEAR;
   by GNN_STR TOT_SCRIPTS_CNT;
   if last.GNN_STR then output;
run; 

/*final dataset for using WAC*/;
proc sql;
   create table FDB_NDC_BASE_&YEAR as
   select distinct a.NDC,
                   a.WAC_UNIT_PRICE,
                   b.WAC_UNIT_PRICE_4VARs,/*combination of BN + GNN + STR + MCBS_FORM*/
		           c.WAC_UNIT_PRICE_3VARs1,/*combination of BN + GNN + STR*/
                   d.WAC_UNIT_PRICE_3VARs2,/*combination of GNN + STR + MCBS_FORM*/
		           e.WAC_UNIT_PRICE_2VARs /*combination of GNN + STR*/
   from FDB_NDC_BASE34_&YEAR a left join FDB_NDC_BASE41_&YEAR b
                                  on a.BN_GNN_STR_MCBS_FORM=b.BN_GNN_STR_MCBS_FORM
							   left join FDB_NDC_BASE42_&YEAR c
                                  on a.BN_GNN_STR=c.BN_GNN_STR
							   left join FDB_NDC_BASE43_&YEAR d
                                  on a.GNN_STR_MCBS_FORM=d.GNN_STR_MCBS_FORM
                               left join FDB_NDC_BASE44_&YEAR e
                                  on a.GNN_STR=e.GNN_STR
   group by a.NDC,
            a.WAC_UNIT_PRICE,
            b.WAC_UNIT_PRICE_4VARs,
		    c.WAC_UNIT_PRICE_3VARs1,
            d.WAC_UNIT_PRICE_3VARs2,
		    e.WAC_UNIT_PRICE_2VARs;
quit;

data FDB_NDC_BASE_&YEAR;
   set FDB_NDC_BASE_&YEAR;
   if WAC_UNIT_PRICE not in (., 0) then WAC_UNIT_PRICE=WAC_UNIT_PRICE;
      else if WAC_UNIT_PRICE in (., 0) and WAC_UNIT_PRICE_4VARs not in (., 0) then WAC_UNIT_PRICE=WAC_UNIT_PRICE_4VARs;
         else if WAC_UNIT_PRICE in (., 0) and WAC_UNIT_PRICE_4VARs in (., 0) and WAC_UNIT_PRICE_3VARs1 not in (., 0) then WAC_UNIT_PRICE=WAC_UNIT_PRICE_3VARs1;
		    else if WAC_UNIT_PRICE in (., 0) and WAC_UNIT_PRICE_4VARs in (., 0) and WAC_UNIT_PRICE_3VARs1 in (., 0) and WAC_UNIT_PRICE_3VARs2 not in (., 0) then WAC_UNIT_PRICE=WAC_UNIT_PRICE_3VARs2;
			   else if WAC_UNIT_PRICE in (., 0) and WAC_UNIT_PRICE_4VARs in (., 0) and WAC_UNIT_PRICE_3VARs1 in (., 0) and WAC_UNIT_PRICE_3VARs2 in (., 0) and WAC_UNIT_PRICE_2VARs not in (., 0) then WAC_UNIT_PRICE=WAC_UNIT_PRICE_2VARs;
run;

/*download the following datasets into Y:\Share\IPG\DSMA\MCBS\MCBS PM\AWP Imputation\2020
MCBS_NDC_PRICES_FDB_2020
FDB_NDC_BASE_2020
*/

data MMU834sl.FDB_NDC_BASE_2020;/*Change to PL000000 due to the Cloud??*/
set FDB_NDC_BASE_2020;
run;

data MMU834sl.MCBS_NDC_PRICES_FDB_2020;/*Change to PL000000 due to the Cloud??*/
set MCBS_NDC_PRICES_FDB_2020;
run;

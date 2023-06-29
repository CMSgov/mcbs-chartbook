*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
|      PROGRAM: 09_MEDICARE_FACTOR                                                      |
|      UPDATED: 03/18/2015                                                              |
|  INPUT FILES: CCW PDE DATA                                                            |
| OUTPUT FILES: MEDICARE FACTOR RTF FILE                                                |
|  DESCRIPTION: Uses data summary data from CCW to determine Medicare AWP factor.       |
|                                                                                       |
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;
/*This is a two part program*/

/*RUN CCW CODE AT VERY END PRIOR TO RUNNING PC SAS CODE BELOW*/

ODS HTML CLOSE;
  ODS HTML;

OPTION MLOGIC MPRINT SYMBOLGEN COMPRESS=YES;

%LET CURRYEAR=20;
%LET LASTYEAR=19;
%let  FDBdate = 20210310_wac; *this is the date of the FDB file;

%let location= C:\Users\S1C3\RIC PME\MCBS\20&CURRYEAR.\PME\Data\;
libname MCBSDATA "&location";

******************************************************************;
* READ BLUEBOOK DATA                                             *;
******************************************************************;

DATA BLUEBOOK;
set mcbsdata.fdb_&fdbdate
(KEEP=NDC gcn_seqno BN GNN GCDF GCRT STR BBPR CL DF FORM GCDF_DESC 
      PS pd GTC STRNUM STRUN50 ETC_NAME);
run;

***Get PDE claim NDC summary;
DATA MEDICARE_FACTOR_NDC_&CurrYear; SET MCBSDATA.MEDICARE_FACTOR_&CurrYear._export;RUN;


***Merge claims summary with Bluebook data;
PROC SORT DATA=MEDICARE_FACTOR_NDC_&CurrYear ; BY NDC;RUN;
PROC SORT DATA=BLUEBOOK   ; BY NDC;RUN;
DATA PRICE;
MERGE MEDICARE_FACTOR_NDC_&CurrYear (IN=A)
      BLUEBOOK    (IN=B);
BY NDC;
IF A OR B;
RUN;


*Limit to Oral Tablets and Capsules and calculate factors;
DATA SOLIDS; SET PRICE;
IF DF='1' 
AND INDEX(gcdf_desc,'TABLET' )>0 
OR  INDEX(gcdf_desc,'CAPSULE')>0 ;
IF CLAIMS=. THEN DO;
  CLAIMS=0;
  INGREDIENT_SUM=0;
  QUANTITY_SUM=0;
END;

IF QUANTITY_SUM NE 0 THEN DO;
 MEDICARE_UNIT_PRICE = INGREDIENT_SUM      / QUANTITY_SUM;
 MEDICARE_FACTOR     = MEDICARE_UNIT_PRICE / BBPR;
END;


 BBPR_SUM = BBPR * QUANTITY_SUM;
IF QUANTITY_SUM NE 0 THEN DO;
 MEDICARE_FACTOR2= INGREDIENT_SUM / BBPR_SUM;
END;

LABEL MEDICARE_UNIT_PRICE="Average Medicare Unit Price"
     MEDICARE_FACTOR= "Ratio of Medicare Unit Price to Blue Book AWP Unit Price";
RUN;


***Summary Reports;

OPTIONS ORIENTATION=LANDSCAPE;
ODS RTF BODYTITLE STARTPAGE=NO SASDATE 
   file="&location.output\Medicare Factors 20&CURRYEAR - %sysfunc(DATE(),mmddyyd10.).rtf" ;

TITLE1 "MEDICARE DISCOUNT FACTOR (MEDICARE AWP / BLUEBOOK AWP)";
TITLE2 "BASED ON 20% SAMPLE, LIMITED TO ORAL TABLES/CAPSULES WITH MEDIAN QUANTITY";

TITLE3 "OVERALL";
proc sql;
select
 sum(claims)         as claim_sum format=comma20.,
 sum(ingredient_sum) as Medicare_sum format=dollar20.2,
 sum(BBPR_SUM)       as AWP_sum format=dollar20.2,
 sum(ingredient_sum) / sum(BBPR_SUM) as Medicare_ratio format=5.3
from solids;
quit;title3;

TITLE3 "BY CLASS";
proc sql;
select 
 ETC_NAME, 
 sum(claims)         as claim_sum format=comma20.,
 sum(ingredient_sum) as Medicare_sum format=dollar20.2,
 sum(BBPR_SUM)       as AWP_sum format=dollar20.2,
 sum(ingredient_sum) / sum(BBPR_SUM) as Medicare_ratio format=5.3

from solids
group by ETC_NAME
order by  claim_sum descending;
quit;title3;

TITLE3 "BY BRAND NAME";
proc sql;
select 
 BN LABEL="BRAND NAME", 
 sum(claims)         as claim_sum format=comma20.,
 sum(ingredient_sum) as Medicare_sum format=dollar20.2,
 sum(BBPR_SUM)       as AWP_sum format=dollar20.2,
 sum(ingredient_sum) / sum(BBPR_SUM) as Medicare_ratio format=5.3

from solids
group by BN
order by  claim_sum descending;
quit;title3;

title1;
TITLE2;
ODS RTF CLOSE;



/*============================================CCW Code (This must be Run on the CCW Thin Files)================================================================================*/
/*Note: upload pmedname_fdb_19 to CCW in the work library before running this program*/;
%LET   YEAR=20;
%LET SAMPLE=20;
%LET USER=PL000000;*user's SAS library;

%emailx(to=&my_email.,subject=MEDICARE FACTOR JOB SUBMITTED);

/*claims by NDC*/;
/*Note: you can use the dataset, claims_2013 I saved in the COMMON follder. You don't need to re-run this dataset, since this may take 4-5+ hours.*/;
proc sql;
   create table COMMON.claims_20&YEAR as
   select distinct NDC,
          sum((case
              when DAYS_SUPLY_NUM <= 34 then 1
                 else (DAYS_SUPLY_NUM/30)  
           end)) as TOT_SCRIPTS /*30 days equivalent method*/
   from GVCLM18.PTD_EVENT_20&YEAR
   group by NDC
   order by NDC;
quit;

/*the most recent WAC unit price for each NDC*/;
proc sql;
   create table FDB_WAC_UNIT_20&YEAR as
   select distinct NDC,
                   NPT_PRICEX as WAC_UNIT_PRICE, 
                   NPT_DATEC
   from PARTD.PRICING_20&YEAR
   where NPT_TYPE='09' /*09=Wholesale Acquisition Cost Unit Price*/
   group by NDC,NPT_DATEC
   order by NDC,NPT_DATEC;
quit;

data FDB_WAC_UNIT_20&YEAR(drop=NPT_DATEC);
   set FDB_WAC_UNIT_20&YEAR;
   by NDC NPT_DATEC;
   if last.NDC then output;
run;

/*merge NDC base and pmedname_fdb_20*/;
proc sql;
   create table FDB_NDC_BASE1_20&YEAR as
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
   from PARTD.NDC_BASE_20&YEAR a left join pmedname_fdb_20 b /*UPDATE*/
                                    on a.BN=b.BN
									   and a.GNN=b.GNN
									   and a.STR=b.STR							 
   group by a.NDC,
            a.BN,
		    a.GNN,
			a.GCN_SEQNO,
            a.STR, 
            a.GCDF,
            a.GCDF_DESC,
            a.GCRT2,
            a.GCRT_DESC,
			b.pmform_fdb_desc
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
   create table BN_GNN_STR_MCBS_FORM as 
   select distinct BN, 
                   GNN,
                   STR, 
                   MCBS_FORM
   from FDB_NDC_BASE1_20&YEAR
   group by  BN, 
             GNN,
             STR,
             MCBS_FORM
   order by  BN, 
             GNN,
             STR,
             MCBS_FORM;
quit;

data BN_GNN_STR_MCBS_FORM;
   set BN_GNN_STR_MCBS_FORM;
   BN_GNN_STR_MCBS_FORM=compress('grp'||_N_+0);
run;

/*===2===BN + GNN + STR*/;
proc sql;
   create table BN_GNN_STR as 
   select distinct BN, 
                   GNN,
                   STR
   from FDB_NDC_BASE1_20&YEAR
   group by  BN, 
             GNN,
             STR
   order by  BN, 
             GNN,
             STR;
quit;

data BN_GNN_STR;
   set BN_GNN_STR;
   BN_GNN_STR=compress('grp'||_N_+0);
run;

/*===3===GNN + STR + MCBS_FORM*/;
proc sql;
   create table GNN_STR_MCBS_FORM as 
   select distinct GNN,
                   STR, 
                   MCBS_FORM
   from FDB_NDC_BASE1_20&YEAR
   group by  GNN,
             STR,
             MCBS_FORM
   order by  GNN,
             STR,
             MCBS_FORM;
quit;

data GNN_STR_MCBS_FORM;
   set GNN_STR_MCBS_FORM;
   GNN_STR_MCBS_FORM=compress('grp'||_N_+0);
run;

/*===4===GNN + STR*/;
proc sql;
   create table GNN_STR as 
   select distinct GNN,
                   STR
   from FDB_NDC_BASE1_20&YEAR
   group by  GNN,
             STR
   order by  GNN,
             STR;
quit;

data GNN_STR;
   set GNN_STR;
   GNN_STR=compress('grp'||_N_+0);
run;

/*NDC base*/
proc sql;
   /*merge with WAC unit price and claims (weight)*/
   create table FDB_NDC_BASE2_20&YEAR as
   select a.*,
          b.WAC_UNIT_PRICE,
		  c.TOT_SCRIPTS
   from FDB_NDC_BASE1_20&YEAR a left join FDB_WAC_UNIT_20&YEAR b
                                  on a.NDC=b.NDC
							   left join COMMON.CLAIMS_20&YEAR c
							      on a.NDC=c.NDC;

   /*merge with the BN + GNN + STR + MCBS_FORM flag*/
   create table FDB_NDC_BASE31_20&YEAR as
   select a.*,
          b.BN_GNN_STR_MCBS_FORM
   from FDB_NDC_BASE2_20&YEAR a left join BN_GNN_STR_MCBS_FORM b
                                      on a.BN=b.BN
								     and a.GNN=b.GNN
									 and a.STR=b.STR
									 and a.MCBS_FORM=b.MCBS_FORM;

   /*merge with the BN + GNN + STR flag*/
   create table FDB_NDC_BASE32_20&YEAR as
   select a.*,
          b.BN_GNN_STR
   from FDB_NDC_BASE31_20&YEAR a left join BN_GNN_STR b
                                      on a.BN=b.BN
								     and a.GNN=b.GNN
									 and a.STR=b.STR;

   /*merge with the GNN + STR + MCBS_FORM flag*/
   create table FDB_NDC_BASE33_20&YEAR as
   select a.*,
          b.GNN_STR_MCBS_FORM
   from FDB_NDC_BASE32_20&YEAR a left join GNN_STR_MCBS_FORM b
                                      on a.GNN=b.GNN
									 and a.STR=b.STR
									 and a.MCBS_FORM=b.MCBS_FORM;

   /*merge with the GNN + STR flag*/
   create table FDB_NDC_BASE34_20&YEAR as
   select a.*,
          b.GNN_STR
   from FDB_NDC_BASE33_20&YEAR a left join GNN_STR b
                                      on a.GNN=b.GNN
									 and a.STR=b.STR;
quit;

/*BN + GNN + STR + MCBS_FORM*/;
proc sql;
   create table FDB_NDC_BASE41_20&YEAR as
   select distinct BN_GNN_STR_MCBS_FORM, 
                   TOT_SCRIPTS,
		           WAC_UNIT_PRICE as WAC_UNIT_PRICE_4VARs
   from FDB_NDC_BASE34_20&YEAR 
   where  BN_GNN_STR_MCBS_FORM ne '' and WAC_UNIT_PRICE not in (., 0) and TOT_SCRIPTS ne .
   group by BN_GNN_STR_MCBS_FORM, 
            TOT_SCRIPTS,
		    WAC_UNIT_PRICE
   order by BN_GNN_STR_MCBS_FORM, 
            TOT_SCRIPTS,
		    WAC_UNIT_PRICE;
quit;

data FDB_NDC_BASE41_20&YEAR;
   set FDB_NDC_BASE41_20&YEAR;
   by BN_GNN_STR_MCBS_FORM TOT_SCRIPTS;
   if last.BN_GNN_STR_MCBS_FORM then output;
run;

/*BN + GNN + STR*/;
proc sql;
   create table FDB_NDC_BASE42_20&YEAR as
   select distinct BN_GNN_STR, 
                   TOT_SCRIPTS,
		           WAC_UNIT_PRICE as WAC_UNIT_PRICE_3VARs1
   from FDB_NDC_BASE34_20&YEAR 
   where BN_GNN_STR ne '' and WAC_UNIT_PRICE not in (., 0) and TOT_SCRIPTS ne .
   group by BN_GNN_STR, 
            TOT_SCRIPTS,
		    WAC_UNIT_PRICE
   order by BN_GNN_STR, 
            TOT_SCRIPTS,
		    WAC_UNIT_PRICE;
quit;

data FDB_NDC_BASE42_20&YEAR;
   set FDB_NDC_BASE42_20&YEAR;
   by BN_GNN_STR TOT_SCRIPTS;
   if last.BN_GNN_STR then output;
run;

/*GNN + STR + MCBS_FORM*/;
proc sql;
   create table FDB_NDC_BASE43_20&YEAR as
   select distinct GNN_STR_MCBS_FORM, 
                   TOT_SCRIPTS,
		           WAC_UNIT_PRICE as WAC_UNIT_PRICE_3VARs2
   from FDB_NDC_BASE34_20&YEAR 
   where GNN_STR_MCBS_FORM ne '' and WAC_UNIT_PRICE not in (., 0) and TOT_SCRIPTS ne .
   group by GNN_STR_MCBS_FORM, 
            TOT_SCRIPTS,
		    WAC_UNIT_PRICE
   order by GNN_STR_MCBS_FORM, 
            TOT_SCRIPTS,
		    WAC_UNIT_PRICE;
quit;

data FDB_NDC_BASE43_20&YEAR;
   set FDB_NDC_BASE43_20&YEAR;
   by GNN_STR_MCBS_FORM TOT_SCRIPTS;
   if last.GNN_STR_MCBS_FORM then output;
run;

/*GNN + STR*/;
proc sql;
   create table FDB_NDC_BASE44_20&YEAR as
   select distinct GNN_STR, 
                   TOT_SCRIPTS,
		           WAC_UNIT_PRICE as WAC_UNIT_PRICE_2VARs
   from FDB_NDC_BASE34_20&YEAR 
   where GNN_STR ne '' and WAC_UNIT_PRICE not in (., 0) and TOT_SCRIPTS ne .
   group by GNN_STR, 
            TOT_SCRIPTS,
		    WAC_UNIT_PRICE
   order by GNN_STR, 
            TOT_SCRIPTS,
		    WAC_UNIT_PRICE;
quit;

data FDB_NDC_BASE44_20&YEAR;
   set FDB_NDC_BASE44_20&YEAR;
   by GNN_STR TOT_SCRIPTS;
   if last.GNN_STR then output;
run; 

/*final dataset for using WAC*/;
proc sql;
   create table FDB_NDC_BASE_20&YEAR as
   select a.*,
          b.WAC_UNIT_PRICE_4VARs,/*combination of BN + GNN + STR + MCBS_FORM*/
		  c.WAC_UNIT_PRICE_3VARs1,/*combination of BN + GNN + STR*/
          d.WAC_UNIT_PRICE_3VARs2,/*combination of GNN + STR + MCBS_FORM*/
		  e.WAC_UNIT_PRICE_2VARs /*combination of GNN + STR*/
   from FDB_NDC_BASE34_20&YEAR a left join FDB_NDC_BASE41_20&YEAR b
                                    on a.BN_GNN_STR_MCBS_FORM=b.BN_GNN_STR_MCBS_FORM
								 left join FDB_NDC_BASE42_20&YEAR c
                                    on a.BN_GNN_STR=c.BN_GNN_STR
							     left join FDB_NDC_BASE43_20&YEAR d
                                    on a.GNN_STR_MCBS_FORM=d.GNN_STR_MCBS_FORM
                                 left join FDB_NDC_BASE44_20&YEAR e
                                    on a.GNN_STR=e.GNN_STR;
quit;

data FDB_NDC_BASE_20&YEAR;
   set FDB_NDC_BASE_20&YEAR;
   if WAC_UNIT_PRICE not in (., 0) then WAC_UNIT_PRICE=WAC_UNIT_PRICE;
      else if WAC_UNIT_PRICE in (., 0) and WAC_UNIT_PRICE_4VARs not in (., 0) then WAC_UNIT_PRICE=WAC_UNIT_PRICE_4VARs;
         else if WAC_UNIT_PRICE in (., 0) and WAC_UNIT_PRICE_4VARs in (., 0) and WAC_UNIT_PRICE_3VARs1 not in (., 0) then WAC_UNIT_PRICE=WAC_UNIT_PRICE_3VARs1;
		    else if WAC_UNIT_PRICE in (., 0) and WAC_UNIT_PRICE_4VARs in (., 0) and WAC_UNIT_PRICE_3VARs1 in (., 0) and WAC_UNIT_PRICE_3VARs2 not in (., 0) then WAC_UNIT_PRICE=WAC_UNIT_PRICE_3VARs2;
			   else if WAC_UNIT_PRICE in (., 0) and WAC_UNIT_PRICE_4VARs in (., 0) and WAC_UNIT_PRICE_3VARs1 in (., 0) and WAC_UNIT_PRICE_3VARs2 in (., 0) and WAC_UNIT_PRICE_2VARs not in (., 0) then WAC_UNIT_PRICE=WAC_UNIT_PRICE_2VARs;
run;

/*======================================*/;
proc sql;
   create table PDE_subset as
   select NDC, 
          FDB_BRAND_NAME,
          FDB_GENERIC_NAME, 
          FDB_FORM_DESCR, 
          FDB_STRENGTH, 
          FDB_NET_WHOLESALE_UNIT_PRICE, 
          INGRDNT_CST_PD_AMT, 
          QTY_DSPNSD_NUM,
          INGRDNT_CST_PD_AMT/QTY_DSPNSD_NUM as AVG_UNIT_PRICE 
   from THN&YEAR._&SAMPLE..PDE 
   where FDB_ROUTE_OF_ADMIN_DESC="ORAL" 
        and (index(FDB_FORM_DESCR,'TABLET' )>0 or index(FDB_FORM_DESCR,'CAPSULE')>0)
   order by NDC;
quit;

*** Get Statistics by NDC ***;
proc summary data=PDE_subset;
   class NDC;
   id FDB_GENERIC_NAME;
   output out=NDC_SUMMARY 
              median(QTY_DSPNSD_NUM)=QUANTITY_MEDIAN
              p75(AVG_UNIT_PRICE)=P75_UNIT_PRICE
              p25(AVG_UNIT_PRICE)=P25_UNIT_PRICE
              p50(AVG_UNIT_PRICE)=P50_UNIT_PRICE;
run;;

data NDC_SUMMARY ;
   set NDC_SUMMARY ;
   if _TYPE_=1;
   drop _TYPE_;
run;

***Sort and create indexes;
proc sort DATA =NDC_SUMMARY out=NDC_SUMMARY(index=(NDC)); by NDC; run;

*** Summarize Ingredient Cost and Quantity limited to median quantity 
    and price within inter-quartile range ***;
proc sql;
   create table MEDICARE_FACTOR1_&YEAR as 
   select B.NDC,
          B.P50_UNIT_PRICE,
          A.FDB_BRAND_NAME,
          A.FDB_GENERIC_NAME,
          A.FDB_FORM_DESCR,
          A.FDB_STRENGTH,
          A.FDB_NET_WHOLESALE_UNIT_PRICE,
          count(A.NDC) as CLAIMS,
          sum(A.INGRDNT_CST_PD_AMT) as INGREDIENT_SUM,
          sum(A.QTY_DSPNSD_NUM) as QUANTITY_SUM
   from PDE_subset A right join NDC_SUMMARY  B
                        on A.NDC=B.NDC
   where A.QTY_DSPNSD_NUM=B.QUANTITY_MEDIAN 
      and A.INGRDNT_CST_PD_AMT/A.QTY_DSPNSD_NUM between P25_UNIT_PRICE and P75_UNIT_PRICE
   group by B.NDC,
            B.P50_UNIT_PRICE,
            A.FDB_BRAND_NAME,
            A.FDB_GENERIC_NAME,
            A.FDB_FORM_DESCR,
            A.FDB_STRENGTH,
            A.FDB_NET_WHOLESALE_UNIT_PRICE;

   create table MEDICARE_FACTOR_&YEAR as 
   select a.*,
          b.WAC_UNIT_PRICE
   from MEDICARE_FACTOR1_&YEAR a left join FDB_NDC_BASE_20&YEAR b
                                    on a.NDC=b.NDC;
quit;

data MEDICARE_FACTOR_&YEAR;
   set MEDICARE_FACTOR_&YEAR ;
   if FDB_NET_WHOLESALE_UNIT_PRICE not in (.,0) then FDB_NET_WHOLESALE_UNIT_PRICE=FDB_NET_WHOLESALE_UNIT_PRICE;
      else FDB_NET_WHOLESALE_UNIT_PRICE=WAC_UNIT_PRICE;
run;

*** Calculate Medicare Unit Price and Medicare Factor ***;
DATA MEDICARE_FACTOR_&YEAR;
SET   MEDICARE_FACTOR_&YEAR;

IF QUANTITY_SUM NE 0 THEN DO;
MEDICARE_UNIT_PRICE = INGREDIENT_SUM      / QUANTITY_SUM;
MEDICARE_FACTOR     = MEDICARE_UNIT_PRICE / FDB_NET_WHOLESALE_UNIT_PRICE;
END;

/*Note: Maggie, as I explained to you in person a few weeks ago, I removed MEDICARE_FACTOR2 below, because this is exact same as MEDICARE_FACTOR.
BBPR_SUM = FDB_NET_WHOLESALE_UNIT_PRICE * QUANTITY_SUM;

IF QUANTITY_SUM NE 0 THEN DO;
MEDICARE_FACTOR2= INGREDIENT_SUM / BBPR_SUM;
END;
*/;

LABEL MEDICARE_UNIT_PRICE="Average Medicare Unit Price"
     MEDICARE_FACTOR= "Ratio of Medicare Unit Price to Blue Book AWP Unit Price";
RUN;

***CREATE TABLE FOR EXPORT;
data &USER..MEDICARE_FACTOR_&YEAR._EXPORT;
SET   MEDICARE_FACTOR_&YEAR;
keep NDC CLAIMS INGREDIENT_SUM QUANTITY_SUM ;
rename NDC = NDC; 
label NDC= ;
run;
%emailx(to=&my_email.,subject=MEDICARE FACTOR JOB COMPLETE);

*NOTE: MUST USE SAS EG "EXPORT" FUNCTION TO DOWNLOAD COPY OF DATAFILE TO LOCAL DRIVE;

/*============================================END OF CCW CODE================================================================================*/

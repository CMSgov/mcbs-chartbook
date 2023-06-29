%include "&myfiles_root./sasnetrc.sas"/nosource2;

%let year=20;

libname  orlib oracle user=&ouser.  PASSWORD="&opassp." path="&opathp." schema=&ouser.;
/*2020 UPDATE TO SNOWFLAKE*/
*libname  snowlib sasiosnf user=&ouser.  PASSWORD="&opassp." path="&spathp." schema=&ouser.;
%emailx(to=&my_email.,subject=MCBS data pull started);

****need to import crosswalk file from local PC ***;

*Create CCW to MCBS crosswalk;
proc sql;
create table /*snowlib.MCBS_bene_id_&year*/ orlib.MCBS_bene_id_&year as 
 select *
 from PL000000.mcbs_ccw_xwalk_&year
 order by bene_id, baseid;
quit;

*Get PDE Data;
proc sql;
connect to /*sasiosnf*/ oracle(user=&ouser. password="&opassp." path="&opathp." preserve_comments=yes);

create table PL000000.MCBS_PDE_20&year as select * from connection to oracle /*sasiosnf*/

(select 
    %str(/)%str(*)+ PARALLEL(pde,8) full(pde) full(mcbs) full(prod) full(plan)  %str(*)%str(/)
       PDE.BENE_ID,
       PDE.HIC_ID,
       PDE.PDE_ID,
       PDE.SRVC_DT,
       prod.PROD_SRVC_ID,
       plan.PLAN_CNTRCT_ID,
       plan.PBP_ID,
       plan.PLAN_CNTRCT_REC_ID,
       plan.PLAN_PBP_REC_NUM,
       PDE.QTY_DSPNSD_NUM,
       PDE.DAYS_SUPLY_NUM,
       PDE.INGRDNT_CST_PD_AMT,
       PDE.DSPNSNG_FEE_PD_AMT,
       PDE.TOT_AMT_ATTR_SLS_TAX_AMT,
       PDE.GDC_BLW_OOPT_AMT,
       PDE.GDC_ABV_OOPT_AMT,
       PDE.PTNT_PAY_AMT,
       PDE.OTHR_TROOP_AMT,
       PDE.LICS_AMT,
       PDE.PLRO_AMT,
       PDE.CVRD_D_PLAN_PD_AMT,
       PDE.NCVRD_PLAN_PD_AMT

   from  &ouser..MCBS_BENE_ID_&year  mcbs,
         ccw_owner.ccw_pde_fact  pde,
		 ccw_owner.ccw_pde_prod_prfl prod,
         ccw_owner.CCW_PDE_PLAN_PRFL plan

   where mcbs.bene_id         = pde.bene_id
     and to_char(pde.srvc_dt,'YY')= &year 
	 and pde.PDE_PROD_PRFL_ID = PROD.PDE_PROD_PRFL_ID
	 and pde.PDE_PLAN_PRFL_ID = plan.PDE_PLAN_PRFL_ID

	 /*NEW FOR 2015*/
	 and pde.FINL_ACTN_ID = 21
     );

  disconnect from oracle /*sasiosnf*/;
quit;

%emailx(to=&my_email.,subject=MCBS data pull completed);

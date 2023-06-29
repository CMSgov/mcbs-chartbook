*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
|      PROGRAM: 04_HandMatch_REMERGE                                                         |
|      UPDATED: 05/13/2010                                                                   |
|  INPUT FILES:                                                                              |
| OUTPUT FILES:                                                                              |
|  DESCRIPTION:                                                                              |
|                                                                                            |
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;
ODS HTML CLOSE;
  ODS HTML;

options nofmterr;

OPTION MLOGIC MPRINT SYMBOLGEN COMPRESS=YES;

%let CurrYear  =20;
%let LastYear  =19;

%let location = C:\Users\S1C3\RIC PME\MCBS\20&CURRYEAR.\PME\Data\;
%let loc_last = C:\Users\S1C3\RIC PME\MCBS\20&LASTYEAR.\PME\DATA\;
libname  MCBSDATA "&location";
LIBNAME  MCBSLAST "&loc_last";


/* * * * * * * * * * * * * * * * * * * *\
	*
	* This is the sixth step in the process
	* of reconciling MCBS PM survey data on
	* prescription drugs with Part D PDE
	* data.
	*
	* In this step, information from the
	* cleaned hand-match fix files is merged
	* into the main files. A final pass through
	* the data is made to clean up generic
	* name, form, and strength.
	*
	* MANUAL ATTENTION IS REQUIRED IN THIS
	* CODE. PLACES WHERE THAT IS NEEDED ARE
	* MARKED WITH AN EXCLAMATION POINT.
	*
	\* * * * * * * * * * * * * * * * * * * */

* !==================================================
	Get the hand match fix surv file and check for
	duplicates. 
	;
data hm;
length baseid $8;
set mcbsdata.surv (in=a keep=baseid pmedid new_type matchid bn GNN STR MCBS_FORM gsf)	;
  by pmedid;
surv=a;
run;
proc sort data=hm out=hm nodupkey;
by pmedid bn gsf matchid;
	run;


data double;
	set hm;
		by pmedid;
	if not (first.pmedid and last.pmedid);
	run; *DOUBLE SHOULD BE EMPTY;

* ====================================================
	Merge the matched and unmatched events back onto
	the master file. Events without a matchid belong
	to people without PDE events.
	;
data survey (drop=surv k new_type hm)
		invalid
		worrisome;
	merge mcbsdata.matched_survey_events_20&curryear (in=a)
		hm (in=b rename=matchid=hm);
			by baseid pmedid;
	if first.baseid then k=0;
	if not a then output invalid;
	else do;
		if b then do;
			type=new_type;
			if matchid ne " " and hm ne " " then output worrisome;
			if hm ne " " then matchid=hm;
			end;
		if matchid=" " then do;
			k+1;
			matchid="PM."||put(k,z3.);
			if type=" " then type="US";
			end;
		output survey;
		end;
	run;


/*edit for 2016*/
proc sort data=survey out=survey nodupkey;
by pmedid;
	run;

proc export data=worrisome
	outfile="&location.EDIT\worrisome survey.xls" 
	dbms=excelcs replace;
	run;

* !==================================================
	Repeat the process for PDE records, again making
	sure that all the fix files are included.
	;
data hmp;
length baseid $8;
set mcbsdata.pharm (in=a keep=baseid pde_id new_type matchid bn GNN STR MCBS_FORM gsf)		;
by pde_id;
pde=a;
run;
proc sort data=hmp out=hmp nodupkey;
by pde_id bn gsf matchid;
	run;
data double;
	set hmp;
		by pde_id;
	if not (first.pde_id and last.pde_id);
	run; *DOUBLE SHOULD BE EMPTY;

* !----------------------------------------------------
	Update the main file with the hand match IDs. Drop
	the file markers on the output.
	;
proc sort data=mcbsdata.matched_pde_events_20&curryear;by baseid pde_id;run;
proc sort data=hmp;by baseid pde_id;run;

data pde (drop=pde k new_type hm)
		invalid
		worrisome;
	merge mcbsdata.matched_pde_events_20&curryear (in=a)
		hmp (in=b rename=matchid=hm);
			by baseid pde_id;
	if first.baseid then k=0;
	if not a then output invalid;
	else do;
		if b then do;
			type=new_type;
			if matchid ne " " and hm ne " " then output worrisome;
			if hm ne " " then matchid=hm;
			end;
		if matchid=" " then do;
			k+1;
			matchid="PD."||put(k,z3.);
			if type=" " then type="UP"; * This should never happen, by the way;
			end;
		output pde;
		end;
	run;

/*edit for 2016*/
proc sort data=pde out=pde nodupkey;
by pde_id;
	run;

proc export data=worrisome
	outfile="&location.EDIT\worrisome PDE matches.xls" 
	dbms=excelcs replace;
	run;

* =======================================================
	Combine the survey and PDE data using MATCHID as a
	key.
	;
proc sort data=survey;by baseid matchid; run;
proc sort data=pde;   by baseid matchid; run;
data pm_events;
	merge survey (in=a)
		pde (drop=h_dod fill rename=round=pde_round);
			by baseid matchid;
	if not a then round=pde_round;
	run;

* ======================================================
	Make a final pass through the data to clean up
	GNN, D(form), and STR.
	;
	/*
proc sort data=pm_events;
	by gsn;
	run;
proc sort data=cost.lookup (keep=gsn gnn str d) nodupkey
	out=gsn_stuff;
	by gsn;
	run;
data pm_events;
	merge pm_events (in=a)
		gsn_stuff(in=b);
			by gsn;
	if a;
	run;
	*/
proc sort data=pm_events out=MCBSDATA.pm_events;
	by baseid gnn pmedid pde_id;
	run;

* =============================================
	Run off some summary measures.
	;
proc freq data=pm_events;
	table round*type gnn;
	run;
proc summary data=pm_events nway;
	class gnn type;
	output out=gnn_type (drop=_type_);
	run;
data gnn_type;
	set gnn_type;
		by gnn;
	label total="Number of events";
	retain MM NP RP NS RS US XS;
	array t {*} MM NP NS RP RS US XS;
	array r {*} rMM rNP rNS rRP rRS rUS rXS;
	if first.gnn then do i=1 to dim(t);t{i}=0;end;
	select(type);
		when ('HN')  MM+_freq_;
		when ('MM')  MM+_freq_;
		when ('NP')  NP=_freq_;
		when ('NS')  NS=_freq_;
		when ('RP')  RP=_freq_;
		when ('RS')  RS=_freq_;
		when ('US')  US=_freq_;
		when ('XS')  XS=_freq_;
		otherwise;
		end;
	if last.gnn then do;
		total=sum(MM, NP, NS, RP, RS, US, XS);
		do i=1 to dim(t);
			r{i}=t{i}/total;
			end;
		output;
		end;
	drop i _freq_ type;
	run;
proc sort data=gnn_type;by descending total;
	run;
proc summary data=gnn_type;
	var total MM NP RP NS RS US XS;
	output out=total (drop=_type_ _freq_) sum=;
	run;
data gnn_type;
	if _n_=1 then do;
		length gnn $30;
		gnn="_TOTAL_";
		set total;
		rmm=mm/total;
		rnp=np/total;
		rrp=rp/total;
		rns=ns/total;
		rrs=rs/total;
		rus=us/total;
		rxs=xs/total;
		output;
		end;
	set gnn_type;
	output;
	run;
proc print data=gnn_type (obs=50);
	id gnn;
	format total MM NP RP NS RS US XS comma8.
		rMM rNP rNS rRP rRS rUS rXS percent6.;
	run;


proc sql; 
select count(baseid) as Total from mcbsdata.pm_events;
select count(evntnum) as S_total from mcbsdata.pm_events;
select count(pde_id)  as P_total from mcbsdata.pm_events;
select sum(case when pde_id is not null and evntnum is not null then 1 else 0 end) as S_and_P from mcbsdata.pm_events;
select sum(case when pde_id is null     and evntnum is not null then 1 else 0 end) as S_only from mcbsdata.pm_events;
select sum(case when pde_id is not null and evntnum is     null then 1 else 0 end) as P_only from mcbsdata.pm_events;
quit;






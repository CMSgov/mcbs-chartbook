*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
|      PROGRAM: 03_HANDMATCH_QA                                                                        |
|      UPDATED: 02/28/2011                                                                   |
|  INPUT FILES: Hand Match Access Database survey, PDE, and computer match tables            |
| OUTPUT FILES: MCBSDATA.SURV, MCBSDATA.PHARM                                                |
|  DESCRIPTION: Inputs the hand match data from the Access database                          |
|                                                                                            |
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;
ODS HTML CLOSE;
  ODS HTML;

OPTION MLOGIC MPRINT SYMBOLGEN COMPRESS=YES;

%let CurrYear  =20;
%let LastYear  =19;

%let location = C:\Users\S1C3\RIC PME\MCBS\20&CURRYEAR.\PME\Data\;
%let loc_last = C:\Users\S1C3\RIC PME\MCBS\20&LASTYEAR.\PME\DATA\;
libname  MCBSDATA "&location";
LIBNAME  MCBSLAST "&loc_last";


/* * * * * * * * * * * * * * * * * * * * * *\
	*
	* PM PDE 5.sas
	*
	* This code retrives the hand matches,
	* makes sure that they are clean,
	* and applies the matchids to the
	* events in the survey and PDE
	* files.
	*
	*
	\* * * * * * * * * * * * * * * * * * * * * */

*=============================================================
2018 UPDATE due to 32-bit access and 64-bit SAS
 Read the fix file (note: SAS direct libname to Access and view created so updates will be reflected dynamically).;
libname test pcfiles path="&location.\Edit\20&CurrYear PME Hand Match.mdb";

data fix /view=fix;
set
test.p
test.s
test.comp_matches;
run;

* =============================================================
	Perform a series of edit checks to make sure that the hand
	matching was not done incorrectly. The various CHK files
	should be empty after each test.
	;
* -------------------------------------------------------------
	Match numbers are integers.
	;
data chk;
	set fix;
	if hand_num and (hand_num<1 or mod(hand_num,1) ne 0 or hand_num>999);
	run; * CHK SHOULD BE EMPTY;
title "Match numbers are integers";
proc print data=chk (obs=500);run;title;

* -------------------------------------------------------------
	Hand matches involve a 1-1 fix.
	;
proc summary data=fix nway;
	class baseid hand_num;
	output out=chk (drop=_type_);
	run;
data chk;
	set chk;
	if _freq_ ne 2;
	run; * CHK SHOULD BE EMPTY;
title "One-to-One match";
proc print data=chk (obs=500);run;title;

* ------------------------------------------------------------
	A survey event (second character of type is S) is matched
	with a PDE event (second character is P).
	;
proc summary data=fix nway;
	class baseid hand_num type;
	output out=chk;
	run;
data chk;
	set chk;
		by baseid hand_num;
	retain t1 t2;
	if first.hand_num then t1=substr(type,2,1);
	if last.hand_num;
	t2=substr(type,2,1);
	if t1 not in ('S','P') or t2 not in ('S','P') or t1=t2;
	drop type _freq_ _type_;
	run; * CHK SHOULD BE EMPTY;
title "Survey matched to PDE";
proc print data=chk ;run;title;


* ----------------------------------------------------------
	The paired records have identical GSF values.
	;

proc sql;
create table chk as select
  a.baseid, a.hand_num, a.gsf as gsf_p, b.gsf as gsf_s, b.pmedname
from test.p a 
  inner join test.s b 
   on a.baseid=b.baseid and a.hand_num=b.hand_num
where a.gsf ne b.gsf ;
quit;
/*
proc summary data=fix nway missing;
	class baseid hand_num gsf;
	where hand_num>0;
	output out=chk;
	run;
data chk;
	set chk;
		by baseid hand_num;
	if not (first.hand_num and last.hand_num) ;
	run;*/ * CHK SHOULD BE EMPTY;
title "Survey matched to PDE";
proc print data=chk (obs=1000);run;title;



***fix bn, gnn, str, form and GSF;
proc sql;
create table gsf_fix as select
 a.hand_num,
 a.null,
 a.round,
 a.BASEID,
 a.PMEDNAME,
 case when b.BN is not null then b.bn else a.bn end as bn,
 case when b.Str is not null then b.Str else a.Str end as Str,
 case when b.MCBS_FORM is not null then b.MCBS_FORM else a.MCBS_FORM end as MCBS_FORM,
 case when b.GNN is not null then b.GNN else a.GNN end as GNN,
 case when b.GSF is not null then b.GSF else a.GSF end as GSF,
 a.bn as bn_old,
 a.Str as str_old,
 a.MCBS_FORM as MCBS_FORM_old,
 a.GNN as gnn_old,
 a.pmedid,
 a.GSF as gsf_old,
 a.type,
 a.new_type,
 a.COND1,
 a.COND2,
 a.PDE_ID,
 a.UPDATE_TS
from fix         a 
      left join 
     test.p    b
       on a.baseid=b.baseid
      and a.hand_num=b.hand_num
      and a.type <> b.type
      and a.hand_num is not null;
quit;
**Re-checked that the paired records have identical GSF values.;

proc summary data=gsf_fix nway missing;
	class baseid hand_num gsf;
	where hand_num>0;
	output out=chk;
	run;
data chk;
	set chk;
		by baseid hand_num;
	if not (first.hand_num and last.hand_num);
	run; * CHK SHOULD BE EMPTY;
title "Survey matched to PDE";
proc print data=chk (obs=500);run;title;


proc freq data=fix;     tables type/missing;run;
proc freq data=gsf_fix; tables type/missing;run;




* ==========================================================
	Split the records into two piles and make sure any new
	types are OK;
data survey_fix pharmacy_fix (drop=evntnum) chk;
	length new_type $2;
	set gsf_fix;
	if pde_id ne . then output pharmacy_fix;
	else if pmedid ne " " then do;
		evntnum=input(substr(pmedid,9,3),3.);
		output survey_fix;
		end;
	if new_type ne " ";
	if (type in ('NS','RS') and new_type not in ('NS','RS','X')) 
    or (type in ('NP','RP') and new_type not in ('NP','RP','X')) then output chk;
	format new_type;
	run; * CHK SHOULD BE EMPTY;

* ----------------------------------------------------------
	Make sure that the PDE event is contemporaneous with
	or predates the survey event.
	;
proc sort data=survey_fix out=sf;by baseid hand_num;where hand_num;
proc sort data=pharmacy_fix out=pf;by baseid hand_num;where hand_num;
	run;
data chk;
	merge sf (in=a rename=round=srnd)
		pf (in=b rename=round=prnd);
			by baseid hand_num;
	if hand_num;
	if (not (a and b)) or (prnd>srnd);
	keep baseid hand_num srnd prnd;
	label srnd=" " prnd=" ";
	run; *CHK SHOULD BE EMPTY;

* ==========================================================
	Now, carry the hand-matching across all instances of
	survey reports. For example, if one survey fill of the
	event has been matched, make other fills of that
	event survey refills;

data hand_match;
	set survey_fix;
	if hand_num>0;
	keep baseid evntnum bn gnn str mcbs_form pmform_fdb gsf;
	rename bn=bn_f gnn=gnn_f str=str_f mcbs_form=mcbs_form_f gsf=gsf_f;
	run;

proc sort data=hand_match nodupkey;
	by baseid evntnum;
	run;
proc sort data=survey_fix;
	by baseid evntnum;
	run;

data survey_fix;
	merge survey_fix (in=a)
		hand_match (in=b);
			by baseid evntnum;
	if b and type in ("NS","RS") and (not hand_num) then do;
		 bn=bn_f; 
		 gnn=gnn_f; 
		 str=str_f; 
		 mcbs_form=mcbs_form_f;
		 gsf=gsf_f;  
		 new_type="RS";
	  end;
	drop bn_f gsf_f;
	if new_type ne " " or hand_num>0;
	run;



* ----------------------------------------------
	Assign a new match_id and/or new type to
	survey events that need to be changed.
	;
data surv huh;
	length matchid $6;
	set survey_fix;
		by baseid;
	if first.baseid then k=1;
		else k+1;
	new_type=upcase(new_type);
	if new_type="X" then new_type="XS";
	if hand_num then do;
		matchid="HM"||"."||put(hand_num,z3.);
		new_type="HM";
		end;
	else if new_type=" " then new_type=type;
	else if new_type not in ('NS','RS','XS') 
		then output huh;
	keep baseid matchid pmedid bn GNN STR MCBS_FORM gsf type new_type;
	output surv;
	run; * HUH SHOULD BE EMPTY;

proc sort data=surv out=mcbsdata.surv
    NODUPKEY; /*Edit for 2016 there were duplicates of PMEDID*/
	by pmedid;
	run;


data test; set surv;where new_type='RS' and type='RS';run;

* ===============================================
	Handle PDE fixes in a manner similar to
	the survey events (although we expect no
	changes to the PDE records as a result of the
	matching).
	;
data hand_match;
	set pharmacy_fix;
	if hand_num>0;
	keep baseid gsf;
	run;
proc sort data=hand_match nodupkey;
	by baseid gsf;
	run;
proc sort data=pharmacy_fix;
	by baseid gsf;
	run;
data pharmacy_fix;
	merge pharmacy_fix (in=a)
		hand_match (in=b);
			by baseid gsf;
	if b and type in ("NP") and (not hand_num) then new_type="RP";
	if new_type ne " " or hand_num>0;
	format new_type;
	run;
data pharm huh;
	length matchid $6;
	set pharmacy_fix;
		by baseid;
	new_type=upcase(new_type);
	if new_type="X" then new_type="XP";
	if hand_num then do;
		matchid="HM"||"."||put(hand_num,z3.);
		new_type="HM";
		end;
	else if new_type=" " then new_type=type;
	else if new_type not in ('NP','RP','XP')
		then output huh;
	output pharm; 
	keep baseid matchid pde_id bn GNN STR MCBS_FORM gsf type new_type;
	run; * HUH SHOULD BE EMPTY;

proc sort data=pharm out=mcbsdata.pharm;
	by pde_id;
	run;

* ============================================================
	Summarize the results.
	;
proc freq data=mcbsdata.surv;
	title "surv";
	table type*new_type / norow nocol nopercent missing;
	run;
proc freq data=mcbsdata.pharm;
	title "pharm";
	table type*new_type / norow nocol nopercent missing;
	run;
title " ";


libname test clear;




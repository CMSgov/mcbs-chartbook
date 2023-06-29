*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
|      PROGRAM: 02_MATCH                                                                     |
|      UPDATED: 11/10/2011                                                                   |
|  INPUT FILES: MATCH_START_SURVEY AND MATCH_START_PDE                                       |
| OUTPUT FILES:                                                                              |
|  DESCRIPTION: Inputs the prepared PDE and Survey files and attempts to match using the     |
|               a modified version of the legacy "Waldo" logic.                              |
|                                                                                            |
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;

/*Before running this program copy the previous years Hand-Match into current year file
C:\Users\S1C3\RIC PME\MCBS\20XX\PME\Data\EDIT and change date*/

OPTION MLOGIC MPRINT SYMBOLGEN COMPRESS=YES;
options nofmterr;

%let reviewer_no=5;
%let rev1=Maggie;
%let rev2=Hafiz ;
%let rev3=Michael ;
%let rev4=Joe ;
%let rev5=Jian ;
*%let rev6=Chris;

%let CurrYear  =20;
%let LastYear  =19;

%let start=85; * This is the round prior to the early straddle round;
%let rnd1 =86;
%let rnd2 =87;
%let rnd3 =88;
%let rnd4 =89; 


%let location = C:\Users\S1C3\RIC PME\MCBS\20&CURRYEAR.\PME\Data\;
%let loc_last = C:\Users\S1C3\RIC PME\MCBS\20&LASTYEAR.\PME\DATA\;
libname  MCBSDATA "&location";
LIBNAME  MCBSLAST "&loc_last";

proc sql; select count (distinct(baseid)) from mcbsdata.match_start_pde;quit;


	/*--------------------------------------------*\
	|
	| The match process goes through a series of
	| attempts, each of which is less rigid in
	| its requirement than the previous.
	| The first set requires a match within the
	| round and checks
	| (M1) BN STR MCBS_FORM
	| (M2) BN STR
	| (M3) GNN STR MCBS_FORM
	| (M4) GNN STR
	| (M5) BN
	| (M6) GNN
    | (MX) GNN (first word)
	|
	| These steps are repeated with the round
	| match relaxed.
	|
	| If none of these steps results in a match,
	| the event is placed into one of four groups:
	| (1) "unmatched pde refill" based on GNN
	| (2) "new pde drug"
	| (3) "Unmatched survey refill" based on GNN
	| (4) "new survey drug"
	|
	| SPs with events in groups (2) and (3) or in
	| groups (1) and (4) or in groups (2) and (4)
	| or in groups (1) and (3) are written to a file
	| that will be handled manually.
	|
	\---------------------------------------------*/

*Import prepped PDE and Survey data;
DATA PDE;    SET MCBSDATA.MATCH_START_PDE;   RUN;
DATA SURVEY; SET MCBSDATA.MATCH_START_SURVEY;RUN;

* --------------------------------------------------------
	Now try for a match. survey_m1 holds the matched
	survey events and pde_m1 holds the matched
	pde events, and each is assigned a match number.
	pde_left and surv_left hold the residual unmatched events.
	;


* M1: BN, STR MCBS_FORM, ROUND	;
proc sort data=survey;
	by baseid bn GSF round;
	run;
data survey;
	set survey;
		by baseid bn GSF round;
	if first.round then index=1;
	else index+1;
	run;

proc sort data=pde;
	by baseid bn GSF round;
	run;
data pde;
	set pde;
		by baseid bn GSF round;
	if first.round then index=1;
	else index+1;
	run;

data survey_m1 (keep=pmedid matchid)
	pde_m1 (keep=pde_id matchid)
	surv_left (keep=BASEID PMEDID PMEDNAME ROUND BN GNN STR MCBS_FORM GSF GNN2)
	pde_left  (keep=BASEID PDE_ID ROUND BN GNN STR MCBS_FORM GSF GNN2);
	length matchid $6;
	merge survey (in=a)
		pde (in=b);
		by baseid bn GSF round index;
	if first.baseid then m=0;
	if a and b then do;
		m+1;
		matchid="M1."||put(m,z3.);
		output survey_m1 pde_m1;
		end;
	else if a then output surv_left;
	else output pde_left;
	run;

* M2: BN STR ROUND;
proc sort data=surv_left;
	by baseid bn str round;
	run;
data surv_left;
	set surv_left;
		by baseid bn str round;
	if first.round then index=1;
	else index+1;
	run;
proc sort data=pde_left;
	by baseid bn str round;
	run;
data pde_left;
	set pde_left;
	by baseid bn str round;
	if first.round then index=1;
	else index+1;
	run;
data survey_m2 (keep=pmedid matchid)
	pde_m2 (keep=pde_id matchid)
	surv_left (keep=BASEID PMEDID PMEDNAME ROUND BN GNN STR MCBS_FORM GSF GNN2)
	pde_left  (keep=BASEID PDE_ID ROUND BN GNN STR MCBS_FORM GSF GNN2);
	length matchid $6;
	merge surv_left (in=a)
		pde_left (in=b);
		by baseid bn str round index;
	if first.baseid then m=0;
	if a and b then do;
		m+1;
		matchid="M2." ||put(m,z3.);
		output survey_m2 pde_m2;
		end;
	else if a then output surv_left;
	else output pde_left;
	run;

* M3 -- GNN STR MCBS_FORM ROUND;
proc sort data=surv_left;
	by baseid  GSF round;
	run;
data surv_left;
	set surv_left;
		by baseid  GSF round;
	if first.round then index=1;
	else index+1;
	run;
proc sort data=pde_left;
	by baseid  GSF round;
	run;
data pde_left;
	set pde_left;
		by baseid  GSF round;
	if first.round then index=1;
	else index+1;
	run;


data survey_m3 (keep=pmedid matchid)
	pde_m3 (keep=pde_id matchid)
	surv_left (keep=BASEID PMEDID PMEDNAME ROUND BN GNN STR MCBS_FORM GSF GNN2)
	pde_left  (keep=BASEID PDE_ID ROUND BN GNN STR MCBS_FORM GSF GNN2);
	length matchid $6;
	merge surv_left (in=a)
		pde_left (in=b);
		by baseid  GSF round index;
	if first.baseid then m=0;
	if a and b then do;
		m+1;
		matchid="M3." ||put(m,z3.);
		output survey_m3 pde_m3;
		end;
	else if a then output surv_left;
	else output pde_left;
	run;

* Round M4: GNN STR ROUND;
proc sort data=surv_left;
	by baseid gnn str round;
	run;
data surv_left;
	set surv_left;
		by baseid gnn str round;
	if first.round then index=1;
	else index+1;
	run;
proc sort data=pde_left;
	by baseid gnn str round;
	run;
data pde_left;
	set pde_left;
	by baseid gnn str round;
	if first.round then index=1;
	else index+1;
	run;
data survey_m4 (keep=pmedid matchid)
	pde_m4 (keep=pde_id matchid)
	surv_left (keep=BASEID PMEDID PMEDNAME ROUND BN GNN STR MCBS_FORM GSF GNN2)
	pde_left  (keep=BASEID PDE_ID ROUND BN GNN STR MCBS_FORM GSF GNN2);
	length matchid $6;
	merge surv_left (in=a)
		pde_left (in=b);
		by baseid gnn str round index;
	if first.baseid then m=0;
	if a and b then do;
		m+1;
		matchid="M4." ||put(m,z3.);
		output survey_m4 pde_m4;
		end;
	else if a then output surv_left;
	else output pde_left;
	run;

* M5 -- BN ROUND;
proc sort data=surv_left;
	by baseid bn round;
	run;
data surv_left;
	set surv_left;
		by baseid bn round;
	if first.round then index=1;
	else index+1;
	run;
proc sort data=pde_left;
	by baseid bn round;
	run;
data pde_left;
	set pde_left;
		by baseid bn round;
	if first.round then index=1;
	else index+1;
	run;

data survey_m5 (keep=pmedid matchid)
	pde_m5 (keep=pde_id matchid)
	surv_left (keep=BASEID PMEDID PMEDNAME ROUND BN GNN STR MCBS_FORM GSF GNN2)
	pde_left  (keep=BASEID PDE_ID ROUND BN GNN STR MCBS_FORM GSF GNN2);
	length matchid $6;
	merge surv_left (in=a)
		pde_left (in=b);
		by baseid bn round index;
	if first.baseid then m=0;
	if a and b then do;
		m+1;
		matchid="M5." ||put(m,z3.);
		output survey_m5 pde_m5;
		end;
	else if a then output surv_left;
	else output pde_left;
	run;

* M6 -- GNN ROUND;
proc sort data=surv_left;
	by baseid gnn round;
	run;
data surv_left;
	set surv_left;
		by baseid gnn round;
	if first.round then index=1;
	else index+1;
	run;
proc sort data=pde_left;
	by baseid gnn round;
	run;
data pde_left;
	set pde_left;
		by baseid gnn round;
	if first.round then index=1;
	else index+1;
	run;

data survey_m6 (keep=pmedid matchid)
	pde_m6 (keep=pde_id matchid)
	surv_left (keep=BASEID PMEDID PMEDNAME ROUND BN GNN STR MCBS_FORM GSF GNN2)
	pde_left  (keep=BASEID PDE_ID ROUND BN GNN STR MCBS_FORM GSF GNN2);
	length matchid $6;
	merge surv_left (in=a)
		pde_left (in=b);
		by baseid gnn round index;
	if first.baseid then m=0;
	if a and b then do;
		m+1;
		matchid="M6." ||put(m,z3.);
		output survey_m6 pde_m6;
		end;
	else if a then output surv_left;
	else output pde_left;
	run;


* MX -- GNN (first word) ROUND;
proc sort data=surv_left;
	by baseid gnn2 round;
	run;
data surv_left;
	set surv_left;
		by baseid gnn2 round;
	if first.round then index=1;
	else index+1;
	run;
proc sort data=pde_left;
	by baseid gnn2 round;
	run;
data pde_left;
	set pde_left;
		by baseid gnn2 round;
	if first.round then index=1;
	else index+1;
	run;

data survey_mx (keep=pmedid matchid)
	pde_mx (keep=pde_id matchid)
	surv_left (keep=BASEID PMEDID PMEDNAME ROUND BN GNN STR MCBS_FORM GSF GNN2)
	pde_left  (keep=BASEID PDE_ID ROUND BN GNN STR MCBS_FORM GSF GNN2);
	length matchid $6;
	merge surv_left (in=a)
		pde_left (in=b);
		by baseid gnn2 round index;
	if first.baseid then m=0;
	if a and b then do;
		m+1;
		matchid="MX." ||put(m,z3.);
		output survey_mx pde_mx;
		end;
	else if a then output surv_left;
	else output pde_left;
	run;

* =======================================================
	Now relax the round requirement ... with the provison
	that the MCBS event has to lag the PDE event.
	
	To do this, we have to cycle through the PM events
	one round at a time. The easiest way to do this
	is to use a macro that runs from the first full
	round (that is, after the first straddle round)
	through the last round. The macro variables have to
	be adjusted annually to correspond with the rounds
	in the C&U file.
	;

*M7: BN STR MCBS_FORM rnd_type;
%macro match;
	%do rnd=&RND2 %to &RND4; 
proc sort data=surv_left;
	by round baseid bn GSF;
	run;
data surv_left s_hold (drop=index);
	set surv_left;
		by round baseid bn GSF;
	if round="&rnd" then do;
		if first.GSF then index=1;
		else index+1;
		output surv_left;
		end;
	else output s_hold;
	run;
proc sort data=surv_left;
	by baseid bn GSF index;
	run;

data pde_left p_hold;
	set pde_left;
	if round<"&rnd" then output pde_left;
	else output p_hold;
	run;
proc sort data=pde_left;
	by baseid bn GSF round;
	run;
data pde_left;
	set pde_left;
	by baseid bn GSF;
	if first.GSF then index=1;
		else index+1;
	run;
data smatch (keep=pmedid baseid round m)
	 pmatch (keep=pde_id baseid round m)
	surv_left (keep=BASEID PMEDID PMEDNAME ROUND BN GNN STR MCBS_FORM GSF GNN2)
	pde_left  (keep=BASEID PDE_ID PROUND BN GNN STR MCBS_FORM GSF GNN2 rename=pround=round);
	merge surv_left (in=a)
		pde_left (in=b rename=round=pround);
		by baseid bn GSF index;
	if first.baseid then m=0;
	if a and b then do;
		m+1;
		output smatch pmatch;
		end;
	else if a then output surv_left;
	else output pde_left;
	run;
proc append data=smatch base=survey_m7 force;
proc append data=pmatch base=pde_m7 force;
	run;
data surv_left;
	set surv_left s_hold;
	run;
data pde_left;
	set pde_left p_hold;
	run;
	%end;
%mend match;
%match;
proc sort data=survey_m7;
	by baseid round m;
	run;
data survey_m7;
	length matchid $6;
	set survey_m7;
		by baseid;
	if first.baseid then k=1;
	else k+1;
	matchid="M7."||put(k,z3.);
	drop baseid round m k;
	run;
proc sort data=pde_m7;
	by baseid round m;
	run;
data pde_m7;
	length matchid $6;
	set pde_m7;
		by baseid;
	if first.baseid then k=1;
	else k+1;
	matchid="M7."||put(k,z3.);
	drop baseid round m k;
	run;

*M8: BN STR;
%macro match;
	%do rnd=&RND2 %to &RND4; 
proc sort data=surv_left;
	by round baseid bn str;
	run;
data surv_left s_hold (drop=index);
	set surv_left;
		by round baseid bn str;
	if round="&rnd" then do;
		if first.str then index=1;
		else index+1;
		output surv_left;
		end;
	else output s_hold;
	run;
proc sort data=surv_left;
	by baseid bn str index;
	run;

data pde_left p_hold;
	set pde_left;
	if round<"&rnd" then output pde_left;
	else output p_hold;
	run;
proc sort data=pde_left;
	by baseid bn str round;
	run;
data pde_left;
	set pde_left;
	by baseid bn str;
	if first.str then index=1;
		else index+1;
	run;
data smatch (keep=pmedid baseid round m)
	pmatch (keep=pde_id baseid round m)
	surv_left (keep=BASEID PMEDID PMEDNAME ROUND BN GNN STR MCBS_FORM GSF GNN2)
	pde_left  (keep=BASEID PDE_ID PROUND BN GNN STR MCBS_FORM GSF GNN2 rename=pround=round);
	merge surv_left (in=a)
		pde_left (in=b rename=round=pround);
		by baseid bn str index;
	if first.baseid then m=0;
	if a and b then do;
		m+1;
		output smatch pmatch;
		end;
	else if a then output surv_left;
	else output pde_left;
	run;
proc append data=smatch base=survey_M8 force;
proc append data=pmatch base=pde_M8  force;
	run;
data surv_left;
	set surv_left s_hold;
	run;
data pde_left;
	set pde_left p_hold;
	run;
	%end;
%mend match;
%match;
proc sort data=survey_M8;
	by baseid round m;
	run;
data survey_M8;
	length matchid $6;
	set survey_M8;
		by baseid;
	if first.baseid then k=1;
	else k+1;
	matchid="M8."||put(k,z3.);
	drop baseid round m k;
	run;
proc sort data=pde_M8;
	by baseid round m;
	run;
data pde_M8;
	length matchid $6;
	set pde_M8;
		by baseid;
	if first.baseid then k=1;
	else k+1;
	matchid="M8."||put(k,z3.);
	drop baseid round m k;
	run;

*M9: GNN GSF;
%macro match;
	%do rnd=&RND2 %to &RND4; 
proc sort data=surv_left;
	by round baseid gnn GSF;
	run;
data surv_left s_hold (drop=index);
	set surv_left;
		by round baseid gnn GSF;
	if round="&rnd" then do;
		if first.GSF then index=1;
		else index+1;
		output surv_left;
		end;
	else output s_hold;
	run;
proc sort data=surv_left;
	by baseid gnn GSF index;
	run;

data pde_left p_hold;
	set pde_left;
	if round<"&rnd" then output pde_left;
	else output p_hold;
	run;
proc sort data=pde_left;
	by baseid gnn GSF round;
	run;
data pde_left;
	set pde_left;
	by baseid gnn GSF;
	if first.GSF then index=1;
		else index+1;
	run;
data smatch (keep=pmedid baseid round m)
	pmatch (keep=pde_id baseid round m)
	surv_left (keep=BASEID PMEDID PMEDNAME ROUND BN GNN STR MCBS_FORM GSF GNN2)
	pde_left  (keep=BASEID PDE_ID PROUND BN GNN STR MCBS_FORM GSF GNN2 rename=pround=round);
	merge surv_left (in=a)
		pde_left (in=b rename=round=pround);
		by baseid gnn GSF index;
	if first.baseid then m=0;
	if a and b then do;
		m+1;
		output smatch pmatch;
		end;
	else if a then output surv_left;
	else output pde_left;
	run;
proc append data=smatch base=survey_M9  force;
proc append data=pmatch base=pde_M9  force;
	run;
data surv_left;
	set surv_left s_hold;
	run;
data pde_left;
	set pde_left p_hold;
	run;
	%end;
%mend match;
%match;
proc sort data=survey_M9;
	by baseid round m;
	run;
data survey_M9;
	length matchid $6;
	set survey_M9;
		by baseid;
	if first.baseid then k=1;
	else k+1;
	matchid="M9."||put(k,z3.);
	drop baseid round m k;
	run;
proc sort data=pde_M9;
	by baseid round m;
	run;
data pde_M9;
	length matchid $6;
	set pde_M9;
		by baseid;
	if first.baseid then k=1;
	else k+1;
	matchid="M9."||put(k,z3.);
	drop baseid round m k;
	run;

*MA: gnn STR;
%macro match;
	%do rnd=&RND2 %to &RND4;
proc sort data=surv_left;
	by round baseid gnn str;
	run;
data surv_left s_hold (drop=index);
	set surv_left;
		by round baseid gnn str;
	if round="&rnd" then do;
		if first.str then index=1;
		else index+1;
		output surv_left;
		end;
	else output s_hold;
	run;
proc sort data=surv_left;
	by baseid gnn str index;
	run;

data pde_left p_hold;
	set pde_left;
	if round<"&rnd" then output pde_left;
	else output p_hold;
	run;
proc sort data=pde_left;
	by baseid gnn str round;
	run;
data pde_left;
	set pde_left;
	by baseid gnn str;
	if first.str then index=1;
		else index+1;
	run;
data smatch (keep=pmedid baseid round m)
	pmatch (keep=pde_id baseid round m)
	surv_left (keep=BASEID PMEDID PMEDNAME ROUND BN GNN STR MCBS_FORM GSF GNN2)
	pde_left  (keep=BASEID PDE_ID PROUND BN GNN STR MCBS_FORM GSF GNN2 rename=pround=round);
	merge surv_left (in=a)
		pde_left (in=b rename=round=pround);
		by baseid gnn str index;
	if first.baseid then m=0;
	if a and b then do;
		m+1;
		output smatch pmatch;
		end;
	else if a then output surv_left;
	else output pde_left;
	run;
proc append data=smatch base=survey_MA  force;
proc append data=pmatch base=pde_MA  force;
	run;
data surv_left;
	set surv_left s_hold;
	run;
data pde_left;
	set pde_left p_hold;
	run;
	%end;
%mend match;
%match;
proc sort data=survey_MA;
	by baseid round m;
	run;
data survey_MA;
	length matchid $6;
	set survey_MA;
		by baseid;
	if first.baseid then k=1;
	else k+1;
	matchid="MA."||put(k,z3.);
	drop baseid round m k;
	run;
proc sort data=pde_MA;
	by baseid round m;
	run;
data pde_MA;
	length matchid $6;
	set pde_MA;
		by baseid;
	if first.baseid then k=1;
	else k+1;
	matchid="MA."||put(k,z3.);
	drop baseid round m k;
	run;

*MB: BN;
%macro match;
	%do rnd=&RND2 %to &RND4; 
proc sort data=surv_left;
	by round baseid bn;
	run;
data surv_left s_hold (drop=index);
	set surv_left;
		by round baseid bn;
	if round="&rnd" then do;
		if first.bn then index=1;
		else index+1;
		output surv_left;
		end;
	else output s_hold;
	run;
proc sort data=surv_left;
	by baseid bn index;
	run;

data pde_left p_hold;
	set pde_left;
	if round<"&rnd" then output pde_left;
	else output p_hold;
	run;
proc sort data=pde_left;
	by baseid bn round;
	run;
data pde_left;
	set pde_left;
	by baseid bn;
	if first.bn then index=1;
		else index+1;
	run;
data smatch (keep=pmedid baseid round m)
	pmatch (keep=pde_id baseid round m)
	surv_left (keep=BASEID PMEDID PMEDNAME ROUND BN GNN STR MCBS_FORM GSF GNN2)
	pde_left  (keep=BASEID PDE_ID PROUND BN GNN STR MCBS_FORM GSF GNN2 rename=pround=round);
	merge surv_left (in=a)
		pde_left (in=b rename=round=pround);
		by baseid bn index;
	if first.baseid then m=0;
	if a and b then do;
		m+1;
		output smatch pmatch;
		end;
	else if a then output surv_left;
	else output pde_left;
	run;
proc append data=smatch base=survey_MB  force;
proc append data=pmatch base=pde_MB  force;
	run;
data surv_left;
	set surv_left s_hold;
	run;
data pde_left;
	set pde_left p_hold;
	run;
	%end;
%mend match;
%match;
proc sort data=survey_MB;
	by baseid round m;
	run;
data survey_MB;
	length matchid $6;
	set survey_MB;
		by baseid;
	if first.baseid then k=1;
	else k+1;
	matchid="MB."||put(k,z3.);
	drop baseid round m k;
	run;
proc sort data=pde_MB;
	by baseid round m;
	run;
data pde_MB;
	length matchid $6;
	set pde_MB;
		by baseid;
	if first.baseid then k=1;
	else k+1;
	matchid="MB."||put(k,z3.);
	drop baseid round m k;
	run;

*MC. GNN;
%macro match;
	%do rnd=&RND2 %to &RND4; 
proc sort data=surv_left;
	by round baseid gnn;
	run;
data surv_left s_hold (drop=index);
	set surv_left;
		by round baseid gnn;
	if round="&rnd" then do;
		if first.gnn then index=1;
		else index+1;
		output surv_left;
		end;
	else output s_hold;
	run;
proc sort data=surv_left;
	by baseid gnn index;
	run;

data pde_left p_hold;
	set pde_left;
	if round<"&rnd" then output pde_left;
	else output p_hold;
	run;
proc sort data=pde_left;
	by baseid gnn round;
	run;
data pde_left;
	set pde_left;
	by baseid gnn;
	if first.gnn then index=1;
		else index+1;
	run;
data smatch (keep=pmedid baseid round m)
	pmatch (keep=pde_id baseid round m)
	surv_left (keep=BASEID PMEDID PMEDNAME ROUND BN GNN STR MCBS_FORM GSF GNN2)
	pde_left  (keep=BASEID PDE_ID PROUND BN GNN STR MCBS_FORM GSF GNN2 rename=pround=round);
	merge surv_left (in=a)
		pde_left (in=b rename=round=pround);
		by baseid gnn index;
	if first.baseid then m=0;
	if a and b then do;
		m+1;
		output smatch pmatch;
		end;
	else if a then output surv_left;
	else output pde_left;
	run;
proc append data=smatch base=survey_MC  force;
proc append data=pmatch base=pde_MC  force;
	run;
data surv_left;
	set surv_left s_hold;
	run;
data pde_left;
	set pde_left p_hold;
	run;
	%end;
%mend match;
%match;
proc sort data=survey_MC;
	by baseid round m;
	run;
data survey_MC;
	length matchid $6;
	set survey_MC;
		by baseid;
	if first.baseid then k=1;
	else k+1;
	matchid="MC."||put(k,z3.);
	drop baseid round m k;
	run;
proc sort data=pde_MC;
	by baseid round m;
	run;
data pde_MC;
	length matchid $6;
	set pde_MC;
		by baseid;
	if first.baseid then k=1;
	else k+1;
	matchid="MC."||put(k,z3.);
	drop baseid round m k;
	run;

*MD. GNN2 (first word only);
%macro match;
	%do rnd=&RND2 %to &RND4; 
proc sort data=surv_left;
	by round baseid gnn2;
	run;
data surv_left s_hold (drop=index);
	set surv_left;
		by round baseid gnn2;
	if round="&rnd" then do;
		if first.gnn2 then index=1;
		else index+1;
		output surv_left;
		end;
	else output s_hold;
	run;
proc sort data=surv_left;
	by baseid gnn2 index;
	run;

data pde_left p_hold;
	set pde_left;
	if round<"&rnd" then output pde_left;
	else output p_hold;
	run;
proc sort data=pde_left;
	by baseid gnn2 round;
	run;
data pde_left;
	set pde_left;
	by baseid gnn2;
	if first.gnn2 then index=1;
		else index+1;
	run;
data smatch (keep=pmedid baseid round m)
	pmatch (keep=pde_id baseid round m)
	surv_left (keep=BASEID PMEDID PMEDNAME ROUND BN GNN STR MCBS_FORM GSF GNN2)
	pde_left  (keep=BASEID PDE_ID PROUND BN GNN STR MCBS_FORM GSF GNN2 rename=pround=round);
	merge surv_left (in=a)
		pde_left (in=b rename=round=pround);
		by baseid gnn2 index;
	if first.baseid then m=0;
	if a and b then do;
		m+1;
		output smatch pmatch;
		end;
	else if a then output surv_left;
	else output pde_left;
	run;
proc append data=smatch base=survey_MD  force;
proc append data=pmatch base=pde_MD  force;
	run;
data surv_left;
	set surv_left s_hold;
	run;
data pde_left;
	set pde_left p_hold;
	run;
	%end;
%mend match;
%match;
proc sort data=survey_MD;
	by baseid round m;
	run;
data survey_MD;
	length matchid $6;
	set survey_MD;
		by baseid;
	if first.baseid then k=1;
	else k+1;
	matchid="MD."||put(k,z3.);
	drop baseid round m k;
	run;
proc sort data=pde_MD;
	by baseid round m;
	run;
data pde_MD;
	length matchid $6;
	set pde_MD;
		by baseid;
	if first.baseid then k=1;
	else k+1;
	matchid="MD."||put(k,z3.);
	drop baseid round m k;
	run;

* ====================================================
	Take up all the matched events and merge the
	matchid onto the respective files.
	;

data surv_match;
	set survey_m1 survey_m2 survey_m3 survey_m4
		survey_m5 survey_m6 survey_mx survey_m7 survey_m8
		survey_m9 survey_ma survey_mb survey_mc survey_md;
	retain type "MM";
	length match $2;
	match=matchid;
	run;
proc freq data=surv_match;
	table match/missing;
	run;
proc sort data=surv_match nodupkey;
	by pmedid;
	run; * There should be no duplicates;

proc sort data=survey;
	by pmedid;
	run;
data survey ouch;
	merge surv_match (in=b drop=match)
 		survey (in=a);
			by pmedid;
	if not a then output ouch;
	else output survey;
	run; * Ouch should be empty;

* ----------------------------------------------------
	Repeat for PDE (bring back in the partial-fills.
	;
data pde_match;
	set pde_m1 pde_m2 pde_m3 pde_m4
		pde_m5 pde_m6 pde_mx pde_m7 pde_m8
		pde_m9 pde_ma pde_mb pde_mc pde_md;
	retain type "MM";
	run;
proc sort data=pde_match nodupkey;
	by pde_id;
	run; * There should be no duplicates;

proc sort data=MCBSDATA.MCBS_PDE_20&CURRYEAR._ONLY  out=pde;
	by pde_id;
	run;
data pde ouch;
	length matchid $6;
	merge pde_match (in=b)
		pde (in=a);
			by pde_id;
	*if pde21="P" then type="PF";
	if not a then output ouch;
	else output pde;
	run; * Ouch should be empty;

* =====================================================
	Pull up a list of GNNs that matched on the basis of
	tradename (match type MT) and a list that matched
	on the basis of generic name (match type MG).
	;
proc summary data=pde nway;
	class baseid gnn bn round;
	where substr(matchid,2,1) in ('1','2','5','7','8','B');
	output out=match (drop=_type_ _freq_);
	run;
* This creates a stub showing where the matches occurred;
data match_bn (rename=r=round);
	set match;
		by baseid gnn bn;
	length r $5;
	retain r;
	if first.bn then r=".....";
	m=input(round,2.)-&start;
	substr(r,m,1)=substr(round,2,1);
	if last.bn then output;
	drop round m;
	run;
proc summary data=pde nway;
	class baseid gnn round;
	where substr(matchid,2,1) in ('3','4','6','9','A','C','D','X');
	output out=match (drop=_type_ _freq_);
	run;
data match_gnn (rename=r=round);
	set match;
		by baseid gnn;
	length r $5;
	retain r;
	if first.gnn then r=".....";
	m=input(round,2.)-&start;
	substr(r,m,1)=substr(round,2,1);
	if last.gnn then output;
	drop round m;
	run;

* ---------------------------------------
	There will be some drugs that appear
	in both files, but without matching
	(round mismatches, for example). Pull
	these as well.
	;
proc summary data=pde nway;
	class baseid gnn;
	output out=pde_gnn(keep=baseid gnn);
	run;
proc summary data=MCBSDATA.PME_NAME_CLEANED_20&CURRYEAR nway;
	class baseid gnn;
	output out=surv_gnn (keep=baseid gnn);
	run;
data general_gnn;
	merge pde_gnn (in=a)
		surv_gnn (in=b);
			by baseid gnn;
	if a and b;
	retain round ".....";
	run;
data common_gnn;
	set general_gnn
		match_bn
		match_gnn;
			by baseid gnn;
	keep baseid gnn;
	run;
proc sort data=common_gnn nodup;
	by baseid gnn;
	run;

* ==========================================================
	Map the list of known drugs onto the events in the
	study period, assigning a type as follows:
	| RS: "survey refill" (known GNN)
	| NS: "survey new" (unknown GNN)
	| RP: "pde refill" (known GNN)
	| NP: "pde new" (unknown GNN)
	;
proc sort data=survey;by baseid gnn;
	run;

data survey;
	merge survey(in=a)
		common_gnn (in=b);
			by baseid gnn;
	if a;
	if type ne "MM" then do;
		if b then type="RS";
		else type="NS";
		end;
	run;

* --------------------------------------------
	Pull together the unmatched events and
	those that never had a chance to match
	(untranslatable GNN).
	;

/* *CP: note, included all "no chance drugs" in match process;
  data surv_left;
	set surv_left
		no_chance_pm;
	run;*/
proc sort data=surv_left;
	by baseid gnn;
	run;
data surv_left;
	merge surv_left (in=a)
		common_gnn (in=b);
			by baseid gnn;
	length type $2;
	if a;
	if b then type="RS";
	else type="NS";
	run;

* -----------------------------------------------
	Map these event types onto the main survey
	file.
	;
proc sort data=survey;
	by pmedid;
	run;
proc sort data=surv_left;
	by pmedid;
	run;
proc sort data=MCBSDATA.PME_NAME_CLEANED_20&CURRYEAR;by pmedid;run;
data mcbsdata.matched_survey_events_20&CURRYEAR ouch;
	merge MCBSDATA.PME_NAME_CLEANED_20&CURRYEAR (in=a)
		survey (in=b)
		surv_left(in=c);
			by pmedid;
	if not a then output ouch;
	else do;
		if type=" " then type="US";
		output mcbsdata.matched_survey_events_20&CURRYEAR;
		end;
	run; *ouch should be empty;


* ----------------------------------------------------
	Do the same thing with the PDE events.
	;
proc sort data=pde;by baseid gnn;
	run;
data pde;
	merge pde (in=a)
		common_gnn (in=b);
			by baseid gnn;
	if a;
	if type ne "MM" then do;
		if b then type="RP";
		else type="NP";
		end;
	run;

/* *CP: note, included all "no chance drugs" in match process;
	data pde_left;
	set pde_left
		no_chance_pde;
	run;*/
proc sort data=pde_left;
	by baseid gnn;
	run;
data pde_left
	mcbsdata.pde_left;
	merge pde_left (in=a)
		common_gnn(in=b);
			by baseid gnn;
	length type $2;
	if a;
	if b then type="RP";
	else type="NP";
	run;

proc sort data=pde;
	by pde_id;
	run;
proc sort data=pde_left;
	by pde_id;
	run;
data MCBSDATA.MATCHED_PDE_EVENTS_20&CURRYEAR ouch;
	merge pde (in=a)
		pde_left (in=b);
			by pde_id;
	if not a then output ouch;
	else output MCBSDATA.MATCHED_PDE_EVENTS_20&CURRYEAR;
	run; *ouch should be empty;


* =====================================================
	Pull together the unmatched events with the
	matched events for hand matching.
	;
* -----------------------------------------------------
	Add back the survey conditions, whihc may help
	in matching;
proc sort data=surv_left;
	by pmedid;
	run;

data surv_left;
	merge surv_left (in=a)
		MCBSDATA.PME_NAME_CLEANED_20&CURRYEAR (in=b keep=pmedid cond1 cond2);
			by pmedid;
	if a;
	run;
* -----------------------------------------------------
	Unduplicate the list of GNNs to remove matched
	GNNs.
	;
data general_gnn;
	merge general_gnn (in=a)
		match_bn (in=b)
		match_gnn (in=c);
			by baseid gnn;
	if a and (not b) and (not c);
	keep baseid gnn round;
	run;

data hand_match;
	length round $5;
	set surv_left (in=a)
		pde_left (in=b)
	match_bn(in=c)
	match_gnn(in=d)
	general_gnn (in=e)
	;
	if c then type="MT";
	else if d then do;
		type="MG";
		bn=gnn;
		end;
	else if e then do;
		type="MU";
		bn=gnn;
		end;
	run;

* -----------------------------------------------------
	There is no point in pushing out BASEIDs where no
	match is possible. This section of code figures
	out who is worth looking at.
	;
proc summary data=hand_match nway;
	class baseid type;
	output out=cull (keep=baseid type);
	run;
data cull;
	set cull;
		by baseid;
	retain RS NS RP NP mt mg MU huh;
	array t {*} RS NS RP NP mt mg MU huh;
	if first.baseid then do i=1 to dim(t);
		t{i}=0;
		end;
	select(type);
		when('RS') RS=1;
		when('NS') NS=1;
		when('RP') RP=1;
		when('NP') NP=1;
		when('MT') mt=1;
		when('MG') mg=1;
        when('MU') MU=1;
		otherwise huh=1;
		end;
	if last.baseid and (
	(RP and (RS or NS)) or
	(NP and (RS or NS or mt or mg or MU)) or
	(RS and (RP or NP)) or
	(NS and (RP or NP or mt or mg or MU))) then output;
	keep baseid;
	run;

proc sort data=hand_match;
	by baseid type bn;
	run;


* !-----------------------------------------------------
	Break the matches into pieces that fit Excel -- 
	keep the observation count at 50k or less.
	Do this by inspecting the hand_match
	dataset and selecting the appropriate BASEIDs.
	;
data hand_match_all
	dont_bother_matching;
	length new_type $2 hand_num 3 null $1 ;*
	       BASEID $8 type $2 bn $30 gsn $6 round $5 str	$10 d3 $3 form $10
		   pmedname $30 gnn $30 pmedid $16 pde_id $19;
	retain new_type null " " hand_num .;
	merge hand_match (in=a)
	cull (in=b);
		by baseid;
	if a and (not b) and (type not in ('MT','MG'))
		then output dont_bother_matching;
	if a and b then output hand_match_all;
	
	run;


data P S M WHAT;
SET hand_match_all;
IF       SUBSTR(TYPE,2,1)='P' THEN OUTPUT P;
ELSE IF  SUBSTR(TYPE,2,1)='S' THEN OUTPUT S;
ELSE IF  SUBSTR(TYPE,1,1)='M' THEN OUTPUT M;
ELSE OUTPUT WHAT;
UPDATE_TS=.;
format UPDATE_TS datetime20.;
RUN;


PROC EXPORT DATA= P  OUTTABLE= "P_%sysfunc(DATE(),mmddyyd10.)" 
DBMS=ACCESSCS REPLACE;  DATABASE="&location.\EDIT\20&CurrYear PME Hand Match.mdb"; 
RUN;

PROC EXPORT DATA= S  OUTTABLE= "S_%sysfunc(DATE(),mmddyyd10.)" 
DBMS=ACCESSCS REPLACE;  DATABASE="&location.\EDIT\20&CurrYear PME Hand Match.mdb"; 
RUN;

PROC EXPORT DATA= M  OUTTABLE= "comp_matches_%sysfunc(DATE(),mmddyyd10.)" 
DBMS=ACCESSCS REPLACE;  DATABASE="&location.\EDIT\20&CurrYear PME Hand Match.mdb"; 
RUN;


****ASSIGN REVIEWERS **************************************************;

proc sql;
create table baseid_reviewer as select distinct 
BASEID, 
'' AS Reviewer length=15, 
'' as Notes  length 200,
. as Done,
. AS DONE_TS format=datetime20.
from HAND_MATCH_ALL;
quit;



PROC SORT DATA=baseid_reviewer; BY baseid;RUN;

proc sql noprint;
select floor(count(*) *1 / &reviewer_no) into : revrec1 from WORK.baseid_reviewer ;
select floor(count(*) *2 / &reviewer_no) into : revrec2 from WORK.baseid_reviewer ;
select floor(count(*) *3 / &reviewer_no) into : revrec3 from WORK.baseid_reviewer ;
select floor(count(*) *4 / &reviewer_no) into : revrec4 from WORK.baseid_reviewer ;
select floor(count(*) *5 / &reviewer_no) into : revrec5 from WORK.baseid_reviewer ;
*select floor(count(*) *6 / &reviewer_no) into : revrec6 from WORK.baseid_reviewer ;
quit;
%put &revrec1; %put &revrec2; %put &revrec3; %put &revrec4; %put &revrec5; *%put &revrec6;


data baseid_reviewer; 
set baseid_reviewer ;
LENGTH REVIEWER $15;
rec_id=_n_;
if               rec_id <=&revrec1 then reviewer="&rev1";
else if &revrec1<rec_id <=&revrec2 then reviewer="&rev2";
else if &revrec2<rec_id <=&revrec3 then reviewer="&rev3";
else if &revrec3<rec_id <=&revrec4 then reviewer="&rev4";
else if &revrec4<rec_id <=&revrec5 then reviewer="&rev5";
*else if &revrec5<rec_id <=&revrec6 then reviewer="&rev6";

DROP REC_ID;
run;


*************************************;
proc sql;
create table untrans as select distinct baseid, 'Y' as untrans 
from mcbsdata.matched_survey_events_20&CURRYEAR 
where bn in('','0');
quit;

proc sql;
create table baseid_reviewer2 as select a.*,b.untrans
from baseid_reviewer a left join untrans b on a.baseid=b.baseid
order by a.baseid;
quit;


PROC EXPORT DATA= baseid_reviewer2
            OUTTABLE= "baseid_reviewer_%sysfunc(DATE(),mmddyyd10.)" 
            DBMS=ACCESSCS REPLACE;
     DATABASE="&location.\EDIT\20&CurrYear PME Hand Match.mdb"; 

RUN;


*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
|      PROGRAM: Read FDB                                                                |
|      UPDATED: 08/31/2011                                                              |
|  INPUT FILES: First DataBank NDDF data (available on CD-ROM)                          |
| OUTPUT FILES: FDB_&date.sas7bdat                                                      |
|  DESCRIPTION: Inputs the First DataBank data and merges to create a SAS dataset       |
|               containing drug ingredient (name, doseage form, strength, route)        |
|               therapeutic classification and pricing.                                 | 
|                                                                                       |
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;
OPTION MLOGIC MPRINT SYMBOLGEN COMPRESS=YES;
%let     CURRYEAR =20; *MCBS YEAR;
%let     FDBYEAR  =21; *FDB YEAR ALWAYS ONE YEAR AHEAD;
%let  FDBdate = 20210310; *this is the date of the FDB file you are creating; ***NEW DATE***;

%LET    LOCATION = C:\Users\S1C3\RIC PME\MCBS\20&CURRYEAR.\PME\Data\;
%let FDBLOCATION = C:\Users\S1C3\RIC PME\FDB_MDDB\Data\20&CURRYEAR.\NDDF Plus DB\;
/*%let FDBLOCATION2 = C:\Users\S1C3\RIC PME\FDB_MDDB2\Data\20&CURRYEAR.\NDDF Plus DB\;  ***NEW LOCATION and 2011 $$****/

libname OUTLIB "&LOCATION";


***FDB file structure macro variables;
%let ingred =\NDDF Descriptive and Pricing\NDDF BASICS 3.0\Generic Formulation and Ingredient\;
%let pack   =\NDDF Descriptive and Pricing\NDDF BASICS 3.0\Packaged Product\;
%let pricing=\NDDF Descriptive and Pricing\NDDF BASICS 3.0\Pricing\;
%let class  =\NDDF Descriptive and Pricing\NDDF BASICS 3.0\Miscellaneous Therapeutic Class\;
%let etc    =\NDDF Descriptive and Pricing\NDDF ETC 1.0\;
%let edu    =\Patient Education\PEM 2.0\;


***GSN Master;
data GSN;
infile "&FDBLOCATION.&ingred.RGCNSEQ4_GCNSEQNO_MSTR" lrecl=99999 missover dlm="|" dsd;
attrib
GCN_SEQNO	format=z6. label="Generic Code Number Sequence Number"
HIC3		length=$3  label="Hierarchical Specific Therapeutic Class Code"	
HICL_SEQNO	           label="Hierarchical Ingredient Code List Sequence Number"		
GCDF		length=$2  label="Dosage Form Code (2 character)"	
GCRT		length=$1  label="Route of Administration Code (1-character)"	
STR			length=$10 label="Drug Strength Description"
GTC			length=$3  label="Therapeutic Class Code, Generic"
TC			length=$2  label="Therapeutic Class Code, Standard"
DCC			length=$1  label="Drug Category Code"
GCNSEQ_GI	length=$1  label="gsn-Level Generic Indicator"		
GENDER		length=$1  label="Gender-Specific Drug Indicator"	
HIC3_SEQN	length=$6  label="Hierarchical Specific Therapeutic Class Code Sequence Number"		
STR60       length=$60 label="Drug Strength Description - 60"
 
;
input GCN_SEQNO hic3 hicl_seqno gcdf gcrt str gtc tc dcc gcnseq_gi gender hic3_seqn str60;
keep  GCN_SEQNO hic3 hicl_seqno gcdf gcrt str gtc tc dcc gcnseq_gi        hic3_seqn str60;
run;

data STRNGTH_DESC;
infile "&FDBLOCATION.&ingred.RSTR1_STRNGTH_DESC" lrecl=99999 missover dlm="|" dsd;
attrib
STR60       length=$60 label="Drug Strength Description - 60"
STRNUM label="Drug Strength Number"
VOLNUM label="Drug Strength Volume Number"
STRUN50 length=$50 label="Drug Strength Units - 50"
VOLUN50 length=$50 label="Drug Strength Volume Units - 50"
;
input STR60   STRNUM  VOLNUM  STRUN50 VOLUN50;
run;


data nddf_GTC;
infile "&FDBLOCATION.&class.RGTCD0_GEN_THERAP_CLASS_DESC" lrecl=99999 missover dlm="|" dsd;
attrib
 GTC			length=$3  label="Therapeutic Class Code, Generic"
 GTC_DESC	length=$55 label="Therapeutic Class Code Description, Generic"
;
input GTC GTC_DESC;
run;



***HICL ingredient list to ingredient link;
data HICL_link;
infile "&FDBLOCATION.&ingred.RHICL1_HIC_HICLSEQNO_LINK" lrecl=99999 missover dlm="|" dsd;
attrib
HICL_SEQNO	label='Ingredient List Identifier (formerly the Hierarchical Ingredient Code List Sequence Number) (Stable ID)'	
HIC_SEQN	label='Hierarchical Ingredient Code Sequence Number (Stable ID)'	
HIC_REL_NO	label='Hierarchical Ingredient Code Relative Number'	
HIC	label='Hierarchical Ingredient Code'	length=$6
;
input HICL_SEQNO HIC_SEQN HIC_REL_NO HIC;
run;


**Strength;
data strength;
infile "&FDBLOCATION.&ingred.RGCNSTR0_INGREDIENT_STRENGTH" lrecl=99999 missover dlm="|" dsd;
attrib
GCN_SEQNO	label='Clinical Formulation ID (Stable ID)' format=z6.
HIC_SEQN label='Ingredient Identifier (Stable ID)'
STRENGTH_STATUS_CODE	label='Clinical Formulation Ingredient Strength Status Code'
STRENGTH	label='Clinical Formulation Ingredient Strength'
STRENGTH_UOM_ID	label='Clinical Formulation Ingredient Strength Unit of Measure Identifier'
STRENGTH_TYP_CODE	label='Clinical Formulation Ingredient Strength Type Code'
VOLUME	label='Clinical Formulation Ingredient Volume'
VOLUME_UOM_ID	label='Clinical Formulation Ingredient Volume Unit of Measure Identifier'
ALT_STRENGTH	label='Clinical Formulation Ingredient Alternate Strength'
ALT_STRENGTH_UOM_ID	label='Clinical Formulation Ingredient Alternate Strength Unit of Measure Identifier'
ALT_STRENGTH_TYP_CODE	label='Clinical Formulation Ingredient Alternate Strength Type Code'
TIME_VALUE	label='Clinical Formulation Ingredient Time'
TIME_UOM_ID	label='Clinical Formulation Ingredient Time Unit of Measure Identifier'
RANGE_MAX	label='Clinical Formulation Ingredient Range Maximum'
RANGE_MIN	label='Clinical Formulation Ingredient Range Minimum'
;
input GCN_SEQNO HIC_SEQN  STRENGTH_STATUS_CODE STRENGTH STRENGTH_UOM_ID STRENGTH_TYP_CODE
VOLUME VOLUME_UOM_ID ALT_STRENGTH ALT_STRENGTH_UOM_ID ALT_STRENGTH_TYP_CODE TIME_VALUE
TIME_UOM_ID RANGE_MAX RANGE_MIN 
;
run;


***NDC Master;
data nddf;
	infile "&FDBLOCATION.&pack.RNDC14_NDC_MSTR"
		lrecl=99999 missover dlm="|" dsd;
	attrib					
	NDC	label='11-digit NDC'	length=$11		
	ndc_9	label='9-digit NDC'	length=$9		
	lblrid	label='Labeler Identifier'	length=$6		
	gcn_seqno	label='Generic Code Number Sequence Number'			format=z6.
	ps	label='Package Size'		informat=12.3	format=12.3
	df	label='Drug Form Code'	length=$1		
	ad	label='Additional Descriptor'	length=$20		
	fda_nm 	label='Label Name'	length=$30		
	bn 	label='Brand Name'	length=$30		
	pndc	label='Previous National Drug Code'	length=$11		
	repndc	label='Replacement National Drug Code'	length=$11		
	ndcfi	label='NDC Format Indicator'	length=$1		
	daddnc 	label='NDC-Level Date of Add'			
	dupdc 	label='NDC-level Date of Update'			
	desi	label='FDA DESI (Drug Efficacy Study Implementa'	length=$1		
	desdtec	label='DESI Date of Status Change by the FDA'	
	desi2 	label='FDA DESI2 Drug Indicator'	length=$1
	des2dtec	label='DESI2 Date of Status Change by the FDA'	
	dea 	label='Drug Enforcement Administration Code'	length=$1
	cl 	label='Drug Class'	length=$1
	gpi_fdb	label='Generic Price Indicator'	length=$1
	hosp	label='Hospital Selection Indicator'	length=$1
	innov 	label='Innovator Indicator'	length=$1
	ipi	label='Institutional Product Indicator'	length=$1
	mini 	label='Mini Selection Indicator'	length=$1
	maint 	label='Maintenance Drug Indicator'	length=$1
	obc 	label='Orange Book Code'	length=$2
	obsdtec	label='Obsolete Date'	
	ppi 	label='Patient Package Insert Indicator'	length=$1
	stpk	label='Standard Package Indicator'	length=$1
	repack	label='Repackaged Indicator'	length=$1
	top200 	label='Top 200 Indicator'	length=$3		
	ud 	label='Unit Dose Indicator'	length=$1		
	csp 	label='Case Size'			
	ndl_gdge 	label='Needle Gauge'		informat=6.3	format=6.3
	ndl_lngth	label='Needle Length'	length=$6 /*	informat=6.3	format=6.3 */
	syr_cpcty 	label='Syringe Capacity'	length=$6 /*	informat=6.3	format=6.3 */
	shlf_pck 	label='Shelf Pack'	length=$7		
	shipper	label='Shipper Quantity'			
	hcfa_fda	label='HCFA FDA Therapeutic Equivalency Code'	length=$2		
	hcfa_unit 	label='HCFA Unit Type'	length=$3		
	hcfa_ps 	label='HCFA Units Per Package'		informat=12.3	format=12.3
	hcfa_appc	label='HCFA FDA Approval Date'			
	hcfa_mrkc	label='HCFA Market Entry Date'			
	hcfa_trmc 	label='HCFA Termination Date'	length=$8		
	hcfa_typ 	label='HCFA Drug Type Code'	length=$1		
	hcfa_desc1	label='HCFA Current DESI Effective Date'	length=$8		
	hcfa_desi1	label='HCFA Current DESI Code'	length=$1		
	uu 	label='Unit of Use Indicator'	length=$1		
	pd 	label='Package Description'	length=$10		
	ln25	label='Label Name - 25'	length=$25		
	ln25i	label='Label Name - 25/Generic Name Use Indicat'	length=$1		
	gpidc	label='Date of Last Change to GPI'	length=$8		
	bbdc 	label='NDC-level Date of Last Change to Blue Bo'	length=$8		
	home	label='Home Health Selection Indicator'	length=$1		
	inpcki	label='Inner Package Indicator'	length=$1		
	outpcki	label='Outer Package Indicator'	length=$1		
	obc_exp	label='Orange Book Code Expanded'	length=$2		
	ps_equiv	label='Package Size Equivalent Value'		informat=12.3	format=12.3
	plblr 	label='Private NDC Labeler Indicator'	length=$1
	top50gen	label='Top 50 Generic Indicator'	length=$2
	obc3 	label='Orange Book three-byte Code'	length=$3
	gmi 	label='Generic Manufacturer Indicator'	length=$1
	gni 	label='Generic-Named Drug Indicator'	length=$1
	gsi 	label='Generic Price Spread Indicator'	length=$1
	gti 	label='Generic Therapeutic Drug Indicator'	length=$1
	ndcgi1 	label='NDC-Level Generic Indicator'	length=$1
	hcfa_dc	label='HCFA Drug Category'	length=$1
	;
	input 
	NDC lblrid gcn_seqno ps df ad fda_nm bn pndc repndc ndcfi daddnc dupdc
		desi desdtec desi2 des2dtec dea cl gpi_fdb  hosp  innov  ipi mini
		maint obc  obsdtec  ppi stpk  repack top200
		ud csp ndl_gdge ndl_lngth syr_cpcty shlf_pck shipper
		hcfa_fda hcfa_unit hcfa_ps hcfa_appc hcfa_mrkc hcfa_trmc hcfa_typ hcfa_desc1
		hcfa_desi1 uu  pd ln25 ln25i  gpidc bbdc home inpcki outpcki
		obc_exp ps_equiv plblr top50gen obc3 gmi gni gsi
		gti ndcgi1 hcfa_dc;

	ndc_9=NDC;
	keep NDC ndc_9 lblrid gcn_seqno ps df ad fda_nm bn pndc repndc ndcfi daddnc dupdc
		cl gpi_fdb obc obsdtec repack top200 pd gmi gni gsi ndcgi1 gti innov;
	run;

***GNN (generic name) Master;
data nddf_gnn;
	infile "&FDBLOCATION.&ingred.RHICLSQ1_HICLSEQNO_MSTR"
		lrecl=999999 missover dlm="|" dsd;
	attrib
	hicl_seqno	label="Hierarchical Ingredient Code List Sequence Number"	
	gnn 		label="USAN Generic Name - Short Version"	length=$30
	gnn60		label="USAN Generic Name - Long Version"	length=$60;
	input hicl_seqno gnn gnn60;
	keep hicl_seqno gnn gnn60;
	run;

***Dosage Form;
data nddf_form;
	infile "&FDBLOCATION.&ingred.RDOSED2_DOSE_DESC"
		lrecl=999999 missover dlm="|" dsd;
	attrib
	gcdf	label="Dosage Form Code (2 character)"	length=$2
	form	label="Dosage Form Description"	length=$10
	gcdf_desc	label="Dosage Form Code Description"	length=$40
	;
	input gcdf form gcdf_desc;
	run;


***Route code (2-digit) and description;
data nddf_route; 
infile "&FDBLOCATION.&ingred.RROUTED3_ROUTE_DESC"
		lrecl=99999 missover dlm="|" dsd;
attrib					
GCRT      label='Route of Administration Code (1-character)'  length=$1
RT        label='Route Description'	                          length=$10
GCRT2     label='Route of Administration Code (2-character)'  length=$2
GCRT_DESC label='Route Code Interpretation'                   length=$40
SYSTEMIC  label='Systemic Route Indicator'                    length=$1
;
input GCRT RT GCRT2 GCRT_DESC SYSTEMIC ;
run;



**Enhanced Theraputic Category (ETC);
data nddf_etc;
	infile "&FDBLOCATION.&etc.RETCNDC0_ETC_NDC"
		lrecl=99999 missover dlm="|" dsd;
	attrib
	NDC	length=$11
	etc_id	label="ETC Identifier"	length=8.
	etc_common_use_ind	label="ETC Common Use Indicator"	length=$1
	etc_default	label="ETC Default Use Indicator"	length=$1;
	input NDC etc_id etc_common_use_ind etc_default;
	run;


*ETC Description Table;
data nddf_ETC_id;
infile "&FDBLOCATION.&etc.\RETCTBL0_ETC_ID"
		lrecl=99999 missover dlm="|" dsd;
attrib
ETC_ID label= 'ETC Identifier-a permanent numeric identifier that represents a unique therapeutic classification. (Stable ID)' format=z8.
ETC_NAME label= 'ETC Name-a unique mixed case descriptive name for a therapeutic classification.' length=$70
ETC_ULTIMATE_CHILD_IND label= 'ETC Ultimate Child Indicator-indicates that the given ETC_ID has no lower-level classifications associated to it.' length=$1
ETC_DRUG_CONCEPT_LINK_IND label= 'ETC Drug Concept Link Indicator-indicates that at least one GCN_SEQNO is associated to the given ETC_ID.' length=$1
ETC_PARENT_ETC_ID  label= 'ETC Parent ETC Identifier-identifies the ETC_ID that is one level higher than the given ETC_ID.' format=z8.
ETC_FORMULARY_LEVEL_IND label= 'ETC Formulary Level Indicator-identifies a suggested level for building formularies.' length=$1
ETC_PRESENTATION_SEQNO label= 'ETC Presentation Sequence Number-provides a sort order for sequencing ETC_IDs with the same parent.' format=z5.
ETC_ULTIMATE_PARENT_ETC_ID  label= 'ETC Ultimate Parent ETC Identifier-identifies the therapeutic classification that is at the top of the hierarchy from the given ETC_ID.' format=z8.
ETC_HIERARCHY_LEVEL label= 'ETC Hierarchy Level-provides the position of the given therapeutic classification in the hierarchical structure.' format=z2.
ETC_SORT_NUMBER label= 'ETC Sort Number-provides a sort order for sequencing the ETC_ID when printing or displaying a list; changes with each product update and should not be used as a class identifier.' format=z5.
ETC_RETIRED_IND label= 'ETC Retired Indicator-indicates that the given ETC_ID has been retired.' length=$1
ETC_RETIRED_DATE label= 'ETC Retired Date-provides the date on which the ETC_ID was retired.' format=z8.
;
input ETC_ID ETC_NAME ETC_ULTIMATE_CHILD_IND ETC_DRUG_CONCEPT_LINK_IND ETC_PARENT_ETC_ID ETC_FORMULARY_LEVEL_IND ETC_PRESENTATION_SEQNO ETC_ULTIMATE_PARENT_ETC_ID ETC_HIERARCHY_LEVEL
ETC_SORT_NUMBER ETC_RETIRED_IND ETC_RETIRED_DATE;
run;

*Merge NDC/ETC_ID to ETC Descriptions; 
proc sql; 
create table nddf_etc_desc as select 
a.NDC, b.ETC_ID, b.ETC_NAME, b.ETC_SORT_NUMBER
from nddf_ETC a full join nddf_ETC_id b on a.ETC_ID=b.ETC_ID
where ETC_COMMON_USE_IND='1';
quit;
run;


**NDC Pricing;
data nddf_price;
	infile "&FDBLOCATION.&pricing.RNP2_NDC_PRICE"
		lrecl=99999 missover dlm="|" dsd;
	attrib
	NDC	length=$11
	npt_type	label="NDC Price Table - Price Type Code"	length=$2
	npt_datec	label="NDC Price Table - Effective Date"	length=$8
	npt_pricex	label="NDC Price Table - Price";
	input NDC npt_type npt_datec npt_pricex;
	run;


proc sort data=nddf_price;
	by NDC npt_type descending npt_datec;
	run;
data bbx;
	set nddf_price;
		by NDC npt_type descending npt_datec;
	length bbx_c01-bbx_c08 $8;
	array dte {*} bbx_c01-bbx_c08;
	array awp {*} bbx_p01-bbx_p08;
	if first.NDC then do;
		k=0;
		do i=1 to dim(dte);dte{i}=" ";awp{i}=.;end;
		end;
	if npt_type='01' then do;
		k+1;
		dte{k}=npt_datec;
		awp{k}=npt_pricex;
		end;
	if last.NDC then output;
	retain;
	keep NDC bbx_c01-bbx_c08 bbx_p01-bbx_p08;
	label bbx_c01="Latest price eff date"
			bbx_p01="Latest AWP";
	run;

data nddf_price;
	set nddf_price;
		by NDC npt_type descending npt_datec;
	if first.NDC then do;
		bbpr=.;dir=.;whn=.;ffpul=.;
		end;
	if first.npt_type then select (npt_type);
		when ('01') bbpr=npt_pricex;
		when ('05') dir=npt_pricex;
		when ('09') whn=npt_pricex;
		when ('11') ffpul=npt_pricex;
		otherwise;
		end;
	if last.NDC then output;
	retain;
	keep NDC bbpr dir whn ffpul;
	label bbpr="Blue Book AWP Unit Price"
		dir="Direct Unit Price"
		whn="Net Wholesale Unit Price"
		ffpul="Federal Financing Participation Upper Limits";
	run;


*** Create seperate tables for ingredient 1 and 2 (all others are ingnored...);
proc sql;
create table str1 as
SELECT strength.GCN_SEQNO, hicl_link.HICL_SEQNO, strength.STRENGTH as str1
FROM hicl_link LEFT JOIN strength ON hicl_link.HIC_SEQN = strength.HIC_SEQN
WHERE hicl_link.HIC_REL_NO=1;

create table str2 as
SELECT strength.GCN_SEQNO, hicl_link.HICL_SEQNO, strength.STRENGTH as str2
FROM hicl_link LEFT JOIN strength ON hicl_link.HIC_SEQN = strength.HIC_SEQN
WHERE hicl_link.HIC_REL_NO=2;
quit;


*Drug Monograph;
data PEC_LINK;
infile "&FDBLOCATION.&edu.RPEMGC0_GCNSEQNO_LINK" lrecl=99999 missover dlm="|" dsd;
attrib
GCN_SEQNO	format=z6. label="Generic Code Number Sequence Number"
PEC          label="Patient Education Code";
input GCN_SEQNO PEC;
run;

data PEC_MONO;
infile "&FDBLOCATION.&edu.RPEMMOE2_MONO" lrecl=99999 missover dlm="|" dsd;
attrib
PEMONO      label='Patient Education Monograph Code'
PEMONOE_SN  label='Patient Education Text Sequence Number (Standard)'
PEMTXTEI    length=$1 label='Patient Education Text Identifier (Standard)'
PEMTXTE     length=$76 label='Patient Education Text (Standard)' 
PEMGNDR     length=$1 
PEMAGE      length=$1;

input PEMONO PEMONOE_SN PEMTXTEI PEMTXTE  PEMGNDR  PEMAGE  ;
if PEMTXTEI='U';
keep PEMONO PEMONOE_SN  PEMTXTE    ; 
run;

data PEC_MASTER;
infile "&FDBLOCATION.&edu.RPEMMA5_MSTR" lrecl=99999 missover dlm="|" dsd;
attrib

PEC                  label='Patient Education Code' 	
DGNAME    length=$30 label='Drug Name'	
LBLMSG1   length=$27 label='Patient Education Message Line #1'	
LBLMSG2   length=$27 label='Patient Education Message Line #2'	
PEMONO               label='Patient Education Monograph Code'	
AMACDE    length=$3  label='This column is not currently being used'	
PHMXCDE   length=$3  label='This column is not currently being used'	
USPCDE    length=$4  label='This column is not currently being used'	
NARDCDE   length=$3  label='This column is not currently being used'	
ASHPCDE3             label='Patient Education—American Society of Health-System Pharmacists Monograph Code Version 3'
ASHPCDE3             label='This column is not currently being used'
PEMONOS              label='Patient Education Spanish Language Monograph Code.'
PEMONOS              label='This column is not currently being used'	
PEMONOFRA            label='Patient Education French Language Monograph Code'	
;
input PEC DGNAME LBLMSG1 LBLMSG2 PEMONO AMACDE PHMXCDE USPCDE NARDCDE
      ASHPCDE3 ASHPCDE3 PEMONOS PEMONOS PEMONOFRA ;
run;

proc sql; create table info as select
b.PEC,
b.dgname,
c.PEMONO,
c.PEMONOE_SN,
c.PEMTXTE

from PEC_MASTER b left join PEC_MONO    c on b.pemono=c.pemono
order by b.PEC,b.dgname,c.PEMONO,c.PEMONOE_SN;
quit;
 
proc transpose data=info
                 out=info2;
by PEC dgname PEMONO;
var PEMTXTE;
run;

data info3; set info2;
mono=
trim(
trim(col1) || " " || 
trim(col2) || " " || 
trim(col3) || " " || 
trim(col4) || " " || 
trim(col5) || " " || 
trim(col6) || " " || 
trim(col7) || " " || 
trim(col8) || " " || 
trim(col9) || " " || 
trim(col10) || " " || 
trim(col11) || " " || 
trim(col12) || " " || 
trim(col13) || " " || 
trim(col14) || " " || 
trim(col15) || " " || 
trim(col16) || " " || 
trim(col17) || " " || 
trim(col18) || " " || 
trim(col19) || " " || 
trim(col20) || " " || 
trim(col21) || " " || 
trim(col22) || " " || 
trim(col23) || " " || 
trim(col24) || " " || 
trim(col25) || " " || 
trim(col26) || " " || 
trim(col27) || " " || 
trim(col28) || " " || 
trim(col29) || " " || 
trim(col30))  ;
keep PEC dgname PEMONO mono;
run;


PROC EXPORT DATA= info3
            OUTTABLE= "MONO_%sysfunc(DATE(),mmddyyd10.)" 
            DBMS=ACCESSCS REPLACE;
     DATABASE="&location.\EDIT\20&CurrYear FDB and PME lookup.mdb"; 

RUN;

PROC EXPORT DATA= PEC_LINK
            OUTTABLE= "MONO_GSN_%sysfunc(DATE(),mmddyyd10.)" 
            DBMS=ACCESSCS REPLACE;
     DATABASE="&location.\EDIT\20&CurrYear FDB and PME lookup.mdb"; 

RUN;

**********************************************************************;
****    Merge tables and create final dataset   **********************;
**********************************************************************;
proc sql;
create table OUTLIB.FDB_&FDBdate as select
n.*,
s1.str1 label='Ingredient 1 Strength',
s2.str2 label='Ingredient 2 Strength',
sd.*,
s.*,
g.*,
f.*,
r.*,
t.*,
e.*,
p.*,
b.*

from      nddf          n
left join gsn           s on n.gcn_seqno  = s.gcn_seqno
left join nddf_gnn      g on s.hicl_seqno = g.hicl_seqno
left join nddf_form     f on s.gcdf       = f.gcdf
left join nddf_route    r on s.GCRT       = r.GCRT
left join nddf_GTC      t on s.gtc        = t.gtc
left join nddf_etc_desc e on n.NDC        = e.NDC
left join nddf_price    p on n.NDC        = p.NDC
left join bbx           b on n.NDC        = b.NDC
left join str1          s1 on s.gcn_seqno = s1.gcn_seqno and s.hicl_seqno = s1.hicl_seqno
left join str2          s2 on s.gcn_seqno = s2.gcn_seqno and s.hicl_seqno = s2.hicl_seqno
left join strngth_desc  sd on s.str60     = sd.str60
;
quit;




ODS HTML CLOSE;
  ODS HTML;

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
|                                                                        |
|  PROGRAM: 10_Final_QA                                                  |
|   AUTHOR: Christopher Powers                                           |
|  CREATED: 06/09/2010                                                   |
|  UPDATED: 06/09/2010                                                   |
|                                                                        |
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;
options nofmterr;

OPTION MLOGIC MPRINT SYMBOLGEN COMPRESS=YES;

%let CurrYear =19;
%let LastYear =18;
%let location = C:\Users\S1C3\RIC PME\MCBS\20&CURRYEAR.\PME\Data\;
%let loc_last = Y:\Share\SMAG\MCBS\MCBS Cost Supplement File\2018\Data\SAS Files;
libname  MCBSDATA "&location";
LIBNAME  MCBSLAST "&loc_last";
libname COST_USE "Y:\Share\SMAG\MCBS\MCBS Cost Supplement File\20&CURRYEAR.\Data\SAS Files";

data oversample_test; set mcbsdata.pme;
if substr(baseid,1,2) = "08";
run;

proc datasets lib=mcbsdata;run;


proc sql;

select count(*) as COST19_FINAL_PM from mcbsdata.COST19_FINAL_PM;
select count(*) as PM_EVENTS from mcbsdata.PM_EVENTS;
select count(*) as FINAL_19_V2 from mcbsdata.FINAL_19_V2;
select count(*) as TOWESTAT_19 from mcbsdata.TOWESTAT_19;

select count(*) as PM19IMP from mcbsdata.PM19IMP;

select count(*) as PM_EVENTS_IMPD_FULL_MERGE from mcbsdata.PM_EVENTS_IMPD_FULL_MERGE;

select count(*) as PM_EVENTS_IMPD_FINAL_2019 from mcbsdata.PM_EVENTS_IMPD_FINAL_2019;
select count(*) as PM_EVENTS_IMPD_86_2020 from mcbsdata.PM_EVENTS_IMPD_86_2020;
select count(*) as PM_EVENTS_IMPD_FINAL_2019_NOOME from mcbsdata.PM_EVENTS_IMPD_FINAL_2019_NOOME;
select count(*) as PM_EVENTS_OM_2019 from mcbsdata.PM_EVENTS_OM_2019;
select count(*) as pme from mcbsdata.pme;

quit;



COST19_FINAL_PM
DELETED_OTC_19
FINAL_19_V2
PM19IMP
PM_EVENTS
PM_EVENTS_IMPD_86_2020
PM_EVENTS_IMPD_FINAL_2019
PM_EVENTS_IMPD_FINAL_2019_NOOME
PM_EVENTS_IMPD_FULL_MERGE
PM_EVENTS_OM_2019
PUFF19
TOWESTAT_19


ods html file="&location.PME QA 20&CurrYear vs. 20&lastyear - %sysfunc(DATE(),mmddyyd10.).html";



PROC FORMAT;
  VALUE MATCH      1 = "Survey Reported Event"
                   2 = "PDE Only Event"
                   3 = "Survey Reported Event matched to PDE";

  VALUE $INTRFMT "C" = "Community"
                 "F" = "Facility" ;

  VALUE $EVNTTYP
                "  " = "Missing"
                "DU" = "Dental"
                "ER" = "Emergency Room"
                "IP" = "Inpatient"
                "IU" = "Institutional utilization"
                "MP" = "Medical provider"
                "OM" = "Other medical expense"
                "OP" = "Outpatient"
                "PM" = "Prescribed medicine"
                "SD" = "Separately billing physician"
                "SL" = "Separately billing lab" ;

  VALUE FORMFMT
                1  = "Pill"
                2  = "Liquid"
                3  = "Drops"
                4  = "Topical ointment"
                5  = "Suppository"
                6  = "Inhalant/aerosol spray"
                7  = "Shampoo, soap"
                8  = "Injection"
                9 = "I.V."
                10 = "Patch/pad"
                11 = "Topical gel/jelly"
                12 = "Powder"
                91 = "Other" 
                .  = "Inapplicable"
               .N  = "Not ascertained"
               .D  = “Don’t know”
               .R  = “Refused;

  VALUE TABFMT     . = "Missing"
                  -8 = "Don't know"
                  -9 = "Not ascertained"
               1-999 = "Number of tablets in container" ;

  VALUE SUPPFMT    . = "Missing or inapplicable"
                  -8 = "Don't know"
                  -9 = "Not ascertained"
                1-98 = "Number of suppositories in container"
                  99 = "99 or more suppositories in container" ;

  VALUE $AMTFMT     "  " = "Missing"
                    "-8" = "Don't know"
                    "-9" = "Not ascertained"
                    "1 " = "Ounces"
                    "2 " = "Grams"
                    "3 " = "Milliliters (ML, CC)"
                    "4 " = "Milliequivalents (MEQ)"
                    "5 " = "Milligrams (MG, MGM)"
                    "6 " = "Micrograms (MCG)"
                    "7 " = "Doses, puffs, blisters"
                    "91" = "Other" ;

  VALUE $THERFMT
                "  " = "Unknown"
                "UN" = "Unclassified drug products"
                "02" = "Analgesics"
                "03" = "Analgesic and antihist combo"
                "05" = "Anesthetics"
                "08" = "Anti-obesity drugs"
                "09" = "Antidotes"
                "11" = "Antiarthritics"
                "14" = "Antiasthmatics"
                "17" = "Antihistamines"
                "18" = "Antihistimine/Decongestant comb"
				"19" = "Antibiotics"
                "20" = "Antiinfectives"
				"21" = "Antivirals"
				"22" = "Antifungals"
                "23" = "Antiinfectives, miscellaneous"
                "26" = "Antineoplastics"
                "29" = "Antiparkinson drugs"
                "32" = "Autonomic drugs"
                "35" = "Blood"
				"36" = "Anticoagulants"
                "38" = "Cardiac drugs"
                "41" = "Cardiovascular"
                "44" = "CNS drugs"
                "47" = "Contraceptives"
                "50" = "Cough and cold preparations"
                "53" = "Diagnostic"
                "56" = "Diuretics"
                "59" = "Electrolyte, caloric, & fluid rep."
                "62" = "EENT preparations"
                "65" = "Gastrointestinal preparations"
                "68" = "Hormones"
                "71" = "Hypoglycemics"
                "72" = "Immunosuppresant"
                "74" = "Misc. medical supp., devices, & other"
                "77" = "Muscle relaxants"
                "80" = "Psychotherapeutic drugs"
                "83" = "Sedative and hypnotic drugs"
                "86" = "Skin preparations"
                "89" = "Thyroid preparations"
                "92" = "Biologicals"
                "94" = "Pre-natal vitamins"
                "95" = "Vitamins, all others"
                "97" = "Smoking Deterrents"
                "98" = "Herbals"
                "99" = "Unclassified drug products" ;

  VALUE $OTCFMT  "F" = "Federal or legend drug"
                 "O" = "Over-the-counter drug"
                 "B" = "Both OTC and RX"
                 "U" = "Unknown"
                 " " = "Missing";

  VALUE $STRNFMT
                "  " = "Missing"
                "-1" = "Inapplicable"
                "-8" = "Don't know"
                "-9" = "Not ascertained"
                "1 " = "Micrograms"
                "2 " = "Milligrams"
                "3 " = "Grains"
                "4 " = "Milliequivalents (MEQ)"
                "5 " = "Grams (GM,G)"
                "6 " = "Percent"
                "7 " = "International units"
                "8 " = "Units"
                "91" = "Other" ;

  VALUE STRNFMT    . = "Missing"
                  -1 = "Inapplicable"
                  -8 = "Don't know"
                  -9 = "Not ascertained"
                   0 = "Zero"
               OTHER = "Number of units of strength" ;

  VALUE AMTFMT     . = "Missing"
                  -8 = "Don't know"
                  -9 = "Not ascertained"
               OTHER = "Number of units in container" ;

  VALUE MONYFMT
               OTHER = "Amount as $$$$$$.CC" ;

  VALUE $IMPFMT  "0" = "Not imputed"
                 "1" = "Imputed" ;

  VALUE $YES4FMT   . = "Missing"
                "-1" = "Inapplicable"
                "-7" = "Refused"
                "-8" = "Don't know"
                "-9" = "Not ascertained"
                " 1" = "Yes"
                " 2" = "No" ;
  
VALUE PMUNIT    
                    1  = "Ounces"
                    2  = "Grams"
                    3  = "Milliliters (ML, CC)"
                    4  = "Milliequivalents (MEQ)"
                    5  = "Milligrams (MG, MGM)"
                    6  = "Micrograms (MCG)"
                    7  = "Doses, puffs, blisters"
                    91 = "Other" 
                     . = "Missing"
                    .D = "Don't know"
                    .N = "Not ascertained"
                    .R = "Refused";
  VALUE STRENGTH
                1  = "Micrograms"
                2  = "Milligrams"
                3  = "Grains"
                4  = "Milliequivalents (MEQ)"
                5  = "Grams (GM,G)"
                6  = "Percent"
                7  = "International units"
                8  = "Units"
                91 = "Other" 
                 . = "Inapplicable"
                .D = "Don't know"
                .N = "Not ascertained"
                .R = "Refused";
run;

data fix;
set mcbslast.pme;
version2 = input(version,best8.);
pmform2 = input(pmform,best8.);
strn12 = input(strnuni1,best8.);
/*strn22 = input(strnuni2,best8.);*/
amtunit2 = input(amtunit,best8.);
serv_dt2 = input(serv_dt,best8.);
drop version pmform strnuni1 strnuni2 amtunit serv_dt;
rename version2=version pmform2=pmform strn12=strnuni1 /*strn22=strnuni2*/ serv_dt2=serv_dt;
run;

data fix2;
set mcbsdata.pme;
rename amtmadv=AMTHMOM isopmadv=ISOPHMOM iamtmadv=IAMTHMOM;
run;


data all; set fix2 (in=a) fix (in=b);
if a then year="20&curryear";
if b then year="20&lastyear";

run;

title "Costs by Year";
PROC TABULATE DATA=all   ;
   VAR    AMTTOT AMTCARE AMTCAID AMTHMOP AMTHMOM /*AMTVA*/ AMTPRVE AMTPRVI AMTPRVU AMTOOP AMTDISC AMTOTH 
          STRNNUM1 /*STRNNUM2*/ TABNUM SUPPNUM AMTNUM QNTY DAYSUPP   ;
   CLASS year;
   TABLE (AMTTOT AMTCARE AMTCAID AMTHMOP AMTHMOM /*AMTVA*/ AMTPRVE AMTPRVI AMTPRVU AMTOOP AMTDISC AMTOTH 
          STRNNUM1 /*STRNNUM2*/ TABNUM SUPPNUM AMTNUM QNTY DAYSUPP   ),
          (year) *
			 ('N'='N'*F=COMMA12.0 
			  "SUM"= "Sum"*F=DOLLAR15.0
              'MEAN'='Mean'*F=DOLLAR15.2
			  'MEDIAN'='Median'*F=DOLLAR15.2  
              'MAX'='Max'*F=DOLLAR15.2 )/ misstext=' ';
RUN;title;




title "Char Vars by Year";
proc tabulate data=all  order=freq ;
   class TYPE CORF PMFORM STRNUNI1 /*STRNUNI2*/ AMTUNIT THERCC OTCLEG
         ISOPCARE ISOPCAID ISOPHMOP ISOPHMOM /*ISOPVA*/ ISOPPRVE ISOPPRVI ISOPUNK ISOPOOP ISOPDISC ISOPOTH
         IAMTTOT IAMTCARE IAMTCAID IAMTHMOP IAMTHMOM /*IAMTVA*/ IAMTPRVE IAMTPRVI IAMTPRVU IAMTOOP IAMTDISC IAMTOTH;
   class year;
   table
		TYPE CORF PMFORM STRNUNI1 /*STRNUNI2*/ AMTUNIT THERCC OTCLEG
        ISOPCARE ISOPCAID ISOPHMOP ISOPHMOM /*ISOPVA*/ ISOPPRVE ISOPPRVI ISOPUNK ISOPOOP ISOPDISC ISOPOTH
        IAMTTOT IAMTCARE IAMTCAID IAMTHMOP IAMTHMOM /*IAMTVA*/ IAMTPRVE IAMTPRVI IAMTPRVU IAMTOOP IAMTDISC IAMTOTH,
		 (year ) *
         ('N'='Number of nonmissing values'*F=COMMA15.0
		  'PCTN'='Frequency percentage')  / misstext=' ';
FORMAT
     TYPE     $EVNTTYP.
     CORF     $INTRFMT.
     PMFORM   FORMFMT.
     TABNUM   TABFMT.
     SUPPNUM  SUPPFMT.
     AMTUNIT  pmunit.
     THERCC   $THERFMT.
     OTCLEG   $OTCFMT.
     STRNUNI1 /*STRNUNI2*/ STRENGTH.
     STRNNUM1 /*STRNNUM2*/ STRNFMT.
     AMTNUM   AMTFMT.
     ISOPCARE ISOPCAID ISOPPRVE ISOPPRVI ISOPHMOP ISOPHMOM ISOPUNK
     /*ISOPVA*/   ISOPOTH  ISOPDISC ISOPOOP  IAMTCARE IAMTCAID IAMTPRVE
     IAMTPRVI IAMTHMOP /*IAMTVA*/   IAMTHMOM IAMTPRVU IAMTOTH  IAMTDISC
     IAMTOOP  IAMTTOT                                      $IMPFMT.
     PDEFLAG  MATCH.;

run;TITLE;


ods html close;

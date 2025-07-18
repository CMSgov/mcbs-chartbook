/******************************************************************************************************/																		
/*** CODE: Create Medical Conditions measures using LDS segments                                    ***/
/******************************************************************************************************/

data tempf.chrncondc;
	set survey.chrncond;

/*----------- Medical Conditions -------------------------------*/

	/* Heart Disease */
	if ocmyocar = 1 or occhd = 1 or occfail = 1	or ochrtcnd = 1			then heartdis = 1;	/* Yes */
	else if ocmyocar = 2 and occhd = 2 and occfail = 2 and ochrtcnd = 2	then heartdis = 0;	/* No */

	/* Hypertension */
	if ochbp = 1							then hyperten = 1;	/* Yes */
	else if ochbp = 2						then hyperten = 0;	/* No */

	/* Diabetes */
	if ocbetes = 1							then diabetes = 1;	/* Yes */
	else if	ocbetes = 2						then diabetes = 0;	/* No */


	/* Arthritis */
	if ocarthrh = 1 or ocosarth = 1 or ocarthot = 1			then arthrits = 1;	/* Yes */
	else if ocarthrh = 2 and ocosarth = 2 and ocarthot = 2	then arthrits = 0;	/* No */


	/* Osteoporosis/Broken Hip */
	if ocosteop = 1 or ocbrkhip = 1			then ostoporo = 1;	/* Yes */
	else if ocosteop = 2 and ocbrkhip = 2	then ostoporo = 0;	/* No */

	/* Pulmonary Disease */
	if ocemphys = 1							then pulmodis = 1;	/* Yes */
	else if ocemphys = 2					then pulmodis = 0;	/* No */

	/* Stroke */
	if ocstroke = 1							then stroke = 1;	/* Yes */
	else if ocstroke = 2					then stroke = 0;	/* No */

	/* Alzheimer's Disease*/
	if ocalzmer = 1 						then alzheimr = 1;	/* Yes */
	else if ocalzmer = 2 					then alzheimr = 0;	/* No */

	/* Non-Alzheimer's Dementia */
	if ocdement = 1							then dementia = 1;  /* Yes */
	else if ocdement = 2					then dementia = 0;  /* No */

	/* Parkinson's Disease*/
	if ocparkin = 1							then parkinsn = 1;	/* Yes */
	else if ocparkin = 2					then parkinsn = 0;	/* No */

	/* Skin Cancer */
	if occskin = 1							then skincanc = 1;	/* Yes */
	else if occskin = 2						then skincanc = 0;	/* No */

	/* Cancer, other than skin */
	if occancer = 1							then oth_canc = 1;	/* Yes */
	else if occancer = 2					then oth_canc = 0;	/* No */

/*----------- Mental Condition ---------------------------------------------------------------*/
	if ocpsycho = 1 or ocdeprss = 1			then mental = 1 ;	/* Yes */
	else if ocpsycho = 2 and ocdeprss = 2	then mental = 0 ; 	/* No */

/*----------- Intellectual or Developmental Disasbility --------------------------------------*/
*Proposed new measure in 2017;
	if ocmental = 1							then IDD = 1 ;	/* Yes */
	else if ocmental = 2					then IDD = 0 ; 	/* No */

/*----------- Urinary Incontinence -----------------------------------------------------------*/
	if losturin in (1:5)					then urinary = 1;	/* Yes */
	else if losturin in (6:7)				then urinary = 0;	/* No */

/*----------- High Cholesterol ---------------------------------------------------------------*/
	if occholes = 1							then cholest = 1;	/* Yes */
	else if occholes = 2					then cholest = 0;	/* No */

/*----------- Hysterectomy -------------------------------------------------------------------*/
	if hysterec = 1							then hyst = 1;		/* Yes */
	else if hysterec = 2					then hyst = 0; 		/* No */

/*----------- Depression ---------------------------------------------------------------------*/
	if ocdeprss = 1 						then depres = 1;
	else if ocdeprss = 2 					then depres = 0;

run;

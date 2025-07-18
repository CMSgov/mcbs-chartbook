/*income assets*/


data temp.income;
 set survey.incasset;

/* Home Ownership */
if IAWNHOME = 1 then HOMEOWN = 1;	/*Home ownership: Yes*/	
else if IAWNHOME in (2, 91) then HOMEOWN = 2;	/*Home ownership: No*/	

/* Ownership of Bank Deposit Accounts */
if	SPCHECK = 1 or SPSECHK = 1 or JNTCHECK = 1 or SPSAVE = 1 or SPSESAVE = 1 or JNTSAVE = 1 or SPDEPT = 1 or SPSEDEPT = 1 or JNTDEPT = 1 
then BANKDEPACC = 1;	/* Ownership of bank deposit accounts: Yes */	
else if SPCHECK = 0 and SPSECHK = 0 and JNTCHECK = 0 and SPSAVE = 0 and SPSESAVE = 0 and JNTSAVE = 0 and SPDEPT = 0 and SPSEDEPT = 0 and JNTDEPT = 0 
then BANKDEPACC = 2; 	/* Ownership of bank deposit accounts: No */

/* Ownership of Checking Accounts */
if SPCHECK = 1 or SPSECHK = 1 or JNTCHECK = 1	then CHKACC = 1;	/* Checking account: Yes */	
else if SPCHECK = 0 and SPSECHK = 0 and JNTCHECK = 0	then CHKACC = 2;	/* Checking account: No */	

/* Ownership of Savings Accounts */
if SPSAVE = 1 or SPSESAVE = 1 or JNTSAVE = 1 then SAVACC = 1;	/* Saving account: Yes */	
else if INCASSET	SPSAVE = 0 and SPSESAVE = 0 and JNTSAVE = 0	then SAVACC = 2;	/* Saving account: No */	

/* Ownership of Certificates of Deposit*/
if SPDEPT = 1 or SPSEDEPT = 1 or JNTDEPT = 1 then	CERTDEP = 1;	/* Certificates of deposit: Yes */	
else if SPDEPT = 0 and SPSEDEPT = 0 and JNTDEPT = 0	then CERTDEP = 2;	/* Certificates of deposit: No */	

/* Ownership of Stocks or Mutual Funds*/
if SPFUND = 1 or SPSEFUND = 1 or JNTFUND = 1 then	STOCKMF = 1; 	/* Stocks or mutual funds: Yes */	
else if SPFUND = 0 and SPSEFUND = 0 and JNTFUND = 0	then STOCKMF = 2;	/* Stocks or mutual funds: No */	

/* Ownership of Retirement Accounts */
if SP401K = 1 or SPSE401K = 1	then RETACC = 1	; /* Retirement account: Yes */	
else if SP401K = 0 and SPSE401K = 0	then RETACC = 2;	/* Retirement account: No */	

/* Receive Social Security*/
if SSRRSP = 1 or SSRRSPSE = 1	then RECSS = 1; 	/* Receive Social Security: Yes	*/	
else if SSRRSP = 0 and SSRRSPSE = 0 then RECSS = 2; 	/* Receive Social Security: No */	

/* Receive Supplemental Security Income (SSI) */
if SPSSIREC = 1 or SPSESIRC = 1	then RECSSI = 1; 	/* Receive Supplemental Security Income: Yes */	
else if SPSSIREC = 0 and SPSESIRC = 0	then RECSSI = 2;	/* Receive Supplemental Security Income: No */

/* Receive pension*/
if	SPPENS = 1 or SPSEPENS = 1	then RECPEN = 1; 	/* Received pension: Yes */	
else if SPPENS = 0 and SPSEPENS = 0 then  RECPEN = 2;	/* Received pension: No */	

/* Worked for Pay Last Month */	
if	WORKMM = 1	then WORK_CAT = 1;	/* Worked for pay last month: Yes */	
else if WORKMM = 2 then WORK_CAT = 2;	/* Worked for pay last month: No */	
	
	
	
	

	


/*median assets: 
Variables used to calculate median are from dataset INCASSET*/

/*Combined Income in the Last Year*//
INC22YR not in (., .D, .R, .N);	INCYR = INC22YR	Median	

/*Combined Monthly Earnings From Work*/
WORK not in (., .D, .R, .N) and (WORKMM = 1 or SPSEWORK  = 1); WORK = WORK	Median	

/*Monthly Earnings From Work*/
WORKSP not in (., .D, .R, .N) and WORKMM = 1; MTHEARN = WORKSP Median	

/*Home Equity*/
HOMEEVAL ne . and HOMEOWE not in (.,0);	HOMEEQU = (HOMEEVAL - HOMEOWE) Median

/*Combined Assets of Bank Deposit Accounts*/
BANK not in (., .D, .R, .N); BANK = BANK Median	

/*Combined Stocks or Mutual Funds*/
FUND not in (., .D, .R, .N); FUND = FUND Median

/*Combined Retirement Account Amounts*/
TOT401K not in (., .D, .R, .N);	TOT401K = TOT401K Median

/*Combined Amount Received From Retirement Accounts Last Year*/
LY401K not in (., .D, .R, .N);	LY401K = LY401K	Median

/*Combined Social Security Payments*/
SSRR not in (., .D, .R, .N); SSRR = SSRR Median

/*Combined Pension Payments*/
PENSION not in (., .D, .R, .N);	PENSION = PENSION Median







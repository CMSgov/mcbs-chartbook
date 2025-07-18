/******************************************************************************************************																		
CODE: Create DENTAL COVERAGE measures using LDS segments                                   
******************************************************************************************************/
	
		

	/** Dental coverage (MA only) **/
	data cov_ma;
		set survey.maplanqx;
		if ( madvdent = . | madvdent = .N |
			madvdent = .R | madvdent = .D )				then cov_ma = .; /* Missing */
		else if madvdent = 1							then cov_ma = 1; /* Yes */
		else if madvdent = 2							then cov_ma = 0; /* No */
		else											cov_ma = 999; /* Undefined */
		keep baseid cov_ma;
	run;
	
	/** Private dental coverage **/
	data hitline_predictors_line;
		set survey.hitline;
		if ( S_DVH = . | S_DVH = .N |
			S_DVH = .R | S_DVH = .D ) AND
			( S_DNTAL = . | S_DNTAL = .N |
			S_DNTAL = .R | S_DNTAL = .D )				then COV_PRIV_t = .; /* Missing */
		else if S_DVH in (1,3,4) OR S_DNTAL = 1			then COV_PRIV_t = 1; /* Yes */
		else if S_DVH in (., 2) OR S_DNTAL in (., 2)	then COV_PRIV_t = 0; /* No */
		else											COV_PRIV_t = 999; /* Undefined */
		keep baseid cov_priv_t;
	run;
	
	/** Create beneficiary-level flags for COV_PRIV and merge datasets **/
	PROC SQL;
		CREATE TABLE hitlinetemp_max AS
			SELECT *, Max(COV_PRIV_t) AS COV_PRIV
			FROM hitline_predictors_line
			GROUP BY baseid;
		CREATE TABLE hitline_bene AS
			SELECT DISTINCT baseid, COV_PRIV
			FROM hitlinetemp_max;
	QUIT;
	
	/** Merge HITLINE flags back onto main predictors dataset **/
	PROC SQL;
		CREATE TABLE cov_dent2 AS
			SELECT B.*, C.*
			FROM survey.demo AS A
			LEFT JOIN hitline_bene AS B ON A.BASEID = B.BASEID
			LEFT JOIN cov_ma AS C ON A.BASEID = C.BASEID;
	QUIT;
	
	/** Combined dental coverage **/
	data cov_dent;
		set cov_dent2;
		if COV_PRIV = 1									then COV_DENT = 1; /* Private dental coverage */
		else if COV_MA = 1								then COV_DENT = 2; /* Dental coverage through MA only */
		else if COV_PRIV ne 1 and COV_MA ne 1			then COV_DENT = 3; /* Other */
		else											COV_DENT = 999; /* Undefined */
		keep baseid cov_dent;
	run;

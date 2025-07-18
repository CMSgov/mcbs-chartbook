/******************************************************************************************************/																		
/*** CODE: Create Transportation/Mobility measures using LDS segments                                   ***/
/******************************************************************************************************/

data tempf.mobility;
	set survey.mobility;

/*-----------Has trouble getting places: TBLGTPL--------------------------------------------------------*/
	/* From DTBLGTPL on MOBILITY*/
	
	if ( dtblgtpl = .  | dtblgtpl = .N | 
	   	 dtblgtpl = .R | dtblgtpl = .D ) 				then tblgtpl = .; /* Missing */
    else if dtblgtpl = 1								then tblgtpl = 1; /* Yes */
	else if dtblgtpl = 2			   					then tblgtpl = 0; /* No */
	else                                        		tblgtpl = 999; /* Undefined */
	
	/*-----------Reduced day-to-day travel: REDTRAV--------------------------------------------------------*/
	/* From DREDTRAV on MOBILITY*/
	
	if ( dredtrav = .  | dredtrav = .N | 
	   	 dredtrav = .R | dredtrav = .D ) 				then redtrav = .; /* Missing */
    else if dredtrav = 1								then redtrav = 1; /* Yes */
	else if dredtrav = 2			   					then redtrav = 0; /* No */
	else                                        		redtrav = 999; /* Undefined */
	
	/*-----------Asks others for rides: ASKRIDE--------------------------------------------------------*/
	/* From DASKRIDE on MOBILITY*/
	
	if ( daskride = .  | daskride = .N | 
	   	 daskride = .R | daskride = .D ) 				then askride = .; /* Missing */
    else if daskride = 1								then askride = 1; /* Yes */
	else if daskride = 2			   					then askride = 0; /* No */
	else                                        		askride = 999; /* Undefined */
	
	/*-----------Does not drive/ has given up driving altogether: GIVUPDR--------------------------------------------------------*/
	/* From DGIVUPDR on MOBILITY*/
	
	if ( dgivupdr = .  | dgivupdr = .N | 
	   	 dgivupdr = .R | dgivupdr = .D ) 				then givupdr = .; /* Missing */
    else if dgivupdr in (1, 4, 5)						then givupdr = 1; /* Does not drive */
	else if dgivupdr = 2			   					then givupdr = 0; /* Has given up driving all together */
	else                                        		givupdr = 999; /* Undefined */
	
	/*-----------Limited driving to daytime: LIMDRIVD--------------------------------------------------------*/
	/* From DLIMDRIV DGIVUPDR on MOBILITY*/
	
	if ( dlimdriv = .  | dlimdriv = .N | 
	   	 dlimdriv = .R | dlimdriv = .D )  AND
	   ( dgivupdr = .  | dgivupdr = .N | 
	   	 dgivupdr = .R | dgivupdr = .D ) 				then limdrivd = .; /* Missing */
    else if dlimdriv = 1 								then limdrivd = 1; /* Yes */
	else if dlimdriv = 2 or dgivupdr in (1, 4, 5)		then limdrivd = 0; /* No */
	else												limdrivd = 999; /* Undefined */
	
	/*-----------Uses taxi or special transportation: USETRNS--------------------------------------------------------*/
	/* From DUSETRNS on MOBILITY*/
	
	if ( dusetrns = .  | dusetrns = .N | 
	   	 dusetrns = .R | dusetrns = .D ) 				then usetrns = .; /* Missing */
    else if dusetrns = 1								then usetrns = 1; /* Yes */
	else if dusetrns = 2			   					then usetrns = 0; /* No */
	else                                        		usetrns = 999; /* Undefined */

run;

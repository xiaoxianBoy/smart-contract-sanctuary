pragma solidity 		^0.4.21	;							
												
		contract	Etats_financiers_10111011		{							
												
			address	owner	;							
												
			function	Etats_financiers_10111011		()	public	{				
				owner	= msg.sender;							
			}									
												
			modifier	onlyOwner	() {							
				require(msg.sender ==		owner	);					
				_;								
			}									
												
												
												
		// IN DATA / SET DATA / GET DATA / UINT 256 / PUBLIC / ONLY OWNER / CONSTANT										
												
												
			uint256	Data_1	=	1000	;					
												
			function	setData_1	(	uint256	newData_1	)	public	onlyOwner	{	
				Data_1	=	newData_1	;					
			}									
												
			function	getData_1	()	public	constant	returns	(	uint256	)	{
				return	Data_1	;						
			}									
												
												
												
//	&quot;{ Compte_1 ; L&amp;A_301201 ; 0,567426855718599 ; 176234,16832 ; 100000 ; 20000 }&quot;											
//	&quot;{ Compte_1 ; ENGIE_301201 ; 0,452349215336893 ; 165801,105555456 ; 75000 ; 15000 }&quot;											
//	&quot;{ Compte_1 ; RENAULT_301201 ; 0,567426855718599 ; 132175,62624 ; 75000 ; 15000 }&quot;											
//	&quot;{ Compte_1 &amp; 2 ; ACCOR_301201 ; 0,513158118230706 ; 682050,985 ; 350000 ; 70000 }&quot;											
//	&quot;{ Compte_1 &#224; 6 ; GOLD_301201 ; 0,513158118230706 ; 3702562,49 ; 1900000 ; 380000 }&quot;											
//	&quot;{ Compte_1 &amp; 2 ; WTI_301201 ; 0,513158118230706 ; 438461,3475 ; 225000 ; 45000 }&quot;											
//	&quot;{ Compte_1, 2 &amp; 5 ; SIE_DE_301201 ; 0,751314800901578 ; 732050 ; 550000 ; 110000 }&quot;											
//	&quot;{ Compte_1 &amp; 9 ; LVMH_301201 ; 0,425060643746142 ; 823411,918156859 ; 350000 ; 70000 }&quot;											
//	&quot;{ Compte_1 ; PICC_301201 ; 0,680583197033753 ; 367332,0192 ; 250000 ; 50000 }&quot;											
//	&quot;{ Compte_1 ; BNP_PARIBAS_301201 ; 0,674971516202016 ; 370386 ; 250000 ; 50000 }&quot;											
//	&quot;{ Compte_1 &amp; 2 ; SOCGEN_301201 ; 0,519368664359815 ; 673895,10384 ; 350000 ; 70000 }&quot;											
//	&quot;{ Compte_2 ; AIRBUS_301201 ; 0,513158118230706 ; 194871,71 ; 100000 ; 20000 }&quot;											
//	&quot;{ Compte_2 ; DAIMLER_301201 ; 0,620921323059155 ; 161051 ; 100000 ; 20000 }&quot;											
//	&quot;{ Compte_2 ; VALEO_301202 ; 0,751314800901578 ; 133100 ; 100000 ; 20000 }&quot;											
//	&quot;{ Compte_2 ; CASINO_301202 ; 0,513158118230706 ; 292307,565 ; 150000 ; 30000 }&quot;											
//	&quot;{ Compte_2 &amp; 5 ; NETSLE_301201 ; 0,513158118230706 ; 389743,42 ; 200000 ; 40000 }&quot;											
//	&quot;{ Compte_2 ; VALLOUREC_301201 ; 0,425060643746142 ; 235260,548044817 ; 100000 ; 20000 }&quot;											
//	&quot;{ Compte_2 ; DEUTSCHE_BANK_301201 ; 0,79383224102017 ; 314928 ; 250000 ; 50000 }&quot;											
//	&quot;{ Compte_2 &amp; 7 ; GOLD_301202 ; 0,583490395262134 ; 856912,13438976 ; 500000 ; 100000 }&quot;											
//	&quot;{ Compte_4 ; WTI_301202 ; 0,425060643746142 ; 235260,548044817 ; 100000 ; 20000 }&quot;											
//	&quot;{ Compte_9 ; VINCI_301201 ; 0,79383224102017 ; 188956,8 ; 150000 ; 30000 }&quot;											
//	&quot;{ Compte_9 ; DANONE_301201 ; 0,79383224102017 ; 188956,8 ; 150000 ; 30000 }&quot;											
//	&quot;{ Compte_1 ;  ;  ;  ; 0 ; 0 }&quot;											
//	&quot;{ Compte_1 ;  ;  ;  ; 0 ; 0 }&quot;											
//	&quot;{ Compte_1 ;  ;  ;  ; 0 ; 0 }&quot;											
//	&quot;{ Compte_1 ;  ;  ;  ; 0 ; 0 }&quot;											
//	&quot;{ Compte_1 ;  ;  ;  ; 0 ; 0 }&quot;											
//	&quot;{ Compte_1 ;  ;  ;  ; 0 ; 0 }&quot;											
//	&quot;{ Compte_1 ;  ;  ;  ; 0 ; 0 }&quot;											
												
												
	}
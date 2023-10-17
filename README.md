# MQL5-Project
Inputs+complementare+Mediere
Learning MQL%
in Meta tarder 5
every time you update write the date down!!!!!!!!
  DATE || MODIFY || DESCRIPTION
1) 17.10.23
Complementare 2
includes
input group GENERAL
MAGICNUMBER
LOT_MODE(FIXED, ADDITION, PERCENT)
input group range inputs RANGE INPUTS COMPLEMENTARE
SL_MODE(FIXED,PERCENT)
input StepRange

verificarea parametrilor


se deschide open trade la pozitia zero t0=0;sl=0,tp=0;X0

dupa fiecare step de X pipsi se deschide cate open trade X1 sl=0,tp=0
							 X2 sl=0,tp=0;
							 x3 SL=0;TP0;
	Daca conditia de range (exista 4 open trades (buy sau sell identice)
		se deschide sl=50%*StepRange sau x pipsi
		Acest sl reprezinta TakeProfit pentru pozitiile anterioare deci negativ
			si stop loss pozitiv pentru pozitia 4 sau pozitia N;
	
	Daca trendul continua ascendent dupa fiecare StepRange se deschid noi tranzactii
care modifica sl pentru poztia n+1 si modifica stop loss ul sub poztia n+1

Youtube uitate tutoeial 103 simple buy grid
2
3
4
5
6
7
8
9

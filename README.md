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
17.10.23 acasa

Create conditia de range adica positionstotal ==4//ne gandim
close all positions
 daca numarul total al pozitiilor este mai mare sau egal cu 4 
si pretul curent scade sub stop lossul anume InpStopLoss inchide toate pozitiile deschise
=> nu mai avem nevoie de stop loss pentru fiecare pozitie=> numia mutam nimic
generalizat

ramane de vazut la adaugarea medierei deoarece noi nu vrem sa inchidem toate pozitile in cazul medierii ok!!

3
!18.10.2023
Am implementat condidtia de range cu ajutorul functiei  PositionSelectByticket PositionGetDouble, PositionGetinteger
Am calculat range price-ul si close priceul 

		folosim for(bucla) pentru a itera pozitiile deschise dupa tichetul lor #i
	
	==>Versiune BETA!!! gata
	
	->trebuie integrata varianta pentru sell
	->lot procent si lot aditional
	->stop loss procent 
 !!!am functia numara prob doar daca este BUY!!!

4
19.10.2023
for merge pana la totalul pozitiolor posibile deschise deoarece ticket numberul nu se reseteaza niciodata
trebuiie aflat maximul!!!

19.10.2023
am iterat in for plecadn de la numarul de ticketul bun adica

	numarul buy + numarul close si am mers pana la acelasi numar plus totalul pozitilor
	
	pt o iterare optima si rapida
ramane dynamyc lots si stop loss dynamic si 
	PT SHORT POSITION
5
19.10.2023

InpStepM

Complementarea SELL: Unde Incepe? InpStepM+InpStepC

enum -->Complementare Buy 
     -->Complementare SELL 
     -->Mediere Buy
     -->Mediere Sell
     Implemenatat input mode complemenatre mediere toate StepC StepM... 
	Verificarea Inputurilor
	Ramane calcularea dinamyc Lots 
	Calcularea Step si stop loss percent
6
7
8
9

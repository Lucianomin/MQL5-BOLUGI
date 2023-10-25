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
21.10.2023
//lucram la dynamic lot function

 if(InpComplementareMode==COMPLEMENTARE_BUY)
  {
  //static next buy price
  static double NextBuyPrice;
  
  double ask =NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
  //sort
  ArraySetAsSeries(PriceInfo,true);
  int PriceData= CopyRates(_Symbol,_Period,0,3,PriceInfo);
 
 
   if(PositionsTotal()==0)
   {NextBuyPrice=0;}
   
   signal=CheckEntrySignal();
   
   if(ask>=NextBuyPrice)
   {
   if(signal=="buy")
   {
      //double sl=ask-InpStepC*_Point;
      //double Lots= CalculateLots(InpLots,sl);
      trade.Buy(InpLots,NULL,ask,0,0,NULL);
      NextBuyPrice=ask+InpStepC*_Point;
   
   }
   }
   //chart output
   Comment("Ask",ask,"\n","NextBuyPrice: ",NextBuyPrice);
  // Print("Ask",ask);
   // range condition not static
   if(PositionsTotal()>=4)
   {
   //RangeCondition=true;
   //Print("Ask",ask);
   int totalPositions = PositionsTotal();
   double RangePrice = 0.0; // Initialize with a default value
   Print("---->",PositionNumber);
   
   int OpenBuySellTrades=PositionNumber;

      for (int i = OpenBuySellTrades; i<OpenBuySellTrades+totalPositions+2; i++) //testat optim??? putem si mai departe aprox 180 de complementari
      { 
      //Alert("ticket",i);
         if (PositionSelectByTicket(i)) 
         {
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) 
               {
                  
                  RangePrice = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN),_Digits);
                  //Print("RangePrice                   ",RangePrice);
               }
         }
         
      }
   
   Print("RangePrice ",RangePrice);
   double ClosePrice=RangePrice-InpStopLoss*_Point; //calculeaza nivelul de stop loss
   Comment("ClosePrice ",ClosePrice);
   Print("ClosePrice ",ClosePrice);
      // daca atinge stop loss-ul
      if(ask<=ClosePrice)
         {
          CloseAllPositions();// inchide toate pozitiile cand
          
          }
          
      }
     //////// double RangeSellPrice=0.0;
    if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) 
               {
                  
                  RangeSellPrice = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN),_Digits);
                  //Print("RangePrice                   ",RangePrice);
               }  


////double CloseSellPrice=RangeSellPrice+InpStopLoss*_Point; //calculeaza nivelul de stop loss


7

//22.10.2023

double CloseBuyPrice=RangeBuyPrice-InpStopLoss*_Point; //calculeaza nivelul de stop loss

//Comment("ClosePrice ",ClosePrice);
  // Print("ClosePrice ",ClosePrice);
      // daca atinge stop loss-ul

//Alert("closebuy",CloseBuyPrice);

if(InpSlMode==SL_MODE_FIXED)
    {
    double CloseBuyPrice=RangeBuyPrice-InpStopLoss*_Point; //calculeaza nivelul de stop loss
    
    if(ask<=CloseBuyPrice)
         {
         //pentru fixed
         Alert("closebuy",CloseBuyPrice);
          CloseBuyPositions();// inchide toate pozitiile cand
         // CloseAllPositions();
          }
    }
   else
     {
     // pentru procent
      double CloseBuyPrice=RangeBuyPrice-(InpStopLoss*InpStepC)*_Point; //procent fata de pas Complemenatre
      
      if(ask<=CloseBuyPrice)
         {
         Alert("closebuy",CloseBuyPrice);
          CloseBuyPositions();// inchide toate pozitiile cand
         // CloseAllPositions();
         


//SELL POSIITONS

static double NextSellPrice;

double bid =NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);

// == cu stop lossul sau mai mare respectiv mai mic
23.10.2023 COMPLEMENTARE BETA working!!!!!
8
25.10.2023
if(TrailMode==true)
{


if(ask>=RangePrice+InpTrailStop)
	{
		RangePrice=RangePrice+InpTrailStop;
	}
}
n intra in bucla deloc
seteaza pretul rau
nu retinr val max
NUU
Am incercat min si amx fara rezulatat
9
10
11
12

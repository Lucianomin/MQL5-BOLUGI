#property copyright "MindaLucian"
#property link      "MindaLucian"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>
#define MAX_DOUBLE 1.79769e+308
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "---->General Inputs<----";

input long InpMagicNumber=181105;

enum LOT_MODE_ENUM
  {
   LOT_MODE_FIXED, //Fixed Lots
   LOT_MODE_ADDITION, //Additional Lots
   LOT_MODE_PERCENT //Percent Lots
  };
input LOT_MODE_ENUM InpLotMode = LOT_MODE_FIXED; //Lot Mode
input double InpLots=0.01; //fixed/additional lots/percent

input group "---->Range Inputs(Complementare)<----";

enum COMPLEMENTARE_MODE
        {
         COMPLEMENTARE_BUY,
         COMPLEMENTARE_SELL,
         COMPLEMENTARE_BUY_SELL
        };
        
input COMPLEMENTARE_MODE InpComplementareMode= COMPLEMENTARE_BUY; //Complementare Mode
//stop loss mode
enum SL_MODE_ENUM
  {
   SL_MODE_FIXED, 
   SL_MODE_PERCENT
  };
  
input SL_MODE_ENUM InpSlMode = SL_MODE_FIXED; //StopLoss Mode

input int InpStopLoss=100; // InpStopLoss (pips / percent)
input int InpStepC=100; // InpStepC (pips)
input bool InpTrailMode=true; //TrailMode (true/false)
input int InpTrailStop=20; //InpTrailStop (pips)


input group "---->Range Inputs(Mediere)<----";
enum MEDIERE_MODE
        {
         MEDIERE_BUY,
         MEDIERE_SELL,
         MEDIERE_BUY_SELL
        };
        
input MEDIERE_MODE InpMediereMode= MEDIERE_BUY; //Mediere Mode
input int InpRangeM=1000;//InpRangeM (pips)
input int InpDistZ=300;//InpDistZ (pips)
input int InpDistTakeProfit=150;//InpDistTakeProfit (pips)
input group "---->Tip Robot<----";
enum BOLUGI_MODE
         {
         BOLUGI_LONG,
         BOLUGI_SHORT,
         BOLUGI_LONG_SHORT
         };
input BOLUGI_MODE InpBotMode= BOLUGI_LONG; //BOLUGI_MODE
//+------------------------------------------------------------------+
//| Global D                                                        |
//+------------------------------------------------------------------+
MqlRates PriceInfo[];
MqlTick currTick;
CTrade trade;
string   signal="";
int      PositionNumber=0;
int      PositionBuyNumber=0;
int      PositionSellNumber=0;
int      TotalBuyPositions=0;
int      TotalSellPositions=0;
double   MaxClose=0.0;
double   MaxSellClose=9999.0;
int      ContorM=0;
bool     medierebuy=false;
bool     complementarebuy=true;
bool     medieresell=false;
bool     complementaresell=true;
bool Level1=false,
     Level2=false,
     Level3=false,
     Level4=false,
     Level5=false,
     Level6=false,
     Level7=false;
int      PositionMediereNumber=0;
int      ContorMC=0;
int      MediereNumber=0;
double   lossZetCopie=0;
double   RangeM=InpRangeM;
ulong    TicketNumber=-1;
//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+

int OnInit()
  {
  trade.SetExpertMagicNumber(InpMagicNumber);
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {

   
  }

void OnTick()
  {
   
  
   if(InpBotMode==BOLUGI_LONG)
   {
   Bolugi_Long();
  
   }
   
   if(InpBotMode==BOLUGI_SHORT)
      {
        Bolugi_Short();
      }
     if(InpBotMode==BOLUGI_LONG_SHORT)
     {
     Bolugi_Long_Short();
     }
   
  }

//+------------------------------------------------------------------+
//| Functions                                                        |
//+------------------------------------------------------------------+
//check for inputs
   bool CheckInputs()
{
  
   if(InpMagicNumber<=0)
   {
   Alert("Magic Number <=0");
   return false;
   }
   
   if(InpLotMode==LOT_MODE_FIXED &&(InpLots<=0 || InpLots >10))
     {
      Alert("lots<=0 or lots>10" );
      return false;
     }
     
     if(InpLotMode==LOT_MODE_ADDITION &&(InpLots<=0 || InpLots >1000))
     {
      Alert("lots<=0 or lots>1000" );
      return false;
     }
     if(InpLotMode==LOT_MODE_PERCENT &&(InpLots<=0 || InpLots >5))
     {
      Alert("lots<=0 or lots>5%" );
      return false;
     }
     
     if((InpLotMode==LOT_MODE_PERCENT || InpLotMode==LOT_MODE_ADDITION) && InpStopLoss==0)
     {
      Alert("selected mode needs a stop loss" );
      return false;
     }
   if(InpSlMode==SL_MODE_FIXED && (InpStopLoss<=0 || InpStopLoss>=1000))
     {
      Alert("Stop Loss lower than 0 or greater than 1000");
      return false;
     }
     if(InpSlMode==SL_MODE_PERCENT && (InpStopLoss<=0 || InpStopLoss>5))
     {
      Alert("Stop Loss lower than 0 or greater than 5%");
      return false;
     }
     /*if(InpStepModeM==STEP_FIXED && (InpStepM<=0 || InpStepM>=1000))
     {
      Alert("Step Mediere lower than 0 or greater than 1000 pips");
      return false;
     }
     if(InpStepModeM==STEP_PERCENT && (InpStepM<=0 || InpStepM>=5))
     {
      Alert("Step Mediere lower than 0 or greater than 5%");
      return false;
     }
     if(InpStepM<=0)
     {
     Alert("Step Mediere <=0");
      return false;
   }
     */
     if(InpStepC<=0)
     {
     Alert("InpStepC <=0");
     return false;
     }
     
  return true;
}
//Check entry signal
string CheckEntrySignal()
{
   if(PriceInfo[1].close>PriceInfo[1].open)
   {
   signal="buy";
   }
   if(PriceInfo[1].close<PriceInfo[1].open)
     {
      signal="sell";
     }
   return signal;
}

//CloseAllPOsitions
void CloseAllPositions()
{
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
   ulong ticket=PositionGetTicket(i);//get ticket
   trade.PositionClose(ticket,i);//close
   PositionNumber=PositionNumber+2;
   
   }

}
//CloseBuyPos
void CloseBuyPositions()
{
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
   ulong ticket=PositionGetTicket(i);//get ticket
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
         {
         trade.PositionClose(ticket,i);//close
         PositionBuyNumber=PositionBuyNumber+2;
         }
   
   }

}
void CloseSellPositions()
{
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
   ulong ticket=PositionGetTicket(i);//get ticket
   if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
   {
   trade.PositionClose(ticket,i);//close
   PositionSellNumber=PositionSellNumber+2;
   }
   
   }

}
//close on positions after the last take profit is reached
void CloseBuyPositionsOnLastTakeProfit()
{

int totalPositions = PositionsTotal();
    double lastBuyTakeProfit = 0.0;
   double ask =NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
    // Find the take profit of the last buy order
    for (int i = totalPositions -1; i >= 0; i--) {
        if (PositionSelectByTicket(PositionGetTicket(i))) {
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
                lastBuyTakeProfit = PositionGetDouble(POSITION_TP);
                
            }
        }
        break; // Stop after finding the last buy order
    }
    lastBuyTakeProfit=NormalizeDouble(lastBuyTakeProfit,_Digits);
    if(ask>=lastBuyTakeProfit-3*_Point)
    {
      CloseBuyPositions();
      medierebuy=false;
      PositionMediereNumber=2*ContorM;
      ContorM=0;
      //ContorMC=0;
      Level1=false;
      Level2=false;
      Level3=false;
      Level4=false;
      Level5=false;
      Level6=false;
      Level7=false;
      MediereNumber++;
      complementarebuy=true;
    }

}
void CloseSellPositionsOnLastTakeProfit()
{
int totalPositions = PositionsTotal();
    double lastSellTakeProfit = 0.0;
   double bid =NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
    // Find the take profit of the last buy order
    for (int i = totalPositions -1; i >= 0; i--) {
        if (PositionSelectByTicket(PositionGetTicket(i))) {
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
                lastSellTakeProfit = PositionGetDouble(POSITION_TP);
                
            }
        }
        break; // Stop after finding the last buy order
    }
    lastSellTakeProfit=NormalizeDouble(lastSellTakeProfit,_Digits);
    if(bid<=lastSellTakeProfit+3*_Point)
    {
      CloseSellPositions();
      medieresell=false;
      PositionMediereNumber=2*ContorM;
      ContorM=0;
      //ContorMC=0;
      Level1=false;
      Level2=false;
      Level3=false;
      Level4=false;
      Level5=false;
      Level6=false;
      Level7=false;
      MediereNumber++;
      complementaresell=true;
    }

}
//calculatelots
double CalculateLots(double lots){

   lots=0.0;
   if(InpLotMode==LOT_MODE_FIXED)
     {
      lots=InpLots;
     }
      if(InpLotMode==LOT_MODE_PERCENT)
        {
         double tickSize=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
         double tickValue=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
         double volumeStep=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
         //Print("TICKsize", tickSize,"tickValue",tickValue,"volumestep",volumeStep);
         if(tickSize==0 || tickValue==0 || volumeStep==0)
         {
         Print(__FUNCTION__,"Can not calculate ticksize tickvalue volumestep");
         return 0;
         }
         double riskMoney=AccountInfoDouble(ACCOUNT_BALANCE)*InpLots*0.01;
         //Print("risk Money",riskMoney);
         // pentru complementare
         if(InpComplementareMode==COMPLEMENTARE_BUY || InpComplementareMode==COMPLEMENTARE_SELL || InpComplementareMode==COMPLEMENTARE_BUY_SELL)
         {
            double moneyVolumeStep= ((1250*_Point)/tickSize) * tickValue *volumeStep;
            lots=MathFloor(riskMoney/moneyVolumeStep)*volumeStep;
         }
         
         return lots;
         //lots=MathFloor(riskMoney/moneyVolumeStep)*volumeStep;
        }
        
        return lots;
        
}
//complementare sell
void Complementare_Sell()
{
   
  //static next buy price
  static double NextSellPrice;
  
  double bid =NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
  //sort
  
  ArraySetAsSeries(PriceInfo,true);
  int PriceData= CopyRates(_Symbol,_Period,0,3,PriceInfo);
 
 
   if(PositionsTotal()==0)
   {NextSellPrice=0;}
   
   signal=CheckEntrySignal();
  // Alert("sell");
   if((bid<=NextSellPrice) || NextSellPrice==0)
  
   if(signal=="sell")
   {
   
      //double sl=ask-InpStepC*_Point;
      double Lots= CalculateLots(InpLots);
      trade.Sell(Lots,NULL,bid,0,0,NULL);
      NextSellPrice=bid-InpStepC*_Point;
      //Comment("NextSellPrice",NextSellPrice);
      TicketNumber=trade.ResultDeal();
      
   }
   
   //chart output
   Comment("Bid",bid,"\n","NextSellPrice: ",NextSellPrice,"\n");
   
   // range condition not static
   if(CountOpenPositions()>=4)
   {
   //RangeCondition=true;
   //Print("Ask",ask);
   int totalPositions = PositionsTotal();
   double RangePrice = 0.0; // Initialize with a default value
   Print("---->",PositionNumber);
   
   int OpenBuySellTrades=PositionBuyNumber;

      for (int i = 0; i<=CountOpenPositions(); i++) //testat optim??? putem si mai departe aprox 180 de complementari
      { 
      //Alert("ticket",i);
      ulong currTicket=PositionGetTicket(i);
      if(currTicket!=-1 && currTicket==TicketNumber)
         {
         if (PositionSelectByTicket(currTicket)) 
            {
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) 
               {
                  
                  RangePrice = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN),_Digits);
                  //Print("RangePrice                   ",RangePrice);
               }
            }
         }
      }
   
      double TrailPrice=RangePrice-InpTrailStop*_Point;
      NormalizeDouble(TrailPrice,_Digits);
      double ClosePrice=RangePrice+InpStopLoss*_Point; //calculeaza nivelul de stop loss
      NormalizeDouble(ClosePrice,_Digits);
      //Print("RangePricebeforeTRail ",RangePrice);
       
       //Print("RangePricebefore->>> ",ClosePrice);
      if(InpTrailMode==true)
      {
         while(bid<=TrailPrice)
	      {
	       ClosePrice=ClosePrice-InpTrailStop*_Point;
		    TrailPrice=TrailPrice-InpTrailStop*_Point; 
		    if(ClosePrice<=MaxSellClose){MaxSellClose=ClosePrice;}
		     //Print("print ---->",ask);
           
	      }
	     //Print("MaxSellClose   ",MaxSellClose);
	     Draw_HLine(MaxSellClose,clrRed);
      }
      else
        {
         MaxSellClose=ClosePrice;
        }
        Draw_HLine(MaxSellClose,clrRed);
      if(bid>=MaxClose)
         {
          CloseSellPositions();// inchide toate pozitiile cand
          Delete_HLine();
          }
     // Print("TrailPrice ",TrailPrice);
    //Print("ClosePrice ",ClosePrice);
          
      }
      
}
//Complementare function
void Complementare_Buy()
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
      double Lots= CalculateLots(InpLots);
      trade.Buy(Lots,NULL,ask,0,0,"COMPLEMENTARE BUY");
      NextBuyPrice=ask+InpStepC*_Point;
      TicketNumber=trade.ResultDeal();
   
   }
   }
   //chart output
   Comment("Ask",ask,"\n","NextBuyPrice: ",NextBuyPrice,"\n");
  // Print("Ask",ask);
   // range condition not static
   if(CountOpenPositions()>=4)
   {
   //RangeCondition=true;
   //Print("Ask",ask);
   int totalPositions = PositionsTotal();
   double RangePrice = 0.0; // Initialize with a default value
   //Print("---->",PositionNumber);
   
   int OpenBuySellTrades=PositionBuyNumber;

      for (int i = 0; i<=CountOpenPositions(); i++) //testat optim??? putem si mai departe aprox 180 de complementari
      { 
      //Alert("ticket",i);
      ulong currTicket=PositionGetTicket(i);
      if(currTicket!=-1 && currTicket==TicketNumber)
        {
         if (PositionSelectByTicket(currTicket)) 
            {
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) 
               {
                  
                  RangePrice = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN),_Digits);
                  //Print("RangePrice                   ",RangePrice);
               }
            }
         }
      }
      double TrailPrice=RangePrice+InpTrailStop*_Point;
      NormalizeDouble(TrailPrice,_Digits);
      double ClosePrice=RangePrice-InpStopLoss*_Point; //calculeaza nivelul de stop loss
      NormalizeDouble(ClosePrice,_Digits);
      //Print("RangePricebeforeTRail ",RangePrice);
       
       //Print("RangePricebefore->>> ",ClosePrice);
      if(InpTrailMode==true)
      {
         while(ask>=TrailPrice)
	      {
	       ClosePrice=ClosePrice+InpTrailStop*_Point;
		    TrailPrice=TrailPrice+InpTrailStop*_Point; 
		    if(ClosePrice>=MaxClose){MaxClose=ClosePrice;}
		     //Print("print ---->",ask);
           
	      }
	     //Print("MaxClose   ",MaxClose);
	     Draw_HLine(MaxClose,clrRed);
      }
      else
        {
         MaxClose=ClosePrice;
        }
        Draw_HLine(MaxClose,clrRed);
      if(ask<=MaxClose)
         {
          CloseBuyPositions();// inchide toate pozitiile cand
          Delete_HLine();
          }
     // Print("TrailPrice ",TrailPrice);
   // Print("ClosePrice ",ClosePrice);
  // Print("RangePrice ",RangePrice);
   //Comment("ClosePrice ",ClosePrice);
  
      // daca atinge stop loss-ul
      
      }
      
}
//draw stop loss
void Draw_HLine(double stopLossPrice,int stopLossColor) {
    // Define the stopLossObjectName
    string stopLossObjectName = "StopLossLine";
    
    // Color and other properties
    //int stopLossColor = clrRed;
    
    // Create the horizontal line
    if (ObjectCreate(_Symbol,stopLossObjectName,OBJ_HLINE,0,0,0)) 
    {
        ObjectSetInteger(0, stopLossObjectName, OBJPROP_RAY_RIGHT, false);
        ObjectSetInteger(0, stopLossObjectName, OBJPROP_RAY_LEFT, false);
        ObjectSetInteger(0, stopLossObjectName, OBJPROP_COLOR, stopLossColor);
        ObjectSetInteger(0, stopLossObjectName, OBJPROP_WIDTH, 2); // Line width
        ObjectMove(_Symbol,stopLossObjectName,0,0,stopLossPrice);
        ObjectSetDouble(0, stopLossObjectName, OBJPROP_PRICE, stopLossPrice);
    }
}

//delete
void Delete_HLine() {
    // Define the stopLossObjectName to be deleted
    string stopLossObjectName = "StopLossLine";
    
    // Check if the object exists and delete it
    if (ObjectCreate(0, stopLossObjectName, OBJ_TREND, 0, 0, 0)) {
        ObjectDelete(0, stopLossObjectName);
    }

}
void Complementare_MaxClose(double x)
{
   if(InpComplementareMode==COMPLEMENTARE_BUY)
   {
   MaxClose=0;
   }
   else if(InpComplementareMode==COMPLEMENTARE_SELL)
     {
      MaxClose=99999;
     }

}
//+------------------------------------------------------------------+
//| Calculate lot/pip value                                          |
//+------------------------------------------------------------------+
double CalculatePipValue() {
    double tickSize =SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);  // Size of one pip/tick
    double tickValue =SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE); // Value of one pip/tick in your account currency
   double volumeStep=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   
    double pipValue = MathFloor(tickValue / tickSize)*volumeStep;// /1000
    return pipValue;
}

// Calculate loss la punctul Z vedem dacca trebuie introdus si start si stop int start, int stop,
double CalculateLossZetBuy(double zetPrice, double volume) {
    double volumeLot = volume*CalculatePipValue();
    double lossInZet = 0.0;
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        if (PositionSelectByTicket(PositionGetTicket(i))) {
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
                double openPrice = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN), _Digits);
                double lossPos = MathAbs(zetPrice - openPrice) * volumeLot;
                lossInZet += lossPos;
                //Print("lossInZET ",lossInZet);
            }
        }
    }

    return lossInZet/0.01;
}
// Calculate loss la punctul Z vedem dacca trebuie introdus si start si stop int start, int stop,
double CalculateLossZetSell(double zetPrice, double volume) {
    double volumeLot = volume*CalculatePipValue();
    double lossInZet = 0.0;
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        if (PositionSelectByTicket(PositionGetTicket(i))) {
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
                double openPrice = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN), _Digits);
                double lossPos = MathAbs(zetPrice - openPrice) * volumeLot;
                lossInZet += lossPos;
                //Print("lossInZET ",lossInZet);
            }
        }
    }

    return lossInZet/0.01;
}
//functia aditie sau/si multiplicator
void Mediere_Buy()
{

 if(CountOpenPositions()<=3+ContorM && PositionsTotal()>0)//ContorM setam pe 0 el se modifica la fiecare deschidere de mediere maxim 7
     {
      double ask =NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
      int totalPositions = PositionsTotal();
      double RangeM0 = 0.0; // Initialize with a default value
      double ValueZ = 0.0;
       //Print("---->",PositionNumber);
   
      int OpenBuySellTrades=PositionBuyNumber;
      //Print("MediereNumber",MediereNumber);
      //Print("Start for: ",OpenBuySellTrades);
      //Print("end for: ",OpenBuySellTrades+CountOpenPositions()+10);
      for (int i = 0; i<=CountOpenPositions(); i++) //testat optim??? putem si mai departe aprox 180 de complementari
      { 
      //Alert("ticket",i);
       ulong currTicket=PositionGetTicket(i);
       //Print("TicketCurent ",currTicket, "tICKET nUMBER ",TicketNumber);
         if(currTicket!=-1 && currTicket==TicketNumber)
         {
            if (PositionSelectByTicket(currTicket)) 
            {
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) 
               {
                  RangeM0 = PositionGetDouble(POSITION_PRICE_OPEN); //pozitia 0 a rangeluiu
                  //double positionProfit = NormalizeDouble(PositionGetDouble(POSITION_PROFIT),_Digits);
                  //ValueZ += positionProfit;
                  //Print("Pret");
               }
            }
         }
      }
      Print("RangeM0->",RangeM0);
      //Print("Value for Z",ValueZ);
      
      //calculam pozitia next ord(pretul la care deschidem pozitia)
      //7 nivele fibonacci
      double PriceStartM=0.0;
      
      double PriceLevel1=NormalizeDouble(InpDistZ*_Point+InpDistTakeProfit*_Point+(23.60*InpRangeM)/100*_Point,_Digits);
      double PriceLevel2=NormalizeDouble(InpDistZ*_Point+InpDistTakeProfit*_Point+(38.20*InpRangeM)/100*_Point,_Digits);
      double PriceLevel3=NormalizeDouble(InpDistZ*_Point+InpDistTakeProfit*_Point+(50.00*InpRangeM)/100*_Point,_Digits);
      double PriceLevel4=NormalizeDouble(InpDistZ*_Point+InpDistTakeProfit*_Point+(61.80*InpRangeM)/100*_Point,_Digits);
      double PriceLevel5=NormalizeDouble(InpDistZ*_Point+InpDistTakeProfit*_Point+(76.45*InpRangeM)/100*_Point,_Digits);
      double PriceLevel6=NormalizeDouble(InpDistZ*_Point+InpDistTakeProfit*_Point+(88.20*InpRangeM)/100*_Point,_Digits);
      double PriceLevel7=NormalizeDouble(InpDistZ*_Point+InpDistTakeProfit*_Point+(100.00*InpRangeM)/100*_Point,_Digits);
     
        double PriceZ;
        int decimalPlace=2;
        double pipValue = CalculatePipValue()*0.01;
        double VolumeZ=InpLots;  
        int ColorZ=clrBlue;     
        PriceStartM=RangeM0-PriceLevel1;
        PriceZ=PriceStartM+InpDistZ*_Point;
        Draw_HLine(PriceZ,ColorZ);
        //Print("Pricez",PriceZ);
        ValueZ=CalculateLossZetBuy(PriceZ,VolumeZ);
        //Print("Volum Mediere=",VolumeZ);
        //Print("Value for Z",ValueZ);
        VolumeZ=NormalizeDouble(ValueZ/InpDistZ/pipValue*10,decimalPlace);
        //Print("Volum Mediere=",VolumeZ);
        /*
        
        */
       if(Level1==false) ///LEVEL 1 Fibonacci
        {
        PriceStartM=RangeM0-PriceLevel1;
        PriceZ=PriceStartM+InpDistZ*_Point;
        Draw_HLine(PriceZ,ColorZ);
        //if(PriceStartM>PriceLevel1)
        //{
        //Print("Level1");
        if(ask<=PriceStartM && ContorM==0) 
            {
               trade.Buy(VolumeZ,NULL,ask,0,ask+(InpDistTakeProfit+InpDistZ)*_Point,"Order1 & TP1");
               Level1=true;
               medierebuy=true;
               complementarebuy=false;
                ContorM=1;
                TicketNumber=trade.ResultDeal();
            }
       // } else {Level1=true;}
                  
        }
         else if(Level1==true && Level2==false)///LEVEL 2 Fibonacci
         {
         
               PriceStartM=RangeM0-(PriceLevel2-PriceLevel1);
               PriceZ=PriceStartM+InpDistZ*_Point;
               Draw_HLine(PriceZ,ColorZ);
               if(PriceStartM>PriceLevel2)
               {
               if(ask<=PriceStartM && ContorM==1) 
                  {
               trade.Buy(VolumeZ,NULL,ask,0,ask+(InpDistTakeProfit+InpDistZ)*_Point,"Order2 & TP2");
               Level2=true;
               ContorM=2;
               TicketNumber=trade.ResultDeal();
                  }
               }
               else {Level2=true;}
            
         }
         
         else if(Level2==true && Level3==false)///LEVEL 3 Fibonacci
         {
         
               PriceStartM=RangeM0-(PriceLevel3-PriceLevel2);
               PriceZ=PriceStartM+InpDistZ*_Point;
               Draw_HLine(PriceZ,ColorZ);
               if(PriceStartM>PriceLevel3)
               {
               if(ask<=PriceStartM && ContorM==2) 
                  {
               trade.Buy(VolumeZ,NULL,ask,0,ask+(InpDistTakeProfit+InpDistZ)*_Point,"Order3 &Tp3");
               Level3=true;
               ContorM=3;
               TicketNumber=trade.ResultDeal();
                  }
               }
               else {Level3=true;}
            
         }
        else if(Level3==true && Level4==false)///LEVEL 4 Fibonacci
         {
         
               PriceStartM=RangeM0-(PriceLevel4-PriceLevel3);
               PriceZ=PriceStartM+InpDistZ*_Point;
               Draw_HLine(PriceZ,ColorZ);
               if(PriceStartM>PriceLevel4)
               {
               if(ask<=PriceStartM && ContorM==3) 
                  {
               trade.Buy(VolumeZ,NULL,ask,0,ask+(InpDistTakeProfit+InpDistZ)*_Point,"Order4 &Tp4");
               Level4=true;
               ContorM=4;
               TicketNumber=trade.ResultDeal();
                  }
               }
               else {Level4=true;}
            
         }
         else if(Level4==true && Level5==false)///LEVEL 5 Fibonacci
         {
         
               PriceStartM=RangeM0-(PriceLevel5-PriceLevel4);
               PriceZ=PriceStartM+InpDistZ*_Point;
               Draw_HLine(PriceZ,ColorZ);
               if(PriceStartM>PriceLevel5)
               {
                if(ask<=PriceStartM && ContorM==4) 
                  {
               trade.Buy(VolumeZ,NULL,ask,0,ask+(InpDistTakeProfit+InpDistZ)*_Point,"Order5 &Tp5");
               Level5=true;
               ContorM=5;
               TicketNumber=trade.ResultDeal();
                  }
               }
              else {Level5=true;}
            
         }
         else if(Level5==true && Level6==false)///LEVEL 6 Fibonacci
         {
         
               PriceStartM=RangeM0-(PriceLevel6-PriceLevel5);
               PriceZ=PriceStartM+InpDistZ*_Point;
               Draw_HLine(PriceZ,ColorZ);
               if(PriceStartM>PriceLevel6)
               {
               if(ask<=PriceStartM && ContorM==5) 
                  {
               trade.Buy(VolumeZ,NULL,ask,0,ask+(InpDistTakeProfit+InpDistZ)*_Point,"Order6 &Tp6");
               Level6=true;
               ContorM=6;
               TicketNumber=trade.ResultDeal();
                   }
               }
               else {Level6=true;}
            
         }
         else if(Level6==true && Level7==false)///LEVEL 7 Fibonacci
         {
         
               PriceStartM=RangeM0-(PriceLevel7-PriceLevel6);
               PriceZ=PriceStartM+InpDistZ*_Point;
               Draw_HLine(PriceZ,ColorZ);
               if(PriceStartM>PriceLevel7)
               {
               if(ask<=PriceStartM && ContorM==6) 
                  {
               trade.Buy(VolumeZ,NULL,ask,0,ask+(InpDistTakeProfit+InpDistZ)*_Point,"Order7 &Tp7");
               Level7=true;//ba e nevoie
               ContorM=7;
               TicketNumber=trade.ResultDeal();
                  }
               }
               else {Level7=true;}
            //CloseBuyPositionsOnLastTakeProfit();
         }
         
      Print("PriceStartM->",PriceStartM);
      Print("LevelMediereContor",ContorM);
      //Print("Contor Pozitii", ContorMC);
      if(medierebuy==true)
      {
      CloseBuyPositionsOnLastTakeProfit();
      }
      Print(MediereNumber);
     }

}
///MEdiere Sell
void Mediere_Sell()
{
     if(PositionsTotal()<=3+ContorM && PositionsTotal()>0)//ContorM setam pe 0 el se modifica la fiecare deschidere de mediere maxim 7
     {
      //Print("MedeiereSell: ",medieresell);
      //Print("ComplementareSell: ",complementaresell);
      double bid =NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
      int totalPositions = PositionsTotal();
      double RangeM0 = 0.0; // Initialize with a default value
      double ValueZ = 0.0;
     
   
      int OpenBuySellTrades=PositionSellNumber;
      //Print("Start for: ",OpenBuySellTrades);
      //Print("end for: ",OpenBuySellTrades+CountOpenPositions()+10);
      for (int i = 0; i<=CountOpenPositions(); i++) //testat optim??? putem si mai departe aprox 180 de complementari
      { 
      //Alert("ticket",i);
       ulong currTicket=PositionGetTicket(i);
       //Print("TicketCurent ",currTicket, "tICKET nUMBER ",TicketNumber);
         if(currTicket!=-1 && currTicket==TicketNumber)
         {
            if (PositionSelectByTicket(currTicket)) 
            {
        
               if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) 
               {
                  RangeM0 = PositionGetDouble(POSITION_PRICE_OPEN); //pozitia 0 a rangeluiu
                  //Print("RangeM0->",RangeM0);
                  //double positionProfit = NormalizeDouble(PositionGetDouble(POSITION_PROFIT),_Digits);
                  //ValueZ += positionProfit;
               }
            }
         }
      }
      Print("RangeM0->",RangeM0);
      //Print("Value for Z",ValueZ);
      
      //calculam pozitia next ord(pretul la care deschidem pozitia)
      //7 nivele fibonacci
      double PriceStartM=0.0;
      double PriceLevel1=NormalizeDouble(InpDistZ*_Point+InpDistTakeProfit*_Point+(23.60*InpRangeM)/100*_Point,_Digits);
      double PriceLevel2=NormalizeDouble(InpDistZ*_Point+InpDistTakeProfit*_Point+(38.20*InpRangeM)/100*_Point,_Digits);
      double PriceLevel3=NormalizeDouble(InpDistZ*_Point+InpDistTakeProfit*_Point+(50.00*InpRangeM)/100*_Point,_Digits);
      double PriceLevel4=NormalizeDouble(InpDistZ*_Point+InpDistTakeProfit*_Point+(61.80*InpRangeM)/100*_Point,_Digits);
      double PriceLevel5=NormalizeDouble(InpDistZ*_Point+InpDistTakeProfit*_Point+(76.45*InpRangeM)/100*_Point,_Digits);
      double PriceLevel6=NormalizeDouble(InpDistZ*_Point+InpDistTakeProfit*_Point+(88.20*InpRangeM)/100*_Point,_Digits);
      double PriceLevel7=NormalizeDouble(InpDistZ*_Point+InpDistTakeProfit*_Point+(100.00*InpRangeM)/100*_Point,_Digits);
     
        double PriceZ;
        int decimalPlace=2;
        double pipValue = CalculatePipValue()*0.01;
        double VolumeZ=InpLots;      
        int ColorZ=clrGold; 
        PriceStartM=RangeM0+PriceLevel1;
        PriceZ=PriceStartM-InpDistZ*_Point;
        //Print("Pricez",PriceZ);
        ValueZ=CalculateLossZetSell(PriceZ,VolumeZ);
        //Print("Volum Mediere=",VolumeZ);
        //Print("Value for Z",ValueZ);
        VolumeZ=NormalizeDouble(ValueZ/InpDistZ/pipValue*10,decimalPlace);
        //Print("Volum Mediere=",VolumeZ);
       if(Level1==false) ///LEVEL 1 Fibonacci
        {
        //Print("Price sTartM in LEvel1",PriceStartM,"  ",PriceLevel1);
        PriceStartM=RangeM0+PriceLevel1;
        PriceZ=PriceStartM-InpDistZ*_Point;
        Draw_HLine(PriceZ,clrGold);
         if(bid>=PriceStartM && ContorM==0) 
            {
            
               trade.Sell(VolumeZ,NULL,bid,0,bid-(InpDistTakeProfit+InpDistZ)*_Point,"Order1 & TP1");
               //trade.SellLimit(VolumeZ,bid,NULL,0,bid-(InpDistTakeProfit+InpDistZ)*_Point,ORDER_TIME_GTC,0,NULL);
               Level1=true;
               medieresell=true;
               complementaresell=false;
                ContorM=1;
                TicketNumber=trade.ResultDeal();
            }
           
 
        }
         else if(Level1==true && Level2==false)///LEVEL 2 Fibonacci
         {
               PriceStartM=RangeM0+(PriceLevel2-PriceLevel1);
               PriceZ=PriceStartM-InpDistZ*_Point;
               Draw_HLine(PriceZ,clrGold);
                  if(bid>=PriceStartM && ContorM==1) 
                  {
               trade.Sell(VolumeZ,NULL,bid,0,bid-(InpDistTakeProfit+InpDistZ)*_Point,"Order2 & TP2");
               Level2=true;
               ContorM=2;
               TicketNumber=trade.ResultDeal();
                  }
     
         }
         
         else if(Level2==true && Level3==false)///LEVEL 3 Fibonacci
         {
         
               PriceStartM=RangeM0+(PriceLevel3-PriceLevel2);
               PriceZ=PriceStartM-InpDistZ*_Point;
               Draw_HLine(PriceZ,clrGold);
         
                  if(bid>=PriceStartM && ContorM==2) 
                  {
               trade.Sell(VolumeZ,NULL,bid,0,bid-(InpDistTakeProfit+InpDistZ)*_Point,"Order3 &Tp3");
               Level3=true;
               ContorM=3;
               TicketNumber=trade.ResultDeal();
                  }
    
            
         }
        else if(Level3==true && Level4==false)///LEVEL 4 Fibonacci
         {
         
               PriceStartM=RangeM0+(PriceLevel4-PriceLevel3);
               PriceZ=PriceStartM-InpDistZ*_Point;
               Draw_HLine(PriceZ,clrGold);
        
               if(bid>=PriceStartM && ContorM==3) 
                  {
               trade.Sell(VolumeZ,NULL,bid,0,bid-(InpDistTakeProfit+InpDistZ)*_Point,"Order4 &Tp4");
               Level4=true;
               ContorM=4;
               TicketNumber=trade.ResultDeal();
                  }
    
         }
         else if(Level4==true && Level5==false)///LEVEL 5 Fibonacci
         {
         
               PriceStartM=RangeM0+(PriceLevel5-PriceLevel4);
               PriceZ=PriceStartM-InpDistZ*_Point;
               Draw_HLine(PriceZ,clrGold);
           
                  if(bid>=PriceStartM && ContorM==4) 
                  {
               trade.Sell(VolumeZ,NULL,bid,0,bid-(InpDistTakeProfit+InpDistZ)*_Point,"Order5 &Tp5");
               Level5=true;
               ContorM=5;
               TicketNumber=trade.ResultDeal();
                  }
    
         }
         else if(Level5==true && Level6==false)///LEVEL 6 Fibonacci
         {
         
               PriceStartM=RangeM0+(PriceLevel6-PriceLevel5);
               PriceZ=PriceStartM-InpDistZ*_Point;
               Draw_HLine(PriceZ,clrGold);
               if(bid>=PriceStartM && ContorM==5) 
                  {
               trade.Sell(VolumeZ,NULL,bid,0,bid-(InpDistTakeProfit+InpDistZ)*_Point,"Order6 &Tp6");
               Level6=true;
               ContorM=6;
               TicketNumber=trade.ResultDeal();
                  }
     
         }
         else if(Level6==true && Level7==false)///LEVEL 7 Fibonacci
         {
               PriceStartM=RangeM0+(PriceLevel7-PriceLevel6);
               PriceZ=PriceStartM-InpDistZ*_Point;
               Draw_HLine(PriceZ,clrGold);
               if(bid>=PriceStartM && ContorM==6) 
                  {
               trade.Sell(VolumeZ,NULL,bid,0,bid-(InpDistTakeProfit+InpDistZ)*_Point,"Order7 &Tp7");
               Level7=true;//ba e nevoie
               ContorM=7;
               TicketNumber=trade.ResultDeal();
                  }
         }
         
      Print("PriceStartM->",PriceStartM);
      //Print("LevelMediereContor",ContorM);
      //Print("Contor Pozitii", ContorMC);
      if(medieresell==true)
      {
      CloseSellPositionsOnLastTakeProfit();
      }
      Print(MediereNumber);
      
      /*if(medieresell==true && Level1==false  && Level2==false && Level3==false 
      && Level4==false && Level5==false && Level6==false && Level7==false )     
       {
         CloseSellPositions();
         medieresell=false;
        }*/
      
     }
}
void Bolugi_Long()
{
   if(medierebuy==false && complementarebuy==true)
     {
      Complementare_Buy();
      //Print("Complementare Buy ?");
     }
 
        Mediere_Buy();
       
}
void Bolugi_Short()
{
if(medieresell==false && complementaresell==true)
     {
      Complementare_Sell();
      //Print("Complementare Buy ?");
     }
     Mediere_Sell();
     
}

void Bolugi_Long_Short()
{
   Complementare_Buy();
   Complementare_Sell();
      
}  

//count open positions
int CountOpenPositions(){

   int counter=0;
   int total=PositionsTotal();
   for(int i=total-1;i>=0;i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket<=0)
        {
         Print("Failed to get position ticket");return -1;
        }
        if(!PositionSelectByTicket(ticket))
          {
           Print("Failed to select position by ticket");return -1;
          }
         ulong magicnumber;
         if(!PositionGetInteger(POSITION_MAGIC,magicnumber)){Print("Failed to get magicnumber");return -1;}
         if(InpMagicNumber==magicnumber){counter++;}
      
     }



   return counter;
}

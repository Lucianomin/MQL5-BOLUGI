#property copyright "MindaLucian"
#property link      "MindaLucian"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>

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

enum SL_MODE_ENUM
  {
   SL_MODE_FIXED, //Fixed /pips
   SL_MODE_PERCENT //Percent step
  };
  
input SL_MODE_ENUM InpSlMode = SL_MODE_FIXED; //StopLoss Mode

input int InpStopLoss=100; // InpStopLoss pips/percent
input int InpStepRange=100; // InpStepRange in pips
//+------------------------------------------------------------------+
//| Global D                                                        |
//+------------------------------------------------------------------+
MqlRates PriceInfo[];
MqlTick currTick;
CTrade trade;
string signal="";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!CheckInputs())
   {return INIT_PARAMETERS_INCORRECT;}
   return(INIT_SUCCEEDED);
  }
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  //static next buy price
  static double NextBuyPrice;
  static int PositionNumber=0;
  bool RangeCondition=false;
  double ask =NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
  //sort
  ArraySetAsSeries(PriceInfo,true);
  int PriceData= CopyRates(_Symbol,_Period,0,3,PriceInfo);
  /*
  if(PositionNumber==PositionsTotal())
  {
  
   trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,InpLots,ask,0,0,NULL);
   PositionNumber++;
  }
  
   if(currTick.ask==ask+100*_Point)
   {
   trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,InpLots,currTick.ask,0,0,NULL);
   }*/
   if(PositionsTotal()==0)
   {NextBuyPrice=0;}
   
   signal=CheckEntrySignal();
   
   if(ask>=NextBuyPrice)
   
   if(signal=="buy")
   {
      trade.Buy(InpLots,NULL,ask,0,0,NULL);
      PositionNumber++;
      NextBuyPrice=ask+InpStepRange*_Point;
   
   }
   
   //chart output
   Comment("Ask",ask,"\n","NextBuyPrice: ",NextBuyPrice);
   // range condition not static
   if(PositionsTotal()==4)
   {
   RangeCondition=true;
   }
   Comment("Range Condition: ",RangeCondition);
   if(RangeCondition==true)
     {
     CloseAllPositions();//test inchide toate pozitiile cand
      //set stop loss for 4 order or n order
     }
   
  }

//+------------------------------------------------------------------+
//| function                                                         |
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
     if(InpSlMode==SL_MODE_PERCENT && (InpStopLoss<=0 || InpStopLoss>=5))
     {
      Alert("Stop Loss lower than 0 or greater than 5%");
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
   else
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
   ulong ticket=PositionGetTicket(i);
   
   trade.PositionClose(ticket,i);
   
   }

}

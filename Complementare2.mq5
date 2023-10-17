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
MqlTick currTick;
CTrade trade;
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
  int PositionNumber=0;
  double ask =NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
  if(PositionNumber==PositionsTotal())
  {
  
   trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,InpLots,ask,0,0,NULL);
   PositionNumber++;
  }
   if(currTick.ask==ask+100*_Point)
   {
   trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,InpLots,currTick.ask,0,0,NULL);
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
//testopen buy positions

#property copyright "MindaLucian"
#property link      "MindaLucian"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Includes                                  |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Variables                                 |
//+------------------------------------------------------------------+
input int InpFastPeriod= 14; // fast period
input int InpSlowPeriod= 21; // slow period
input int InpStopLoss=100; //SL points pips
input int InpTakeProfit=200;//TP

//+------------------------------------------------------------------+
//|  global Variables                                 |
//+------------------------------------------------------------------+
int fastHandle;
int slowHandle;
double fastBuffer[];
double slowBuffer[];
datetime OpenTimeBuy=0;
datetime OpenTimeSell=0;
CTrade trade;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
//check useer
  if(InpFastPeriod<=0)
  {
  Alert("fast period <=0");
  return INIT_PARAMETERS_INCORRECT;
  }
  //slow period
  if(InpSlowPeriod<=0)
  {
  Alert("slow period <=0");
  return INIT_PARAMETERS_INCORRECT;
  
  }
  //INPfastperiod
  if(InpFastPeriod >= InpSlowPeriod)
  {
  Alert("fast period >= slow period ");
  return INIT_PARAMETERS_INCORRECT;
  }
  //SL
  if(InpStopLoss<=0)
  {
  Alert("stop loss <=0");
  return INIT_PARAMETERS_INCORRECT;
  }
  //TP
  if(InpTakeProfit<=0)
  {
  Alert("take profit <=0");
  return INIT_PARAMETERS_INCORRECT;
  }
   
   //create handles
   fastHandle=iMA(_Symbol,PERIOD_CURRENT,InpFastPeriod,0,MODE_SMA,PRICE_CLOSE);
  if(fastHandle==INVALID_HANDLE){
  Alert("failed to create fast handle");
  return INIT_FAILED;
  }
  
  slowHandle=iMA(_Symbol,PERIOD_CURRENT,InpSlowPeriod,0,MODE_SMA,PRICE_CLOSE);
  if(slowHandle==INVALID_HANDLE){
  Alert("failed to create slow handle");
  return INIT_FAILED;
  }
  
  
  ArraySetAsSeries(fastBuffer,true);
  ArraySetAsSeries(slowBuffer,true);
  
  return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
  if(fastHandle != INVALID_HANDLE){IndicatorRelease(fastHandle);}
  if(slowHandle != INVALID_HANDLE){IndicatorRelease(slowHandle);}

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){

//get indicator value
   int values= CopyBuffer(fastHandle,0,0,2,fastBuffer);
   if(values != 2)
   {
   Print("NOt Enough Data for fast moving average");
   return;  
   }
  
  values= CopyBuffer(slowHandle,0,0,2,slowBuffer);
   if(values != 2)
   {
   Print("NOt Enough Data for slow moving average");
   return;  
   }
   
   Comment("fast[0]:",fastBuffer[0],"\n",
           "fast[1]:",fastBuffer[1],"\n",
           "slow[0]:",slowBuffer[0],"\n",
           "slow[1]:",slowBuffer[1]);
   //check for cross buy
   if(fastBuffer[1] <= slowBuffer[1] && fastBuffer[0] > slowBuffer[0] && OpenTimeBuy!=iTime(_Symbol,PERIOD_CURRENT,0))
     {
     OpenTimeBuy = iTime(_Symbol,PERIOD_CURRENT,0);
     double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
     double sl = ask - InpStopLoss * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
     double tp = ask + InpTakeProfit * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
      trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,1.0,ask,sl,tp,"Cross EA");
     }
   //check for cross sell  
     if(fastBuffer[1] >= slowBuffer[1] && fastBuffer[0] < slowBuffer[0] && OpenTimeSell!=iTime(_Symbol,PERIOD_CURRENT,0))
     {
     OpenTimeSell = iTime(_Symbol,PERIOD_CURRENT,0);
     double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
     double sl = bid + InpStopLoss * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
     double tp = bid - InpTakeProfit * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
      trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,1.0,bid,sl,tp,"Cross EA");
     }
     
  }
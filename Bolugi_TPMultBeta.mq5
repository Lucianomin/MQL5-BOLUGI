//+------------------------------------------------------------------+
//|                                                                  |
//|                    Copyright 2023, BOLUGI                        |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "MindaLucian"
#property link      "MindaLucian"
#property version   "1.00"
#property description "X-Close all positions on Bolugi."
#property description "S-Close all posiitons on all instruments."
#property description "H-Half the volumes on Bolugi."
#property description "Send Notifications pt TP All & SL All"
#property description "TP MUltiplicator."
//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "---->General Inputs<----";

input long InpMagicNumber=181105;
enum TRADING_INSTRUMENT
  {
   TRADING_FOREX,
   TRADING_INDICES,
   TRADING_COMMODITIES,
   TRADING_CRYPTO
  };
enum LOT_MODE_ENUM
  {
   LOT_MODE_FIXED,
   LOT_MODE_ADDITION,
   LOT_MODE_PERCENT
  };
enum STOP_LOSS_ENUM
  {
   STOP_LOSS_NONE,
   STOP_LOSS_PERCENT,
   STOP_LOSS_MONEY
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input group "---->Tip Robot<----";
enum BOLUGI_MODE
  {
   BOLUGI_LONG,
   BOLUGI_SHORT,
   BOLUGI_LONG_SHORT
  };
input BOLUGI_MODE InpBotMode= BOLUGI_LONG; //BOLUGI_MODE
input TRADING_INSTRUMENT InpTradingInstrument=TRADING_INDICES;
input LOT_MODE_ENUM InpLotMode = LOT_MODE_FIXED; //Lot Mode
input double InpLots=0.01; //fixed/additional lots/percent
input group "---->Notifications<----";
input bool InpNotifications=true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input group "---->MaxStopLossAll<----";
input STOP_LOSS_ENUM InpStopLossMode=STOP_LOSS_NONE;//StopLossAll Mode(None/Money/Percent of Balance)
input double InpStopLossAll=100;//MaxStopLossAll(Percent of Balance/Money)*See Above
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input group "---->MaxProfitAll<----";
input bool InpTakeProfitMode=true; //True-activate ProfitAll/ False-Dezactivate
input double InpTakeProfitAll=150; //TakeProfitAll(dollars/euros)(Profit>=Input=>CloseAllPositions)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

input group "---->Range Inputs(Complementare-LONG)<----";
input int InpStopLoss=100; // InpStopLoss (pips / percent)
input int InpStepC=100; // InpStepC (pips)
input bool InpTrailMode=true; //TrailMode (true/false)
input int InpTrailStop=20; //InpTrailStop (pips)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input group "---->Range Inputs(Mediere-LONG)<----";
input int InpRangeM=1000;//InpRangeM (pips)
input double InpZTP=2;//InpZTP (pips)(InpDistTakeProfit/ZTP, ZTP>=1)
input int InpDistTakeProfit=150;//InpDistTakeProfit (pips)
input bool InpTPMode=true; //Multiplicator(true/false)
input double InpTPMultiplicator=1.1;//InpTPMultiplicator
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input group "---->(Mediere-LONG), FIBONACCI LEVELS<----";
input bool InpLevel1=true;
input bool InpLevel2=true;
input bool InpLevel3=true;
input bool InpLevel4=true;
input bool InpLevel5=true;
input bool InpLevel6=true;
input bool InpLevel7=true;
input bool InpLevel8=true;
input bool InpLevel9=true;
input bool InpLevel10=true;
input bool InpLevel11=true;
input bool InpLevel12=true;
input bool InpLevel13=true;
input bool InpLevel14=true;
input bool InpLevel15=true;
input bool InpLevel16=true;
input bool InpLevel17=true;
input bool InpLevel18=true;
input bool InpLevel19=true;
input group "---->Range Inputs(Complementare-SHORT)<----";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input int InpStopLossS=100; // InpStopLoss (pips / percent)
input int InpStepCS=100; // InpStepC (pips)
input bool InpTrailModeS=true; //TrailMode (true/false)
input int InpTrailStopS=20; //InpTrailStop (pips)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input group "---->Range Inputs(Mediere-SHORT)<----";
input int InpRangeMS=1000;//InpRangeM (pips)
input double InpZTPS=2;//InpZTP (pips)(InpDistTakeProfit/ZTP, ZTP>=1)
input int InpDistTakeProfitS=150;//InpDistTakeProfit (pips)
input bool InpTPSMode=true; //Multiplicator(true/false)
input double InpTPSMultiplicator=1.1;//InpTPMultiplicator
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input group "---->(Mediere-SHORT), FIBONACCI LEVELS<----";
input bool InpLevel1S=true;
input bool InpLevel2S=true;
input bool InpLevel3S=true;
input bool InpLevel4S=true;
input bool InpLevel5S=true;
input bool InpLevel6S=true;
input bool InpLevel7S=true;
input bool InpLevel8S=true;
input bool InpLevel9S=true;
input bool InpLevel10S=true;
input bool InpLevel11S=true;
input bool InpLevel12S=true;
input bool InpLevel13S=true;
input bool InpLevel14S=true;
input bool InpLevel15S=true;
input bool InpLevel16S=true;
input bool InpLevel17S=true;
input bool InpLevel18S=true;
input bool InpLevel19S=true;


//+------------------------------------------------------------------+
//| Global D                                                        |
//+------------------------------------------------------------------+
MqlTick prevTick, lastTick;
#define KEY_X 88
#define KEY_E 69
#define KEY_H 72
#define KEY_S 83

CTrade trade;

int      ContorM=0;
bool     medierebuy=false;
bool     complementarebuy=false;

bool     medieresell=false;
bool     complementaresell=true;
//LEVEL MEDIERE BUY
bool Level1=false,
     Level2=false,
     Level3=false,
     Level4=false,
     Level5=false,
     Level6=false,
     Level7=false,
     Level8=false,
     Level9=false,
     Level10=false,
     Level11=false,
     Level12=false,
     Level13=false,
     Level14=false,
     Level15=false,
     Level16=false,
     Level17=false,
     Level18=false,
     Level19=false;
//LEVELE MEDIERE SELL
bool LevelS1=false,
     LevelS2=false,
     LevelS3=false,
     LevelS4=false,
     LevelS5=false,
     LevelS6=false,
     LevelS7=false,
     LevelS8=false,
     LevelS9=false,
     LevelS10=false,
     LevelS11=false,
     LevelS12=false,
     LevelS13=false,
     LevelS14=false,
     LevelS15=false,
     LevelS16=false,
     LevelS17=false,
     LevelS18=false,
     LevelS19=false;
//TICKET BUY
ulong    TicketNumber=-1;
ulong    TicketNumber1=-1;
//TICKET SELL
ulong    TicketNumberS=-1;
ulong    TicketNumberS1=-1;
//VAriable LONG
double RangeMB0=0.0;
int CONTOR=0;
int contorTPB=0;
int contorTP1=0;
//VARIABLE SHORT
double RangeMS0=0.0;
int CONTORS=0;
int contorTPS=0;
int contorTP=0;
//+------------------------------------------------------------------+
//+VOLUME                                           |
//+------------------------------------------------------------------+
//LOSS BUUY
double  Loss1=0.0,
        Loss2=0.0,
        Loss3=0.0,
        Loss4=0.0,
        Loss5=0.0,
        Loss6=0.0,
        Loss7=0.0,
        Loss8=0.0,
        Loss9=0.0,
        Loss10=0.0,
        Loss11=0.0,
        Loss12=0.0,
        Loss13=0.0,
        Loss14=0.0,
        Loss15=0.0,
        Loss16=0.0,
        Loss17=0.0,
        Loss18=0.0,
        Loss19=0.0;

//LOSS SELL
double Loss1S=0.0,
       Loss2S=0.0,
       Loss3S=0.0,
       Loss4S=0.0,
       Loss5S=0.0,
       Loss6S=0.0,
       Loss7S=0.0,
       Loss8S=0.0,
       Loss9S=0.0,
       Loss10S=0.0,
       Loss11S=0.0,
       Loss12S=0.0,
       Loss13S=0.0,
       Loss14S=0.0,
       Loss15S=0.0,
       Loss16S=0.0,
       Loss17S=0.0,
       Loss18S=0.0,
       Loss19S=0.0;

//VOLUME BUY
double   Vl1=0.0,
         Vl2=0.0,
         Vl3=0.0,
         Vl4=0.0,
         Vl5=0.0,
         Vl6=0.0,
         Vl7=0.0,
         Vl8=0.0,
         Vl9=0.0,
         Vl10=0.0,
         Vl11=0.0,
         Vl12=0.0,
         Vl13=0.0,
         Vl14=0.0,
         Vl15=0.0,
         Vl16=0.0,
         Vl17=0.0,
         Vl18=0.0,
         Vl19=0.0;

//VOLUME SELL
double Vl1S=0.0,
       Vl2S=0.0,
       Vl3S=0.0,
       Vl4S=0.0,
       Vl5S=0.0,
       Vl6S=0.0,
       Vl7S=0.0,
       Vl8S=0.0,
       Vl9S=0.0,
       Vl10S=0.0,
       Vl11S=0.0,
       Vl12S=0.0,
       Vl13S=0.0,
       Vl14S=0.0,
       Vl15S=0.0,
       Vl16S=0.0,
       Vl17S=0.0,
       Vl18S=0.0,
       Vl19S=0.0;

//PRICELEVELS BUY
double PL1,
       PL2,
       PL3,
       PL4,
       PL5,
       PL6,
       PL7,
       PL8,
       PL9,
       PL10,
       PL11,
       PL12,
       PL13,
       PL14,
       PL15,
       PL16,
       PL17,
       PL18,
       PL19;
//PRICELEVELS SELL
double   PL1S,
         PL2S,
         PL3S,
         PL4S,
         PL5S,
         PL6S,
         PL7S,
         PL8S,
         PL9S,
         PL10S,
         PL11S,
         PL12S,
         PL13S,
         PL14S,
         PL15S,
         PL16S,
         PL17S,
         PL18S,
         PL19S;
int decimalPlace=2;
//LONG VARIABLEs
double TZ=InpDistTakeProfit/InpZTP*_Point;
double TZ1=TZ*InpTPMultiplicator;
double TZ2=TZ1*InpTPMultiplicator;
double TZ3=TZ2*InpTPMultiplicator;
double TZ4=TZ3*InpTPMultiplicator;
double TZ5=TZ4*InpTPMultiplicator;
double TZ6=TZ5*InpTPMultiplicator;
double TZ7=TZ6*InpTPMultiplicator;
double TZ8=TZ7*InpTPMultiplicator;
double TZ9=TZ8*InpTPMultiplicator;
//TP
double TP1=InpDistTakeProfit;
double TP2=TP1*InpTPMultiplicator;
double TP3=TP2*InpTPMultiplicator;
double TP4=TP3*InpTPMultiplicator;
double TP5=TP4*InpTPMultiplicator;
double TP6=TP5*InpTPMultiplicator;
double TP7=TP6*InpTPMultiplicator;
double TP8=TP7*InpTPMultiplicator;
double TP9=TP8*InpTPMultiplicator;
double TP10=TP9*InpTPMultiplicator;
double step2=(InpStepC/2)*_Point;
double step3=InpStepC*_Point;
double PL0;
//SHORT VARIABLES
double TZS=InpDistTakeProfitS/InpZTPS*_Point;
double TZS1=TZS*InpTPMultiplicator;
double TZS2=TZS1*InpTPMultiplicator;
double TZS3=TZS2*InpTPMultiplicator;
double TZS4=TZS3*InpTPMultiplicator;
double TZS5=TZS4*InpTPMultiplicator;
double TZS6=TZS5*InpTPMultiplicator;
double TZS7=TZS6*InpTPMultiplicator;
double TZS8=TZS7*InpTPMultiplicator;
double TZS9=TZS8*InpTPMultiplicator;
//TPs
double TPS1=InpDistTakeProfitS;
double TPS2=TPS1*InpTPSMultiplicator;
double TPS3=TPS2*InpTPSMultiplicator;
double TPS4=TPS3*InpTPSMultiplicator;
double TPS5=TPS4*InpTPSMultiplicator;
double TPS6=TPS5*InpTPSMultiplicator;
double TPS7=TPS6*InpTPSMultiplicator;
double TPS8=TPS7*InpTPSMultiplicator;
double TPS9=TPS8*InpTPSMultiplicator;
double TPS10=TPS9*InpTPSMultiplicator;
double step2S=(InpStepCS/2)*_Point;
double step3S=InpStepCS*_Point;
double PL0S;
int OnInit()

  {
   if(!CheckInputs())
     {
      return INIT_PARAMETERS_INCORRECT;
     }
   trade.SetExpertMagicNumber(InpMagicNumber);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   prevTick=lastTick;
   SymbolInfoTick(_Symbol,lastTick);

   if(InpBotMode==BOLUGI_LONG_SHORT)
     {
      Bolugi_Long_Short();
     }
   if(InpBotMode==BOLUGI_LONG)
     {
      Bolugi_Long();
     }
   if(InpBotMode==BOLUGI_SHORT)
     {
      Bolugi_Short();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  OnChartEvent(const int       id,       const long&     lparam,    const double&   dparam,   const string&   sparam)
  {
   if(id==CHARTEVENT_KEYDOWN)
     {
      Print(id, lparam, dparam);
      if(lparam==KEY_X)
        {
         CloseBuyPositions();
         CloseSellPositions();
         CONTOR=0;
         medierebuy=false;
         Level1=false;
         Level2=false;
         Level3=false;
         Level4=false;
         Level5=false;
         Level6=false;
         Level7=false;
         Level8=false;
         Level9=false;
         Level10=false;
         Level11=false;
         Level12=false;
         Level13=false;
         Level14=false;
         Level15=false;
         Level16=false;
         Level17=false;
         Level18=false;
         Level19=false;
         CONTORS=0;
         medieresell=false;
         LevelS1=false;
         LevelS2=false;
         LevelS3=false;
         LevelS4=false;
         LevelS5=false;
         LevelS6=false;
         LevelS7=false;
         LevelS8=false;
         LevelS9=false;
         LevelS10=false;
         LevelS11=false;
         LevelS12=false;
         LevelS13=false;
         LevelS14=false;
         LevelS15=false;
         LevelS16=false;
         LevelS17=false;
         LevelS18=false;
         LevelS19=false;
        }
     }

   if(id==CHARTEVENT_KEYDOWN)
     {
      if(lparam==KEY_S)
        {
         CloseAllPositions();
         CONTOR=0;
         medierebuy=false;
         Level1=false;
         Level2=false;
         Level3=false;
         Level4=false;
         Level5=false;
         Level6=false;
         Level7=false;
         Level8=false;
         Level9=false;
         Level10=false;
         Level11=false;
         Level12=false;
         Level13=false;
         Level14=false;
         Level15=false;
         Level16=false;
         Level17=false;
         Level18=false;
         Level19=false;
         CONTORS=0;
         medieresell=false;
         LevelS1=false;
         LevelS2=false;
         LevelS3=false;
         LevelS4=false;
         LevelS5=false;
         LevelS6=false;
         LevelS7=false;
         LevelS8=false;
         LevelS9=false;
         LevelS10=false;
         LevelS11=false;
         LevelS12=false;
         LevelS13=false;
         LevelS14=false;
         LevelS15=false;
         LevelS16=false;
         LevelS17=false;
         LevelS18=false;
         LevelS19=false;
        }
     }
   if(id==CHARTEVENT_KEYDOWN)
     {
      //Print(lparam);
      if(lparam==KEY_H)
        {
         for(int i=0; i<CountOpenPositions(); i++)
           {
            ulong currticket=PositionGetTicket(i);
            ulong magicnumber=PositionGetInteger(POSITION_MAGIC);            
            if(PositionSelectByTicket(currticket))
              {
               if(PositionGetDouble(POSITION_VOLUME)>0.01)
                 {
                 if(InpMagicNumber==magicnumber)
                 {
                     double currvolume=PositionGetDouble(POSITION_VOLUME);
                     double halfvolume=NormalizeDouble((currvolume/2),2);
                     trade.PositionClosePartial(currticket,halfvolume,-1);
                     }
                 }
              }
           }
        }
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
      Alert("lots<=0 or lots>10");
      return false;
     }

   if(InpLotMode==LOT_MODE_ADDITION &&(InpLots<=0 || InpLots >1000))
     {
      Alert("lots<=0 or lots>1000");
      return false;
     }
   if(InpLotMode==LOT_MODE_PERCENT &&(InpLots<=0 || InpLots >5))
     {
      Alert("lots<=0 or lots>5%");
      return false;
     }

   if((InpLotMode==LOT_MODE_PERCENT || InpLotMode==LOT_MODE_ADDITION) && InpStopLoss==0)
     {
      Alert("selected mode needs a stop loss");
      return false;
     }
   if(InpRangeM<=0)
     {
      Alert("Step Mediere lower than 0 pips");
      return false;
     }
   if(InpDistTakeProfit<=0)
     {
      Alert("Distance from TP FIBO to Z lower than 0 ");
      return false;
     }
   if(InpZTP<=0)
     {
      Alert("input ZTp  <=0");
      return false;
     }

   if(InpStepC<=0)
     {
      Alert("InpStepCS <=0");
      return false;
     }
   if(InpRangeMS<=0)
     {
      Alert("Step Mediere lower than 0 pips");
      return false;
     }
   if(InpDistTakeProfitS<=0)
     {
      Alert("Distance from TP FIBO to Z lower than 0 ");
      return false;
     }
   if(InpZTPS<=0)
     {
      Alert("input ZTp  <=0");
      return false;
     }

   if(InpStepCS<=0)
     {
      Alert("InpStepC <=0");
      return false;
     }
   return true;
  }
//close all positions
void CloseAllPositions()
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      ulong ticket=PositionGetTicket(i);//get ticket
      trade.PositionClose(ticket,i);//close
     }

  }
//CloseBuyPos
void CloseBuyPositions()
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      ulong ticket=PositionGetTicket(i);//get ticket
      ulong magicnumber;
      PositionGetInteger(POSITION_MAGIC,magicnumber);
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         if(InpMagicNumber==magicnumber)
           {
            trade.PositionClose(ticket,i);//close
           }

        }

     }
   CONTOR=0;
  }
//Close Sell Pos
void CloseSellPositions()
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      ulong ticket=PositionGetTicket(i);//get ticket
      ulong magicnumber;
      PositionGetInteger(POSITION_MAGIC,magicnumber);
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         if(InpMagicNumber==magicnumber)
           {
            trade.PositionClose(ticket,i);//close
           }

        }

     }
   CONTORS=0;
  }

//calculatelots
double CalculateLots(double lots)
  {

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

      double moneyVolumeStep= ((1250*_Point)/tickSize) * tickValue *volumeStep;
      lots=MathFloor(riskMoney/moneyVolumeStep)*volumeStep;

      return lots;
     }

   return lots;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Bolugi_Long()
  {
   static double NextBuyPrice;

   double Lots= CalculateLots(InpLots);

   if(CONTOR==0)
     {
      NextBuyPrice=0;
      if(trade.Buy(Lots,NULL,lastTick.ask,0,0,"COMPLEMENTARE BUY"))
        {
         TicketNumber1=trade.ResultOrder();
         RangeMB0=lastTick.ask;
         CONTOR=1;
         NextBuyPrice=RangeMB0+InpStepC*_Point;
        }
     }
//SELECT PL0
   for(int i=0; i<CountOpenPositions(); i++)
     {
      ulong currTicket=PositionGetTicket(i);
      if(currTicket!=TicketNumber1)
        {
         Print("ticket!=TicketNumber1",currTicket);
        }
      else
        {
         if(!PositionSelectByTicket(TicketNumber1))
           {
            Print("Cannot get ticket number1!");
           }
         else
           {
            PL0=PositionGetDouble(POSITION_PRICE_OPEN);
           }
        }

     }
//OPEN BUYS
   if(lastTick.ask>=NextBuyPrice  && medierebuy==false)
     {
      if(trade.Buy(Lots,NULL,lastTick.ask,0,0,"COMPLEMENTARE BUY"))
        {
         //a deschis poziti
         RangeMB0=lastTick.ask;
         NextBuyPrice=RangeMB0+InpStepC*_Point;// averificat range
         TicketNumber=trade.ResultOrder();
         CONTOR++;
        }
     }
   Print("NextBuyPrice",NextBuyPrice);

//LONG
   if(InpTPMode==false)
     {
      TP2=TP1;
      TP3=TP1;
      TP4=TP1;
      TP5=TP1;
      TP6=TP1;
      TP7=TP1;
      TP8=TP1;
      TP9=TP1;
      TP10=TP1;

     }
     if(InpTPMode==true)
       {
        PL1=NormalizeDouble(PL0-((23.60*InpRangeM)/100*_Point+TP1*_Point),_Digits);
   PL2=NormalizeDouble(PL0-((38.20*InpRangeM)/100*_Point+TP2*_Point),_Digits);
   PL3=NormalizeDouble(PL0-((50.0*InpRangeM)/100*_Point+TP3*_Point),_Digits);
   PL4=NormalizeDouble(PL0-((61.80*InpRangeM)/100*_Point+TP4*_Point),_Digits);
   PL5=NormalizeDouble(PL0-((78.80*InpRangeM)/100*_Point+TP5*_Point),_Digits);
   PL6=NormalizeDouble(PL0-((88.20*InpRangeM)/100*_Point+TP6*_Point),_Digits);
   PL7=NormalizeDouble(PL0-(InpRangeM*_Point+TP7*_Point),_Digits);
   PL8=NormalizeDouble(PL0-((127.20*InpRangeM)/100*_Point+TP8*_Point),_Digits);
   PL9=NormalizeDouble(PL0-((161.80*InpRangeM)/100*_Point+TP9*_Point),_Digits);
   PL10=NormalizeDouble(PL0-((200.00*InpRangeM)/100*_Point+TP10*_Point),_Digits);//STOP
       }
   PL1=NormalizeDouble(PL0-((23.60*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL2=NormalizeDouble(PL0-((38.20*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL3=NormalizeDouble(PL0-((50.0*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL4=NormalizeDouble(PL0-((61.80*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL5=NormalizeDouble(PL0-((78.80*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL6=NormalizeDouble(PL0-((88.20*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL7=NormalizeDouble(PL0-(InpRangeM*_Point+InpDistTakeProfit*_Point),_Digits);
   PL8=NormalizeDouble(PL0-((127.20*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL9=NormalizeDouble(PL0-((161.80*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL10=NormalizeDouble(PL0-((200.00*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);//STOP
   PL11=NormalizeDouble(PL0-((227.20*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL12=NormalizeDouble(PL0-((261.80*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL13=NormalizeDouble(PL0-((300.00*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL14=NormalizeDouble(PL0-((327.20*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL15=NormalizeDouble(PL0-((361.80*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL16=NormalizeDouble(PL0-((400.00*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL17=NormalizeDouble(PL0-((427.20*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL18=NormalizeDouble(PL0-((461.80*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL19=NormalizeDouble(PL0-((500.00*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);

//LONG FUNCTION
   if(InpTPMode==true)
     {
      Calculate_V1();
      Calculate_V2M();
      Calculate_V3M();
      Calculate_V4M();
      Calculate_V5M();
      Calculate_V6M();
      Calculate_V7M();
      Calculate_V8M();
      Calculate_V9M();
      Calculate_V10M();
     }
   else
     {
      Calculate_V1();
      Calculate_V2();
      Calculate_V3();
      Calculate_V4();
      Calculate_V5();
      Calculate_V6();
      Calculate_V7();
      Calculate_V8();
      Calculate_V9();
      Calculate_V10();

     }

   if(InpLevel1==false)
     {
      PL1=PL2;
      Calculate_V2();
      PL1=PL3;
      Calculate_V3();
      PL1=PL4;
      Calculate_V4();
      PL1=PL5;
      Calculate_V5();
      PL1=PL6;
      Calculate_V6();
      PL1=PL7;
      Calculate_V7();
      PL1=PL8;
      Calculate_V8();
      PL1=PL9;
      Calculate_V9();

     }
   if(InpLevel2==false)
     {
      PL2=PL3;
      Calculate_V3();
      PL2=PL4;
      Calculate_V4();
      PL2=PL5;
      Calculate_V5();
      PL2=PL6;
      Calculate_V6();
      PL2=PL7;
      Calculate_V7();
      PL2=PL8;
      Calculate_V8();
      PL2=PL9;
      Calculate_V9();
     }
   if(InpLevel3==false)
     {
      PL3=PL4;
      Calculate_V4();
      PL3=PL5;
      Calculate_V5();
      PL3=PL6;
      Calculate_V6();
      PL3=PL7;
      Calculate_V7();
      PL3=PL8;
      Calculate_V8();
      PL3=PL9;
      Calculate_V9();
     }
   if(InpLevel4==false)
     {
      PL4=PL5;
      Calculate_V5();
      PL4=PL6;
      Calculate_V6();
      PL4=PL7;
      Calculate_V7();
      PL4=PL8;
      Calculate_V8();
      PL4=PL9;
      Calculate_V9();
     }
   if(InpLevel5==false)
     {
      PL5=PL6;
      Calculate_V6();
      PL5=PL7;
      Calculate_V7();
      PL5=PL8;
      Calculate_V8();
      PL5=PL9;
      Calculate_V9();
     }
   if(InpLevel6==false)
     {
      PL6=PL7;
      Calculate_V7();
      PL6=PL8;
      Calculate_V8();
      PL6=PL9;
      Calculate_V9();
     }

   if(InpLevel7==false)
     {
      PL7=PL8;
      Calculate_V8();
      PL7=PL9;
      Calculate_V9();
     }
   if(InpLevel8==false)
     {
      PL8=PL9;
      Calculate_V9();
     }
//Normalize Indices Volumes
   if(InpTradingInstrument==TRADING_INDICES)
     {
      //Long
      Vl1=NormalizeDouble(Vl1,1);
      Vl2=NormalizeDouble(Vl2,1);
      Vl3=NormalizeDouble(Vl3,1);
      Vl4=NormalizeDouble(Vl4,1);
      Vl5=NormalizeDouble(Vl5,1);
      Vl6=NormalizeDouble(Vl6,1);
      Vl7=NormalizeDouble(Vl7,1);
      Vl8=NormalizeDouble(Vl8,1);
      Vl9=NormalizeDouble(Vl9,1);
      Vl10=NormalizeDouble(Vl10,1);
      Vl11=NormalizeDouble(Vl11,1);
      Vl12=NormalizeDouble(Vl12,1);
      Vl13=NormalizeDouble(Vl13,1);
      Vl14=NormalizeDouble(Vl14,1);
      Vl15=NormalizeDouble(Vl15,1);
      Vl16=NormalizeDouble(Vl16,1);
      Vl17=NormalizeDouble(Vl17,1);
      Vl18=NormalizeDouble(Vl18,1);
      Vl19=NormalizeDouble(Vl19,1);
     }

//LONG
   Print("PL0  ",PL0);
   Print("PL1  ",PL1);
   Print("PL2  ",PL2);
   Print("PL3  ",PL3);
   Print("PL4  ",PL4);
   Print("PL5  ",PL5);
   Print("PL6  ",PL6);
   Print("PL7  ",PL7);
   Print("PL8  ",PL8);
   Print("PL9  ",PL9);
   
   Comment("CONTOR:",CONTOR);
   Comment("NextBuyPrice: ",NextBuyPrice,"\n");
   //Comment("Lots Available:",1000/CalculatePipValue());
//complementare buy
   if(CountOpenPositions()>=4 && medierebuy==false && CONTOR>=4)
     {
      complementarebuy=true;
      if(PositionSelectByTicket(TicketNumber))
        {
         if(PositionGetDouble(POSITION_SL)==0)
           {
            trade.PositionModify(TicketNumber,(RangeMB0-(InpStopLoss*_Point)),0);
           }
        }

     }

//afara din complementar BUY if statement set the trailing stop loss
   if(medierebuy==false && complementarebuy==true)
     {
      double lastBuyStopLoss=0.0,lastBuyPosition=0.0,currP=0.0;
      if(PositionSelectByTicket(TicketNumber))
        {
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
           {
            lastBuyStopLoss = PositionGetDouble(POSITION_SL);//1.20563 modifica 1.20583
            lastBuyPosition=PositionGetDouble(POSITION_PRICE_OPEN);//1.20613
            currP=PositionGetDouble(POSITION_PRICE_CURRENT);//1.20612 20pips
           }

        }
      static double TrailPrice=NormalizeDouble(lastBuyStopLoss+InpTrailStop*_Point+InpStopLoss*_Point,_Digits);
      if(lastTick.ask>=TrailPrice)
        {
         if(PositionSelectByTicket(TicketNumber))
           {
            trade.PositionModify(TicketNumber,NormalizeDouble(lastBuyStopLoss+InpTrailStop*_Point,_Digits),0);
            TrailPrice=NormalizeDouble(TrailPrice+InpTrailStop*_Point,_Digits);
           }

        }
      if(lastBuyStopLoss==currP)
        {
         CloseBuyPositions();
         CONTOR=0;
         complementarebuy=false;
         if(PositionSelectByTicket(TicketNumber))
           {
            trade.PositionModify(TicketNumber,0,0);
           }
        }
     }
   if(PL0==0.0)
     {
      Alert("Atentie PL0 e 0.0");
     }
           
//mediere buy
   if(Level1==false && InpLevel1==true) ///LEVEL 1 Fibonacci
     {

      if(lastTick.ask<=PL1)
        {

         if(trade.Buy(Vl1,NULL,lastTick.ask,0,lastTick.ask+TP1*_Point,"Order1 & TP1"))
           {
            Level1=true;
            medierebuy=true;
            complementarebuy=false;
            TicketNumber=trade.ResultOrder();
           }
         else
           {
            SendNotification("ERROR, Check Volume!!!");
           }
        }

     }
   else
      if(Level2==false && InpLevel2==true)///LEVEL 2 Fibonacci
        {
         if(lastTick.ask<=PL2)
           {

            if(trade.Buy(Vl2,NULL,lastTick.ask,0,lastTick.ask+TP2*_Point,"Order2 & TP2"))
              {
               medierebuy=true;
               Level2=true;
               ContorM=2;
               TicketNumber=trade.ResultOrder();
              }
            else
              {
               SendNotification("ERROR, Check Volume!!!");
              }
           }
        }

      else
         if(Level3==false && InpLevel3==true)///LEVEL 3 Fibonacci
           {

            if(lastTick.ask<=PL3)
              {

               if(trade.Buy(Vl3,NULL,lastTick.ask,0,lastTick.ask+TP3*_Point,"Order3 &Tp3"))
                 {
                  medierebuy=true;
                  Level3=true;
                  ContorM=3;
                  TicketNumber=trade.ResultOrder();
                 }
               else
                 {
                  SendNotification("ERROR, Check Volume!!!");
                 }
              }

           }
         else
            if(Level4==false && InpLevel4==true)///LEVEL 4 Fibonacci
              {


               if(lastTick.ask<=PL4)
                 {

                  if(trade.Buy(Vl4,NULL,lastTick.ask,0,lastTick.ask+TP4*_Point,"Order4 &Tp4"))
                    {
                     medierebuy=true;
                     Level4=true;
                     ContorM=4;
                     TicketNumber=trade.ResultOrder();
                    }
                  else
                    {
                     SendNotification("ERROR, Check Volume!!!");
                    }
                 }

              }
            else
               if(Level5==false && InpLevel5==true)///LEVEL 5 Fibonacci
                 {


                  if(lastTick.ask<=PL5)
                    {

                     if(trade.Buy(Vl5,NULL,lastTick.ask,0,lastTick.ask+TP5*_Point,"Order5 &Tp5"))
                       {
                        medierebuy=true;
                        Level5=true;
                        ContorM=5;
                        TicketNumber=trade.ResultOrder();
                       }
                     else
                       {
                        SendNotification("ERROR, Check Volume!!!");
                       }
                    }


                 }
               else
                  if(Level6==false && InpLevel6==true)///LEVEL 6 Fibonacci
                    {

                     if(lastTick.ask<=PL6)
                       {

                        if(trade.Buy(Vl6,NULL,lastTick.ask,0,lastTick.ask+TP6*_Point,"Order6 &Tp6"))
                          {
                           medierebuy=true;
                           Level6=true;
                           ContorM=6;
                           TicketNumber=trade.ResultOrder();
                          }
                        else
                          {
                           SendNotification("ERROR, Check Volume!!!");
                          }
                       }

                    }
                  else
                     if(Level7==false && InpLevel7==true)///LEVEL 7 Fibonacci
                       {


                        if(lastTick.ask<=PL7)
                          {

                           if(trade.Buy(Vl7,NULL,lastTick.ask,0,lastTick.ask+TP7*_Point,"Order7 &Tp7"))
                             {
                              medierebuy=true;
                              Level7=true;//ba e nevoie
                              ContorM=7;
                              TicketNumber=trade.ResultOrder();
                             }
                           else
                             {
                              SendNotification("ERROR, Check Volume!!!");
                             }
                          }

                       }
                     else
                        if(Level8==false && InpLevel8==true)///LEVEL 7 Fibonacci
                          {


                           if(lastTick.ask<=PL8)
                             {

                              if(trade.Buy(Vl8,NULL,lastTick.ask,0,lastTick.ask+TP8*_Point,"Order8 &Tp8"))
                                {
                                 medierebuy=true;
                                 Level8=true;//ba e nevoie
                                 ContorM=8;
                                 TicketNumber=trade.ResultOrder();
                                }
                              else
                                {
                                 SendNotification("ERROR, Check Volume!!!");
                                }
                             }

                          }
                        else
                           if(Level9==false && InpLevel9==true)///LEVEL 7 Fibonacci
                             {


                              if(lastTick.ask<=PL9)
                                {

                                 if(trade.Buy(Vl9,NULL,lastTick.ask,0,lastTick.ask+TP9*_Point,"Order9 &Tp9"))
                                   {
                                    medierebuy=true;
                                    Level9=true;//ba e nevoie
                                    ContorM=9;
                                    TicketNumber=trade.ResultOrder();
                                   }
                                 else
                                   {
                                    SendNotification("ERROR, Check Volume!!!");
                                   }
                                }

                             }
                           else
                              if(Level10==false && InpLevel10==true)///LEVEL 10 Fibonacci
                                {


                                 if(lastTick.ask<=PL10)
                                   {

                                    if(trade.Buy(Vl10,NULL,lastTick.ask,0,lastTick.ask+TP10*_Point,"Order10 &Tp10"))
                                      {
                                       medierebuy=true;
                                       Level10=true;//ba e nevoie
                                       ContorM=10;
                                       TicketNumber=trade.ResultOrder();
                                      }
                                    else
                                      {
                                       SendNotification("ERROR, Check Volume!!!");
                                      }
                                   }

                                }
                              else
                                 if(Level11==false && InpLevel11==true)///LEVEL 11 Fibonacci
                                   {


                                    if(lastTick.ask<=PL11)
                                      {

                                       if(trade.Buy(Vl11,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order11 &Tp11"))
                                         {
                                          medierebuy=true;
                                          Level11=true;//ba e nevoie
                                          ContorM=11;
                                          TicketNumber=trade.ResultOrder();
                                         }
                                       else
                                         {
                                          SendNotification("ERROR, Check Volume!!!");
                                         }
                                      }

                                   }
                                 else
                                    if(Level12==false && InpLevel12==true)///LEVEL 7 Fibonacci
                                      {


                                       if(lastTick.ask<=PL12)
                                         {

                                          if(trade.Buy(Vl12,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order12 &Tp12"))
                                            {
                                             medierebuy=true;
                                             Level12=true;//ba e nevoie
                                             ContorM=12;
                                             TicketNumber=trade.ResultOrder();
                                            }
                                          else
                                            {
                                             SendNotification("ERROR, Check Volume!!!");
                                            }
                                         }

                                      }
                                    else
                                       if(Level13==false && InpLevel13==true)///LEVEL 7 Fibonacci
                                         {


                                          if(lastTick.ask<=PL13)
                                            {

                                             if(trade.Buy(Vl13,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order13 &Tp13"))
                                               {
                                                medierebuy=true;
                                                Level13=true;//ba e nevoie
                                                ContorM=13;
                                                TicketNumber=trade.ResultOrder();
                                               }
                                             else
                                               {
                                                SendNotification("ERROR, Check Volume!!!");
                                               }
                                            }

                                         }

                                       else
                                          if(Level14==false && InpLevel14==true)///LEVEL 7 Fibonacci
                                            {


                                             if(lastTick.ask<=PL14)
                                               {

                                                if(trade.Buy(Vl14,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order14 &Tp14"))
                                                  {
                                                   medierebuy=true;
                                                   Level14=true;//ba e nevoie
                                                   ContorM=14;
                                                   TicketNumber=trade.ResultOrder();
                                                  }
                                                else
                                                  {
                                                   SendNotification("ERROR, Check Volume!!!");
                                                  }
                                               }

                                            }
                                          else
                                             if(Level15==false && InpLevel15==true)///LEVEL 7 Fibonacci
                                               {


                                                if(lastTick.ask<=PL15)
                                                  {

                                                   if(trade.Buy(Vl15,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order15 &Tp15"))
                                                     {
                                                      medierebuy=true;
                                                      Level15=true;//ba e nevoie
                                                      ContorM=15;
                                                      TicketNumber=trade.ResultOrder();
                                                     }
                                                   else
                                                     {
                                                      SendNotification("ERROR, Check Volume!!!");
                                                     }
                                                  }

                                               }
                                             else
                                                if(Level16==false && InpLevel16==true)///LEVEL 7 Fibonacci
                                                  {


                                                   if(lastTick.ask<=PL16)
                                                     {

                                                      if(trade.Buy(Vl16,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order16 &Tp16"))
                                                        {
                                                         medierebuy=true;
                                                         Level16=true;//ba e nevoie
                                                         ContorM=16;
                                                         TicketNumber=trade.ResultOrder();
                                                        }
                                                      else
                                                        {
                                                         SendNotification("ERROR, Check Volume!!!");
                                                        }
                                                     }

                                                  }
                                                else
                                                   if(Level17==false && InpLevel17==true)///LEVEL 7 Fibonacci
                                                     {


                                                      if(lastTick.ask<=PL17)
                                                        {

                                                         if(trade.Buy(Vl17,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order17 &Tp17"))
                                                           {
                                                            medierebuy=true;
                                                            Level17=true;//ba e nevoie
                                                            ContorM=17;
                                                            TicketNumber=trade.ResultOrder();
                                                           }
                                                         else
                                                           {
                                                            SendNotification("ERROR, Check Volume!!!");
                                                           }
                                                        }

                                                     }
                                                   else
                                                      if(Level18==false && InpLevel18==true)///LEVEL 7 Fibonacci
                                                        {


                                                         if(lastTick.ask<=PL18)
                                                           {

                                                            if(trade.Buy(Vl18,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order18 &Tp18"))
                                                              {
                                                               medierebuy=true;
                                                               Level18=true;//ba e nevoie
                                                               ContorM=18;
                                                               TicketNumber=trade.ResultOrder();
                                                              }
                                                            else
                                                              {
                                                               SendNotification("ERROR, Check Volume!!!");
                                                              }
                                                           }

                                                        }
                                                      else
                                                         if(Level19==false && InpLevel19==true)///LEVEL 7 Fibonacci
                                                           {


                                                            if(lastTick.ask<=PL19)
                                                              {

                                                               if(trade.Buy(Vl19,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order19 &Tp19"))
                                                                 {
                                                                  medierebuy=true;
                                                                  Level19=true;//ba e nevoie
                                                                  ContorM=179;
                                                                  TicketNumber=trade.ResultOrder();
                                                                 }
                                                               else
                                                                 {
                                                                  SendNotification("ERROR, Check Volume!!!");
                                                                 }
                                                              }

                                                           }
   if(medierebuy==true)
     {
      double lastBuyTakeProfit=0.0,lastBuyPosition=0.0;
      if(PositionSelectByTicket(TicketNumber))
        {
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
           {
            lastBuyTakeProfit = PositionGetDouble(POSITION_TP);
            lastBuyPosition=PositionGetDouble(POSITION_PRICE_CURRENT);
           }
        }
      if(lastBuyTakeProfit==lastBuyPosition)
        {
         CloseBuyPositions();
         CONTOR=0;
         medierebuy=false;
         Level1=false;
         Level2=false;
         Level3=false;
         Level4=false;
         Level5=false;
         Level6=false;
         Level7=false;
         Level8=false;
         Level9=false;
         Level10=false;
         Level11=false;
         Level12=false;
         Level13=false;
         Level14=false;
         Level15=false;
         Level16=false;
         Level17=false;
         Level18=false;
         Level19=false;
        }

     }

   double Account_Profit=AccountInfoDouble(ACCOUNT_PROFIT);
   if(InpTakeProfitMode==true && Account_Profit>=InpTakeProfitAll)
     {
      CloseBuyPositions();
      CONTOR=0;
      medierebuy=false;
      Level1=false;
      Level2=false;
      Level3=false;
      Level4=false;
      Level5=false;
      Level6=false;
      Level7=false;
      Level8=false;
      Level9=false;
      Level10=false;
      Level11=false;
      Level12=false;
      Level13=false;
      Level14=false;
      Level15=false;
      Level16=false;
      Level17=false;
      Level18=false;
      Level19=false;

     }
   if(InpStopLossMode==STOP_LOSS_MONEY)
     {
      if(InpStopLossAll*(-1)>=AccountInfoDouble(ACCOUNT_PROFIT))
        {
         //close LONG
         CloseBuyPositions();
         CONTOR=0;
         medierebuy=false;
         Level1=false;
         Level2=false;
         Level3=false;
         Level4=false;
         Level5=false;
         Level6=false;
         Level7=false;
         Level8=false;
         Level9=false;
         Level10=false;
         Level11=false;
         Level12=false;
         Level13=false;
         Level14=false;
         Level15=false;
         Level16=false;
         Level17=false;
         Level18=false;
         Level19=false;
        }
     }
   if(InpStopLossMode==STOP_LOSS_PERCENT)
     {
      if((InpStopLossAll*AccountInfoDouble(ACCOUNT_BALANCE))/100*(-1)>=AccountInfoDouble(ACCOUNT_PROFIT))
        {
         //close LONG
         CloseBuyPositions();
         CONTOR=0;
         medierebuy=false;
         Level1=false;
         Level2=false;
         Level3=false;
         Level4=false;
         Level5=false;
         Level6=false;
         Level7=false;
         Level8=false;
         Level9=false;
         Level10=false;
         Level11=false;
         Level12=false;
         Level13=false;
         Level14=false;
         Level15=false;
         Level16=false;
         Level17=false;
         Level18=false;
         Level19=false;
        }
     }
   if(InpNotifications==true && InpStopLossAll*(-1)>=AccountInfoDouble(ACCOUNT_PROFIT))
     {
      SendNotification("Drawdown > StopLossAll!");
     }

   if(InpNotifications==true && AccountInfoDouble(ACCOUNT_PROFIT)>=InpTakeProfitAll)
     {
      SendNotification("P&L Profit > TakeProfitAll!");
     }
  }
//Bolugi_Short
void Bolugi_Short()
  {
   static double NextSellPrice=0;

   double Lots= CalculateLots(InpLots);

   if(CONTORS==0)
     {
      NextSellPrice=0;
      if(trade.Sell(Lots,NULL,lastTick.bid,0,0,"COMPLEMENTARE SELL"))
        {
         TicketNumberS1=trade.ResultOrder();
         RangeMS0=lastTick.bid;
         CONTORS=1;
         NextSellPrice=RangeMS0-InpStepC*_Point;
        }

     }
   for(int i=0; i<CountOpenPositions(); i++)
     {
      ulong currTicket=PositionGetTicket(i);
      if(currTicket!=TicketNumberS1)
        {
         Print("ticket!=TicketNumberS1",currTicket);
        }
      else
        {
         if(!PositionSelectByTicket(TicketNumberS1))
           {
            Print("Cannot get ticket number1!");
           }
         else
           {
            PL0S=PositionGetDouble(POSITION_PRICE_OPEN);
           }
        }

     }
//OPEN SELLS
   if(lastTick.bid<=NextSellPrice  && medieresell==false)
     {
      if(trade.Sell(Lots,NULL,lastTick.bid,0,0,"COMPLEMENTARE SELL"))
        {
         //a deschis poziti
         RangeMS0=lastTick.bid;
         NextSellPrice=RangeMS0-InpStepCS*_Point;// averificat range
         TicketNumberS=trade.ResultOrder();
         CONTORS++;
        }
     }
   Print("NextSellPrice",NextSellPrice);

//SHORT PL0S
   if(InpTPSMode==true)
     {
      PL1S=NormalizeDouble(PL0S+((23.60*InpRangeMS)/100*_Point+TPS1*_Point),_Digits);
   PL2S=NormalizeDouble(PL0S+((38.20*InpRangeMS)/100*_Point+TPS2*_Point),_Digits);
   PL3S=NormalizeDouble(PL0S+((50.0*InpRangeMS)/100*_Point+TPS3*_Point),_Digits);
   PL4S=NormalizeDouble(PL0S+((61.80*InpRangeMS)/100*_Point+TPS4*_Point),_Digits);
   PL5S=NormalizeDouble(PL0S+((78.80*InpRangeMS)/100*_Point+TPS5*_Point),_Digits);
   PL6S=NormalizeDouble(PL0S+((88.20*InpRangeMS)/100*_Point+TPS6*_Point),_Digits);
   PL7S=NormalizeDouble(PL0S+(InpRangeMS*_Point+TPS7*_Point),_Digits);
   PL8S=NormalizeDouble(PL0S+((127.20*InpRangeMS)/100*_Point+TPS8*_Point),_Digits);
   PL9S=NormalizeDouble(PL0S+((161.80*InpRangeMS)/100*_Point+TPS9*_Point),_Digits);
   PL10S=NormalizeDouble(PL0S+((200.00*InpRangeMS)/100*_Point+TPS10*_Point),_Digits);
     }
   PL1S=NormalizeDouble(PL0S+((23.60*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
   PL2S=NormalizeDouble(PL0S+((38.20*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
   PL3S=NormalizeDouble(PL0S+((50.0*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
   PL4S=NormalizeDouble(PL0S+((61.80*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
   PL5S=NormalizeDouble(PL0S+((78.80*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
   PL6S=NormalizeDouble(PL0S+((88.20*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
   PL7S=NormalizeDouble(PL0S+(InpRangeMS*_Point+InpDistTakeProfitS*_Point),_Digits);
   PL8S=NormalizeDouble(PL0S+((127.20*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
   PL9S=NormalizeDouble(PL0S+((161.80*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
   PL10S=NormalizeDouble(PL0S+((200.00*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);


//SHORT FUNCITON
   if(InpTPSMode==true)
     {
      Calculate_V1S();
      Calculate_V2MS();
      Calculate_V3MS();
      Calculate_V4MS();
      Calculate_V5MS();
      Calculate_V6MS();
      Calculate_V7MS();
      Calculate_V8MS();
      Calculate_V9MS();
      Calculate_V10MS();
     }
   else
     {
      Calculate_V1S();
      Calculate_V2S();
      Calculate_V3S();
      Calculate_V4S();
      Calculate_V5S();
      Calculate_V6S();
      Calculate_V7S();
      Calculate_V8S();
      Calculate_V9S();
      Calculate_V10S();

     }
   if(InpTPSMode==false)
     {
      TPS2=TPS1;
      TPS3=TPS1;
      TPS4=TPS1;
      TPS5=TPS1;
      TPS6=TPS1;
      TPS7=TPS1;
      TPS8=TPS1;
      TPS9=TPS1;
      TPS10=TPS1;

     }
   if(InpLevel1S==false)
     {
      PL1S=PL2S;
      Calculate_V2S();
      PL1S=PL3S;
      Calculate_V3S();
      PL1S=PL4S;
      Calculate_V4S();
      PL1S=PL5S;
      Calculate_V5S();
      PL1S=PL6S;
      Calculate_V6S();
      PL1S=PL7S;
      Calculate_V7S();
      PL1S=PL8S;
      Calculate_V8S();
      PL1S=PL9S;
      Calculate_V9S();
     }
   if(InpLevel2S==false)
     {
      PL2S=PL3S;
      Calculate_V3S();
      PL2S=PL4S;
      Calculate_V4S();
      PL2S=PL5S;
      Calculate_V5S();
      PL2S=PL6S;
      Calculate_V6S();
      PL2S=PL7S;
      Calculate_V7S();
      PL2S=PL8S;
      Calculate_V8S();
      PL2S=PL9S;
      Calculate_V9S();
     }
   if(InpLevel3S==false)
     {
      PL3S=PL4S;
      Calculate_V4S();
      PL3S=PL5S;
      Calculate_V5S();
      PL3S=PL6S;
      Calculate_V6S();
      PL3S=PL7S;
      Calculate_V7S();
      PL3S=PL8S;
      Calculate_V8S();
      PL3S=PL9S;
      Calculate_V9S();
     }
   if(InpLevel4S==false)
     {
      PL4S=PL5S;
      Calculate_V5S();
      PL4S=PL6S;
      Calculate_V6S();
      PL4S=PL7S;
      Calculate_V7S();
      PL4S=PL8S;
      Calculate_V8S();
      PL4S=PL9S;
      Calculate_V9S();
     }
   if(InpLevel5S==false)
     {
      PL5S=PL6S;
      Calculate_V6S();
      PL5S=PL7S;
      Calculate_V7S();
      PL5S=PL8S;
      Calculate_V8S();
      PL5S=PL9S;
      Calculate_V9S();
     }
   if(InpLevel6S==false)
     {
      PL6S=PL7S;
      Calculate_V7S();
      PL6S=PL8S;
      Calculate_V8S();
      PL6S=PL9S;
      Calculate_V9S();
     }

   if(InpLevel7S==false)
     {
      PL7S=PL8S;
      Calculate_V8S();
      PL7S=PL9S;
      Calculate_V9S();
     }
   if(InpLevel8S==false)
     {
      PL8S=PL9S;
      Calculate_V9S();
     }

//Normalize Indices Volumes
   if(InpTradingInstrument==TRADING_INDICES)
     {
      //Short
      Vl1S = NormalizeDouble(Vl1S, 1);
      Vl2S = NormalizeDouble(Vl2S, 1);
      Vl3S = NormalizeDouble(Vl3S, 1);
      Vl4S = NormalizeDouble(Vl4S, 1);
      Vl5S = NormalizeDouble(Vl5S, 1);
      Vl6S = NormalizeDouble(Vl6S, 1);
      Vl7S = NormalizeDouble(Vl7S, 1);
      Vl8S = NormalizeDouble(Vl8S, 1);
      Vl9S = NormalizeDouble(Vl9S, 1);
     

     }

//SHORT
   Print("PL0S ",PL0S);
   Print("PL1S ", PL1S);
   Print("PL2S ", PL2S);
   Print("PL3S ", PL3S);
   Print("PL4S ", PL4S);
   Print("PL5S ", PL5S);
   Print("PL6S ", PL6S);
   Print("PL7S ", PL7S);
   Print("PL8S ", PL8S);
   Print("PL9S ", PL9S);
 
   Comment("CONTORS:",CONTORS);
   Comment("NexSellPrice: ",NextSellPrice,"\n");

//complementare sell
   if(CountOpenPositions()>=4 && medieresell==false && CONTORS>=4)
     {
      complementaresell=true;
      if(PositionSelectByTicket(TicketNumberS))
        {
         if(PositionGetDouble(POSITION_SL)==0)
           {
            trade.PositionModify(TicketNumberS,(RangeMS0+(InpStopLossS*_Point)),0);
           }
        }

     }

//afara din complementar SELL if statement set the trailing stop loss
   if(medieresell==false && complementaresell==true)
     {
      double lastBuyStopLossS=0.0,lastBuyPositionS=0.0,currPS=0.0;
      if(PositionSelectByTicket(TicketNumberS))
        {
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
           {
            lastBuyStopLossS = PositionGetDouble(POSITION_SL);//1.20563 modifica 1.20583
            lastBuyPositionS=PositionGetDouble(POSITION_PRICE_OPEN);//1.20613
            currPS=PositionGetDouble(POSITION_PRICE_CURRENT);//1.20612 20pips
           }

        }
      static double TrailPriceS=NormalizeDouble(lastBuyStopLossS-InpTrailStopS*_Point-InpStopLossS*_Point,_Digits);
      if(lastTick.bid<=TrailPriceS)
        {
         if(PositionSelectByTicket(TicketNumberS))
           {
            trade.PositionModify(TicketNumberS,NormalizeDouble(lastBuyStopLossS+InpTrailStopS*_Point,_Digits),0);
            TrailPriceS=NormalizeDouble(TrailPriceS-InpTrailStopS*_Point,_Digits);
           }

        }
      if(lastBuyStopLossS==currPS)
        {
         CloseSellPositions();
         CONTORS=0;
         complementaresell=false;
         if(PositionSelectByTicket(TicketNumberS))
           {
            trade.PositionModify(TicketNumberS,0,0);
           }
        }
     }
   if(PL0S==0.0)
     {
      Alert("Atentie PLS0 e 0.0");
     }
//LevelS1=true;
//medieresell
   if(LevelS1==false && InpLevel1S==true) ///LEVEL 1 Fibonacci
     {

      if(lastTick.bid>=PL1S)
        {

         if(trade.Sell(Vl1S,NULL,lastTick.bid,0,lastTick.bid-TPS1*_Point,"Order1 & TP1 SELL"))
           {
            LevelS1=true;
            medieresell=true;
            complementaresell=false;
            TicketNumberS=trade.ResultOrder();
           }
         else
           {
            SendNotification("ERROR, Check Volume!!!");
           }
        }

     }
   else
      if(LevelS2==false &&InpLevel2S==true)///LEVEL 2 Fibonacci
        {
         if(lastTick.bid>=PL2S)
           {

            if(trade.Sell(Vl2S,NULL,lastTick.bid,0,lastTick.bid-TPS2*_Point,"Order2 & TP2 SELL"))
              {
               LevelS2=true;
               medieresell=true;
               ContorM=2;
               TicketNumberS=trade.ResultOrder();
              }
            else
              {
               SendNotification("ERROR, Check Volume!!!");
              }
           }
        }

      else
         if(LevelS3==false &&InpLevel3S==true)///LEVEL 3 Fibonacci
           {

            if(lastTick.bid>=PL3S)
              {

               if(trade.Sell(Vl3S,NULL,lastTick.bid,0,lastTick.bid-TPS3*_Point,"Order3 &Tp3 SELL"))
                 {
                  LevelS3=true;
                  medieresell=true;
                  ContorM=3;
                  TicketNumberS=trade.ResultOrder();
                 }
               else
                 {
                  SendNotification("ERROR, Check Volume!!!");
                 }
              }

           }
         else
            if(LevelS4==false && InpLevel4S==true)///LEVEL 4 Fibonacci
              {


               if(lastTick.bid>=PL4S)
                 {

                  if(trade.Sell(Vl4S,NULL,lastTick.bid,0,lastTick.bid-TPS4*_Point,"Order4 &Tp4 SELL"))
                    {
                     LevelS4=true;
                     medieresell=true;
                     ContorM=4;
                     TicketNumberS=trade.ResultOrder();
                    }
                  else
                    {
                     SendNotification("ERROR, Check Volume!!!");
                    }
                 }

              }
            else
               if(LevelS5==false && InpLevel5S==true)///LEVEL 5 Fibonacci
                 {


                  if(lastTick.bid>=PL5S)
                    {

                     if(trade.Sell(Vl5S,NULL,lastTick.bid,0,lastTick.bid-TPS5*_Point,"Order5 &Tp5 SELL"))
                       {
                        medieresell=true;
                        LevelS5=true;
                        ContorM=5;
                        TicketNumberS=trade.ResultOrder();
                       }
                     else
                       {
                        SendNotification("ERROR, Check Volume!!!");
                       }
                    }


                 }
               else
                  if(LevelS6==false && InpLevel6S==true)///LEVEL 6 Fibonacci
                    {

                     if(lastTick.bid>=PL6S)
                       {

                        if(trade.Sell(Vl6S,NULL,lastTick.bid,0,lastTick.bid-TPS6*_Point,"Order6 &Tp6 SELL"))
                          {
                           medieresell=true;
                           LevelS6=true;
                           ContorM=6;
                           TicketNumberS=trade.ResultOrder();
                          }
                        else
                          {
                           SendNotification("ERROR, Check Volume!!!");
                          }
                       }

                    }
                  else
                     if(LevelS7==false && InpLevel7S==true)///LEVEL 7 Fibonacci
                       {


                        if(lastTick.bid>=PL7S)
                          {

                           if(trade.Sell(Vl7S,NULL,lastTick.bid,0,lastTick.bid-TPS7*_Point,"Order7 &Tp7 SELL"))
                             {
                              medieresell=true;
                              LevelS7=true;//ba e nevoie
                              ContorM=7;
                              TicketNumberS=trade.ResultOrder();
                             }
                           else
                             {
                              SendNotification("ERROR, Check Volume!!!");
                             }
                          }

                       }
                     else
                        if(LevelS8==false && InpLevel8S==true) ///LEVEL 8 Fibonacci
                          {


                           if(lastTick.bid>=PL8S)
                             {

                              if(trade.Sell(Vl8S,NULL,lastTick.bid,0,lastTick.bid-TPS8*_Point,"Order8 &Tp8 SELL"))
                                {
                                 medieresell=true;
                                 LevelS8=true;//ba e nevoie
                                 ContorM=8;
                                 TicketNumberS=trade.ResultOrder();
                                }
                              else
                                {
                                 SendNotification("ERROR, Check Volume!!!");
                                }
                             }

                          }
                        else
                           if(LevelS9==false && InpLevel9S==true)///LEVEL 9 Fibonacci
                             {


                              if(lastTick.bid>=PL9S)
                                {

                                 if(trade.Sell(Vl9S,NULL,lastTick.bid,0,lastTick.bid-TPS9*_Point,"Order9 &Tp9 SELL"))
                                   {
                                    medieresell=true;
                                    LevelS9=true;//ba e nevoie
                                    ContorM=9;
                                    TicketNumberS=trade.ResultOrder();
                                   }
                                 else
                                   {
                                    SendNotification("ERROR, Check Volume!!!");
                                   }
                                }

                             }
                           else
                              if(LevelS10==false && InpLevel10S==true)///LEVEL 7 Fibonacci
                                {


                                 if(lastTick.bid>=PL10S)
                                   {

                                    if(trade.Sell(Vl10S,NULL,lastTick.bid,0,lastTick.bid-TPS10*_Point,"Order10 &Tp10 SELL"))
                                      {
                                       medieresell=true;
                                       LevelS10=true;//ba e nevoie
                                       ContorM=10;
                                       TicketNumberS=trade.ResultOrder();
                                      }
                                    else
                                      {
                                       SendNotification("ERROR, Check Volume!!!");
                                      }
                                   }

                                }
                              else
                                 if(LevelS11==false && InpLevel11S==true)///LEVEL 7 Fibonacci
                                   {


                                    if(lastTick.bid>=PL11S)
                                      {

                                       if(trade.Sell(Vl11S,NULL,lastTick.bid,0,lastTick.bid-InpDistTakeProfitS*_Point,"Order11 &Tp11 SELL"))
                                         {
                                          medieresell=true;
                                          LevelS11=true;//ba e nevoie
                                          ContorM=11;
                                          TicketNumberS=trade.ResultOrder();
                                         }
                                       else
                                         {
                                          SendNotification("ERROR, Check Volume!!!");
                                         }
                                      }

                                   }
                                 else
                                    if(LevelS12==false && InpLevel12S==true)///LEVEL 7 Fibonacci
                                      {


                                       if(lastTick.bid>=PL12S)
                                         {

                                          if(trade.Sell(Vl12S,NULL,lastTick.bid,0,lastTick.bid-InpDistTakeProfitS*_Point,"Order12 &Tp12 SELL"))
                                            {
                                             medieresell=true;
                                             LevelS12=true;//ba e nevoie
                                             ContorM=12;
                                             TicketNumberS=trade.ResultOrder();
                                            }
                                          else
                                            {
                                             SendNotification("ERROR, Check Volume!!!");
                                            }
                                         }

                                      }
                                    else
                                       if(LevelS13==false && InpLevel13S==true)///LEVEL 7 Fibonacci
                                         {


                                          if(lastTick.bid>=PL13S)
                                            {

                                             if(trade.Sell(Vl13S,NULL,lastTick.bid,0,lastTick.bid-InpDistTakeProfitS*_Point,"Order13 &Tp13 SELL"))
                                               {
                                                medieresell=true;
                                                LevelS13=true;//ba e nevoie
                                                ContorM=13;
                                                TicketNumberS=trade.ResultOrder();
                                               }
                                             else
                                               {
                                                SendNotification("ERROR, Check Volume!!!");
                                               }
                                            }

                                         }

                                       else
                                          if(LevelS14==false && InpLevel14S==true)///LEVEL 7 Fibonacci
                                            {


                                             if(lastTick.bid>=PL14S)
                                               {

                                                if(trade.Sell(Vl14S,NULL,lastTick.bid,0,lastTick.bid-InpDistTakeProfitS*_Point,"Order14 &Tp14 SELL"))
                                                  {
                                                   medieresell=true;
                                                   LevelS14=true;//ba e nevoie
                                                   ContorM=14;
                                                   TicketNumberS=trade.ResultOrder();
                                                  }
                                                else
                                                  {
                                                   SendNotification("ERROR, Check Volume!!!");
                                                  }
                                               }

                                            }
                                          else
                                             if(LevelS15==false && InpLevel15S==true)///LEVEL 7 Fibonacci
                                               {


                                                if(lastTick.bid>=PL15S)
                                                  {

                                                   if(trade.Sell(Vl15S,NULL,lastTick.bid,0,lastTick.bid-InpDistTakeProfitS*_Point,"Order15 &Tp15 SELL"))
                                                     {
                                                      medieresell=true;
                                                      LevelS15=true;//ba e nevoie
                                                      ContorM=15;
                                                      TicketNumberS=trade.ResultOrder();
                                                     }
                                                   else
                                                     {
                                                      SendNotification("ERROR, Check Volume!!!");
                                                     }
                                                  }

                                               }
                                             else
                                                if(LevelS16==false && InpLevel16S==true)///LEVEL 7 Fibonacci
                                                  {


                                                   if(lastTick.bid>=PL16S)
                                                     {

                                                      if(trade.Sell(Vl16S,NULL,lastTick.bid,0,lastTick.bid-InpDistTakeProfitS*_Point,"Order16 &Tp16 SELL"))
                                                        {
                                                         medieresell=true;
                                                         LevelS16=true;//ba e nevoie
                                                         ContorM=16;
                                                         TicketNumberS=trade.ResultOrder();
                                                        }
                                                      else
                                                        {
                                                         SendNotification("ERROR, Check Volume!!!");
                                                        }
                                                     }

                                                  }
                                                else
                                                   if(LevelS17==false && InpLevel17S==true)///LEVEL 7 Fibonacci
                                                     {


                                                      if(lastTick.bid>=PL17S)
                                                        {

                                                         if(trade.Sell(Vl17S,NULL,lastTick.bid,0,lastTick.bid-InpDistTakeProfitS*_Point,"Order17 &Tp17 SELL"))
                                                           {
                                                            medieresell=true;
                                                            LevelS17=true;//ba e nevoie
                                                            ContorM=17;
                                                            TicketNumberS=trade.ResultOrder();
                                                           }
                                                         else
                                                           {
                                                            SendNotification("ERROR, Check Volume!!!");
                                                           }
                                                        }

                                                     }
                                                   else
                                                      if(LevelS18==false && InpLevel18S==true)///LEVEL 7 Fibonacci
                                                        {


                                                         if(lastTick.bid>=PL18S)
                                                           {

                                                            if(trade.Sell(Vl18S,NULL,lastTick.bid,0,lastTick.bid-InpDistTakeProfitS*_Point,"Order18 &Tp18 SELL"))
                                                              {
                                                               medieresell=true;
                                                               LevelS18=true;//ba e nevoie
                                                               ContorM=18;
                                                               TicketNumberS=trade.ResultOrder();
                                                              }
                                                            else
                                                              {
                                                               SendNotification("ERROR, Check Volume!!!");
                                                              }
                                                           }

                                                        }
                                                      else
                                                         if(LevelS19==false && InpLevel19S==true)///LEVEL 7 Fibonacci
                                                           {


                                                            if(lastTick.bid>=PL19S)
                                                              {

                                                               if(trade.Sell(Vl19S,NULL,lastTick.bid,0,lastTick.bid-InpDistTakeProfitS*_Point,"Order19 &Tp19 SELL"))
                                                                 {
                                                                  LevelS19=true;//ba e nevoie
                                                                  ContorM=19;
                                                                  TicketNumberS=trade.ResultOrder();
                                                                 }
                                                               else
                                                                 {
                                                                  SendNotification("ERROR, Check Volume!!!");
                                                                 }
                                                              }

                                                           }
   if(medieresell==true)
     {
      double lastBuyTakeProfitS=0.0,lastBuyPositionS=0.0;
      if(PositionSelectByTicket(TicketNumberS))
        {
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
           {
            lastBuyTakeProfitS = PositionGetDouble(POSITION_TP);
            lastBuyPositionS=PositionGetDouble(POSITION_PRICE_CURRENT);
           }
        }
      if(lastBuyTakeProfitS==lastBuyPositionS)
        {
         CloseSellPositions();
         CONTORS=0;
         medieresell=false;
         LevelS1=false;
         LevelS2=false;
         LevelS3=false;
         LevelS4=false;
         LevelS5=false;
         LevelS6=false;
         LevelS7=false;
         LevelS8=false;
         LevelS9=false;
         LevelS10=false;
         LevelS11=false;
         LevelS12=false;
         LevelS13=false;
         LevelS14=false;
         LevelS15=false;
         LevelS16=false;
         LevelS17=false;
         LevelS18=false;
         LevelS19=false;
        }

     }
   double Account_Profit=AccountInfoDouble(ACCOUNT_PROFIT);
   if(InpTakeProfitMode==true && Account_Profit>=InpTakeProfitAll)
     {
      CloseSellPositions();
      CONTORS=0;
      medieresell=false;
      LevelS1=false;
      LevelS2=false;
      LevelS3=false;
      LevelS4=false;
      LevelS5=false;
      LevelS6=false;
      LevelS7=false;
      LevelS8=false;
      LevelS9=false;
      LevelS10=false;
      LevelS11=false;
      LevelS12=false;
      LevelS13=false;
      LevelS14=false;
      LevelS15=false;
      LevelS16=false;
      LevelS17=false;
      LevelS18=false;
      LevelS19=false;
     }
   if(InpStopLossMode==STOP_LOSS_MONEY)
     {
      if(InpStopLossAll*(-1)>=AccountInfoDouble(ACCOUNT_PROFIT))
        {

         //close short
         CloseSellPositions();
         CONTORS=0;
         medieresell=false;
         LevelS1=false;
         LevelS2=false;
         LevelS3=false;
         LevelS4=false;
         LevelS5=false;
         LevelS6=false;
         LevelS7=false;
         LevelS8=false;
         LevelS9=false;
         LevelS10=false;
         LevelS11=false;
         LevelS12=false;
         LevelS13=false;
         LevelS14=false;
         LevelS15=false;
         LevelS16=false;
         LevelS17=false;
         LevelS18=false;
         LevelS19=false;
        }
     }
   if(InpStopLossMode==STOP_LOSS_PERCENT)
     {
      if((InpStopLossAll*AccountInfoDouble(ACCOUNT_BALANCE))/100*(-1)>=AccountInfoDouble(ACCOUNT_PROFIT))
        {

         //close short
         CloseSellPositions();
         CONTORS=0;
         medieresell=false;
         LevelS1=false;
         LevelS2=false;
         LevelS3=false;
         LevelS4=false;
         LevelS5=false;
         LevelS6=false;
         LevelS7=false;
         LevelS8=false;
         LevelS9=false;
         LevelS10=false;
         LevelS11=false;
         LevelS12=false;
         LevelS13=false;
         LevelS14=false;
         LevelS15=false;
         LevelS16=false;
         LevelS17=false;
         LevelS18=false;
         LevelS19=false;
        }
     }
  }



//Bolugi Long_Short function
void Bolugi_Long_Short()
  {
   static double NextBuyPrice,NextSellPrice;

   double Lots= CalculateLots(InpLots);

   if(CONTOR==0)
     {
      NextBuyPrice=0;
      if(trade.Buy(Lots,NULL,lastTick.ask,0,0,"COMPLEMENTARE BUY"))
        {
         TicketNumber1=trade.ResultOrder();
         RangeMB0=lastTick.ask;
         CONTOR=1;
         NextBuyPrice=RangeMB0+InpStepC*_Point;
        }
     }
   if(CONTORS==0)
     {
      NextSellPrice=0;
      if(trade.Sell(Lots,NULL,lastTick.bid,0,0,"COMPLEMENTARE SELL"))
        {
         TicketNumberS1=trade.ResultOrder();
         RangeMS0=lastTick.bid;
         CONTORS=1;
         NextSellPrice=RangeMS0-InpStepC*_Point;
        }

     }


//SELECT PL0 FOR BUY
   for(int i=0; i<CountOpenPositions(); i++)
     {
      ulong currTicket=PositionGetTicket(i);
      if(currTicket!=TicketNumber1)
        {
         Print("ticket!=TicketNumber1",currTicket);
        }
      else
        {
         if(!PositionSelectByTicket(TicketNumber1))
           {
            Print("Cannot get ticket number1!");
           }
         else
           {
            PL0=PositionGetDouble(POSITION_PRICE_OPEN);
           }
        }

     }
//SELECT PLS0 FOR SELL
   for(int i=0; i<CountOpenPositions(); i++)
     {
      ulong currTicket=PositionGetTicket(i);
      if(currTicket!=TicketNumberS1)
        {
         Print("ticket!=TicketNumberS1",currTicket);
        }
      else
        {
         if(!PositionSelectByTicket(TicketNumberS1))
           {
            Print("Cannot get ticket number1!");
           }
         else
           {
            PL0S=PositionGetDouble(POSITION_PRICE_OPEN);
           }
        }

     }
//OPEN BUYS
   if(lastTick.ask>=NextBuyPrice  && medierebuy==false)
     {
      if(trade.Buy(Lots,NULL,lastTick.ask,0,0,"COMPLEMENTARE BUY"))
        {
         //a deschis poziti
         RangeMB0=lastTick.ask;
         NextBuyPrice=RangeMB0+InpStepC*_Point;// averificat range
         TicketNumber=trade.ResultOrder();
         CONTOR++;
        }
     }
   Comment("NextBuyPrice",NextBuyPrice);
//OPEN SELLS
   if(lastTick.bid<=NextSellPrice  && medieresell==false)
     {
      if(trade.Sell(Lots,NULL,lastTick.bid,0,0,"COMPLEMENTARE SELL"))
        {
         //a deschis poziti
         RangeMS0=lastTick.bid;
         NextSellPrice=RangeMS0-InpStepCS*_Point;// averificat range
         TicketNumberS=trade.ResultOrder();
         CONTORS++;
        }
     }
   Comment("NextSellPrice",NextSellPrice);
//+------------------------------------------------------------------+
//| LEVELE FIBONACCI                                             |
//+------------------------------------------------------------------+
//LONG
   if(InpTPMode==true)
     {
      PL1=NormalizeDouble(PL0-((23.60*InpRangeM)/100*_Point+TP1*_Point),_Digits);
      PL2=NormalizeDouble(PL0-((38.20*InpRangeM)/100*_Point+TP2*_Point),_Digits);
      PL3=NormalizeDouble(PL0-((50.0*InpRangeM)/100*_Point+TP3*_Point),_Digits);
      PL4=NormalizeDouble(PL0-((61.80*InpRangeM)/100*_Point+TP4*_Point),_Digits);
      PL5=NormalizeDouble(PL0-((78.60*InpRangeM)/100*_Point+TP5*_Point),_Digits);
      PL6=NormalizeDouble(PL0-((88.20*InpRangeM)/100*_Point+TP6*_Point),_Digits);
      PL7=NormalizeDouble(PL0-(InpRangeM*_Point+TP7*_Point),_Digits);
      PL8=NormalizeDouble(PL0-((127.20*InpRangeM)/100*_Point+TP8*_Point),_Digits);
      PL9=NormalizeDouble(PL0-((161.80*InpRangeM)/100*_Point+TP9*_Point),_Digits);
      PL10=NormalizeDouble(PL0-((200.00*InpRangeM)/100*_Point+TP10*_Point),_Digits);
     }
   PL1=NormalizeDouble(PL0-((23.60*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL2=NormalizeDouble(PL0-((38.20*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL3=NormalizeDouble(PL0-((50.0*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL4=NormalizeDouble(PL0-((61.80*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL5=NormalizeDouble(PL0-((78.60*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL6=NormalizeDouble(PL0-((88.20*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL7=NormalizeDouble(PL0-(InpRangeM*_Point+InpDistTakeProfit*_Point),_Digits);
   PL8=NormalizeDouble(PL0-((127.20*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL9=NormalizeDouble(PL0-((161.80*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL10=NormalizeDouble(PL0-((200.00*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL11=NormalizeDouble(PL0-((227.20*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL12=NormalizeDouble(PL0-((261.80*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL13=NormalizeDouble(PL0-((300.00*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL14=NormalizeDouble(PL0-((327.20*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL15=NormalizeDouble(PL0-((361.80*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL16=NormalizeDouble(PL0-((400.00*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL17=NormalizeDouble(PL0-((427.20*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL18=NormalizeDouble(PL0-((461.80*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL19=NormalizeDouble(PL0-((500.00*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
//SHORT PL0S
   if(InpTPSMode==true)
     {
      PL1S=NormalizeDouble(PL0S+((23.60*InpRangeMS)/100*_Point+TPS1*_Point),_Digits);
      PL2S=NormalizeDouble(PL0S+((38.20*InpRangeMS)/100*_Point+TPS2*_Point),_Digits);
      PL3S=NormalizeDouble(PL0S+((50.0*InpRangeMS)/100*_Point+TPS3*_Point),_Digits);
      PL4S=NormalizeDouble(PL0S+((61.80*InpRangeMS)/100*_Point+TPS4*_Point),_Digits);
      PL5S=NormalizeDouble(PL0S+((78.60*InpRangeMS)/100*_Point+TPS5*_Point),_Digits);
      PL6S=NormalizeDouble(PL0S+((88.20*InpRangeMS)/100*_Point+TPS6*_Point),_Digits);
      PL7S=NormalizeDouble(PL0S+(InpRangeMS*_Point+TPS7*_Point),_Digits);
      PL8S=NormalizeDouble(PL0S+((127.20*InpRangeMS)/100*_Point+TPS8*_Point),_Digits);
      PL9S=NormalizeDouble(PL0S+((161.80*InpRangeMS)/100*_Point+TPS9*_Point),_Digits);
      PL10S=NormalizeDouble(PL0S+((200.00*InpRangeMS)/100*_Point+TPS10*_Point),_Digits);
     }
   PL1S=NormalizeDouble(PL0S+((23.60*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
   PL2S=NormalizeDouble(PL0S+((38.20*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
   PL3S=NormalizeDouble(PL0S+((50.0*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
   PL4S=NormalizeDouble(PL0S+((61.80*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
   PL5S=NormalizeDouble(PL0S+((78.60*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
   PL6S=NormalizeDouble(PL0S+((88.20*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
   PL7S=NormalizeDouble(PL0S+(InpRangeMS*_Point+InpDistTakeProfitS*_Point),_Digits);
   PL8S=NormalizeDouble(PL0S+((127.20*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
   PL9S=NormalizeDouble(PL0S+((161.80*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
   PL10S=NormalizeDouble(PL0S+((200.00*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
  
//LONG FUNCTION
   if(InpTPMode==true)
     {
      Calculate_V1();
      Calculate_V2M();
      Calculate_V3M();
      Calculate_V4M();
      Calculate_V5M();
      Calculate_V6M();
      Calculate_V7M();
      Calculate_V8M();
      Calculate_V9M();
      Calculate_V10M();
     }
   else
     {
      Calculate_V1();
      Calculate_V2();
      Calculate_V3();
      Calculate_V4();
      Calculate_V5();
      Calculate_V6();
      Calculate_V7();
      Calculate_V8();
      Calculate_V9();
      Calculate_V10();

     }
   if(InpTPMode==false)
     {
      TP2=TP1;
      TP3=TP1;
      TP4=TP1;
      TP5=TP1;
      TP6=TP1;
      TP7=TP1;
      TP8=TP1;
      TP9=TP1;
      TP10=TP1;
     }
   if(InpLevel1==false)
     {
      PL1=PL2;
      Calculate_V2();
      PL1=PL3;
      Calculate_V3();
      PL1=PL4;
      Calculate_V4();
      PL1=PL5;
      Calculate_V5();
      PL1=PL6;
      Calculate_V6();
      PL1=PL7;
      Calculate_V7();
      PL1=PL8;
      Calculate_V8();
      PL1=PL9;
      Calculate_V9();

     }
   if(InpLevel2==false)
     {
      PL2=PL3;
      Calculate_V3();
      PL2=PL4;
      Calculate_V4();
      PL2=PL5;
      Calculate_V5();
      PL2=PL6;
      Calculate_V6();
      PL2=PL7;
      Calculate_V7();
      PL2=PL8;
      Calculate_V8();
      PL2=PL9;
      Calculate_V9();
     }
   if(InpLevel3==false)
     {
      PL3=PL4;
      Calculate_V4();
      PL3=PL5;
      Calculate_V5();
      PL3=PL6;
      Calculate_V6();
      PL3=PL7;
      Calculate_V7();
      PL3=PL8;
      Calculate_V8();
      PL3=PL9;
      Calculate_V9();
     }
   if(InpLevel4==false)
     {
      PL4=PL5;
      Calculate_V5();
      PL4=PL6;
      Calculate_V6();
      PL4=PL7;
      Calculate_V7();
      PL4=PL8;
      Calculate_V8();
      PL4=PL9;
      Calculate_V9();
     }
   if(InpLevel5==false)
     {
      PL5=PL6;
      Calculate_V6();
      PL5=PL7;
      Calculate_V7();
      PL5=PL8;
      Calculate_V8();
      PL5=PL9;
      Calculate_V9();
     }
   if(InpLevel6==false)
     {
      PL6=PL7;
      Calculate_V7();
      PL6=PL8;
      Calculate_V8();
      PL6=PL9;
      Calculate_V9();
     }

   if(InpLevel7==false)
     {
      PL7=PL8;
      Calculate_V8();
      PL7=PL9;
      Calculate_V9();
     }
   if(InpLevel8==false)
     {
      PL8=PL9;
      Calculate_V9();
     }
//SHORT FUNCITON
   if(InpTPSMode==true)
     {
      Calculate_V1S();
      Calculate_V2MS();
      Calculate_V3MS();
      Calculate_V4MS();
      Calculate_V5MS();
      Calculate_V6MS();
      Calculate_V7MS();
      Calculate_V8MS();
      Calculate_V9MS();
      
     }
   else
     {
      Calculate_V1S();
      Calculate_V2S();
      Calculate_V3S();
      Calculate_V4S();
      Calculate_V5S();
      Calculate_V6S();
      Calculate_V7S();
      Calculate_V8S();
      Calculate_V9S();
 

     }
   if(InpTPSMode==false)
     {
      TPS2=TPS1;
      TPS3=TPS1;
      TPS4=TPS1;
      TPS5=TPS1;
      TPS6=TPS1;
      TPS7=TPS1;
      TPS8=TPS1;
      TPS9=TPS1;
      TPS10=TPS1;
     }
   if(InpLevel1S==false)
     {
      PL1S=PL2S;
      Calculate_V2S();
      PL1S=PL3S;
      Calculate_V3S();
      PL1S=PL4S;
      Calculate_V4S();
      PL1S=PL5S;
      Calculate_V5S();
      PL1S=PL6S;
      Calculate_V6S();
      PL1S=PL7S;
      Calculate_V7S();
      PL1S=PL8S;
      Calculate_V8S();
      PL1S=PL9S;
      Calculate_V9S();
     }
   if(InpLevel2S==false)
     {
      PL2S=PL3S;
      Calculate_V3S();
      PL2S=PL4S;
      Calculate_V4S();
      PL2S=PL5S;
      Calculate_V5S();
      PL2S=PL6S;
      Calculate_V6S();
      PL2S=PL7S;
      Calculate_V7S();
      PL2S=PL8S;
      Calculate_V8S();
      PL2S=PL9S;
      Calculate_V9S();
     }
   if(InpLevel3S==false)
     {
      PL3S=PL4S;
      Calculate_V4S();
      PL3S=PL5S;
      Calculate_V5S();
      PL3S=PL6S;
      Calculate_V6S();
      PL3S=PL7S;
      Calculate_V7S();
      PL3S=PL8S;
      Calculate_V8S();
      PL3S=PL9S;
      Calculate_V9S();
     }
   if(InpLevel4S==false)
     {
      PL4S=PL5S;
      Calculate_V5S();
      PL4S=PL6S;
      Calculate_V6S();
      PL4S=PL7S;
      Calculate_V7S();
      PL4S=PL8S;
      Calculate_V8S();
      PL4S=PL9S;
      Calculate_V9S();
     }
   if(InpLevel5S==false)
     {
      PL5S=PL6S;
      Calculate_V6S();
      PL5S=PL7S;
      Calculate_V7S();
      PL5S=PL8S;
      Calculate_V8S();
      PL5S=PL9S;
      Calculate_V9S();
     }
   if(InpLevel6S==false)
     {
      PL6S=PL7S;
      Calculate_V7S();
      PL6S=PL8S;
      Calculate_V8S();
      PL6S=PL9S;
      Calculate_V9S();
     }

   if(InpLevel7S==false)
     {
      PL7S=PL8S;
      Calculate_V8S();
      PL7S=PL9S;
      Calculate_V9S();
     }
   if(InpLevel8S==false)
     {
      PL8S=PL9S;
      Calculate_V9S();
     }

//Normalize Indices Volumes
   if(InpTradingInstrument==TRADING_INDICES)
     {
      //Long
      Vl1=NormalizeDouble(Vl1,1);
      Vl2=NormalizeDouble(Vl2,1);
      Vl3=NormalizeDouble(Vl3,1);
      Vl4=NormalizeDouble(Vl4,1);
      Vl5=NormalizeDouble(Vl5,1);
      Vl6=NormalizeDouble(Vl6,1);
      Vl7=NormalizeDouble(Vl7,1);
      Vl8=NormalizeDouble(Vl8,1);
      Vl9=NormalizeDouble(Vl9,1);
      
      //Short
      Vl1S = NormalizeDouble(Vl1S, 1);
      Vl2S = NormalizeDouble(Vl2S, 1);
      Vl3S = NormalizeDouble(Vl3S, 1);
      Vl4S = NormalizeDouble(Vl4S, 1);
      Vl5S = NormalizeDouble(Vl5S, 1);
      Vl6S = NormalizeDouble(Vl6S, 1);
      Vl7S = NormalizeDouble(Vl7S, 1);
      Vl8S = NormalizeDouble(Vl8S, 1);
      Vl9S = NormalizeDouble(Vl9S, 1);


     }

//LONG
   Print("PL0  ",PL0);
   Print("PL1  ",PL1);
   Print("PL2  ",PL2);
   Print("PL3  ",PL3);
   Print("PL4  ",PL4);
   Print("PL5  ",PL5);
   Print("PL6  ",PL6);
   Print("PL7  ",PL7);
   Print("PL8  ",PL8);
   Print("PL9  ",PL9);
   Print("PL10  ",PL10);
//SHORT
   Print("PL0  ",PL0S);
   Print("PL1S ", PL1S);
   Print("PL2S ", PL2S);
   Print("PL3S ", PL3S);
   Print("PL4S ", PL4S);
   Print("PL5S ", PL5S);
   Print("PL6S ", PL6S);
   Print("PL7S ", PL7S);
   Print("PL8S ", PL8S);
   Print("PL9S ", PL9S);
   Print("PL10S ", PL10S);

   Comment("CONTOR:",CONTOR);
   Comment("CONTORS:",CONTORS);

   Comment("\n","NextBuyPrice: ",NextBuyPrice,"\n");
   Comment("\n","NexSellPrice: ",NextSellPrice,"\n");

//complementare buy
   if(CountOpenPositions()>=4 && medierebuy==false && CONTOR>=4)
     {
      complementarebuy=true;
      if(PositionSelectByTicket(TicketNumber))
        {
         if(PositionGetDouble(POSITION_SL)==0)
           {
            trade.PositionModify(TicketNumber,(RangeMB0-(InpStopLoss*_Point)),0);
           }
        }

     }
//complementare sell
   if(CountOpenPositions()>=4 && medieresell==false && CONTORS>=4)
     {
      complementaresell=true;
      if(PositionSelectByTicket(TicketNumberS))
        {
         if(PositionGetDouble(POSITION_SL)==0)
           {
            trade.PositionModify(TicketNumberS,(RangeMS0+(InpStopLossS*_Point)),0);
           }
        }

     }
//afara din complementar BUY if statement set the trailing stop loss
   if(medierebuy==false && complementarebuy==true)
     {
      double lastBuyStopLoss=0.0,lastBuyPosition=0.0,currP=0.0;
      if(PositionSelectByTicket(TicketNumber))
        {
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
           {
            lastBuyStopLoss = PositionGetDouble(POSITION_SL);//1.20563 modifica 1.20583
            lastBuyPosition=PositionGetDouble(POSITION_PRICE_OPEN);//1.20613
            currP=PositionGetDouble(POSITION_PRICE_CURRENT);//1.20612 20pips
           }

        }
      static double TrailPrice=NormalizeDouble(lastBuyStopLoss+InpTrailStop*_Point+InpStopLoss*_Point,_Digits);
      if(lastTick.ask>=TrailPrice)
        {
         if(PositionSelectByTicket(TicketNumber))
           {
            trade.PositionModify(TicketNumber,NormalizeDouble(lastBuyStopLoss+InpTrailStop*_Point,_Digits),0);
            TrailPrice=NormalizeDouble(TrailPrice+InpTrailStop*_Point,_Digits);
           }

        }
      if(lastBuyStopLoss==currP)
        {
         CloseBuyPositions();
         CONTOR=0;
         complementarebuy=false;
         if(PositionSelectByTicket(TicketNumber))
           {
            trade.PositionModify(TicketNumber,0,0);
           }
        }
     }
   if(PL0==0.0)
     {
      Alert("Atentie PL0 e 0.0");
     }

//afara din complementar SELL if statement set the trailing stop loss
   if(medieresell==false && complementaresell==true)
     {
      double lastBuyStopLossS=0.0,lastBuyPositionS=0.0,currPS=0.0;
      if(PositionSelectByTicket(TicketNumberS))
        {
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
           {
            lastBuyStopLossS = PositionGetDouble(POSITION_SL);//1.20563 modifica 1.20583
            lastBuyPositionS=PositionGetDouble(POSITION_PRICE_OPEN);//1.20613
            currPS=PositionGetDouble(POSITION_PRICE_CURRENT);//1.20612 20pips
           }

        }
      static double TrailPriceS=NormalizeDouble(lastBuyStopLossS-InpTrailStopS*_Point-InpStopLossS*_Point,_Digits);
      if(lastTick.bid<=TrailPriceS)
        {
         if(PositionSelectByTicket(TicketNumberS))
           {
            trade.PositionModify(TicketNumberS,NormalizeDouble(lastBuyStopLossS+InpTrailStopS*_Point,_Digits),0);
            TrailPriceS=NormalizeDouble(TrailPriceS-InpTrailStopS*_Point,_Digits);
           }

        }
      if(lastBuyStopLossS==currPS)
        {
         CloseSellPositions();
         CONTORS=0;
         complementaresell=false;
         if(PositionSelectByTicket(TicketNumberS))
           {
            trade.PositionModify(TicketNumberS,0,0);
           }
        }
     }
   if(PL0S==0.0)
     {
      Alert("Atentie PLS0 e 0.0");
     }

//mediere buy
   if(Level1==false && InpLevel1==true) ///LEVEL 1 Fibonacci
     {

      if(lastTick.ask<=PL1)
        {

         if(trade.Buy(Vl1,NULL,lastTick.ask,0,lastTick.ask+TP1*_Point,"Order1 & TP1"))
           {
            Level1=true;
            medierebuy=true;
            complementarebuy=false;
            TicketNumber=trade.ResultOrder();
           }
         else
           {
            SendNotification("ERROR, Check Volume!!!");
           }
        }

     }
   else
      if(Level2==false && InpLevel2==true)///LEVEL 2 Fibonacci
        {
         if(lastTick.ask<=PL2)
           {

            if(trade.Buy(Vl2,NULL,lastTick.ask,0,lastTick.ask+TP2*_Point,"Order2 & TP2"))
              {
               medierebuy=true;
               Level2=true;
               ContorM=2;
               TicketNumber=trade.ResultOrder();
              }
            else
              {
               SendNotification("ERROR, Check Volume!!!");
              }
           }
        }

      else
         if(Level3==false && InpLevel3==true)///LEVEL 3 Fibonacci
           {

            if(lastTick.ask<=PL3)
              {

               if(trade.Buy(Vl3,NULL,lastTick.ask,0,lastTick.ask+TP3*_Point,"Order3 &Tp3"))
                 {
                  medierebuy=true;
                  Level3=true;
                  ContorM=3;
                  TicketNumber=trade.ResultOrder();
                 }
               else
                 {
                  SendNotification("ERROR, Check Volume!!!");
                 }
              }

           }
         else
            if(Level4==false && InpLevel4==true)///LEVEL 4 Fibonacci
              {


               if(lastTick.ask<=PL4)
                 {

                  if(trade.Buy(Vl4,NULL,lastTick.ask,0,lastTick.ask+TP4*_Point,"Order4 &Tp4"))
                    {
                     medierebuy=true;
                     Level4=true;
                     ContorM=4;
                     TicketNumber=trade.ResultOrder();
                    }
                  else
                    {
                     SendNotification("ERROR, Check Volume!!!");
                    }
                 }

              }
            else
               if(Level5==false && InpLevel5==true)///LEVEL 5 Fibonacci
                 {


                  if(lastTick.ask<=PL5)
                    {

                     if(trade.Buy(Vl5,NULL,lastTick.ask,0,lastTick.ask+TP5*_Point,"Order5 &Tp5"))
                       {
                        medierebuy=true;
                        Level5=true;
                        ContorM=5;
                        TicketNumber=trade.ResultOrder();
                       }
                     else
                       {
                        SendNotification("ERROR, Check Volume!!!");
                       }
                    }


                 }
               else
                  if(Level6==false && InpLevel6==true)///LEVEL 6 Fibonacci
                    {

                     if(lastTick.ask<=PL6)
                       {

                        if(trade.Buy(Vl6,NULL,lastTick.ask,0,lastTick.ask+TP6*_Point,"Order6 &Tp6"))
                          {
                           medierebuy=true;
                           Level6=true;
                           ContorM=6;
                           TicketNumber=trade.ResultOrder();
                          }
                        else
                          {
                           SendNotification("ERROR, Check Volume!!!");
                          }
                       }

                    }
                  else
                     if(Level7==false && InpLevel7==true)///LEVEL 7 Fibonacci
                       {


                        if(lastTick.ask<=PL7)
                          {

                           if(trade.Buy(Vl7,NULL,lastTick.ask,0,lastTick.ask+TP7*_Point,"Order7 &Tp7"))
                             {
                              medierebuy=true;
                              Level7=true;//ba e nevoie
                              ContorM=7;
                              TicketNumber=trade.ResultOrder();
                             }
                           else
                             {
                              SendNotification("ERROR, Check Volume!!!");
                             }
                          }

                       }
                     else
                        if(Level8==false && InpLevel8==true)///LEVEL 7 Fibonacci
                          {


                           if(lastTick.ask<=PL8)
                             {

                              if(trade.Buy(Vl8,NULL,lastTick.ask,0,lastTick.ask+TP8*_Point,"Order8 &Tp8"))
                                {
                                 medierebuy=true;
                                 Level8=true;//ba e nevoie
                                 ContorM=8;
                                 TicketNumber=trade.ResultOrder();
                                }
                              else
                                {
                                 SendNotification("ERROR, Check Volume!!!");
                                }
                             }

                          }
                        else
                           if(Level9==false && InpLevel9==true)///LEVEL 7 Fibonacci
                             {


                              if(lastTick.ask<=PL9)
                                {

                                 if(trade.Buy(Vl9,NULL,lastTick.ask,0,lastTick.ask+TP9*_Point,"Order9 &Tp9"))
                                   {
                                    medierebuy=true;
                                    Level9=true;//ba e nevoie
                                    ContorM=9;
                                    TicketNumber=trade.ResultOrder();
                                   }
                                 else
                                   {
                                    SendNotification("ERROR, Check Volume!!!");
                                   }
                                }

                             }
                           else
                              if(Level10==false && InpLevel10==true)///LEVEL 10 Fibonacci
                                {


                                 if(lastTick.ask<=PL10)
                                   {

                                    if(trade.Buy(Vl10,NULL,lastTick.ask,0,lastTick.ask+TP10*_Point,"Order10 &Tp10"))
                                      {
                                       medierebuy=true;
                                       Level10=true;//ba e nevoie
                                       ContorM=10;
                                       TicketNumber=trade.ResultOrder();
                                      }
                                    else
                                      {
                                       SendNotification("ERROR, Check Volume!!!");
                                      }
                                   }

                                }
                              else
                                 if(Level11==false && InpLevel11==true)///LEVEL 11 Fibonacci
                                   {


                                    if(lastTick.ask<=PL11)
                                      {

                                       if(trade.Buy(Vl11,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order11 &Tp11"))
                                         {
                                          medierebuy=true;
                                          Level11=true;//ba e nevoie
                                          ContorM=11;
                                          TicketNumber=trade.ResultOrder();
                                         }
                                       else
                                         {
                                          SendNotification("ERROR, Check Volume!!!");
                                         }
                                      }

                                   }
                                 else
                                    if(Level12==false && InpLevel12==true)///LEVEL 7 Fibonacci
                                      {


                                       if(lastTick.ask<=PL12)
                                         {

                                          if(trade.Buy(Vl12,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order12 &Tp12"))
                                            {
                                             medierebuy=true;
                                             Level12=true;//ba e nevoie
                                             ContorM=12;
                                             TicketNumber=trade.ResultOrder();
                                            }
                                          else
                                            {
                                             SendNotification("ERROR, Check Volume!!!");
                                            }
                                         }

                                      }
                                    else
                                       if(Level13==false && InpLevel13==true)///LEVEL 7 Fibonacci
                                         {


                                          if(lastTick.ask<=PL13)
                                            {

                                             if(trade.Buy(Vl13,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order13 &Tp13"))
                                               {
                                                medierebuy=true;
                                                Level13=true;//ba e nevoie
                                                ContorM=13;
                                                TicketNumber=trade.ResultOrder();
                                               }
                                             else
                                               {
                                                SendNotification("ERROR, Check Volume!!!");
                                               }
                                            }

                                         }

                                       else
                                          if(Level14==false && InpLevel14==true)///LEVEL 7 Fibonacci
                                            {


                                             if(lastTick.ask<=PL14)
                                               {

                                                if(trade.Buy(Vl14,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order14 &Tp14"))
                                                  {
                                                   medierebuy=true;
                                                   Level14=true;//ba e nevoie
                                                   ContorM=14;
                                                   TicketNumber=trade.ResultOrder();
                                                  }
                                                else
                                                  {
                                                   SendNotification("ERROR, Check Volume!!!");
                                                  }
                                               }

                                            }
                                          else
                                             if(Level15==false && InpLevel15==true)///LEVEL 7 Fibonacci
                                               {


                                                if(lastTick.ask<=PL15)
                                                  {

                                                   if(trade.Buy(Vl15,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order15 &Tp15"))
                                                     {
                                                      medierebuy=true;
                                                      Level15=true;//ba e nevoie
                                                      ContorM=15;
                                                      TicketNumber=trade.ResultOrder();
                                                     }
                                                   else
                                                     {
                                                      SendNotification("ERROR, Check Volume!!!");
                                                     }
                                                  }

                                               }
                                             else
                                                if(Level16==false && InpLevel16==true)///LEVEL 7 Fibonacci
                                                  {


                                                   if(lastTick.ask<=PL16)
                                                     {

                                                      if(trade.Buy(Vl16,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order16 &Tp16"))
                                                        {
                                                         medierebuy=true;
                                                         Level16=true;//ba e nevoie
                                                         ContorM=16;
                                                         TicketNumber=trade.ResultOrder();
                                                        }
                                                      else
                                                        {
                                                         SendNotification("ERROR, Check Volume!!!");
                                                        }
                                                     }

                                                  }
                                                else
                                                   if(Level17==false && InpLevel17==true)///LEVEL 7 Fibonacci
                                                     {


                                                      if(lastTick.ask<=PL17)
                                                        {

                                                         if(trade.Buy(Vl17,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order17 &Tp17"))
                                                           {
                                                            medierebuy=true;
                                                            Level17=true;//ba e nevoie
                                                            ContorM=17;
                                                            TicketNumber=trade.ResultOrder();
                                                           }
                                                         else
                                                           {
                                                            SendNotification("ERROR, Check Volume!!!");
                                                           }
                                                        }

                                                     }
                                                   else
                                                      if(Level18==false && InpLevel18==true)///LEVEL 7 Fibonacci
                                                        {


                                                         if(lastTick.ask<=PL18)
                                                           {

                                                            if(trade.Buy(Vl18,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order18 &Tp18"))
                                                              {
                                                               medierebuy=true;
                                                               Level18=true;//ba e nevoie
                                                               ContorM=18;
                                                               TicketNumber=trade.ResultOrder();
                                                              }
                                                            else
                                                              {
                                                               SendNotification("ERROR, Check Volume!!!");
                                                              }
                                                           }

                                                        }
                                                      else
                                                         if(Level19==false && InpLevel19==true)///LEVEL 7 Fibonacci
                                                           {


                                                            if(lastTick.ask<=PL19)
                                                              {

                                                               if(trade.Buy(Vl19,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order19 &Tp19"))
                                                                 {
                                                                  medierebuy=true;
                                                                  Level19=true;//ba e nevoie
                                                                  ContorM=179;
                                                                  TicketNumber=trade.ResultOrder();
                                                                 }
                                                               else
                                                                 {
                                                                  SendNotification("ERROR, Check Volume!!!");
                                                                 }
                                                              }

                                                           }
   if(medierebuy==true)
     {
      double lastBuyTakeProfit=0.0,lastBuyPosition=0.0;
      if(PositionSelectByTicket(TicketNumber))
        {
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
           {
            lastBuyTakeProfit = PositionGetDouble(POSITION_TP);
            lastBuyPosition=PositionGetDouble(POSITION_PRICE_CURRENT);
           }
        }
      if(lastBuyTakeProfit==lastBuyPosition)
        {
         CloseBuyPositions();
         CONTOR=0;
         medierebuy=false;
         Level1=false;
         Level2=false;
         Level3=false;
         Level4=false;
         Level5=false;
         Level6=false;
         Level7=false;
         Level8=false;
         Level9=false;
         Level10=false;
         Level11=false;
         Level12=false;
         Level13=false;
         Level14=false;
         Level15=false;
         Level16=false;
         Level17=false;
         Level18=false;
         Level19=false;
        }

     }


//medieresell
   if(LevelS1==false && InpLevel1S==true) ///LEVEL 1 Fibonacci
     {

      if(lastTick.bid>=PL1S)
        {

         if(trade.Sell(Vl1S,NULL,lastTick.bid,0,lastTick.bid-TPS1*_Point,"Order1 & TP1 SELL"))
           {
            LevelS1=true;
            medieresell=true;
            complementaresell=false;
            TicketNumberS=trade.ResultOrder();
           }
         else
           {
            SendNotification("ERROR, Check Volume!!!");
           }
        }

     }
   else
      if(LevelS2==false &&InpLevel2S==true)///LEVEL 2 Fibonacci
        {
         if(lastTick.bid>=PL2S)
           {

            if(trade.Sell(Vl2S,NULL,lastTick.bid,0,lastTick.bid-TPS2*_Point,"Order2 & TP2 SELL"))
              {
               LevelS2=true;
               medieresell=true;
               ContorM=2;
               TicketNumberS=trade.ResultOrder();
              }
            else
              {
               SendNotification("ERROR, Check Volume!!!");
              }
           }
        }

      else
         if(LevelS3==false &&InpLevel3S==true)///LEVEL 3 Fibonacci
           {

            if(lastTick.bid>=PL3S)
              {

               if(trade.Sell(Vl3S,NULL,lastTick.bid,0,lastTick.bid-TPS3*_Point,"Order3 &Tp3 SELL"))
                 {
                  LevelS3=true;
                  medieresell=true;
                  ContorM=3;
                  TicketNumberS=trade.ResultOrder();
                 }
               else
                 {
                  SendNotification("ERROR, Check Volume!!!");
                 }
              }

           }
         else
            if(LevelS4==false && InpLevel4S==true)///LEVEL 4 Fibonacci
              {


               if(lastTick.bid>=PL4S)
                 {

                  if(trade.Sell(Vl4S,NULL,lastTick.bid,0,lastTick.bid-TPS4*_Point,"Order4 &Tp4 SELL"))
                    {
                     LevelS4=true;
                     medieresell=true;
                     ContorM=4;
                     TicketNumberS=trade.ResultOrder();
                    }
                  else
                    {
                     SendNotification("ERROR, Check Volume!!!");
                    }
                 }

              }
            else
               if(LevelS5==false && InpLevel5S==true)///LEVEL 5 Fibonacci
                 {


                  if(lastTick.bid>=PL5S)
                    {

                     if(trade.Sell(Vl5S,NULL,lastTick.bid,0,lastTick.bid-TPS5*_Point,"Order5 &Tp5 SELL"))
                       {
                        medieresell=true;
                        LevelS5=true;
                        ContorM=5;
                        TicketNumberS=trade.ResultOrder();
                       }
                     else
                       {
                        SendNotification("ERROR, Check Volume!!!");
                       }
                    }


                 }
               else
                  if(LevelS6==false && InpLevel6S==true)///LEVEL 6 Fibonacci
                    {

                     if(lastTick.bid>=PL6S)
                       {

                        if(trade.Sell(Vl6S,NULL,lastTick.bid,0,lastTick.bid-TPS6*_Point,"Order6 &Tp6 SELL"))
                          {
                           medieresell=true;
                           LevelS6=true;
                           ContorM=6;
                           TicketNumberS=trade.ResultOrder();
                          }
                        else
                          {
                           SendNotification("ERROR, Check Volume!!!");
                          }
                       }

                    }
                  else
                     if(LevelS7==false && InpLevel7S==true)///LEVEL 7 Fibonacci
                       {


                        if(lastTick.bid>=PL7S)
                          {

                           if(trade.Sell(Vl7S,NULL,lastTick.bid,0,lastTick.bid-TPS7*_Point,"Order7 &Tp7 SELL"))
                             {
                              medieresell=true;
                              LevelS7=true;//ba e nevoie
                              ContorM=7;
                              TicketNumberS=trade.ResultOrder();
                             }
                           else
                             {
                              SendNotification("ERROR, Check Volume!!!");
                             }
                          }

                       }
                     else
                        if(LevelS8==false && InpLevel8S==true) ///LEVEL 7 Fibonacci
                          {


                           if(lastTick.bid>=PL8S)
                             {

                              if(trade.Sell(Vl8S,NULL,lastTick.bid,0,lastTick.bid-TPS8*_Point,"Order8 &Tp8 SELL"))
                                {
                                 medieresell=true;
                                 LevelS8=true;//ba e nevoie
                                 ContorM=8;
                                 TicketNumberS=trade.ResultOrder();
                                }
                              else
                                {
                                 SendNotification("ERROR, Check Volume!!!");
                                }
                             }

                          }
                        else
                           if(LevelS9==false && InpLevel9S==true)///LEVEL 7 Fibonacci
                             {


                              if(lastTick.bid>=PL9S)
                                {

                                 if(trade.Sell(Vl9S,NULL,lastTick.bid,0,lastTick.bid-TPS9*_Point,"Order9 &Tp9 SELL"))
                                   {
                                    medieresell=true;
                                    LevelS9=true;//ba e nevoie
                                    ContorM=9;
                                    TicketNumberS=trade.ResultOrder();
                                   }
                                 else
                                   {
                                    SendNotification("ERROR, Check Volume!!!");
                                   }
                                }

                             }
                           else
                              if(LevelS10==false && InpLevel10S==true)///LEVEL 7 Fibonacci
                                {


                                 if(lastTick.bid>=PL10S)
                                   {

                                    if(trade.Sell(Vl10S,NULL,lastTick.bid,0,lastTick.bid-TPS10*_Point,"Order10 &Tp10 SELL"))
                                      {
                                       medieresell=true;
                                       LevelS10=true;//ba e nevoie
                                       ContorM=10;
                                       TicketNumberS=trade.ResultOrder();
                                      }
                                    else
                                      {
                                       SendNotification("ERROR, Check Volume!!!");
                                      }
                                   }

                                }
                              else
                                 if(LevelS11==false && InpLevel11S==true)///LEVEL 7 Fibonacci
                                   {


                                    if(lastTick.bid>=PL11S)
                                      {

                                       if(trade.Sell(Vl11S,NULL,lastTick.bid,0,lastTick.bid-InpDistTakeProfitS*_Point,"Order11 &Tp11 SELL"))
                                         {
                                          medieresell=true;
                                          LevelS11=true;//ba e nevoie
                                          ContorM=11;
                                          TicketNumberS=trade.ResultOrder();
                                         }
                                       else
                                         {
                                          SendNotification("ERROR, Check Volume!!!");
                                         }
                                      }

                                   }
                                 else
                                    if(LevelS12==false && InpLevel12S==true)///LEVEL 7 Fibonacci
                                      {


                                       if(lastTick.bid>=PL12S)
                                         {

                                          if(trade.Sell(Vl12S,NULL,lastTick.bid,0,lastTick.bid-InpDistTakeProfitS*_Point,"Order12 &Tp12 SELL"))
                                            {
                                             medieresell=true;
                                             LevelS12=true;//ba e nevoie
                                             ContorM=12;
                                             TicketNumberS=trade.ResultOrder();
                                            }
                                          else
                                            {
                                             SendNotification("ERROR, Check Volume!!!");
                                            }
                                         }

                                      }
                                    else
                                       if(LevelS13==false && InpLevel13S==true)///LEVEL 7 Fibonacci
                                         {


                                          if(lastTick.bid>=PL13S)
                                            {

                                             if(trade.Sell(Vl13S,NULL,lastTick.bid,0,lastTick.bid-InpDistTakeProfitS*_Point,"Order13 &Tp13 SELL"))
                                               {
                                                medieresell=true;
                                                LevelS13=true;//ba e nevoie
                                                ContorM=13;
                                                TicketNumberS=trade.ResultOrder();
                                               }
                                             else
                                               {
                                                SendNotification("ERROR, Check Volume!!!");
                                               }
                                            }

                                         }

                                       else
                                          if(LevelS14==false && InpLevel14S==true)///LEVEL 7 Fibonacci
                                            {


                                             if(lastTick.bid>=PL14S)
                                               {

                                                if(trade.Sell(Vl14S,NULL,lastTick.bid,0,lastTick.bid-InpDistTakeProfitS*_Point,"Order14 &Tp14 SELL"))
                                                  {
                                                   medieresell=true;
                                                   LevelS14=true;//ba e nevoie
                                                   ContorM=14;
                                                   TicketNumberS=trade.ResultOrder();
                                                  }
                                                else
                                                  {
                                                   SendNotification("ERROR, Check Volume!!!");
                                                  }
                                               }

                                            }
                                          else
                                             if(LevelS15==false && InpLevel15S==true)///LEVEL 7 Fibonacci
                                               {


                                                if(lastTick.bid>=PL15S)
                                                  {

                                                   if(trade.Sell(Vl15S,NULL,lastTick.bid,0,lastTick.bid-InpDistTakeProfitS*_Point,"Order15 &Tp15 SELL"))
                                                     {
                                                      medieresell=true;
                                                      LevelS15=true;//ba e nevoie
                                                      ContorM=15;
                                                      TicketNumberS=trade.ResultOrder();
                                                     }
                                                   else
                                                     {
                                                      SendNotification("ERROR, Check Volume!!!");
                                                     }
                                                  }

                                               }
                                             else
                                                if(LevelS16==false && InpLevel16S==true)///LEVEL 7 Fibonacci
                                                  {


                                                   if(lastTick.bid>=PL16S)
                                                     {

                                                      if(trade.Sell(Vl16S,NULL,lastTick.bid,0,lastTick.bid-InpDistTakeProfitS*_Point,"Order16 &Tp16 SELL"))
                                                        {
                                                         medieresell=true;
                                                         LevelS16=true;//ba e nevoie
                                                         ContorM=16;
                                                         TicketNumberS=trade.ResultOrder();
                                                        }
                                                      else
                                                        {
                                                         SendNotification("ERROR, Check Volume!!!");
                                                        }
                                                     }

                                                  }
                                                else
                                                   if(LevelS17==false && InpLevel17S==true)///LEVEL 7 Fibonacci
                                                     {


                                                      if(lastTick.bid>=PL17S)
                                                        {

                                                         if(trade.Sell(Vl17S,NULL,lastTick.bid,0,lastTick.bid-InpDistTakeProfitS*_Point,"Order17 &Tp17 SELL"))
                                                           {
                                                            medieresell=true;
                                                            LevelS17=true;//ba e nevoie
                                                            ContorM=17;
                                                            TicketNumberS=trade.ResultOrder();
                                                           }
                                                         else
                                                           {
                                                            SendNotification("ERROR, Check Volume!!!");
                                                           }
                                                        }

                                                     }
                                                   else
                                                      if(LevelS18==false && InpLevel18S==true)///LEVEL 7 Fibonacci
                                                        {


                                                         if(lastTick.bid>=PL18S)
                                                           {

                                                            if(trade.Sell(Vl18S,NULL,lastTick.bid,0,lastTick.bid-InpDistTakeProfitS*_Point,"Order18 &Tp18 SELL"))
                                                              {
                                                               medieresell=true;
                                                               LevelS18=true;//ba e nevoie
                                                               ContorM=18;
                                                               TicketNumberS=trade.ResultOrder();
                                                              }
                                                            else
                                                              {
                                                               SendNotification("ERROR, Check Volume!!!");
                                                              }
                                                           }

                                                        }
                                                      else
                                                         if(LevelS19==false && InpLevel19S==true)///LEVEL 7 Fibonacci
                                                           {


                                                            if(lastTick.bid>=PL19S)
                                                              {

                                                               if(trade.Sell(Vl19S,NULL,lastTick.bid,0,lastTick.bid-InpDistTakeProfitS*_Point,"Order19 &Tp19 SELL"))
                                                                 {
                                                                  LevelS19=true;//ba e nevoie
                                                                  ContorM=19;
                                                                  TicketNumberS=trade.ResultOrder();
                                                                 }
                                                               else
                                                                 {
                                                                  SendNotification("ERROR, Check Volume!!!");
                                                                 }
                                                              }

                                                           }
   if(medieresell==true)
     {
      double lastBuyTakeProfitS=0.0,lastBuyPositionS=0.0;
      if(PositionSelectByTicket(TicketNumberS))
        {
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
           {
            lastBuyTakeProfitS = PositionGetDouble(POSITION_TP);
            lastBuyPositionS=PositionGetDouble(POSITION_PRICE_CURRENT);
           }
        }
      if(lastBuyTakeProfitS==lastBuyPositionS)
        {
         CloseSellPositions();
         CONTORS=0;
         medieresell=false;
         LevelS1=false;
         LevelS2=false;
         LevelS3=false;
         LevelS4=false;
         LevelS5=false;
         LevelS6=false;
         LevelS7=false;
         LevelS8=false;
         LevelS9=false;
         LevelS10=false;
         LevelS11=false;
         LevelS12=false;
         LevelS13=false;
         LevelS14=false;
         LevelS15=false;
         LevelS16=false;
         LevelS17=false;
         LevelS18=false;
         LevelS19=false;
        }

     }
   double Account_Profit=AccountInfoDouble(ACCOUNT_PROFIT);
   if(InpTakeProfitMode==true && Account_Profit>=InpTakeProfitAll)
     {
      CloseBuyPositions();
      CloseSellPositions();
      Print("Sunt un robot fraier");
      CONTOR=0;
      medierebuy=false;
      Level1=false;
      Level2=false;
      Level3=false;
      Level4=false;
      Level5=false;
      Level6=false;
      Level7=false;
      Level8=false;
      Level9=false;
      Level10=false;
      Level11=false;
      Level12=false;
      Level13=false;
      Level14=false;
      Level15=false;
      Level16=false;
      Level17=false;
      Level18=false;
      Level19=false;
      CloseSellPositions();
      CONTORS=0;
      medieresell=false;
      LevelS1=false;
      LevelS2=false;
      LevelS3=false;
      LevelS4=false;
      LevelS5=false;
      LevelS6=false;
      LevelS7=false;
      LevelS8=false;
      LevelS9=false;
      LevelS10=false;
      LevelS11=false;
      LevelS12=false;
      LevelS13=false;
      LevelS14=false;
      LevelS15=false;
      LevelS16=false;
      LevelS17=false;
      LevelS18=false;
      LevelS19=false;
     }
   if(InpStopLossMode==STOP_LOSS_MONEY)
     {
      if(InpStopLossAll*(-1)>=AccountInfoDouble(ACCOUNT_PROFIT))
        {
         //close LONG
         CloseBuyPositions();
         CONTOR=0;
         medierebuy=false;
         Level1=false;
         Level2=false;
         Level3=false;
         Level4=false;
         Level5=false;
         Level6=false;
         Level7=false;
         Level8=false;
         Level9=false;
         Level10=false;
         Level11=false;
         Level12=false;
         Level13=false;
         Level14=false;
         Level15=false;
         Level16=false;
         Level17=false;
         Level18=false;
         Level19=false;
         //close short
         CloseSellPositions();
         CONTORS=0;
         medieresell=false;
         LevelS1=false;
         LevelS2=false;
         LevelS3=false;
         LevelS4=false;
         LevelS5=false;
         LevelS6=false;
         LevelS7=false;
         LevelS8=false;
         LevelS9=false;
         LevelS10=false;
         LevelS11=false;
         LevelS12=false;
         LevelS13=false;
         LevelS14=false;
         LevelS15=false;
         LevelS16=false;
         LevelS17=false;
         LevelS18=false;
         LevelS19=false;
        }
     }
   if(InpStopLossMode==STOP_LOSS_PERCENT)
     {
      if((InpStopLossAll*AccountInfoDouble(ACCOUNT_BALANCE))/100*(-1)>=AccountInfoDouble(ACCOUNT_PROFIT))
        {
         //close LONG
         CloseBuyPositions();
         CONTOR=0;
         medierebuy=false;
         Level1=false;
         Level2=false;
         Level3=false;
         Level4=false;
         Level5=false;
         Level6=false;
         Level7=false;
         Level8=false;
         Level9=false;
         Level10=false;
         Level11=false;
         Level12=false;
         Level13=false;
         Level14=false;
         Level15=false;
         Level16=false;
         Level17=false;
         Level18=false;
         Level19=false;
         //close short
         CloseSellPositions();
         CONTORS=0;
         medieresell=false;
         LevelS1=false;
         LevelS2=false;
         LevelS3=false;
         LevelS4=false;
         LevelS5=false;
         LevelS6=false;
         LevelS7=false;
         LevelS8=false;
         LevelS9=false;
         LevelS10=false;
         LevelS11=false;
         LevelS12=false;
         LevelS13=false;
         LevelS14=false;
         LevelS15=false;
         LevelS16=false;
         LevelS17=false;
         LevelS18=false;
         LevelS19=false;
        }
     }
  }
//+------------------------------------------------------------------+
//| Calculate lot/pip value                                          |
//+------------------------------------------------------------------+
double CalculatePipValue()
  {
   double tickSize =SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);  // Size of one pip/tick
   double tickValue =SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE); // Value of one pip/tick in your account currency
   double volumeStep=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);

   double pipValue = MathFloor(tickValue / tickSize)*volumeStep;// /1000
   return pipValue;
  }

//count open positions
int CountOpenPositions()
  {

   int counter=0;
   int total=PositionsTotal();
   for(int i=total-1; i>=0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket<=0)
        {
         Print("Failed to get position ticket");
         return -1;
        }
      if(!PositionSelectByTicket(ticket))
        {
         Print("Failed to select position by ticket");
         return -1;
        }
      ulong magicnumber;
      if(!PositionGetInteger(POSITION_MAGIC,magicnumber))
        {
         Print("Failed to get magicnumber");
         return -1;
        }
      if(InpMagicNumber==magicnumber)
        {
         counter++;
        }

     }



   return counter;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V1()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss1=InpLots*PipValue*(-PL0+PL1+TZ)*100000;//0.00436-1.27503+0.00100
      Loss1=NormalizeDouble(MathAbs(Loss1),decimalPlace);
      Vl1=NormalizeDouble(Loss1/TZ/PipValue/100000,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss1=2*InpLots*PipValue*(-PL0+PL1+TZ-step2)*100000;
      Loss1=NormalizeDouble(MathAbs(Loss1),decimalPlace);
      Vl1=NormalizeDouble(Loss1/TZ/PipValue/100000,decimalPlace);
     }
   if(CONTOR==3)
     {
      Loss1=3*InpLots*PipValue*(-PL0+PL1+TZ-step3)*100000;
      Loss1=NormalizeDouble(MathAbs(Loss1),decimalPlace);
      Vl1=NormalizeDouble(Loss1/TZ/PipValue/100000,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss1:",Loss1,"Vl1: ",Vl1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V2()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss2=InpLots*PipValue*(PL2-PL0+TZ)*100000 //100000
            +(Vl1*PipValue*(PL2-PL1+TZ))*100000; //100000
      Loss2=NormalizeDouble(MathAbs(Loss2),decimalPlace);
      Vl2=NormalizeDouble(Loss2/TZ/PipValue/100000,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss2=2*InpLots*PipValue*(-PL0+PL2+TZ-step2)*100000
            +(Vl1*PipValue*(-PL1+PL2+TZ))*100000;
      Loss2=NormalizeDouble(MathAbs(Loss2),decimalPlace);
      Vl2=NormalizeDouble(Loss2/TZ/PipValue/100000,decimalPlace);
     }
   if(CONTOR==3)
     {
      Loss2=3*InpLots*PipValue*(-PL0+PL2+TZ-step3)*100000
            +(Vl1*PipValue*(-PL1+PL2+TZ))*100000;
      Loss2=NormalizeDouble(MathAbs(Loss2),decimalPlace);
      Vl2=NormalizeDouble(Loss2/TZ/PipValue/100000,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss2:",Loss2,"Vl2: ",Vl2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V2M()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss2=InpLots*PipValue*(PL0-PL2-TZ1)*100000
         +(Vl1*PipValue*((PL0-PL2)-(PL0-PL1)-TZ1))*100000;
      Loss2=NormalizeDouble(MathAbs(Loss2),decimalPlace);
      Vl2=NormalizeDouble(Loss2/TZ1/PipValue/100000,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss2=2*InpLots*PipValue*(-PL0+PL2+TZ1-step2)*100000
            +(Vl1*PipValue*(-PL1+PL2+TZ1))*100000;
      Loss2=NormalizeDouble(MathAbs(Loss2),decimalPlace);
      Vl2=NormalizeDouble(Loss2/TZ1/PipValue/100000,decimalPlace);
     }
   if(CONTOR==3)
     {
      Loss2=3*InpLots*PipValue*(-PL0+PL2+TZ1-step3)*100000
            +(Vl1*PipValue*(-PL1+PL2+TZ1))*100000;
      Loss2=NormalizeDouble(MathAbs(Loss2),decimalPlace);
      Vl2=NormalizeDouble(Loss2/TZ1/PipValue/100000,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss2:",Loss2,"Vl2: ",NormalizeDouble(Vl2,2));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V3()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss3=InpLots*PipValue*(-PL0+PL3+TZ)*100000
            +(Vl1*PipValue*(-PL1+PL3+TZ))*100000
            +(Vl2*PipValue*(-PL2+PL3+TZ))*100000;
      Loss3=NormalizeDouble(MathAbs(Loss3),decimalPlace);
      Vl3=NormalizeDouble(Loss3/TZ/PipValue/100000,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss3=2*InpLots*PipValue*(-PL0+PL3+TZ-step2)*100000
            +(Vl1*PipValue*(-PL1+PL3+TZ))*100000
            +(Vl2*PipValue*(-PL2+PL3+TZ))*100000;
      Loss3=NormalizeDouble(MathAbs(Loss3),decimalPlace);
      Vl3=NormalizeDouble(Loss3/TZ/PipValue/100000,decimalPlace);
     }
   if(CONTOR==3)
     {
      Loss3=3*InpLots*PipValue*(-PL0+PL3+TZ-step3)*100000
            +(Vl1*PipValue*(-PL1+PL3+TZ))*100000
            +(Vl2*PipValue*(-PL2+PL3+TZ))*100000;
      Loss3=NormalizeDouble(MathAbs(Loss3),decimalPlace);
      Vl3=NormalizeDouble(Loss3/TZ/PipValue/100000,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss3:",Loss3,"Vl3: ",Vl3);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V3M()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss3=InpLots*PipValue*(-PL0+PL3+TZ2)*100000
            +(Vl1*PipValue*(-PL1+PL3+TZ2))*100000
            +(Vl2*PipValue*(-PL2+PL3+TZ2))*100000;
      Loss3=NormalizeDouble(MathAbs(Loss3),decimalPlace);
      Vl3=NormalizeDouble(Loss3/TZ2/PipValue/100000,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss3=2*InpLots*PipValue*(-PL0+PL3+TZ2-step2)*100000
            +(Vl1*PipValue*(-PL1+PL3+TZ2))*100000
            +(Vl2*PipValue*(-PL2+PL3+TZ2))*100000;
      Loss3=NormalizeDouble(MathAbs(Loss3),decimalPlace);
      Vl3=NormalizeDouble(Loss3/TZ2/PipValue/100000,decimalPlace);
     }
   if(CONTOR==3)
     {
      Loss3=3*InpLots*PipValue*(-PL0+PL3+TZ2-step3)*100000
            +(Vl1*PipValue*(-PL1+PL3+TZ2))*100000
            +(Vl2*PipValue*(-PL2+PL3+TZ2))*100000;
      Loss3=NormalizeDouble(MathAbs(Loss3),decimalPlace);
      Vl3=NormalizeDouble(Loss3/TZ2/PipValue/100000,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss3:",Loss3,"Vl3: ",Vl3);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V4()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss4=InpLots*PipValue*(+PL4-PL0+TZ)*100000
            +(Vl1*PipValue*(+PL4-PL1+TZ))*100000
            +(Vl2*PipValue*(+PL4-PL2+TZ))*100000
            +(Vl3*PipValue*(+PL4-PL3+TZ))*100000;

      Loss4=NormalizeDouble(MathAbs(Loss4),decimalPlace);
      Vl4=NormalizeDouble(Loss4/TZ/PipValue/100000,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss4=2*InpLots*PipValue*(+PL4-PL0+TZ-step2)*100000
            +(Vl1*PipValue*(+PL4-PL1+TZ))*100000
            +(Vl2*PipValue*(+PL4-PL2+TZ))*100000
            +(Vl3*PipValue*(PL4-PL3+TZ))*100000;
      Loss4=NormalizeDouble(MathAbs(Loss4),decimalPlace);
      Vl4=NormalizeDouble(Loss4/TZ/PipValue/100000,decimalPlace);
     }
   if(CONTOR==3)
     {
      Loss4=3*InpLots*PipValue*(PL4-PL0+TZ-step3)*100000
            +(Vl1*PipValue*(PL4-PL1+TZ))*100000
            +(Vl2*PipValue*(PL4-PL2+TZ))*100000
            +(Vl3*PipValue*(PL4-PL3+TZ))*100000;
      Loss4=NormalizeDouble(MathAbs(Loss4),decimalPlace);
      Vl4=NormalizeDouble(Loss4/TZ/PipValue/100000,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss4:",Loss4," Vl4: ",Vl4);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V4M()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss4=InpLots*PipValue*(PL4-PL0+TZ3)*100000
            +(Vl1*PipValue*(PL4-PL1+TZ3))*100000
            +(Vl2*PipValue*(PL4-PL2+TZ3))*100000
            +(Vl3*PipValue*(PL4-PL3+TZ3))*100000;

      Loss4=NormalizeDouble(MathAbs(Loss4),decimalPlace);
      Vl4=NormalizeDouble(Loss4/TZ3/PipValue/100000,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss4=2*InpLots*PipValue*(PL4-PL0+TZ3-step2)*100000
            +(Vl1*PipValue*(PL4-PL1+TZ3))*100000
            +(Vl2*PipValue*(PL4-PL2+TZ3))*100000
            +(Vl3*PipValue*(PL4-PL3+TZ3))*100000;
      Loss4=NormalizeDouble(MathAbs(Loss4),decimalPlace);
      Vl4=NormalizeDouble(Loss4/TZ3/PipValue/100000,decimalPlace);
     }
   if(CONTOR==3)
     {
      Loss4=3*InpLots*PipValue*(PL4-PL0+TZ3-step3)*100000
            +(Vl1*PipValue*(PL4-PL1+TZ3))*100000
            +(Vl2*PipValue*(PL4-PL2+TZ3))*100000
            +(Vl3*PipValue*(PL4-PL3+TZ3))*100000;
      Loss4=NormalizeDouble(MathAbs(Loss4),decimalPlace);
      Vl4=NormalizeDouble(Loss4/TZ3/PipValue/100000,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss4:",Loss4," Vl4: ",Vl4);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V5()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss5=InpLots*PipValue*(PL5-PL0+TZ)*100000
            +(Vl1*PipValue*(PL5-PL1+TZ))*100000
            +(Vl2*PipValue*(PL5-PL2+TZ))*100000
            +(Vl3*PipValue*(PL5-PL3+TZ))*100000
            +(Vl4*PipValue*(PL5-PL4+TZ))*100000;
      Loss5=NormalizeDouble(MathAbs(Loss5),decimalPlace);
      Vl5=NormalizeDouble(Loss5/TZ/PipValue/100000,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss5=2*InpLots*PipValue*(PL5-PL0+TZ-step2)*100000
            +(Vl1*PipValue*(PL5-PL1+TZ))*100000
            +(Vl2*PipValue*(PL5-PL2+TZ))*100000
            +(Vl3*PipValue*(PL5-PL3+TZ))*100000
            +(Vl4*PipValue*(PL5-PL4+TZ))*100000;
      Loss5=NormalizeDouble(MathAbs(Loss5),decimalPlace);
      Vl5=NormalizeDouble(Loss5/TZ/PipValue/100000,decimalPlace);
     }
   if(CONTOR==3)
     {
      Loss5=3*InpLots*PipValue*(PL5-PL0+TZ-step3)*100000
            +(Vl1*PipValue*(PL5-PL1+TZ))*100000
            +(Vl2*PipValue*(PL5-PL2+TZ))*100000
            +(Vl3*PipValue*(PL5-PL3+TZ))*100000
            +(Vl4*PipValue*(PL5-PL4+TZ))*100000;
      Loss5=NormalizeDouble(MathAbs(Loss5),decimalPlace);
      Vl5=NormalizeDouble(Loss5/TZ/PipValue/100000,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss5:",Loss5," Vl5: ",Vl5);
  }
//+------------------------------------------------------------------+
//| Multiplicator                                                                 |
//+------------------------------------------------------------------+
void Calculate_V5M()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss5=InpLots*PipValue*(PL5-PL0+TZ4)*100000
            +(Vl1*PipValue*(PL5-PL1+TZ4))*100000
            +(Vl2*PipValue*(PL5-PL2+TZ4))*100000
            +(Vl3*PipValue*(PL5-PL3+TZ4))*100000
            +(Vl4*PipValue*(PL5-PL4+TZ4))*100000;
      Loss5=NormalizeDouble(MathAbs(Loss5),decimalPlace);
      Vl5=NormalizeDouble(Loss5/TZ4/PipValue/100000,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss5=2*InpLots*PipValue*(PL5-PL0+TZ4-step2)*100000
            +(Vl1*PipValue*(PL5-PL1+TZ4))*100000
            +(Vl2*PipValue*(PL5-PL2+TZ4))*100000
            +(Vl3*PipValue*(PL5-PL3+TZ4))*100000
            +(Vl4*PipValue*(PL5-PL4+TZ4))*100000;
      Loss5=NormalizeDouble(MathAbs(Loss5),decimalPlace);
      Vl5=NormalizeDouble(Loss5/TZ4/PipValue/100000,decimalPlace);
     }
   if(CONTOR==3)
     {
      Loss5=3*InpLots*PipValue*(PL5-PL0+TZ4-step3)*100000
            +(Vl1*PipValue*(PL5-PL1+TZ4))*100000
            +(Vl2*PipValue*(PL5-PL2+TZ4))*100000
            +(Vl3*PipValue*(PL5-PL3+TZ4))*100000
            +(Vl4*PipValue*(PL5-PL4+TZ4))*100000;
      Loss5=NormalizeDouble(MathAbs(Loss5),decimalPlace);
      Vl5=NormalizeDouble(Loss5/TZ4/PipValue/100000,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss5:",Loss5," Vl5: ",Vl5);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V6()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss6=InpLots*PipValue*(PL6-PL0+TZ)*100000
            +(Vl1*PipValue*(PL6-PL1+TZ))*100000
            +(Vl2*PipValue*(PL6-PL2+TZ))*100000
            +(Vl3*PipValue*(PL6-PL3+TZ))*100000
            +(Vl4*PipValue*(PL6-PL4+TZ))*100000
            +(Vl5*PipValue*(PL6-PL5+TZ))*100000;
      Loss6=NormalizeDouble(MathAbs(Loss6),decimalPlace);
      Vl6=NormalizeDouble(Loss6/TZ/PipValue/100000,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss6=2*InpLots*PipValue*(PL6-PL0+TZ-step2)*100000
            +(Vl1*PipValue*(PL6-PL1+TZ))*100000
            +(Vl2*PipValue*(PL6-PL2+TZ))*100000
            +(Vl3*PipValue*(PL6-PL3+TZ))*100000
            +(Vl4*PipValue*(PL6-PL4+TZ))*100000
            +(Vl5*PipValue*(PL6-PL5+TZ))*100000;
      Loss6=NormalizeDouble(MathAbs(Loss6),decimalPlace);
      Vl6=NormalizeDouble(Loss6/TZ/PipValue/100000,decimalPlace);
     }
   if(CONTOR==3)
     {
      Loss6=3*InpLots*PipValue*(PL6-PL0+TZ-step3)*100000
            +(Vl1*PipValue*(PL6-PL1+TZ))*100000
            +(Vl2*PipValue*(PL6-PL2+TZ))*100000
            +(Vl3*PipValue*(PL6-PL3+TZ))*100000
            +(Vl4*PipValue*(PL6-PL4+TZ))*100000
            +(Vl5*PipValue*(PL6-PL5+TZ))*100000;
      Loss6=NormalizeDouble(MathAbs(Loss6),decimalPlace);
      Vl6=NormalizeDouble(Loss6/TZ/PipValue/100000,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss6:",Loss6," Vl6:",Vl6);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V6M()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss6=InpLots*PipValue*(PL6-PL0+TZ5)*100000
            +(Vl1*PipValue*(PL6-PL1+TZ5))*100000
            +(Vl2*PipValue*(PL6-PL2+TZ5))*100000
            +(Vl3*PipValue*(PL6-PL3+TZ5))*100000
            +(Vl4*PipValue*(PL6-PL4+TZ5))*100000
            +(Vl5*PipValue*(PL6-PL5+TZ5))*100000;
      Loss6=NormalizeDouble(MathAbs(Loss6),decimalPlace);
      Vl6=NormalizeDouble(Loss6/TZ5/PipValue/100000,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss6=2*InpLots*PipValue*(PL6-PL0+TZ5-step2)*100000
            +(Vl1*PipValue*(PL6-PL1+TZ5))*100000
            +(Vl2*PipValue*(PL6-PL2+TZ5))*100000
            +(Vl3*PipValue*(PL6-PL3+TZ5))*100000
            +(Vl4*PipValue*(PL6-PL4+TZ5))*100000
            +(Vl5*PipValue*(PL6-PL5+TZ5))*100000;
      Loss6=NormalizeDouble(MathAbs(Loss6),decimalPlace);
      Vl6=NormalizeDouble(Loss6/TZ5/PipValue/100000,decimalPlace);
     }
   if(CONTOR==3)
     {
      Loss6=3*InpLots*PipValue*(PL6-PL0+TZ5-step3)*100000
            +(Vl1*PipValue*(PL6-PL1+TZ5))*100000
            +(Vl2*PipValue*(PL6-PL2+TZ5))*100000
            +(Vl3*PipValue*(PL6-PL3+TZ5))*100000
            +(Vl4*PipValue*(PL6-PL4+TZ5))*100000
            +(Vl5*PipValue*(PL6-PL5+TZ5))*100000;
      Loss6=NormalizeDouble(MathAbs(Loss6),decimalPlace);
      Vl6=NormalizeDouble(Loss6/TZ5/PipValue/100000,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss6:",Loss6," Vl6:",Vl6);
  }
//++-----------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V7()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss7=InpLots*PipValue*(+PL7-PL0+TZ)*100000
            +(Vl1*PipValue*(+PL7-PL1+TZ))*100000
            +(Vl2*PipValue*(+PL7-PL2+TZ))*100000
            +(Vl3*PipValue*(+PL7-PL3+TZ))*100000
            +(Vl4*PipValue*(+PL7-PL4+TZ))*100000
            +(Vl5*PipValue*(+PL7-PL5+TZ))*100000
            +(Vl6*PipValue*(+PL7-PL6+TZ))*100000;
      Loss7=MathAbs(Loss7);
      Vl7=NormalizeDouble(Loss7/TZ/PipValue/100000,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss7=2*InpLots*PipValue*(+PL7-PL0+TZ-step2)
            +(Vl1*PipValue*(+PL7-PL1+TZ))
            +(Vl2*PipValue*(+PL7-PL2+TZ))
            +(Vl3*PipValue*(+PL7-PL3+TZ))
            +(Vl4*PipValue*(+PL7-PL4+TZ))
            +(Vl5*PipValue*(+PL7-PL5+TZ))
            +(Vl6*PipValue*(+PL7-PL6+TZ));
      Loss7=NormalizeDouble(MathAbs(Loss7*100000),decimalPlace);
      Vl7=NormalizeDouble(Loss7/TZ/PipValue/100000,decimalPlace);
     }
   if(CONTOR==3)
     {
      Loss7=3*InpLots*PipValue*(+PL7-PL0+TZ-step3)
            +(Vl1*PipValue*(+PL7-PL1+TZ))
            +(Vl2*PipValue*(+PL7-PL2+TZ))
            +(Vl3*PipValue*(+PL7-PL3+TZ))
            +(Vl4*PipValue*(+PL7-PL4+TZ))
            +(Vl5*PipValue*(+PL7-PL5+TZ))
            +(Vl6*PipValue*(+PL7-PL6+TZ));
      Loss7=NormalizeDouble(MathAbs(Loss7*100000),decimalPlace);
      Vl7=NormalizeDouble(Loss7/TZ/PipValue/100000,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss7:",Loss7," Vl7: ",Vl7);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V7M()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss7=InpLots*PipValue*(+PL7-PL0+TZ6)
            +(Vl1*PipValue*(+PL7-PL1+TZ6))
            +(Vl2*PipValue*(+PL7-PL2+TZ6))
            +(Vl3*PipValue*(+PL7-PL3+TZ6))
            +(Vl4*PipValue*(+PL7-PL4+TZ6))
            +(Vl5*PipValue*(+PL7-PL5+TZ6))
            +(Vl6*PipValue*(+PL7-PL6+TZ6));
      Loss7=NormalizeDouble(MathAbs(Loss7*100000),decimalPlace);
      Vl7=NormalizeDouble(Loss7/TZ6/PipValue/100000,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss7=2*InpLots*PipValue*(+PL7-PL0+TZ6-step2)
            +(Vl1*PipValue*(+PL7-PL1+TZ6))
            +(Vl2*PipValue*(+PL7-PL2+TZ6))
            +(Vl3*PipValue*(+PL7-PL3+TZ6))
            +(Vl4*PipValue*(+PL7-PL4+TZ6))
            +(Vl5*PipValue*(+PL7-PL5+TZ6))
            +(Vl6*PipValue*(+PL7-PL6+TZ6));
      Loss7=NormalizeDouble(MathAbs(Loss7*100000),decimalPlace);
      Vl7=NormalizeDouble(Loss7/TZ6/PipValue/100000,decimalPlace);
     }
   if(CONTOR==3)
     {
      Loss7=3*InpLots*PipValue*(+PL7-PL0+TZ6-step3)
            +(Vl1*PipValue*(+PL7-PL1+TZ6))
            +(Vl2*PipValue*(+PL7-PL2+TZ6))
            +(Vl3*PipValue*(+PL7-PL3+TZ6))
            +(Vl4*PipValue*(+PL7-PL4+TZ6))
            +(Vl5*PipValue*(+PL7-PL5+TZ6))
            +(Vl6*PipValue*(+PL7-PL6+TZ6));
      Loss7=NormalizeDouble(MathAbs(Loss7*100000),decimalPlace);
      Vl7=NormalizeDouble(Loss7/TZ6/PipValue/100000,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss7:",Loss7," Vl7: ",Vl7);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V8()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss8=InpLots*PipValue*(+PL8-PL0+TZ)
            +(Vl1*PipValue*(+PL8-PL1+TZ))
            +(Vl2*PipValue*(+PL8-PL2+TZ))
            +(Vl3*PipValue*(+PL8-PL3+TZ))
            +(Vl4*PipValue*(+PL8-PL4+TZ))
            +(Vl5*PipValue*(+PL8-PL5+TZ))
            +(Vl6*PipValue*(+PL8-PL6+TZ))
            +(Vl7*PipValue*(+PL8-PL7+TZ));
      Loss8=NormalizeDouble(MathAbs(Loss8*100000),decimalPlace);
      Vl8=NormalizeDouble(Loss8/TZ/PipValue/100000,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss8=2*InpLots*PipValue*(+PL8-PL0+TZ-step2)
            +(Vl1*PipValue*(+PL8-PL1+TZ))
            +(Vl2*PipValue*(+PL8-PL2+TZ))
            +(Vl3*PipValue*(+PL8-PL3+TZ))
            +(Vl4*PipValue*(+PL8-PL4+TZ))
            +(Vl5*PipValue*(+PL8-PL5+TZ))
            +(Vl6*PipValue*(+PL8-PL6+TZ))
            +(Vl7*PipValue*(+PL8-PL7+TZ));
      Loss8=NormalizeDouble(MathAbs(Loss8*100000),decimalPlace);
      Vl8=NormalizeDouble(Loss8/TZ/PipValue/100000,decimalPlace);
     }
   if(CONTOR==3)
     {
      Loss8=3*InpLots*PipValue*(+PL8-PL0+TZ-step3)
            +(Vl1*PipValue*(+PL8-PL1+TZ))
            +(Vl2*PipValue*(+PL8-PL2+TZ))
            +(Vl3*PipValue*(+PL8-PL3+TZ))
            +(Vl4*PipValue*(+PL8-PL4+TZ))
            +(Vl5*PipValue*(+PL8-PL5+TZ))
            +(Vl6*PipValue*(+PL8-PL6+TZ))
            +(Vl7*PipValue*(+PL8-PL7+TZ));
      Loss8=NormalizeDouble(MathAbs(Loss8*100000),decimalPlace);
      Vl8=NormalizeDouble(Loss8/TZ/PipValue/100000,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss8:",Loss8," Vl8:",Vl8);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V8M()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss8=InpLots*PipValue*(+PL8-PL0+TZ7)
            +(Vl1*PipValue*(+PL8-PL1+TZ7))
            +(Vl2*PipValue*(+PL8-PL2+TZ7))
            +(Vl3*PipValue*(+PL8-PL3+TZ7))
            +(Vl4*PipValue*(+PL8-PL4+TZ7))
            +(Vl5*PipValue*(+PL8-PL5+TZ7))
            +(Vl6*PipValue*(+PL8-PL6+TZ7))
            +(Vl7*PipValue*(+PL8-PL7+TZ7));
      Loss8=NormalizeDouble(MathAbs(Loss8*100000),decimalPlace);
      Vl8=NormalizeDouble(Loss8/TZ7/PipValue/100000,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss8=2*InpLots*PipValue*(+PL8-PL0+TZ7-step2)
            +(Vl1*PipValue*(+PL8-PL1+TZ7))
            +(Vl2*PipValue*(+PL8-PL2+TZ7))
            +(Vl3*PipValue*(+PL8-PL3+TZ7))
            +(Vl4*PipValue*(+PL8-PL4+TZ7))
            +(Vl5*PipValue*(+PL8-PL5+TZ7))
            +(Vl6*PipValue*(+PL8-PL6+TZ7))
            +(Vl7*PipValue*(+PL8-PL7+TZ7));
      Loss8=NormalizeDouble(MathAbs(Loss8*100000),decimalPlace);
      Vl8=NormalizeDouble(Loss8/TZ7/PipValue/100000,decimalPlace);
     }
   if(CONTOR==3)
     {
      Loss8=3*InpLots*PipValue*(+PL8-PL0+TZ7-step3)
            +(Vl1*PipValue*(+PL8-PL1+TZ7))
            +(Vl2*PipValue*(+PL8-PL2+TZ7))
            +(Vl3*PipValue*(+PL8-PL3+TZ7))
            +(Vl4*PipValue*(+PL8-PL4+TZ7))
            +(Vl5*PipValue*(+PL8-PL5+TZ7))
            +(Vl6*PipValue*(+PL8-PL6+TZ7))
            +(Vl7*PipValue*(+PL8-PL7+TZ7));
      Loss8=NormalizeDouble(MathAbs(Loss8*100000),decimalPlace);
      Vl8=NormalizeDouble(Loss8/TZ7/PipValue/100000,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss8:",Loss8," Vl8:",Vl8);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V9()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss9=InpLots*PipValue*(+PL9-PL0+TZ)
            +(Vl1*PipValue*(+PL9-PL1+TZ))
            +(Vl2*PipValue*(+PL9-PL2+TZ))
            +(Vl3*PipValue*(+PL9-PL3+TZ))
            +(Vl4*PipValue*(+PL9-PL4+TZ))
            +(Vl5*PipValue*(+PL9-PL5+TZ))
            +(Vl6*PipValue*(+PL9-PL6+TZ))
            +(Vl7*PipValue*(+PL9-PL7+TZ))
            +(Vl8*PipValue*(+PL9-PL8+TZ));
      Loss9=NormalizeDouble(MathAbs(Loss9*100000),decimalPlace);
      Vl9=NormalizeDouble(Loss9/TZ/PipValue/100000,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss9=2*InpLots*PipValue*(+PL9-PL0+TZ-step2)
            +(Vl1*PipValue*(+PL9-PL1+TZ))
            +(Vl2*PipValue*(+PL9-PL2+TZ))
            +(Vl3*PipValue*(+PL9-PL3+TZ))
            +(Vl4*PipValue*(+PL9-PL4+TZ))
            +(Vl5*PipValue*(+PL9-PL5+TZ))
            +(Vl6*PipValue*(+PL9-PL6+TZ))
            +(Vl7*PipValue*(+PL9-PL7+TZ))
            +(Vl8*PipValue*(+PL9-PL8+TZ));
      Loss9=NormalizeDouble(MathAbs(Loss9*100000),decimalPlace);
      Vl9=NormalizeDouble(Loss9/TZ/PipValue/100000,decimalPlace);
     }
   if(CONTOR==3)
     {
      Loss9=3*InpLots*PipValue*(+PL9-PL0+TZ-step3)
            +(Vl1*PipValue*(+PL9-PL1+TZ))
            +(Vl2*PipValue*(+PL9-PL2+TZ))
            +(Vl3*PipValue*(+PL9-PL3+TZ))
            +(Vl4*PipValue*(+PL9-PL4+TZ))
            +(Vl5*PipValue*(+PL9-PL5+TZ))
            +(Vl6*PipValue*(+PL9-PL6+TZ))
            +(Vl7*PipValue*(+PL9-PL7+TZ))
            +(Vl8*PipValue*(+PL9-PL8+TZ));
      Loss9=NormalizeDouble(MathAbs(Loss9*100000),decimalPlace);
      Vl9=NormalizeDouble(Loss9/TZ/PipValue/100000,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss9:",Loss9," Vl9: ",Vl9);
  }
//++-----------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V9M()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss9=InpLots*PipValue*(+PL9-PL0+TZ8)
            +(Vl1*PipValue*(+PL9-PL1+TZ8))
            +(Vl2*PipValue*(+PL9-PL2+TZ8))
            +(Vl3*PipValue*(+PL9-PL3+TZ8))
            +(Vl4*PipValue*(+PL9-PL4+TZ8))
            +(Vl5*PipValue*(+PL9-PL5+TZ8))
            +(Vl6*PipValue*(+PL9-PL6+TZ8))
            +(Vl7*PipValue*(+PL9-PL7+TZ8))
            +(Vl8*PipValue*(+PL9-PL8+TZ8));
      Loss9=NormalizeDouble(MathAbs(Loss9*100000),decimalPlace);
      Vl9=NormalizeDouble(Loss9/TZ8/PipValue/100000,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss9=2*InpLots*PipValue*(+PL9-PL0+TZ8-step2)
            +(Vl1*PipValue*(+PL9-PL1+TZ8))
            +(Vl2*PipValue*(+PL9-PL2+TZ8))
            +(Vl3*PipValue*(+PL9-PL3+TZ8))
            +(Vl4*PipValue*(+PL9-PL4+TZ8))
            +(Vl5*PipValue*(+PL9-PL5+TZ8))
            +(Vl6*PipValue*(+PL9-PL6+TZ8))
            +(Vl7*PipValue*(+PL9-PL7+TZ8))
            +(Vl8*PipValue*(+PL9-PL8+TZ8));
      Loss9=NormalizeDouble(MathAbs(Loss9*100000),decimalPlace);
      Vl9=NormalizeDouble(Loss9/TZ8/PipValue/100000,decimalPlace);
     }
   if(CONTOR==3)
     {
      Loss9=3*InpLots*PipValue*(+PL9-PL0+TZ8-step3)
            +(Vl1*PipValue*(+PL9-PL1+TZ8))
            +(Vl2*PipValue*(+PL9-PL2+TZ8))
            +(Vl3*PipValue*(+PL9-PL3+TZ8))
            +(Vl4*PipValue*(+PL9-PL4+TZ8))
            +(Vl5*PipValue*(+PL9-PL5+TZ8))
            +(Vl6*PipValue*(+PL9-PL6+TZ8))
            +(Vl7*PipValue*(+PL9-PL7+TZ8))
            +(Vl8*PipValue*(+PL9-PL8+TZ8));
      Loss9=NormalizeDouble(MathAbs(Loss9*100000),decimalPlace);
      Vl9=NormalizeDouble(Loss9/TZ8/PipValue/100000,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss9:",Loss9," Vl9: ",Vl9);
  }

//+++----------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V10()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss10=InpLots*PipValue*(+PL10-PL0+TZ)
             +(Vl1*PipValue*(+PL10-PL1+TZ))
             +(Vl2*PipValue*(+PL10-PL2+TZ))
             +(Vl3*PipValue*(+PL10-PL3+TZ))
             +(Vl4*PipValue*(+PL10-PL4+TZ))
             +(Vl5*PipValue*(+PL10-PL5+TZ))
             +(Vl6*PipValue*(+PL10-PL6+TZ))
             +(Vl7*PipValue*(+PL10-PL7+TZ))
             +(Vl8*PipValue*(+PL10-PL8+TZ))
             +(Vl8*PipValue*(+PL10-PL8+TZ))
             +(Vl9*PipValue*(+PL10-PL9+TZ));
      Vl10=NormalizeDouble(MathAbs(Loss10)/TZ/PipValue,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss10=2*InpLots*PipValue*(+PL10-PL0+TZ+step2)
             +(Vl1*PipValue*(+PL10-PL1+TZ))
             +(Vl2*PipValue*(+PL10-PL2+TZ))
             +(Vl3*PipValue*(+PL10-PL3+TZ))
             +(Vl4*PipValue*(+PL10-PL4+TZ))
             +(Vl5*PipValue*(+PL10-PL5+TZ))
             +(Vl6*PipValue*(+PL10-PL6+TZ))
             +(Vl7*PipValue*(+PL10-PL7+TZ))
             +(Vl8*PipValue*(+PL10-PL8+TZ))
             +(Vl8*PipValue*(+PL10-PL8+TZ))
             +(Vl9*PipValue*(+PL10-PL9+TZ));
      Vl10=NormalizeDouble(MathAbs(Loss10)/TZ/PipValue,decimalPlace);
     }
   if(CONTOR==3)
     {
      Loss10=3*InpLots*PipValue*(+PL10-PL0+TZ+step3)
             +(Vl1*PipValue*(+PL10-PL1+TZ))
             +(Vl2*PipValue*(+PL10-PL2+TZ))
             +(Vl3*PipValue*(+PL10-PL3+TZ))
             +(Vl4*PipValue*(+PL10-PL4+TZ))
             +(Vl5*PipValue*(+PL10-PL5+TZ))
             +(Vl6*PipValue*(+PL10-PL6+TZ))
             +(Vl7*PipValue*(+PL10-PL7+TZ))
             +(Vl8*PipValue*(+PL10-PL8+TZ))
             +(Vl8*PipValue*(+PL10-PL8+TZ))
             +(Vl9*PipValue*(+PL10-PL9+TZ));
      Vl10=NormalizeDouble(MathAbs(Loss10)/TZ/PipValue,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss10:",Loss10," Vl10: ",Vl10);
  }
//++++++-------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V10M()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss10=InpLots*PipValue*(+PL10-PL0+TZ9)
             +(Vl1*PipValue*(+PL10-PL1+TZ9))
             +(Vl2*PipValue*(+PL10-PL2+TZ9))
             +(Vl3*PipValue*(+PL10-PL3+TZ9))
             +(Vl4*PipValue*(+PL10-PL4+TZ9))
             +(Vl5*PipValue*(+PL10-PL5+TZ9))
             +(Vl6*PipValue*(+PL10-PL6+TZ9))
             +(Vl7*PipValue*(+PL10-PL7+TZ9))
             +(Vl8*PipValue*(+PL10-PL8+TZ9))
             +(Vl8*PipValue*(+PL10-PL8+TZ9))
             +(Vl9*PipValue*(+PL10-PL9+TZ9));
      Vl10=NormalizeDouble(MathAbs(Loss10)/TZ9/PipValue,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss10=2*InpLots*PipValue*(+PL10-PL0+TZ9+step2)
             +(Vl1*PipValue*(+PL10-PL1+TZ9))
             +(Vl2*PipValue*(+PL10-PL2+TZ9))
             +(Vl3*PipValue*(+PL10-PL3+TZ9))
             +(Vl4*PipValue*(+PL10-PL4+TZ9))
             +(Vl5*PipValue*(+PL10-PL5+TZ9))
             +(Vl6*PipValue*(+PL10-PL6+TZ9))
             +(Vl7*PipValue*(+PL10-PL7+TZ9))
             +(Vl8*PipValue*(+PL10-PL8+TZ9))
             +(Vl8*PipValue*(+PL10-PL8+TZ9))
             +(Vl9*PipValue*(+PL10-PL9+TZ9));
      Vl10=NormalizeDouble(MathAbs(Loss10)/TZ9/PipValue,decimalPlace);
     }
   if(CONTOR==3)
     {
      Loss10=3*InpLots*PipValue*(+PL10-PL0+TZ9+step3)
             +(Vl1*PipValue*(+PL10-PL1+TZ9))
             +(Vl2*PipValue*(+PL10-PL2+TZ9))
             +(Vl3*PipValue*(+PL10-PL3+TZ9))
             +(Vl4*PipValue*(+PL10-PL4+TZ9))
             +(Vl5*PipValue*(+PL10-PL5+TZ9))
             +(Vl6*PipValue*(+PL10-PL6+TZ9))
             +(Vl7*PipValue*(+PL10-PL7+TZ9))
             +(Vl8*PipValue*(+PL10-PL8+TZ9))
             +(Vl8*PipValue*(+PL10-PL8+TZ9))
             +(Vl9*PipValue*(+PL10-PL9+TZ9));
      Vl10=NormalizeDouble(MathAbs(Loss10)/TZ9/PipValue,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss10:",Loss10," Vl10: ",Vl10);
  }

//++-----------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V11()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss11=InpLots*PipValue*(PL11-PL0+TZ)
             +(Vl1*PipValue*(PL11-PL1+TZ))
             +(Vl2*PipValue*(PL11-PL2+TZ))
             +(Vl3*PipValue*(PL11-PL3+TZ))
             +(Vl4*PipValue*(PL11-PL4+TZ))
             +(Vl5*PipValue*(PL11-PL5+TZ))
             +(Vl6*PipValue*(PL11-PL6+TZ))
             +(Vl7*PipValue*(PL11-PL7+TZ))
             +(Vl8*PipValue*(PL11-PL8+TZ))
             +(Vl8*PipValue*(PL11-PL9+TZ))
             +(Vl9*PipValue*(PL11-PL9+TZ))
             +(Vl10*PipValue*(PL11-PL10+TZ));
      Vl11=NormalizeDouble(MathAbs(Loss11)/TZ/PipValue,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss11=2*InpLots*PipValue*(PL11-PL0+TZ+step2)
             +(Vl1*PipValue*(PL11-PL1+TZ))
             +(Vl2*PipValue*(PL11-PL2+TZ))
             +(Vl3*PipValue*(PL11-PL3+TZ))
             +(Vl4*PipValue*(PL11-PL4+TZ))
             +(Vl5*PipValue*(PL11-PL5+TZ))
             +(Vl6*PipValue*(PL11-PL6+TZ))
             +(Vl7*PipValue*(PL11-PL7+TZ))
             +(Vl8*PipValue*(PL11-PL8+TZ))
             +(Vl8*PipValue*(PL11-PL9+TZ))
             +(Vl9*PipValue*(PL11-PL9+TZ))
             +(Vl10*PipValue*(PL11-PL10+TZ));
      Vl11=NormalizeDouble(MathAbs(Loss11)/TZ/PipValue,decimalPlace);
     }
   if(CONTOR==3)
     {
      Loss11=3*InpLots*PipValue*(-PL11+PL0+TZ+step3)
             +(Vl1*PipValue*(-PL11+PL1+TZ))
             +(Vl2*PipValue*(-PL11+PL2+TZ))
             +(Vl3*PipValue*(-PL11+PL3+TZ))
             +(Vl4*PipValue*(-PL11+PL4+TZ))
             +(Vl5*PipValue*(-PL11+PL5+TZ))
             +(Vl6*PipValue*(-PL11+PL6+TZ))
             +(Vl7*PipValue*(-PL11+PL7+TZ))
             +(Vl8*PipValue*(-PL11+PL8+TZ))
             +(Vl8*PipValue*(-PL11+PL9+TZ))
             +(Vl9*PipValue*(-PL11+PL9+TZ))
             +(Vl10*PipValue*(-PL11+PL10+TZ));
      Vl11=NormalizeDouble(MathAbs(Loss11)/TZ/PipValue,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss11:",Loss11," Vl11: ",Vl11);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V12()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss12=InpLots*PipValue*(-PL12+PL0+TZ)
             +(Vl1*PipValue*(-PL12+PL1+TZ))
             +(Vl2*PipValue*(-PL12+PL2+TZ))
             +(Vl3*PipValue*(-PL12+PL3+TZ))
             +(Vl4*PipValue*(-PL12+PL4+TZ))
             +(Vl5*PipValue*(-PL12+PL5+TZ))
             +(Vl6*PipValue*(-PL12+PL6+TZ))
             +(Vl7*PipValue*(-PL12+PL7+TZ))
             +(Vl8*PipValue*(-PL12+PL8+TZ))
             +(Vl8*PipValue*(-PL12+PL9+TZ))
             +(Vl9*PipValue*(-PL12+PL9+TZ))
             +(Vl10*PipValue*(-PL12+PL10+TZ))
             +(Vl11*PipValue*(-PL12+PL11+TZ));
      Vl12=NormalizeDouble(MathAbs(Loss12)/TZ/PipValue,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss12=2*InpLots*PipValue*(-PL12+PL0+TZ+step2)
             +(Vl1*PipValue*(-PL12+PL1+TZ))
             +(Vl2*PipValue*(-PL12+PL2+TZ))
             +(Vl3*PipValue*(-PL12+PL3+TZ))
             +(Vl4*PipValue*(-PL12+PL4+TZ))
             +(Vl5*PipValue*(-PL12+PL5+TZ))
             +(Vl6*PipValue*(-PL12+PL6+TZ))
             +(Vl7*PipValue*(-PL12+PL7+TZ))
             +(Vl8*PipValue*(-PL12+PL8+TZ))
             +(Vl8*PipValue*(-PL12+PL9+TZ))
             +(Vl9*PipValue*(-PL12+PL9+TZ))
             +(Vl10*PipValue*(-PL12+PL10+TZ))
             +(Vl11*PipValue*(-PL12+PL11+TZ));
      Vl12=NormalizeDouble(MathAbs(Loss12)/TZ/PipValue,decimalPlace);
     }
   if(CONTOR==3)
     {
      Loss12=3*InpLots*PipValue*(-PL12+PL0+TZ+step3)
             +(Vl1*PipValue*(-PL12+PL1+TZ))
             +(Vl2*PipValue*(-PL12+PL2+TZ))
             +(Vl3*PipValue*(-PL12+PL3+TZ))
             +(Vl4*PipValue*(-PL12+PL4+TZ))
             +(Vl5*PipValue*(-PL12+PL5+TZ))
             +(Vl6*PipValue*(-PL12+PL6+TZ))
             +(Vl7*PipValue*(-PL12+PL7+TZ))
             +(Vl8*PipValue*(-PL12+PL8+TZ))
             +(Vl8*PipValue*(-PL12+PL9+TZ))
             +(Vl9*PipValue*(-PL12+PL9+TZ))
             +(Vl10*PipValue*(-PL12+PL10+TZ))
             +(Vl11*PipValue*(-PL12+PL11+TZ));
      Vl12=NormalizeDouble(MathAbs(Loss12)/TZ/PipValue,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss12:",Loss12," Vl12: ",Vl12);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V13()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss13=InpLots*PipValue*(-PL13+PL0+TZ)
             +(Vl1*PipValue*(-PL13+PL1+TZ))
             +(Vl2*PipValue*(-PL13+PL2+TZ))
             +(Vl3*PipValue*(-PL13+PL3+TZ))
             +(Vl4*PipValue*(-PL13+PL4+TZ))
             +(Vl5*PipValue*(-PL13+PL5+TZ))
             +(Vl6*PipValue*(-PL13+PL6+TZ))
             +(Vl7*PipValue*(-PL13+PL7+TZ))
             +(Vl8*PipValue*(-PL13+PL8+TZ))
             +(Vl8*PipValue*(-PL13+PL9+TZ))
             +(Vl9*PipValue*(-PL13+PL9+TZ))
             +(Vl10*PipValue*(-PL13+PL10+TZ))
             +(Vl11*PipValue*(-PL13+PL11+TZ))
             +(Vl12*PipValue*(-PL13+PL12+TZ));
      Vl13=NormalizeDouble(MathAbs(Loss13)/TZ/PipValue,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss13=2*InpLots*PipValue*(-PL13+PL0+TZ+step2)
             +(Vl1*PipValue*(-PL13+PL1+TZ))
             +(Vl2*PipValue*(-PL13+PL2+TZ))
             +(Vl3*PipValue*(-PL13+PL3+TZ))
             +(Vl4*PipValue*(-PL13+PL4+TZ))
             +(Vl5*PipValue*(-PL13+PL5+TZ))
             +(Vl6*PipValue*(-PL13+PL6+TZ))
             +(Vl7*PipValue*(-PL13+PL7+TZ))
             +(Vl8*PipValue*(-PL13+PL8+TZ))
             +(Vl8*PipValue*(-PL13+PL9+TZ))
             +(Vl9*PipValue*(-PL13+PL9+TZ))
             +(Vl10*PipValue*(-PL13+PL10+TZ))
             +(Vl11*PipValue*(-PL13+PL11+TZ))
             +(Vl12*PipValue*(-PL13+PL12+TZ));
      Vl13=NormalizeDouble(MathAbs(Loss13)/TZ/PipValue,decimalPlace);
     }
   if(CONTOR==3)
     {
      Loss13=3*InpLots*PipValue*(-PL13+PL0+TZ+step3)
             +(Vl1*PipValue*(-PL13+PL1+TZ))
             +(Vl2*PipValue*(-PL13+PL2+TZ))
             +(Vl3*PipValue*(-PL13+PL3+TZ))
             +(Vl4*PipValue*(-PL13+PL4+TZ))
             +(Vl5*PipValue*(-PL13+PL5+TZ))
             +(Vl6*PipValue*(-PL13+PL6+TZ))
             +(Vl7*PipValue*(-PL13+PL7+TZ))
             +(Vl8*PipValue*(-PL13+PL8+TZ))
             +(Vl8*PipValue*(-PL13+PL9+TZ))
             +(Vl9*PipValue*(-PL13+PL9+TZ))
             +(Vl10*PipValue*(-PL13+PL10+TZ))
             +(Vl11*PipValue*(-PL13+PL11+TZ))
             +(Vl12*PipValue*(-PL13+PL12+TZ));
      Vl13=NormalizeDouble(MathAbs(Loss13)/TZ/PipValue,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss13:",Loss13," Vl13: ",Vl13);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V14()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss14=InpLots*PipValue*(-PL14+PL0+TZ)
             +(Vl1*PipValue*(-PL14+PL1+TZ))
             +(Vl2*PipValue*(-PL14+PL2+TZ))
             +(Vl3*PipValue*(-PL14+PL3+TZ))
             +(Vl4*PipValue*(-PL14+PL4+TZ))
             +(Vl5*PipValue*(-PL14+PL5+TZ))
             +(Vl6*PipValue*(-PL14+PL6+TZ))
             +(Vl7*PipValue*(-PL14+PL7+TZ))
             +(Vl8*PipValue*(-PL14+PL8+TZ))
             +(Vl8*PipValue*(-PL14+PL9+TZ))
             +(Vl9*PipValue*(-PL14+PL9+TZ))
             +(Vl10*PipValue*(-PL14+PL10+TZ))
             +(Vl11*PipValue*(-PL14+PL11+TZ))
             +(Vl12*PipValue*(-PL14+PL12+TZ))
             +(Vl13*PipValue*(-PL14+PL13+TZ));
      Vl14=NormalizeDouble(MathAbs(Loss14)/TZ/PipValue,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss14=2*InpLots*PipValue*(-PL14+PL0+TZ+step2)
             +(Vl1*PipValue*(-PL14+PL1+TZ))
             +(Vl2*PipValue*(-PL14+PL2+TZ))
             +(Vl3*PipValue*(-PL14+PL3+TZ))
             +(Vl4*PipValue*(-PL14+PL4+TZ))
             +(Vl5*PipValue*(-PL14+PL5+TZ))
             +(Vl6*PipValue*(-PL14+PL6+TZ))
             +(Vl7*PipValue*(-PL14+PL7+TZ))
             +(Vl8*PipValue*(-PL14+PL8+TZ))
             +(Vl8*PipValue*(-PL14+PL9+TZ))
             +(Vl9*PipValue*(-PL14+PL9+TZ))
             +(Vl10*PipValue*(-PL14+PL10+TZ))
             +(Vl11*PipValue*(-PL14+PL11+TZ))
             +(Vl12*PipValue*(-PL14+PL12+TZ))
             +(Vl13*PipValue*(-PL14+PL13+TZ));
      Vl14=NormalizeDouble(MathAbs(Loss14)/TZ/PipValue,decimalPlace);
     }
   if(CONTOR==3)
     {
      Loss14=3*InpLots*PipValue*(-PL14+PL0+TZ+step3)
             +(Vl1*PipValue*(-PL14+PL1+TZ))
             +(Vl2*PipValue*(-PL14+PL2+TZ))
             +(Vl3*PipValue*(-PL14+PL3+TZ))
             +(Vl4*PipValue*(-PL14+PL4+TZ))
             +(Vl5*PipValue*(-PL14+PL5+TZ))
             +(Vl6*PipValue*(-PL14+PL6+TZ))
             +(Vl7*PipValue*(-PL14+PL7+TZ))
             +(Vl8*PipValue*(-PL14+PL8+TZ))
             +(Vl8*PipValue*(-PL14+PL9+TZ))
             +(Vl9*PipValue*(-PL14+PL9+TZ))
             +(Vl10*PipValue*(-PL14+PL10+TZ))
             +(Vl11*PipValue*(-PL14+PL11+TZ))
             +(Vl12*PipValue*(-PL14+PL12+TZ))
             +(Vl13*PipValue*(-PL14+PL13+TZ));
      Vl14=NormalizeDouble(MathAbs(Loss14)/TZ/PipValue,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss14:",Loss14," Vl14: ",Vl14);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V15()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss15=InpLots*PipValue*(-PL15+PL0+TZ)
             +(Vl1*PipValue*(-PL15+PL1+TZ))
             +(Vl2*PipValue*(-PL15+PL2+TZ))
             +(Vl3*PipValue*(-PL15+PL3+TZ))
             +(Vl4*PipValue*(-PL15+PL4+TZ))
             +(Vl5*PipValue*(-PL15+PL5+TZ))
             +(Vl6*PipValue*(-PL15+PL6+TZ))
             +(Vl7*PipValue*(-PL15+PL7+TZ))
             +(Vl8*PipValue*(-PL15+PL8+TZ))
             +(Vl8*PipValue*(-PL15+PL9+TZ))
             +(Vl9*PipValue*(-PL15+PL9+TZ))
             +(Vl10*PipValue*(-PL15+PL10+TZ))
             +(Vl11*PipValue*(-PL15+PL11+TZ))
             +(Vl12*PipValue*(-PL15+PL12+TZ))
             +(Vl13*PipValue*(-PL15+PL13+TZ))
             +(Vl14*PipValue*(-PL15+PL14+TZ));
      Vl15=NormalizeDouble(MathAbs(Loss15)/TZ/PipValue,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss15=2*InpLots*PipValue*(-PL15+PL0+TZ+step2)
             +(Vl1*PipValue*(-PL15+PL1+TZ))
             +(Vl2*PipValue*(-PL15+PL2+TZ))
             +(Vl3*PipValue*(-PL15+PL3+TZ))
             +(Vl4*PipValue*(-PL15+PL4+TZ))
             +(Vl5*PipValue*(-PL15+PL5+TZ))
             +(Vl6*PipValue*(-PL15+PL6+TZ))
             +(Vl7*PipValue*(-PL15+PL7+TZ))
             +(Vl8*PipValue*(-PL15+PL8+TZ))
             +(Vl8*PipValue*(-PL15+PL9+TZ))
             +(Vl9*PipValue*(-PL15+PL9+TZ))
             +(Vl10*PipValue*(-PL15+PL10+TZ))
             +(Vl11*PipValue*(-PL15+PL11+TZ))
             +(Vl12*PipValue*(-PL15+PL12+TZ))
             +(Vl13*PipValue*(-PL15+PL13+TZ))
             +(Vl14*PipValue*(-PL15+PL14+TZ));
      Vl15=NormalizeDouble(MathAbs(Loss15)/TZ/PipValue,decimalPlace);
     }
   if(CONTOR==3)
     {
      Loss15=3*InpLots*PipValue*(-PL15+PL0+TZ+step3)
             +(Vl1*PipValue*(-PL15+PL1+TZ))
             +(Vl2*PipValue*(-PL15+PL2+TZ))
             +(Vl3*PipValue*(-PL15+PL3+TZ))
             +(Vl4*PipValue*(-PL15+PL4+TZ))
             +(Vl5*PipValue*(-PL15+PL5+TZ))
             +(Vl6*PipValue*(-PL15+PL6+TZ))
             +(Vl7*PipValue*(-PL15+PL7+TZ))
             +(Vl8*PipValue*(-PL15+PL8+TZ))
             +(Vl8*PipValue*(-PL15+PL9+TZ))
             +(Vl9*PipValue*(-PL15+PL9+TZ))
             +(Vl10*PipValue*(-PL15+PL10+TZ))
             +(Vl11*PipValue*(-PL15+PL11+TZ))
             +(Vl12*PipValue*(-PL15+PL12+TZ))
             +(Vl13*PipValue*(-PL15+PL13+TZ))
             +(Vl14*PipValue*(-PL15+PL14+TZ));
      Vl15=NormalizeDouble(MathAbs(Loss15)/TZ/PipValue,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss15:",Loss15," Vl15: ",Vl15);
  }

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//|                                                                  |
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
void Calculate_V16()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss16=InpLots*PipValue*(-PL16+PL0+TZ)
             +(Vl1*PipValue*(-PL16+PL1+TZ))
             +(Vl2*PipValue*(-PL16+PL2+TZ))
             +(Vl3*PipValue*(-PL16+PL3+TZ))
             +(Vl4*PipValue*(-PL16+PL4+TZ))
             +(Vl5*PipValue*(-PL16+PL5+TZ))
             +(Vl6*PipValue*(-PL16+PL6+TZ))
             +(Vl7*PipValue*(-PL16+PL7+TZ))
             +(Vl8*PipValue*(-PL16+PL8+TZ))
             +(Vl8*PipValue*(-PL16+PL9+TZ))
             +(Vl9*PipValue*(-PL16+PL9+TZ))
             +(Vl10*PipValue*(-PL16+PL10+TZ))
             +(Vl11*PipValue*(-PL16+PL11+TZ))
             +(Vl12*PipValue*(-PL16+PL12+TZ))
             +(Vl13*PipValue*(-PL16+PL13+TZ))
             +(Vl14*PipValue*(-PL16+PL14+TZ))
             +(Vl15*PipValue*(-PL16+PL15+TZ));
      Vl16=NormalizeDouble(MathAbs(Loss16)/TZ/PipValue,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss16=2*InpLots*PipValue*(-PL16+PL0+TZ+step2)
             +(Vl1*PipValue*(-PL16+PL1+TZ))
             +(Vl2*PipValue*(-PL16+PL2+TZ))
             +(Vl3*PipValue*(-PL16+PL3+TZ))
             +(Vl4*PipValue*(-PL16+PL4+TZ))
             +(Vl5*PipValue*(-PL16+PL5+TZ))
             +(Vl6*PipValue*(-PL16+PL6+TZ))
             +(Vl7*PipValue*(-PL16+PL7+TZ))
             +(Vl8*PipValue*(-PL16+PL8+TZ))
             +(Vl8*PipValue*(-PL16+PL9+TZ))
             +(Vl9*PipValue*(-PL16+PL9+TZ))
             +(Vl10*PipValue*(-PL16+PL10+TZ))
             +(Vl11*PipValue*(-PL16+PL11+TZ))
             +(Vl12*PipValue*(-PL16+PL12+TZ))
             +(Vl13*PipValue*(-PL16+PL13+TZ))
             +(Vl14*PipValue*(-PL16+PL14+TZ))
             +(Vl15*PipValue*(-PL16+PL15+TZ));
      Vl16=NormalizeDouble(MathAbs(Loss16)/TZ/PipValue,decimalPlace);
     }
   if(CONTOR==3)
     {
      Loss16=3*InpLots*PipValue*(-PL16+PL0+TZ+step3)
             +(Vl1*PipValue*(-PL16+PL1+TZ))
             +(Vl2*PipValue*(-PL16+PL2+TZ))
             +(Vl3*PipValue*(-PL16+PL3+TZ))
             +(Vl4*PipValue*(-PL16+PL4+TZ))
             +(Vl5*PipValue*(-PL16+PL5+TZ))
             +(Vl6*PipValue*(-PL16+PL6+TZ))
             +(Vl7*PipValue*(-PL16+PL7+TZ))
             +(Vl8*PipValue*(-PL16+PL8+TZ))
             +(Vl8*PipValue*(-PL16+PL9+TZ))
             +(Vl9*PipValue*(-PL16+PL9+TZ))
             +(Vl10*PipValue*(-PL16+PL10+TZ))
             +(Vl11*PipValue*(-PL16+PL11+TZ))
             +(Vl12*PipValue*(-PL16+PL12+TZ))
             +(Vl13*PipValue*(-PL16+PL13+TZ))
             +(Vl14*PipValue*(-PL16+PL14+TZ))
             +(Vl15*PipValue*(-PL16+PL15+TZ));
      Vl16=NormalizeDouble(MathAbs(Loss16)/TZ/PipValue,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss16:",Loss16," Vl16: ",Vl16);
  }

//++++++++++---------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V17()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss17=InpLots*PipValue*(-PL17+PL0+TZ)
             +(Vl1*PipValue*(-PL17+PL1+TZ))
             +(Vl2*PipValue*(-PL17+PL2+TZ))
             +(Vl3*PipValue*(-PL17+PL3+TZ))
             +(Vl4*PipValue*(-PL17+PL4+TZ))
             +(Vl5*PipValue*(-PL17+PL5+TZ))
             +(Vl6*PipValue*(-PL17+PL6+TZ))
             +(Vl7*PipValue*(-PL17+PL7+TZ))
             +(Vl8*PipValue*(-PL17+PL8+TZ))
             +(Vl8*PipValue*(-PL17+PL9+TZ))
             +(Vl9*PipValue*(-PL17+PL9+TZ))
             +(Vl10*PipValue*(-PL17+PL10+TZ))
             +(Vl11*PipValue*(-PL17+PL11+TZ))
             +(Vl12*PipValue*(-PL17+PL12+TZ))
             +(Vl13*PipValue*(-PL17+PL13+TZ))
             +(Vl14*PipValue*(-PL17+PL14+TZ))
             +(Vl15*PipValue*(-PL17+PL15+TZ))
             +(Vl16*PipValue*(-PL17+PL16+TZ));
      Vl17=NormalizeDouble(MathAbs(Loss17)/TZ/PipValue,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss17=2*InpLots*PipValue*(-PL17+PL0+TZ+step2)
             +(Vl1*PipValue*(-PL17+PL1+TZ))
             +(Vl2*PipValue*(-PL17+PL2+TZ))
             +(Vl3*PipValue*(-PL17+PL3+TZ))
             +(Vl4*PipValue*(-PL17+PL4+TZ))
             +(Vl5*PipValue*(-PL17+PL5+TZ))
             +(Vl6*PipValue*(-PL17+PL6+TZ))
             +(Vl7*PipValue*(-PL17+PL7+TZ))
             +(Vl8*PipValue*(-PL17+PL8+TZ))
             +(Vl8*PipValue*(-PL17+PL9+TZ))
             +(Vl9*PipValue*(-PL17+PL9+TZ))
             +(Vl10*PipValue*(-PL17+PL10+TZ))
             +(Vl11*PipValue*(-PL17+PL11+TZ))
             +(Vl12*PipValue*(-PL17+PL12+TZ))
             +(Vl13*PipValue*(-PL17+PL13+TZ))
             +(Vl14*PipValue*(-PL17+PL14+TZ))
             +(Vl15*PipValue*(-PL17+PL15+TZ))
             +(Vl16*PipValue*(-PL17+PL16+TZ));
      Vl17=NormalizeDouble(MathAbs(Loss17)/TZ/PipValue,decimalPlace);
     }
   if(CONTOR==3)
     {

      Loss17=3*InpLots*PipValue*(-PL17+PL0+TZ+step3)
             +(Vl1*PipValue*(-PL17+PL1+TZ))
             +(Vl2*PipValue*(-PL17+PL2+TZ))
             +(Vl3*PipValue*(-PL17+PL3+TZ))
             +(Vl4*PipValue*(-PL17+PL4+TZ))
             +(Vl5*PipValue*(-PL17+PL5+TZ))
             +(Vl6*PipValue*(-PL17+PL6+TZ))
             +(Vl7*PipValue*(-PL17+PL7+TZ))
             +(Vl8*PipValue*(-PL17+PL8+TZ))
             +(Vl8*PipValue*(-PL17+PL9+TZ))
             +(Vl9*PipValue*(-PL17+PL9+TZ))
             +(Vl10*PipValue*(-PL17+PL10+TZ))
             +(Vl11*PipValue*(-PL17+PL11+TZ))
             +(Vl12*PipValue*(-PL17+PL12+TZ))
             +(Vl13*PipValue*(-PL17+PL13+TZ))
             +(Vl14*PipValue*(-PL17+PL14+TZ))
             +(Vl15*PipValue*(-PL17+PL15+TZ))
             +(Vl16*PipValue*(-PL17+PL16+TZ));
      Vl17=NormalizeDouble(MathAbs(Loss17)/TZ/PipValue,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss17:",Loss17," Vl17: ",Vl17);
  }

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//|                                                                  |
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
void Calculate_V18()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss18=InpLots*PipValue*(-PL18+PL0+TZ)
             +(Vl1*PipValue*(-PL18+PL1+TZ))
             +(Vl2*PipValue*(-PL18+PL2+TZ))
             +(Vl3*PipValue*(-PL18+PL3+TZ))
             +(Vl4*PipValue*(-PL18+PL4+TZ))
             +(Vl5*PipValue*(-PL18+PL5+TZ))
             +(Vl6*PipValue*(-PL18+PL6+TZ))
             +(Vl7*PipValue*(-PL18+PL7+TZ))
             +(Vl8*PipValue*(-PL18+PL8+TZ))
             +(Vl8*PipValue*(-PL18+PL9+TZ))
             +(Vl9*PipValue*(-PL18+PL9+TZ))
             +(Vl10*PipValue*(-PL18+PL10+TZ))
             +(Vl11*PipValue*(-PL18+PL11+TZ))
             +(Vl12*PipValue*(-PL18+PL12+TZ))
             +(Vl13*PipValue*(-PL18+PL13+TZ))
             +(Vl14*PipValue*(-PL18+PL14+TZ))
             +(Vl15*PipValue*(-PL18+PL15+TZ))
             +(Vl16*PipValue*(-PL18+PL16+TZ))
             +(Vl17*PipValue*(-PL18+PL17+TZ));
      Vl18=NormalizeDouble(MathAbs(Loss18)/TZ/PipValue,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss18=2*InpLots*PipValue*(-PL18+PL0+TZ+step2)
             +(Vl1*PipValue*(-PL18+PL1+TZ))
             +(Vl2*PipValue*(-PL18+PL2+TZ))
             +(Vl3*PipValue*(-PL18+PL3+TZ))
             +(Vl4*PipValue*(-PL18+PL4+TZ))
             +(Vl5*PipValue*(-PL18+PL5+TZ))
             +(Vl6*PipValue*(-PL18+PL6+TZ))
             +(Vl7*PipValue*(-PL18+PL7+TZ))
             +(Vl8*PipValue*(-PL18+PL8+TZ))
             +(Vl8*PipValue*(-PL18+PL9+TZ))
             +(Vl9*PipValue*(-PL18+PL9+TZ))
             +(Vl10*PipValue*(-PL18+PL10+TZ))
             +(Vl11*PipValue*(-PL18+PL11+TZ))
             +(Vl12*PipValue*(-PL18+PL12+TZ))
             +(Vl13*PipValue*(-PL18+PL13+TZ))
             +(Vl14*PipValue*(-PL18+PL14+TZ))
             +(Vl15*PipValue*(-PL18+PL15+TZ))
             +(Vl16*PipValue*(-PL18+PL16+TZ))
             +(Vl17*PipValue*(-PL18+PL17+TZ));
      Vl18=NormalizeDouble(MathAbs(Loss18)/TZ/PipValue,decimalPlace);
     }
   if(CONTOR==3)
     {

      Loss18=3*InpLots*PipValue*(-PL18+PL0+TZ+step3)
             +(Vl1*PipValue*(-PL18+PL1+TZ))
             +(Vl2*PipValue*(-PL18+PL2+TZ))
             +(Vl3*PipValue*(-PL18+PL3+TZ))
             +(Vl4*PipValue*(-PL18+PL4+TZ))
             +(Vl5*PipValue*(-PL18+PL5+TZ))
             +(Vl6*PipValue*(-PL18+PL6+TZ))
             +(Vl7*PipValue*(-PL18+PL7+TZ))
             +(Vl8*PipValue*(-PL18+PL8+TZ))
             +(Vl8*PipValue*(-PL18+PL9+TZ))
             +(Vl9*PipValue*(-PL18+PL9+TZ))
             +(Vl10*PipValue*(-PL18+PL10+TZ))
             +(Vl11*PipValue*(-PL18+PL11+TZ))
             +(Vl12*PipValue*(-PL18+PL12+TZ))
             +(Vl13*PipValue*(-PL18+PL13+TZ))
             +(Vl14*PipValue*(-PL18+PL14+TZ))
             +(Vl15*PipValue*(-PL18+PL15+TZ))
             +(Vl16*PipValue*(-PL18+PL16+TZ))
             +(Vl17*PipValue*(-PL18+PL17+TZ));
      Vl18=NormalizeDouble(MathAbs(Loss18)/TZ/PipValue,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss18:",Loss18," Vl18: ",Vl18);
  }

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//|                                                                  |
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
void Calculate_V19()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
     {
      Loss19=InpLots*PipValue*(-PL19+PL0+TZ)
             +(Vl1*PipValue*(-PL19+PL1+TZ))
             +(Vl2*PipValue*(-PL19+PL2+TZ))
             +(Vl3*PipValue*(-PL19+PL3+TZ))
             +(Vl4*PipValue*(-PL19+PL4+TZ))
             +(Vl5*PipValue*(-PL19+PL5+TZ))
             +(Vl6*PipValue*(-PL19+PL6+TZ))
             +(Vl7*PipValue*(-PL19+PL7+TZ))
             +(Vl8*PipValue*(-PL19+PL8+TZ))
             +(Vl8*PipValue*(-PL19+PL9+TZ))
             +(Vl9*PipValue*(-PL19+PL9+TZ))
             +(Vl10*PipValue*(-PL19+PL10+TZ))
             +(Vl11*PipValue*(-PL19+PL11+TZ))
             +(Vl12*PipValue*(-PL19+PL12+TZ))
             +(Vl13*PipValue*(-PL19+PL13+TZ))
             +(Vl14*PipValue*(-PL19+PL14+TZ))
             +(Vl15*PipValue*(-PL19+PL15+TZ))
             +(Vl16*PipValue*(-PL19+PL16+TZ))
             +(Vl17*PipValue*(-PL19+PL17+TZ))
             +(Vl18*PipValue*(-PL19+PL18+TZ));
      Vl19=NormalizeDouble(MathAbs(Loss19)/TZ/PipValue,decimalPlace);

     }
   if(CONTOR==2)
     {
      Loss19=2*InpLots*PipValue*(-PL19+PL0+TZ+step2)
             +(Vl1*PipValue*(-PL19+PL1+TZ))
             +(Vl2*PipValue*(-PL19+PL2+TZ))
             +(Vl3*PipValue*(-PL19+PL3+TZ))
             +(Vl4*PipValue*(-PL19+PL4+TZ))
             +(Vl5*PipValue*(-PL19+PL5+TZ))
             +(Vl6*PipValue*(-PL19+PL6+TZ))
             +(Vl7*PipValue*(-PL19+PL7+TZ))
             +(Vl8*PipValue*(-PL19+PL8+TZ))
             +(Vl8*PipValue*(-PL19+PL9+TZ))
             +(Vl9*PipValue*(-PL19+PL9+TZ))
             +(Vl10*PipValue*(-PL19+PL10+TZ))
             +(Vl11*PipValue*(-PL19+PL11+TZ))
             +(Vl12*PipValue*(-PL19+PL12+TZ))
             +(Vl13*PipValue*(-PL19+PL13+TZ))
             +(Vl14*PipValue*(-PL19+PL14+TZ))
             +(Vl15*PipValue*(-PL19+PL15+TZ))
             +(Vl16*PipValue*(-PL19+PL16+TZ))
             +(Vl17*PipValue*(-PL19+PL17+TZ))
             +(Vl18*PipValue*(-PL19+PL18+TZ));
      Vl19=NormalizeDouble(MathAbs(Loss19)/TZ/PipValue,decimalPlace);

     }
   if(CONTOR==3)
     {

      Loss19=3*InpLots*PipValue*(-PL19+PL0+TZ+step3)
             +(Vl1*PipValue*(-PL19+PL1+TZ))
             +(Vl2*PipValue*(-PL19+PL2+TZ))
             +(Vl3*PipValue*(-PL19+PL3+TZ))
             +(Vl4*PipValue*(-PL19+PL4+TZ))
             +(Vl5*PipValue*(-PL19+PL5+TZ))
             +(Vl6*PipValue*(-PL19+PL6+TZ))
             +(Vl7*PipValue*(-PL19+PL7+TZ))
             +(Vl8*PipValue*(-PL19+PL8+TZ))
             +(Vl8*PipValue*(-PL19+PL9+TZ))
             +(Vl9*PipValue*(-PL19+PL9+TZ))
             +(Vl10*PipValue*(-PL19+PL10+TZ))
             +(Vl11*PipValue*(-PL19+PL11+TZ))
             +(Vl12*PipValue*(-PL19+PL12+TZ))
             +(Vl13*PipValue*(-PL19+PL13+TZ))
             +(Vl14*PipValue*(-PL19+PL14+TZ))
             +(Vl15*PipValue*(-PL19+PL15+TZ))
             +(Vl16*PipValue*(-PL19+PL16+TZ))
             +(Vl17*PipValue*(-PL19+PL17+TZ))
             +(Vl18*PipValue*(-PL19+PL18+TZ));
      Vl19=NormalizeDouble(MathAbs(Loss19)/TZ/PipValue,decimalPlace);
     }
   Print("PipValue:",PipValue," Loss19:",Loss19," Vl19: ",Vl19);
  }
//SHORT CALCULATION

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V1S()
  {
   double PipValue = CalculatePipValue() * InpLots;
   if(CONTORS == 1)
     {
      Loss1S = InpLots * PipValue * (PL1S - PL0S - TZS);

      Vl1S = NormalizeDouble(MathAbs(Loss1S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 2)
     {
      Loss1S = 2 * InpLots * PipValue * (PL1S - PL0S - TZS +step2S);

      Vl1S = NormalizeDouble(MathAbs(Loss1S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 3)
     {
      Loss1S = 3 * InpLots * PipValue * (PL1S - PL0S - TZS + step3S);

      Vl1S = NormalizeDouble(MathAbs(Loss1S) / TZS / PipValue, decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss1S:", Loss1S, " Vl1S:", Vl1S);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V2S()
  {
   double PipValue = CalculatePipValue() * InpLots;
   if(CONTORS == 1)
     {
      Loss2S = InpLots * PipValue * (PL2S - PL0S - TZS)
               + (Vl1S * PipValue * (PL2S - PL1S - TZS));

      Vl2S = NormalizeDouble(MathAbs(Loss2S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 2)
     {
      Loss2S = 2 * InpLots * PipValue * (PL2S - PL0S  -TZS + step2S)
               + (Vl1S * PipValue * (PL2S - PL1S - TZS));

      Vl2S = NormalizeDouble(MathAbs(Loss2S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 3)
     {
      Loss2S = 3 * InpLots * PipValue * (PL2S - PL0S - TZS + step3S)
               + (Vl1S * PipValue * (PL2S - PL1S - TZS));

      Vl2S = NormalizeDouble(MathAbs(Loss2S) / TZS / PipValue, decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss2S:", Loss2S, " Vl2S:", Vl2S);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V2MS()
  {
   double PipValue = CalculatePipValue() * InpLots;
   if(CONTORS == 1)
     {
      Loss2S = InpLots * PipValue * (PL2S - PL0S - TZS1)
               + (Vl1S * PipValue * (PL2S - PL1S - TZS1));

      Vl2S = NormalizeDouble(MathAbs(Loss2S) / TZS1 / PipValue, decimalPlace);
     }
   if(CONTORS == 2)
     {
      Loss2S = 2 * InpLots * PipValue * (PL2S - PL0S - TZS1 + step2S)
               + (Vl1S * PipValue * (PL2S - PL1S - TZS1));

      Vl2S = NormalizeDouble(MathAbs(Loss2S) / TZS1 / PipValue, decimalPlace);
     }
   if(CONTORS == 3)
     {
      Loss2S = 3 * InpLots * PipValue * (PL2S - PL0S - TZS1+ step3S)
               + (Vl1S * PipValue * (PL2S - PL1S - TZS1));

      Vl2S = NormalizeDouble(MathAbs(Loss2S) / TZS1 / PipValue, decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss2S:", Loss2S, " Vl2S:", Vl2S);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V3S()
  {
   double PipValue = CalculatePipValue() * InpLots;
   if(CONTORS == 1)
     {
      Loss3S = InpLots * PipValue * (PL3S - PL0S - TZS)
               + (Vl1S * PipValue * (PL3S - PL1S - TZS))
               + (Vl2S * PipValue * (PL3S - PL2S - TZS));

      Vl3S = NormalizeDouble(MathAbs(Loss3S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 2)
     {
      Loss3S = 2 * InpLots * PipValue * (PL3S - PL0S - TZS + step2S)
               + (Vl1S * PipValue * (PL3S - PL1S - TZS))
               + (Vl2S * PipValue * (PL3S - PL2S - TZS));

      Vl3S = NormalizeDouble(MathAbs(Loss3S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 3)
     {
      Loss3S = 3 * InpLots * PipValue * (PL3S - PL0S - TZS + step3S)
               + (Vl1S * PipValue * (PL3S - PL1S - TZS))
               + (Vl2S * PipValue * (PL3S - PL2S - TZS));

      Vl3S = NormalizeDouble(MathAbs(Loss3S) / TZS / PipValue, decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss3S:", Loss3S, " Vl3S:", Vl3S);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V3MS()
  {
   double PipValue = CalculatePipValue() * InpLots;
   if(CONTORS == 1)
     {
      Loss3S = InpLots * PipValue * (PL3S - PL0S - TZS2)
               + (Vl1S * PipValue * (PL3S - PL1S - TZS2))
               + (Vl2S * PipValue * (PL3S - PL2S - TZS2));

      Vl3S = NormalizeDouble(MathAbs(Loss3S) / TZS2 / PipValue, decimalPlace);
     }
   if(CONTORS == 2)
     {
      Loss3S = 2 * InpLots * PipValue * (PL3S - PL0S - TZS2 + step2S)
               + (Vl1S * PipValue * (PL3S - PL1S - TZS2))
               + (Vl2S * PipValue * (PL3S - PL2S - TZS2));

      Vl3S = NormalizeDouble(MathAbs(Loss3S) / TZS2 / PipValue, decimalPlace);
     }
   if(CONTORS == 3)
     {
      Loss3S = 3 * InpLots * PipValue * (PL3S - PL0S - TZS2 + step3S)
               + (Vl1S * PipValue * (PL3S - PL1S - TZS2))
               + (Vl2S * PipValue * (PL3S - PL2S - TZS2));

      Vl3S = NormalizeDouble(MathAbs(Loss3S) / TZS2 / PipValue, decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss3S:", Loss3S, " Vl3S:", Vl3S);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V4S()
  {
   double PipValue = CalculatePipValue() * InpLots;
   if(CONTORS == 1)
     {
      Loss4S = InpLots * PipValue * (PL4S - PL0S - TZS)
               + (Vl1S * PipValue * (PL4S - PL1S - TZS))
               + (Vl2S * PipValue * (PL4S - PL2S - TZS))
               + (Vl3S * PipValue * (PL4S - PL3S - TZS));

      Vl4S = NormalizeDouble(MathAbs(Loss4S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 2)
     {
      Loss4S = 2 * InpLots * PipValue * (PL4S - PL0S - TZS + step2S)
               + (Vl1S * PipValue * (PL4S - PL1S - TZS))
               + (Vl2S * PipValue * (PL4S - PL2S - TZS))
               + (Vl3S * PipValue * (PL4S - PL3S - TZS));

      Vl4S = NormalizeDouble(MathAbs(Loss4S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 3)
     {
      Loss4S = 3 * InpLots * PipValue * (PL4S - PL0S - TZS + step3S)
               + (Vl1S * PipValue * (PL4S - PL1S - TZS))
               + (Vl2S * PipValue * (PL4S - PL2S - TZS))
               + (Vl3S * PipValue * (PL4S - PL3S - TZS));

      Vl4S = NormalizeDouble(MathAbs(Loss4S) / TZS / PipValue, decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss4S:", Loss4S, " Vl4S:", Vl4S);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V4MS()
  {
   double PipValue = CalculatePipValue() * InpLots;
   if(CONTORS == 1)
     {
      Loss4S = InpLots * PipValue * (PL4S - PL0S - TZS3)
               + (Vl1S * PipValue * (PL4S - PL1S - TZS3))
               + (Vl2S * PipValue * (PL4S - PL2S - TZS3))
               + (Vl3S * PipValue * (PL4S - PL3S - TZS3));

      Vl4S = NormalizeDouble(MathAbs(Loss4S) / TZS3 / PipValue, decimalPlace);
     }
   if(CONTORS == 2)
     {
      Loss4S = 2 * InpLots * PipValue * (PL4S - PL0S - TZS3 + step2S)
               + (Vl1S * PipValue * (PL4S - PL1S - TZS3))
               + (Vl2S * PipValue * (PL4S - PL2S - TZS3))
               + (Vl3S * PipValue * (PL4S - PL3S - TZS3));

      Vl4S = NormalizeDouble(MathAbs(Loss4S) / TZS3 / PipValue, decimalPlace);
     }
   if(CONTORS == 3)
     {
      Loss4S = 3 * InpLots * PipValue * (PL4S - PL0S - TZS3 + step3S)
               + (Vl1S * PipValue * (PL4S - PL1S - TZS3))
               + (Vl2S * PipValue * (PL4S - PL2S - TZS3))
               + (Vl3S * PipValue * (PL4S - PL3S - TZS3));

      Vl4S = NormalizeDouble(MathAbs(Loss4S) / TZS3 / PipValue, decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss4S:", Loss4S, " Vl4S:", Vl4S);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V5S()
  {
   double PipValue = CalculatePipValue() * InpLots;
   if(CONTORS == 1)
     {
      Loss5S = InpLots * PipValue * (PL5S - PL0S - TZS)
               + (Vl1S * PipValue * (PL5S - PL1S - TZS))
               + (Vl2S * PipValue * (PL5S - PL2S - TZS))
               + (Vl3S * PipValue * (PL5S - PL3S - TZS))
               + (Vl4S * PipValue * (PL5S - PL4S - TZS));

      Vl5S = NormalizeDouble(MathAbs(Loss5S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 2)
     {
      Loss5S = 2 * InpLots * PipValue * (PL5S - PL0S - TZS + step2S)
               + (Vl1S * PipValue * (PL5S - PL1S - TZS))
               + (Vl2S * PipValue * (PL5S - PL2S - TZS))
               + (Vl3S * PipValue * (PL5S - PL3S - TZS))
               + (Vl4S * PipValue * (PL5S - PL4S - TZS));

      Vl5S = NormalizeDouble(MathAbs(Loss5S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 3)
     {
      Loss5S = 3 * InpLots * PipValue * (PL5S - PL0S - TZS + step3S)
               + (Vl1S * PipValue * (PL5S - PL1S - TZS))
               + (Vl2S * PipValue * (PL5S - PL2S - TZS))
               + (Vl3S * PipValue * (PL5S - PL3S - TZS))
               + (Vl4S * PipValue * (PL5S - PL4S - TZS));

      Vl5S = NormalizeDouble(MathAbs(Loss5S) / TZS / PipValue, decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss5S:", Loss5S, " Vl5S:", Vl5S);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V5MS()
  {
   double PipValue = CalculatePipValue() * InpLots;
   if(CONTORS == 1)
     {
      Loss5S = InpLots * PipValue * (PL5S - PL0S - TZS4)
               + (Vl1S * PipValue * (PL5S - PL1S - TZS4))
               + (Vl2S * PipValue * (PL5S - PL2S - TZS4))
               + (Vl3S * PipValue * (PL5S - PL3S - TZS4))
               + (Vl4S * PipValue * (PL5S - PL4S - TZS4));

      Vl5S = NormalizeDouble(MathAbs(Loss5S) / TZS4 / PipValue, decimalPlace);
     }
   if(CONTORS == 2)
     {
      Loss5S = 2 * InpLots * PipValue * (PL5S - PL0S - TZS4 + step2S)
               + (Vl1S * PipValue * (PL5S - PL1S - TZS4))
               + (Vl2S * PipValue * (PL5S - PL2S - TZS4))
               + (Vl3S * PipValue * (PL5S - PL3S - TZS4))
               + (Vl4S * PipValue * (PL5S - PL4S - TZS4));

      Vl5S = NormalizeDouble(MathAbs(Loss5S) / TZS4 / PipValue, decimalPlace);
     }
   if(CONTORS == 3)
     {
      Loss5S = 3 * InpLots * PipValue * (PL5S - PL0S - TZS4 + step3S)
               + (Vl1S * PipValue * (PL5S - PL1S - TZS4))
               + (Vl2S * PipValue * (PL5S - PL2S -TZS4))
               + (Vl3S * PipValue * (PL5S - PL3S - TZS4))
               + (Vl4S * PipValue * (PL5S - PL4S -TZS4));

      Vl5S = NormalizeDouble(MathAbs(Loss5S) / TZS4 / PipValue, decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss5S:", Loss5S, " Vl5S:", Vl5S);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V6S()
  {
   double PipValue = CalculatePipValue() * InpLots;
   if(CONTORS == 1)
     {
      Loss6S = InpLots * PipValue * (PL6S - PL0S - TZS)
               + (Vl1S * PipValue * (PL6S - PL1S - TZS))
               + (Vl2S * PipValue * (PL6S - PL2S - TZS))
               + (Vl3S * PipValue * (PL6S - PL3S - TZS))
               + (Vl4S * PipValue * (PL6S - PL4S - TZS))
               + (Vl5S * PipValue * (PL6S - PL5S - TZS));

      Vl6S = NormalizeDouble(MathAbs(Loss6S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 2)
     {
      Loss6S = 2 * InpLots * PipValue * (PL6S - PL0S - TZS + step2S)
               + (Vl1S * PipValue * (PL6S - PL1S - TZS))
               + (Vl2S * PipValue * (PL6S - PL2S - TZS))
               + (Vl3S * PipValue * (PL6S - PL3S - TZS))
               + (Vl4S * PipValue * (PL6S - PL4S - TZS))
               + (Vl5S * PipValue * (PL6S - PL5S - TZS));

      Vl6S = NormalizeDouble(MathAbs(Loss6S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 3)
     {
      Loss6S = 3 * InpLots * PipValue * (PL6S - PL0S - TZS + step3S)
               + (Vl1S * PipValue * (PL6S - PL1S - TZS))
               + (Vl2S * PipValue * (PL6S - PL2S - TZS))
               + (Vl3S * PipValue * (PL6S - PL3S - TZS))
               + (Vl4S * PipValue * (PL6S - PL4S - TZS))
               + (Vl5S * PipValue * (PL6S - PL5S - TZS));

      Vl6S = NormalizeDouble(MathAbs(Loss6S) / TZS / PipValue, decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss6S:", Loss6S, " Vl6S:", Vl6S);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V6MS()
  {
   double PipValue = CalculatePipValue() * InpLots;
   if(CONTORS == 1)
     {
      Loss6S = InpLots * PipValue * (PL6S - PL0S - TZS5)
               + (Vl1S * PipValue * (PL6S - PL1S - TZS5))
               + (Vl2S * PipValue * (PL6S - PL2S - TZS5))
               + (Vl3S * PipValue * (PL6S - PL3S - TZS5))
               + (Vl4S * PipValue * (PL6S - PL4S - TZS5))
               + (Vl5S * PipValue * (PL6S - PL5S - TZS5));

      Vl6S = NormalizeDouble(MathAbs(Loss6S) / TZS5 / PipValue, decimalPlace);
     }
   if(CONTORS == 2)
     {
      Loss6S = 2 * InpLots * PipValue * (PL6S - PL0S - TZS5 + step2S)
               + (Vl1S * PipValue * (PL6S - PL1S - TZS5))
               + (Vl2S * PipValue * (PL6S - PL2S - TZS5))
               + (Vl3S * PipValue * (PL6S - PL3S - TZS5))
               + (Vl4S * PipValue * (PL6S - PL4S - TZS5))
               + (Vl5S * PipValue * (PL6S - PL5S - TZS5));

      Vl6S = NormalizeDouble(MathAbs(Loss6S) / TZS5 / PipValue, decimalPlace);
     }
   if(CONTORS == 3)
     {
      Loss6S = 3 * InpLots * PipValue * (PL6S - PL0S - TZS5 +step3S)
               + (Vl1S * PipValue * (PL6S - PL1S - TZS5))
               + (Vl2S * PipValue * (PL6S - PL2S - TZS5))
               + (Vl3S * PipValue * (PL6S - PL3S - TZS5))
               + (Vl4S * PipValue * (PL6S - PL4S - TZS5))
               + (Vl5S * PipValue * (PL6S - PL5S - TZS5));

      Vl6S = NormalizeDouble(MathAbs(Loss6S) / TZS5 / PipValue, decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss6S:", Loss6S, " Vl6S:", Vl6S);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V7S()
  {
   double PipValue = CalculatePipValue() * InpLots;
   if(CONTORS == 1)
     {
      Loss7S = InpLots * PipValue * (PL7S - PL0S - TZS)
               + (Vl1S * PipValue * (PL7S - PL1S - TZS))
               + (Vl2S * PipValue * (PL7S - PL2S - TZS))
               + (Vl3S * PipValue * (PL7S - PL3S - TZS))
               + (Vl4S * PipValue * (PL7S - PL4S - TZS))
               + (Vl5S * PipValue * (PL7S - PL5S - TZS))
               + (Vl6S * PipValue * (PL7S - PL6S - TZS));

      Vl7S = NormalizeDouble(MathAbs(Loss7S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 2)
     {
      Loss7S = 2 * InpLots * PipValue * (PL7S - PL0S - TZS + step2S)
               + (Vl1S * PipValue * (PL7S - PL1S - TZS))
               + (Vl2S * PipValue * (PL7S - PL2S - TZS))
               + (Vl3S * PipValue * (PL7S - PL3S - TZS))
               + (Vl4S * PipValue * (PL7S - PL4S - TZS))
               + (Vl5S * PipValue * (PL7S - PL5S - TZS))
               + (Vl6S * PipValue * (PL7S - PL6S - TZS));

      Vl7S = NormalizeDouble(MathAbs(Loss7S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 3)
     {
      Loss7S = 3 * InpLots * PipValue * (PL7S - PL0S - TZS + step3S)
               + (Vl1S * PipValue * (PL7S - PL1S - TZS))
               + (Vl2S * PipValue * (PL7S - PL2S - TZS))
               + (Vl3S * PipValue * (PL7S - PL3S - TZS))
               + (Vl4S * PipValue * (PL7S - PL4S - TZS))
               + (Vl5S * PipValue * (PL7S - PL5S - TZS))
               + (Vl6S * PipValue * (PL7S - PL6S - TZS));

      Vl7S = NormalizeDouble(MathAbs(Loss7S) / TZS / PipValue, decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss7S:", Loss7S, " Vl7S:", Vl7S);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V7MS()
  {
   double PipValue = CalculatePipValue() * InpLots;
   if(CONTORS == 1)
     {
      Loss7S = InpLots * PipValue * (PL7S - PL0S - TZS6)
               + (Vl1S * PipValue * (PL7S - PL1S - TZS6))
               + (Vl2S * PipValue * (PL7S - PL2S - TZS6))
               + (Vl3S * PipValue * (PL7S - PL3S - TZS6))
               + (Vl4S * PipValue * (PL7S - PL4S - TZS6))
               + (Vl5S * PipValue * (PL7S - PL5S - TZS6))
               + (Vl6S * PipValue * (PL7S - PL6S - TZS6));

      Vl7S = NormalizeDouble(MathAbs(Loss7S) / TZS6 / PipValue, decimalPlace);
     }
   if(CONTORS == 2)
     {
      Loss7S = 2 * InpLots * PipValue * (PL7S - PL0S - TZS6 + step2S)
               + (Vl1S * PipValue * (PL7S - PL1S - TZS6))
               + (Vl2S * PipValue * (PL7S - PL2S - TZS6))
               + (Vl3S * PipValue * (PL7S - PL3S - TZS6))
               + (Vl4S * PipValue * (PL7S - PL4S - TZS6))
               + (Vl5S * PipValue * (PL7S - PL5S - TZS6))
               + (Vl6S * PipValue * (PL7S - PL6S - TZS6));

      Vl7S = NormalizeDouble(MathAbs(Loss7S) / TZS6 / PipValue, decimalPlace);
     }
   if(CONTORS == 3)
     {
      Loss7S = 3 * InpLots * PipValue * (PL7S - PL0S - TZS6 + step3S)
               + (Vl1S * PipValue * (PL7S - PL1S - TZS6))
               + (Vl2S * PipValue * (PL7S - PL2S - TZS6))
               + (Vl3S * PipValue * (PL7S - PL3S - TZS6))
               + (Vl4S * PipValue * (PL7S - PL4S - TZS6))
               + (Vl5S * PipValue * (PL7S - PL5S - TZS6))
               + (Vl6S * PipValue * (PL7S - PL6S - TZS6));

      Vl7S = NormalizeDouble(MathAbs(Loss7S) / TZS6 / PipValue, decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss7S:", Loss7S, " Vl7S:", Vl7S);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V8S()
  {
   double PipValue = CalculatePipValue() * InpLots;
   if(CONTORS == 1)
     {
      Loss8S = InpLots * PipValue * (PL8S - PL0S - TZS)
               + (Vl1S * PipValue * (PL8S - PL1S - TZS))
               + (Vl2S * PipValue * (PL8S - PL2S - TZS))
               + (Vl3S * PipValue * (PL8S - PL3S - TZS))
               + (Vl4S * PipValue * (PL8S - PL4S - TZS))
               + (Vl5S * PipValue * (PL8S - PL5S - TZS))
               + (Vl6S * PipValue * (PL8S - PL6S - TZS))
               + (Vl7S * PipValue * (PL8S - PL7S - TZS));

      Vl8S = NormalizeDouble(MathAbs(Loss8S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 2)
     {
      Loss8S = 2 * InpLots * PipValue * (PL8S - PL0S - TZS + step2S)
               + (Vl1S * PipValue * (PL8S - PL1S - TZS))
               + (Vl2S * PipValue * (PL8S - PL2S - TZS))
               + (Vl3S * PipValue * (PL8S - PL3S - TZS))
               + (Vl4S * PipValue * (PL8S - PL4S - TZS))
               + (Vl5S * PipValue * (PL8S - PL5S - TZS))
               + (Vl6S * PipValue * (PL8S - PL6S - TZS))
               + (Vl7S * PipValue * (PL8S - PL7S - TZS));

      Vl8S = NormalizeDouble(MathAbs(Loss8S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 3)
     {
      Loss8S = 3 * InpLots * PipValue * (PL8S - PL0S - TZS + step3S)
               + (Vl1S * PipValue * (PL8S - PL1S - TZS))
               + (Vl2S * PipValue * (PL8S - PL2S - TZS))
               + (Vl3S * PipValue * (PL8S - PL3S - TZS))
               + (Vl4S * PipValue * (PL8S - PL4S - TZS))
               + (Vl5S * PipValue * (PL8S - PL5S - TZS))
               + (Vl6S * PipValue * (PL8S - PL6S - TZS))
               + (Vl7S * PipValue * (PL8S - PL7S - TZS));

      Vl8S = NormalizeDouble(MathAbs(Loss8S) / TZS / PipValue, decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss8S:", Loss8S, " Vl8S:", Vl8S);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V8MS()
  {
   double PipValue = CalculatePipValue() * InpLots;
   if(CONTORS == 1)
     {
      Loss8S = InpLots * PipValue * (PL8S - PL0S - TZS7)
               + (Vl1S * PipValue * (PL8S - PL1S - TZS7))
               + (Vl2S * PipValue * (PL8S - PL2S - TZS7))
               + (Vl3S * PipValue * (PL8S - PL3S - TZS7))
               + (Vl4S * PipValue * (PL8S - PL4S - TZS7))
               + (Vl5S * PipValue * (PL8S - PL5S - TZS7))
               + (Vl6S * PipValue * (PL8S - PL6S - TZS7))
               + (Vl7S * PipValue * (PL8S - PL7S - TZS7));

      Vl8S = NormalizeDouble(MathAbs(Loss8S) / TZS7 / PipValue, decimalPlace);
     }
   if(CONTORS == 2)
     {
      Loss8S = 2 * InpLots * PipValue * (PL8S - PL0S - TZS7 + step2S)
               + (Vl1S * PipValue * (PL8S - PL1S - TZS7))
               + (Vl2S * PipValue * (PL8S - PL2S - TZS7))
               + (Vl3S * PipValue * (PL8S - PL3S - TZS7))
               + (Vl4S * PipValue * (PL8S - PL4S - TZS7))
               + (Vl5S * PipValue * (PL8S - PL5S - TZS7))
               + (Vl6S * PipValue * (PL8S - PL6S - TZS7))
               + (Vl7S * PipValue * (PL8S - PL7S - TZS7));

      Vl8S = NormalizeDouble(MathAbs(Loss8S) / TZS7 / PipValue, decimalPlace);
     }
   if(CONTORS == 3)
     {
      Loss8S = 3 * InpLots * PipValue * (PL8S - PL0S - TZS7 + step3S)
               + (Vl1S * PipValue * (PL8S - PL1S - TZS7))
               + (Vl2S * PipValue * (PL8S - PL2S - TZS7))
               + (Vl3S * PipValue * (PL8S - PL3S - TZS7))
               + (Vl4S * PipValue * (PL8S - PL4S - TZS7))
               + (Vl5S * PipValue * (PL8S - PL5S - TZS7))
               + (Vl6S * PipValue * (PL8S - PL6S - TZS7))
               + (Vl7S * PipValue * (PL8S - PL7S - TZS7));

      Vl8S = NormalizeDouble(MathAbs(Loss8S) / TZS7 / PipValue, decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss8S:", Loss8S, " Vl8S:", Vl8S);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V9S()
  {
   double PipValue = CalculatePipValue() * InpLots;
   if(CONTORS == 1)
     {
      Loss9S = InpLots * PipValue * (PL9S - PL0S - TZS)
               + (Vl1S * PipValue * (PL9S - PL1S - TZS))
               + (Vl2S * PipValue * (PL9S - PL2S - TZS))
               + (Vl3S * PipValue * (PL9S - PL3S - TZS))
               + (Vl4S * PipValue * (PL9S - PL4S - TZS))
               + (Vl5S * PipValue * (PL9S - PL5S - TZS))
               + (Vl6S * PipValue * (PL9S - PL6S - TZS))
               + (Vl7S * PipValue * (PL9S - PL7S - TZS))
               + (Vl8S * PipValue * (PL9S - PL8S - TZS));

      Vl9S = NormalizeDouble(MathAbs(Loss9S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 2)
     {
      Loss9S = 2 * InpLots * PipValue * (PL9S - PL0S - TZS + step2S)
               + (Vl1S * PipValue * (PL9S - PL1S - TZS))
               + (Vl2S * PipValue * (PL9S - PL2S - TZS))
               + (Vl3S * PipValue * (PL9S - PL3S - TZS))
               + (Vl4S * PipValue * (PL9S - PL4S - TZS))
               + (Vl5S * PipValue * (PL9S - PL5S - TZS))
               + (Vl6S * PipValue * (PL9S - PL6S - TZS))
               + (Vl7S * PipValue * (PL9S - PL7S - TZS))
               + (Vl8S * PipValue * (PL9S - PL8S - TZS));

      Vl9S = NormalizeDouble(MathAbs(Loss9S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 3)
     {
      Loss9S = 3 * InpLots * PipValue * (PL9S - PL0S - TZS + step3S)
               + (Vl1S * PipValue * (PL9S - PL1S - TZS))
               + (Vl2S * PipValue * (PL9S - PL2S - TZS))
               + (Vl3S * PipValue * (PL9S - PL3S - TZS))
               + (Vl4S * PipValue * (PL9S - PL4S - TZS))
               + (Vl5S * PipValue * (PL9S - PL5S - TZS))
               + (Vl6S * PipValue * (PL9S - PL6S - TZS))
               + (Vl7S * PipValue * (PL9S - PL7S - TZS))
               + (Vl8S * PipValue * (PL9S - PL8S - TZS));

      Vl9S = NormalizeDouble(MathAbs(Loss9S) / TZS / PipValue, decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss9S:", Loss9S, " Vl9S:", Vl9S);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V9MS()
  {
   double PipValue = CalculatePipValue() * InpLots;
   if(CONTORS == 1)
     {
      Loss9S = InpLots * PipValue * (PL9S - PL0S - TZS8)
               + (Vl1S * PipValue * (PL9S - PL1S - TZS8))
               + (Vl2S * PipValue * (PL9S - PL2S - TZS8))
               + (Vl3S * PipValue * (PL9S - PL3S - TZS8))
               + (Vl4S * PipValue * (PL9S - PL4S - TZS8))
               + (Vl5S * PipValue * (PL9S - PL5S - TZS8))
               + (Vl6S * PipValue * (PL9S - PL6S - TZS8))
               + (Vl7S * PipValue * (PL9S - PL7S - TZS8))
               + (Vl8S * PipValue * (PL9S - PL8S - TZS8));

      Vl9S = NormalizeDouble(MathAbs(Loss9S) / TZS8 / PipValue, decimalPlace);
     }
   if(CONTORS == 2)
     {
      Loss9S = 2 * InpLots * PipValue * (PL9S - PL0S - TZS8 + step2S)
               + (Vl1S * PipValue * (PL9S - PL1S - TZS8))
               + (Vl2S * PipValue * (PL9S - PL2S - TZS8))
               + (Vl3S * PipValue * (PL9S - PL3S - TZS8))
               + (Vl4S * PipValue * (PL9S - PL4S - TZS8))
               + (Vl5S * PipValue * (PL9S - PL5S - TZS8))
               + (Vl6S * PipValue * (PL9S - PL6S - TZS8))
               + (Vl7S * PipValue * (PL9S - PL7S - TZS8))
               + (Vl8S * PipValue * (PL9S - PL8S - TZS8));

      Vl9S = NormalizeDouble(MathAbs(Loss9S) / TZS8 / PipValue, decimalPlace);
     }
   if(CONTORS == 3)
     {
      Loss9S = 3 * InpLots * PipValue * (PL9S - PL0S - TZS8 + step3S)
               + (Vl1S * PipValue * (PL9S - PL1S - TZS8))
               + (Vl2S * PipValue * (PL9S - PL2S - TZS8))
               + (Vl3S * PipValue * (PL9S - PL3S - TZS8))
               + (Vl4S * PipValue * (PL9S - PL4S - TZS8))
               + (Vl5S * PipValue * (PL9S - PL5S - TZS8))
               + (Vl6S * PipValue * (PL9S - PL6S - TZS8))
               + (Vl7S * PipValue * (PL9S - PL7S - TZS8))
               + (Vl8S * PipValue * (PL9S - PL8S - TZS8));

      Vl9S = NormalizeDouble(MathAbs(Loss9S) / TZS8 / PipValue, decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss9S:", Loss9S, " Vl9S:", Vl9S);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V10S()
  {
   double PipValue = CalculatePipValue() * InpLots;
   if(CONTORS == 1)
     {
      Loss10S = InpLots * PipValue * (PL10S - PL0S - TZS)
                + (Vl1S * PipValue * (PL10S - PL1S - TZS))
                + (Vl2S * PipValue * (PL10S - PL2S - TZS))
                + (Vl3S * PipValue * (PL10S - PL3S - TZS))
                + (Vl4S * PipValue * (PL10S - PL4S - TZS))
                + (Vl5S * PipValue * (PL10S - PL5S - TZS))
                + (Vl6S * PipValue * (PL10S - PL6S - TZS))
                + (Vl7S * PipValue * (PL10S - PL7S - TZS))
                + (Vl8S * PipValue * (PL10S - PL8S - TZS))
                + (Vl8S * PipValue * (PL10S - PL9S - TZS))
                + (Vl9S * PipValue * (PL10S - PL9S - TZS));
      Vl10S = NormalizeDouble(MathAbs(Loss10S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 2)
     {
      Loss10S = 2 * InpLots * PipValue * (PL10S - PL0S - TZS + step2S)
                + (Vl1S * PipValue * (PL10S - PL1S - TZS))
                + (Vl2S * PipValue * (PL10S - PL2S - TZS))
                + (Vl3S * PipValue * (PL10S - PL3S - TZS))
                + (Vl4S * PipValue * (PL10S - PL4S - TZS))
                + (Vl5S * PipValue * (PL10S - PL5S - TZS))
                + (Vl6S * PipValue * (PL10S - PL6S - TZS))
                + (Vl7S * PipValue * (PL10S - PL7S - TZS))
                + (Vl8S * PipValue * (PL10S - PL8S - TZS))
                + (Vl8S * PipValue * (PL10S - PL9S - TZS))
                + (Vl9S * PipValue * (PL10S - PL9S - TZS));
      Vl10S = NormalizeDouble(MathAbs(Loss10S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 3)
     {
      Loss10S = 3 * InpLots * PipValue * (PL10S - PL0S - TZS +step3S)
                + (Vl1S * PipValue * (PL10S - PL1S - TZS))
                + (Vl2S * PipValue * (PL10S - PL2S - TZS))
                + (Vl3S * PipValue * (PL10S - PL3S - TZS))
                + (Vl4S * PipValue * (PL10S - PL4S - TZS))
                + (Vl5S * PipValue * (PL10S - PL5S - TZS))
                + (Vl6S * PipValue * (PL10S - PL6S - TZS))
                + (Vl7S * PipValue * (PL10S - PL7S - TZS))
                + (Vl8S * PipValue * (PL10S - PL8S - TZS))
                + (Vl8S * PipValue * (PL10S - PL9S - TZS))
                + (Vl9S * PipValue * (PL10S - PL9S - TZS));
      Vl10S = NormalizeDouble(MathAbs(Loss10S) / TZS / PipValue, decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss10S:", Loss10S, " Vl10S:", Vl10S);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V10MS()
  {
   double PipValue = CalculatePipValue() * InpLots;
   if(CONTORS == 1)
     {
      Loss10S = InpLots * PipValue * (PL10S - PL0S - TZS9)
                + (Vl1S * PipValue * (PL10S - PL1S  -TZS9))
                + (Vl2S * PipValue * (PL10S - PL2S  -TZS9))
                + (Vl3S * PipValue * (PL10S - PL3S - TZS9))
                + (Vl4S * PipValue * (PL10S - PL4S - TZS9))
                + (Vl5S * PipValue * (PL10S - PL5S - TZS9))
                + (Vl6S * PipValue * (PL10S - PL6S - TZS9))
                + (Vl7S * PipValue * (PL10S - PL7S - TZS9))
                + (Vl8S * PipValue * (PL10S - PL8S -TZS9))
                + (Vl8S * PipValue * (PL10S - PL9S - TZS9))
                + (Vl9S * PipValue * (PL10S - PL9S - TZS9));
      Vl10S = NormalizeDouble(MathAbs(Loss10S) / TZS9 / PipValue, decimalPlace);
     }
   if(CONTORS == 2)
     {
      Loss10S = 2 * InpLots * PipValue * (PL10S - PL0S - TZS9 + step2S)
                + (Vl1S * PipValue * (PL10S - PL1S - TZS9))
                + (Vl2S * PipValue * (PL10S - PL2S - TZS9))
                + (Vl3S * PipValue * (PL10S - PL3S - TZS9))
                + (Vl4S * PipValue * (PL10S - PL4S - TZS9))
                + (Vl5S * PipValue * (PL10S - PL5S - TZS9))
                + (Vl6S * PipValue * (PL10S - PL6S - TZS9))
                + (Vl7S * PipValue * (PL10S - PL7S - TZS9))
                + (Vl8S * PipValue * (PL10S - PL8S - TZS9))
                + (Vl8S * PipValue * (PL10S - PL9S - TZS9))
                + (Vl9S * PipValue * (PL10S - PL9S - TZS9));
      Vl10S = NormalizeDouble(MathAbs(Loss10S) / TZS9 / PipValue, decimalPlace);
     }
   if(CONTORS == 3)
     {
      Loss10S = 3 * InpLots * PipValue * (PL10S - PL0S - TZS9 + step3S)
                + (Vl1S * PipValue * (PL10S - PL1S - TZS9))
                + (Vl2S * PipValue * (PL10S - PL2S - TZS9))
                + (Vl3S * PipValue * (PL10S - PL3S - TZS9))
                + (Vl4S * PipValue * (PL10S - PL4S - TZS9))
                + (Vl5S * PipValue * (PL10S - PL5S - TZS9))
                + (Vl6S * PipValue * (PL10S - PL6S - TZS9))
                + (Vl7S * PipValue * (PL10S - PL7S - TZS9))
                + (Vl8S * PipValue * (PL10S - PL8S - TZS9))
                + (Vl8S * PipValue * (PL10S - PL9S - TZS9))
                + (Vl9S * PipValue * (PL10S - PL9S - TZS9));
      Vl10S = NormalizeDouble(MathAbs(Loss10S) / TZS9 / PipValue, decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss10S:", Loss10S, " Vl10S:", Vl10S);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V11S()
  {
   double PipValue = CalculatePipValue() * InpLots;
   if(CONTORS == 1)
     {
      Loss11S = InpLots * PipValue * (PL11S - PL0S + TZS)
                + (Vl1S * PipValue * (PL11S - PL1S + TZS))
                + (Vl2S * PipValue * (PL11S - PL2S + TZS))
                + (Vl3S * PipValue * (PL11S - PL3S + TZS))
                + (Vl4S * PipValue * (PL11S - PL4S + TZS))
                + (Vl5S * PipValue * (PL11S - PL5S + TZS))
                + (Vl6S * PipValue * (PL11S - PL6S + TZS))
                + (Vl7S * PipValue * (PL11S - PL7S + TZS))
                + (Vl8S * PipValue * (PL11S - PL8S + TZS))
                + (Vl8S * PipValue * (PL11S - PL9S + TZS))
                + (Vl9S * PipValue * (PL11S - PL9S + TZS))
                + (Vl10S * PipValue * (PL11S - PL10S + TZS));
      Vl11S = NormalizeDouble(MathAbs(Loss11S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 2)
     {
      Loss11S = 2 * InpLots * PipValue * (PL11S - PL0S + TZS + step2S)
                + (Vl1S * PipValue * (PL11S - PL1S + TZS))
                + (Vl2S * PipValue * (PL11S - PL2S + TZS))
                + (Vl3S * PipValue * (PL11S - PL3S + TZS))
                + (Vl4S * PipValue * (PL11S - PL4S + TZS))
                + (Vl5S * PipValue * (PL11S - PL5S + TZS))
                + (Vl6S * PipValue * (PL11S - PL6S + TZS))
                + (Vl7S * PipValue * (PL11S - PL7S + TZS))
                + (Vl8S * PipValue * (PL11S - PL8S + TZS))
                + (Vl8S * PipValue * (PL11S - PL9S + TZS))
                + (Vl9S * PipValue * (PL11S - PL9S + TZS))
                + (Vl10S * PipValue * (PL11S - PL10S + TZS));
      Vl11S = NormalizeDouble(MathAbs(Loss11S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 3)
     {
      Loss11S = 3 * InpLots * PipValue * (PL11S - PL0S + TZS + step3S)
                + (Vl1S * PipValue * (PL11S - PL1S + TZS))
                + (Vl2S * PipValue * (PL11S - PL2S + TZS))
                + (Vl3S * PipValue * (PL11S - PL3S + TZS))
                + (Vl4S * PipValue * (PL11S - PL4S + TZS))
                + (Vl5S * PipValue * (PL11S - PL5S + TZS))
                + (Vl6S * PipValue * (PL11S - PL6S + TZS))
                + (Vl7S * PipValue * (PL11S - PL7S + TZS))
                + (Vl8S * PipValue * (PL11S - PL8S + TZS))
                + (Vl8S * PipValue * (PL11S - PL9S + TZS))
                + (Vl9S * PipValue * (PL11S - PL9S + TZS))
                + (Vl10S * PipValue * (PL11S - PL10S + TZS));
      Vl11S = NormalizeDouble(MathAbs(Loss11S) / TZS / PipValue, decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss11S:", Loss11S, " Vl11S:", Vl11S);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V12S()
  {
   double PipValue = CalculatePipValue() * InpLots;
   if(CONTORS == 1)
     {
      Loss12S = InpLots * PipValue * (PL12S - PL0S + TZS)
                + (Vl1S * PipValue * (PL12S - PL1S + TZS))
                + (Vl2S * PipValue * (PL12S - PL2S + TZS))
                + (Vl3S * PipValue * (PL12S - PL3S + TZS))
                + (Vl4S * PipValue * (PL12S - PL4S + TZS))
                + (Vl5S * PipValue * (PL12S - PL5S + TZS))
                + (Vl6S * PipValue * (PL12S - PL6S + TZS))
                + (Vl7S * PipValue * (PL12S - PL7S + TZS))
                + (Vl8S * PipValue * (PL12S - PL8S + TZS))
                + (Vl8S * PipValue * (PL12S - PL9S + TZS))
                + (Vl9S * PipValue * (PL12S - PL9S + TZS))
                + (Vl10S * PipValue * (PL12S - PL10S + TZS))
                + (Vl11S * PipValue * (PL12S - PL11S + TZS));
      Vl12S = NormalizeDouble(MathAbs(Loss12S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 2)
     {
      Loss12S = 2 * InpLots * PipValue * (PL12S - PL0S + TZS + step2S)
                + (Vl1S * PipValue * (PL12S - PL1S + TZS))
                + (Vl2S * PipValue * (PL12S - PL2S + TZS))
                + (Vl3S * PipValue * (PL12S - PL3S + TZS))
                + (Vl4S * PipValue * (PL12S - PL4S + TZS))
                + (Vl5S * PipValue * (PL12S - PL5S + TZS))
                + (Vl6S * PipValue * (PL12S - PL6S + TZS))
                + (Vl7S * PipValue * (PL12S - PL7S + TZS))
                + (Vl8S * PipValue * (PL12S - PL8S + TZS))
                + (Vl8S * PipValue * (PL12S - PL9S + TZS))
                + (Vl9S * PipValue * (PL12S - PL9S + TZS))
                + (Vl10S * PipValue * (PL12S - PL10S + TZS))
                + (Vl11S * PipValue * (PL12S - PL11S + TZS));
      Vl12S = NormalizeDouble(MathAbs(Loss12S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 3)
     {
      Loss12S = 3 * InpLots * PipValue * (PL12S - PL0S + TZS + step3S)
                + (Vl1S * PipValue * (PL12S - PL1S + TZS))
                + (Vl2S * PipValue * (PL12S - PL2S + TZS))
                + (Vl3S * PipValue * (PL12S - PL3S + TZS))
                + (Vl4S * PipValue * (PL12S - PL4S + TZS))
                + (Vl5S * PipValue * (PL12S - PL5S + TZS))
                + (Vl6S * PipValue * (PL12S - PL6S + TZS))
                + (Vl7S * PipValue * (PL12S - PL7S + TZS))
                + (Vl8S * PipValue * (PL12S - PL8S + TZS))
                + (Vl8S * PipValue * (PL12S - PL9S + TZS))
                + (Vl9S * PipValue * (PL12S - PL9S + TZS))
                + (Vl10S * PipValue * (PL12S - PL10S + TZS))
                + (Vl11S * PipValue * (PL12S - PL11S + TZS));
      Vl12S = NormalizeDouble(MathAbs(Loss12S) / TZS / PipValue, decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss12S:", Loss12S, " Vl12S:", Vl12S);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V13S()
  {
   double PipValue = CalculatePipValue() * InpLots;
   if(CONTORS == 1)
     {
      Loss13S = InpLots * PipValue * (PL13S - PL0S + TZS)
                + (Vl1S * PipValue * (PL13S - PL1S + TZS))
                + (Vl2S * PipValue * (PL13S - PL2S + TZS))
                + (Vl3S * PipValue * (PL13S - PL3S + TZS))
                + (Vl4S * PipValue * (PL13S - PL4S + TZS))
                + (Vl5S * PipValue * (PL13S - PL5S + TZS))
                + (Vl6S * PipValue * (PL13S - PL6S + TZS))
                + (Vl7S * PipValue * (PL13S - PL7S + TZS))
                + (Vl8S * PipValue * (PL13S - PL8S + TZS))
                + (Vl8S * PipValue * (PL13S - PL9S + TZS))
                + (Vl9S * PipValue * (PL13S - PL9S + TZS))
                + (Vl10S * PipValue * (PL13S - PL10S + TZS))
                + (Vl11S * PipValue * (PL13S - PL11S + TZS))
                + (Vl12S * PipValue * (PL13S - PL12S + TZS));
      Vl13S = NormalizeDouble(MathAbs(Loss13S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 2)
     {
      Loss13S = 2 * InpLots * PipValue * (PL13S - PL0S + TZS + step2S)
                + (Vl1S * PipValue * (PL13S - PL1S + TZS))
                + (Vl2S * PipValue * (PL13S - PL2S + TZS))
                + (Vl3S * PipValue * (PL13S - PL3S + TZS))
                + (Vl4S * PipValue * (PL13S - PL4S + TZS))
                + (Vl5S * PipValue * (PL13S - PL5S + TZS))
                + (Vl6S * PipValue * (PL13S - PL6S + TZS))
                + (Vl7S * PipValue * (PL13S - PL7S + TZS))
                + (Vl8S * PipValue * (PL13S - PL8S + TZS))
                + (Vl8S * PipValue * (PL13S - PL9S + TZS))
                + (Vl9S * PipValue * (PL13S - PL9S + TZS))
                + (Vl10S * PipValue * (PL13S - PL10S + TZS))
                + (Vl11S * PipValue * (PL13S - PL11S + TZS))
                + (Vl12S * PipValue * (PL13S - PL12S + TZS));
      Vl13S = NormalizeDouble(MathAbs(Loss13S) / TZS / PipValue, decimalPlace);
     }
   if(CONTORS == 3)
     {
      Loss13S = 3 * InpLots * PipValue * (PL13S - PL0S + TZS + step3S)
                + (Vl1S * PipValue * (PL13S - PL1S + TZS))
                + (Vl2S * PipValue * (PL13S - PL2S + TZS))
                + (Vl3S * PipValue * (PL13S - PL3S + TZS))
                + (Vl4S * PipValue * (PL13S - PL4S + TZS))
                + (Vl5S * PipValue * (PL13S - PL5S + TZS))
                + (Vl6S * PipValue * (PL13S - PL6S + TZS))
                + (Vl7S * PipValue * (PL13S - PL7S + TZS))
                + (Vl8S * PipValue * (PL13S - PL8S + TZS))
                + (Vl8S * PipValue * (PL13S - PL9S + TZS))
                + (Vl9S * PipValue * (PL13S - PL9S + TZS))
                + (Vl10S * PipValue * (PL13S - PL10S + TZS))
                + (Vl11S * PipValue * (PL13S - PL11S + TZS))
                + (Vl12S * PipValue * (PL13S - PL12S + TZS));
      Vl13S = NormalizeDouble(MathAbs(Loss13S) / TZS / PipValue, decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss13S:", Loss13S, " Vl13S:", Vl13S);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V14S()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTORS==1)
     {
      Loss14S=InpLots*PipValue*(PL14S-PL0S+TZS)
              +(Vl1S*PipValue*(PL14S-PL1S+TZS))
              +(Vl2S*PipValue*(PL14S-PL2S+TZS))
              +(Vl3S*PipValue*(PL14S-PL3S+TZS))
              +(Vl4S*PipValue*(PL14S-PL4S+TZS))
              +(Vl5S*PipValue*(PL14S-PL5S+TZS))
              +(Vl6S*PipValue*(PL14S-PL6S+TZS))
              +(Vl7S*PipValue*(PL14S-PL7S+TZS))
              +(Vl8S*PipValue*(PL14S-PL8S+TZS))
              +(Vl8S*PipValue*(PL14S-PL9S+TZS))
              +(Vl9S*PipValue*(PL14S-PL9S+TZS))
              +(Vl10S*PipValue*(PL14S-PL10S+TZS))
              +(Vl11S*PipValue*(PL14S-PL11S+TZS))
              +(Vl12S*PipValue*(PL14S-PL12S+TZS))
              +(Vl13S*PipValue*(PL14S-PL13S+TZS));
      Vl14S=NormalizeDouble(MathAbs(Loss14S)/TZS/PipValue,decimalPlace);
     }
   if(CONTORS==2)
     {
      Loss14S=2*InpLots*PipValue*(PL14S-PL0S+TZS+step2S)
              +(Vl1S*PipValue*(PL14S-PL1S+TZS))
              +(Vl2S*PipValue*(PL14S-PL2S+TZS))
              +(Vl3S*PipValue*(PL14S-PL3S+TZS))
              +(Vl4S*PipValue*(PL14S-PL4S+TZS))
              +(Vl5S*PipValue*(PL14S-PL5S+TZS))
              +(Vl6S*PipValue*(PL14S-PL6S+TZS))
              +(Vl7S*PipValue*(PL14S-PL7S+TZS))
              +(Vl8S*PipValue*(PL14S-PL8S+TZS))
              +(Vl8S*PipValue*(PL14S-PL9S+TZS))
              +(Vl9S*PipValue*(PL14S-PL9S+TZS))
              +(Vl10S*PipValue*(PL14S-PL10S+TZS))
              +(Vl11S*PipValue*(PL14S-PL11S+TZS))
              +(Vl12S*PipValue*(PL14S-PL12S+TZS))
              +(Vl13S*PipValue*(PL14S-PL13S+TZS));
      Vl14S=NormalizeDouble(MathAbs(Loss14S)/TZS/PipValue,decimalPlace);
     }
   if(CONTORS==3)
     {
      Loss14S=3*InpLots*PipValue*(PL14S-PL0S+TZS+step3S)
              +(Vl1S*PipValue*(PL14S-PL1S+TZS))
              +(Vl2S*PipValue*(PL14S-PL2S+TZS))
              +(Vl3S*PipValue*(PL14S-PL3S+TZS))
              +(Vl4S*PipValue*(PL14S-PL4S+TZS))
              +(Vl5S*PipValue*(PL14S-PL5S+TZS))
              +(Vl6S*PipValue*(PL14S-PL6S+TZS))
              +(Vl7S*PipValue*(PL14S-PL7S+TZS))
              +(Vl8S*PipValue*(PL14S-PL8S+TZS))
              +(Vl8S*PipValue*(PL14S-PL9S+TZS))
              +(Vl9S*PipValue*(PL14S-PL9S+TZS))
              +(Vl10S*PipValue*(PL14S-PL10S+TZS))
              +(Vl11S*PipValue*(PL14S-PL11S+TZS))
              +(Vl12S*PipValue*(PL14S-PL12S+TZS))
              +(Vl13S*PipValue*(PL14S-PL13S+TZS));
      Vl14S=NormalizeDouble(MathAbs(Loss14S)/TZS/PipValue,decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss14S:", Loss14S, " Vl14S:", Vl14S);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V15S()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTORS==1)
     {
      Loss15S=InpLots*PipValue*(PL15S-PL0S+TZS)
              +(Vl1S*PipValue*(PL15S-PL1S+TZS))
              +(Vl2S*PipValue*(PL15S-PL2S+TZS))
              +(Vl3S*PipValue*(PL15S-PL3S+TZS))
              +(Vl4S*PipValue*(PL15S-PL4S+TZS))
              +(Vl5S*PipValue*(PL15S-PL5S+TZS))
              +(Vl6S*PipValue*(PL15S-PL6S+TZS))
              +(Vl7S*PipValue*(PL15S-PL7S+TZS))
              +(Vl8S*PipValue*(PL15S-PL8S+TZS))
              +(Vl8S*PipValue*(PL15S-PL9S+TZS))
              +(Vl9S*PipValue*(PL15S-PL9S+TZS))
              +(Vl10S*PipValue*(PL15S-PL10S+TZS))
              +(Vl11S*PipValue*(PL15S-PL11S+TZS))
              +(Vl12S*PipValue*(PL15S-PL12S+TZS))
              +(Vl13S*PipValue*(PL15S-PL13S+TZS))
              +(Vl14S*PipValue*(PL15S-PL14S+TZS));
      Vl15S=NormalizeDouble(MathAbs(Loss15S)/TZS/PipValue,decimalPlace);
     }
   if(CONTORS==2)
     {
      Loss15S=2*InpLots*PipValue*(PL15S-PL0S+TZS+step2S)
              +(Vl1S*PipValue*(PL15S-PL1S+TZS))
              +(Vl2S*PipValue*(PL15S-PL2S+TZS))
              +(Vl3S*PipValue*(PL15S-PL3S+TZS))
              +(Vl4S*PipValue*(PL15S-PL4S+TZS))
              +(Vl5S*PipValue*(PL15S-PL5S+TZS))
              +(Vl6S*PipValue*(PL15S-PL6S+TZS))
              +(Vl7S*PipValue*(PL15S-PL7S+TZS))
              +(Vl8S*PipValue*(PL15S-PL8S+TZS))
              +(Vl8S*PipValue*(PL15S-PL9S+TZS))
              +(Vl9S*PipValue*(PL15S-PL9S+TZS))
              +(Vl10S*PipValue*(PL15S-PL10S+TZS))
              +(Vl11S*PipValue*(PL15S-PL11S+TZS))
              +(Vl12S*PipValue*(PL15S-PL12S+TZS))
              +(Vl13S*PipValue*(PL15S-PL13S+TZS))
              +(Vl14S*PipValue*(PL15S-PL14S+TZS));
      Vl15S=NormalizeDouble(MathAbs(Loss15S)/TZS/PipValue,decimalPlace);
     }
   if(CONTORS==3)
     {
      Loss15S=3*InpLots*PipValue*(PL15S-PL0S+TZS+step3S)
              +(Vl1S*PipValue*(PL15S-PL1S+TZS))
              +(Vl2S*PipValue*(PL15S-PL2S+TZS))
              +(Vl3S*PipValue*(PL15S-PL3S+TZS))
              +(Vl4S*PipValue*(PL15S-PL4S+TZS))
              +(Vl5S*PipValue*(PL15S-PL5S+TZS))
              +(Vl6S*PipValue*(PL15S-PL6S+TZS))
              +(Vl7S*PipValue*(PL15S-PL7S+TZS))
              +(Vl8S*PipValue*(PL15S-PL8S+TZS))
              +(Vl8S*PipValue*(PL15S-PL9S+TZS))
              +(Vl9S*PipValue*(PL15S-PL9S+TZS))
              +(Vl10S*PipValue*(PL15S-PL10S+TZS))
              +(Vl11S*PipValue*(PL15S-PL11S+TZS))
              +(Vl12S*PipValue*(PL15S-PL12S+TZS))
              +(Vl13S*PipValue*(PL15S-PL13S+TZS))
              +(Vl14S*PipValue*(PL15S-PL14S+TZS));
      Vl15S=NormalizeDouble(MathAbs(Loss15S)/TZS/PipValue,decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss15S:", Loss15S, " Vl15S:", Vl15S);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V16S()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTORS==1)
     {
      Loss16S=InpLots*PipValue*(PL16S-PL0S+TZS)
              +(Vl1S*PipValue*(PL16S-PL1S+TZS))
              +(Vl2S*PipValue*(PL16S-PL2S+TZS))
              +(Vl3S*PipValue*(PL16S-PL3S+TZS))
              +(Vl4S*PipValue*(PL16S-PL4S+TZS))
              +(Vl5S*PipValue*(PL16S-PL5S+TZS))
              +(Vl6S*PipValue*(PL16S-PL6S+TZS))
              +(Vl7S*PipValue*(PL16S-PL7S+TZS))
              +(Vl8S*PipValue*(PL16S-PL8S+TZS))
              +(Vl8S*PipValue*(PL16S-PL9S+TZS))
              +(Vl9S*PipValue*(PL16S-PL9S+TZS))
              +(Vl10S*PipValue*(PL16S-PL10S+TZS))
              +(Vl11S*PipValue*(PL16S-PL11S+TZS))
              +(Vl12S*PipValue*(PL16S-PL12S+TZS))
              +(Vl13S*PipValue*(PL16S-PL13S+TZS))
              +(Vl14S*PipValue*(PL16S-PL14S+TZS))
              +(Vl15S*PipValue*(PL16S-PL15S+TZS));
      Vl16S=NormalizeDouble(MathAbs(Loss16S)/TZS/PipValue,decimalPlace);
     }
   if(CONTORS==2)
     {
      Loss16S=2*InpLots*PipValue*(PL16S-PL0S+TZS+step2S)
              +(Vl1S*PipValue*(PL16S-PL1S+TZS))
              +(Vl2S*PipValue*(PL16S-PL2S+TZS))
              +(Vl3S*PipValue*(PL16S-PL3S+TZS))
              +(Vl4S*PipValue*(PL16S-PL4S+TZS))
              +(Vl5S*PipValue*(PL16S-PL5S+TZS))
              +(Vl6S*PipValue*(PL16S-PL6S+TZS))
              +(Vl7S*PipValue*(PL16S-PL7S+TZS))
              +(Vl8S*PipValue*(PL16S-PL8S+TZS))
              +(Vl8S*PipValue*(PL16S-PL9S+TZS))
              +(Vl9S*PipValue*(PL16S-PL9S+TZS))
              +(Vl10S*PipValue*(PL16S-PL10S+TZS))
              +(Vl11S*PipValue*(PL16S-PL11S+TZS))
              +(Vl12S*PipValue*(PL16S-PL12S+TZS))
              +(Vl13S*PipValue*(PL16S-PL13S+TZS))
              +(Vl14S*PipValue*(PL16S-PL14S+TZS))
              +(Vl15S*PipValue*(PL16S-PL15S+TZS));
      Vl16S=NormalizeDouble(MathAbs(Loss16S)/TZS/PipValue,decimalPlace);
     }
   if(CONTORS==3)
     {
      Loss16S=3*InpLots*PipValue*(PL16S-PL0S+TZS+step3S)
              +(Vl1S*PipValue*(PL16S-PL1S+TZS))
              +(Vl2S*PipValue*(PL16S-PL2S+TZS))
              +(Vl3S*PipValue*(PL16S-PL3S+TZS))
              +(Vl4S*PipValue*(PL16S-PL4S+TZS))
              +(Vl5S*PipValue*(PL16S-PL5S+TZS))
              +(Vl6S*PipValue*(PL16S-PL6S+TZS))
              +(Vl7S*PipValue*(PL16S-PL7S+TZS))
              +(Vl8S*PipValue*(PL16S-PL8S+TZS))
              +(Vl8S*PipValue*(PL16S-PL9S+TZS))
              +(Vl9S*PipValue*(PL16S-PL9S+TZS))
              +(Vl10S*PipValue*(PL16S-PL10S+TZS))
              +(Vl11S*PipValue*(PL16S-PL11S+TZS))
              +(Vl12S*PipValue*(PL16S-PL12S+TZS))
              +(Vl13S*PipValue*(PL16S-PL13S+TZS))
              +(Vl14S*PipValue*(PL16S-PL14S+TZS))
              +(Vl15S*PipValue*(PL16S-PL15S+TZS));
      Vl16S=NormalizeDouble(MathAbs(Loss16S)/TZS/PipValue,decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss16S:", Loss16S, " Vl16S:", Vl16S);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V17S()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTORS==1)
     {
      Loss17S=InpLots*PipValue*(PL17S-PL0S+TZS)
              +(Vl1S*PipValue*(PL17S-PL1S+TZS))
              +(Vl2S*PipValue*(PL17S-PL2S+TZS))
              +(Vl3S*PipValue*(PL17S-PL3S+TZS))
              +(Vl4S*PipValue*(PL17S-PL4S+TZS))
              +(Vl5S*PipValue*(PL17S-PL5S+TZS))
              +(Vl6S*PipValue*(PL17S-PL6S+TZS))
              +(Vl7S*PipValue*(PL17S-PL7S+TZS))
              +(Vl8S*PipValue*(PL17S-PL8S+TZS))
              +(Vl8S*PipValue*(PL17S-PL9S+TZS))
              +(Vl9S*PipValue*(PL17S-PL9S+TZS))
              +(Vl10S*PipValue*(PL17S-PL10S+TZS))
              +(Vl11S*PipValue*(PL17S-PL11S+TZS))
              +(Vl12S*PipValue*(PL17S-PL12S+TZS))
              +(Vl13S*PipValue*(PL17S-PL13S+TZS))
              +(Vl14S*PipValue*(PL17S-PL14S+TZS))
              +(Vl15S*PipValue*(PL17S-PL15S+TZS))
              +(Vl16S*PipValue*(PL17S-PL16S+TZS));
      Vl17S=NormalizeDouble(MathAbs(Loss17S)/TZS/PipValue,decimalPlace);
     }
   if(CONTORS==2)
     {
      Loss17S=2*InpLots*PipValue*(PL17S-PL0S+TZS+step2S)
              +(Vl1S*PipValue*(PL17S-PL1S+TZS))
              +(Vl2S*PipValue*(PL17S-PL2S+TZS))
              +(Vl3S*PipValue*(PL17S-PL3S+TZS))
              +(Vl4S*PipValue*(PL17S-PL4S+TZS))
              +(Vl5S*PipValue*(PL17S-PL5S+TZS))
              +(Vl6S*PipValue*(PL17S-PL6S+TZS))
              +(Vl7S*PipValue*(PL17S-PL7S+TZS))
              +(Vl8S*PipValue*(PL17S-PL8S+TZS))
              +(Vl8S*PipValue*(PL17S-PL9S+TZS))
              +(Vl9S*PipValue*(PL17S-PL9S+TZS))
              +(Vl10S*PipValue*(PL17S-PL10S+TZS))
              +(Vl11S*PipValue*(PL17S-PL11S+TZS))
              +(Vl12S*PipValue*(PL17S-PL12S+TZS))
              +(Vl13S*PipValue*(PL17S-PL13S+TZS))
              +(Vl14S*PipValue*(PL17S-PL14S+TZS))
              +(Vl15S*PipValue*(PL17S-PL15S+TZS))
              +(Vl16S*PipValue*(PL17S-PL16S+TZS));
      Vl17S=NormalizeDouble(MathAbs(Loss17S)/TZS/PipValue,decimalPlace);
     }
   if(CONTORS==3)
     {
      Loss17S=3*InpLots*PipValue*(PL17S-PL0S+TZS+step3S)
              +(Vl1S*PipValue*(PL17S-PL1S+TZS))
              +(Vl2S*PipValue*(PL17S-PL2S+TZS))
              +(Vl3S*PipValue*(PL17S-PL3S+TZS))
              +(Vl4S*PipValue*(PL17S-PL4S+TZS))
              +(Vl5S*PipValue*(PL17S-PL5S+TZS))
              +(Vl6S*PipValue*(PL17S-PL6S+TZS))
              +(Vl7S*PipValue*(PL17S-PL7S+TZS))
              +(Vl8S*PipValue*(PL17S-PL8S+TZS))
              +(Vl8S*PipValue*(PL17S-PL9S+TZS))
              +(Vl9S*PipValue*(PL17S-PL9S+TZS))
              +(Vl10S*PipValue*(PL17S-PL10S+TZS))
              +(Vl11S*PipValue*(PL17S-PL11S+TZS))
              +(Vl12S*PipValue*(PL17S-PL12S+TZS))
              +(Vl13S*PipValue*(PL17S-PL13S+TZS))
              +(Vl14S*PipValue*(PL17S-PL14S+TZS))
              +(Vl15S*PipValue*(PL17S-PL15S+TZS))
              +(Vl16S*PipValue*(PL17S-PL16S+TZS));

      Vl17S=NormalizeDouble(MathAbs(Loss17S)/TZS/PipValue,decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss17S:", Loss17S, " Vl17S:", Vl17S);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V18S()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTORS==1)
     {
      Loss18S=InpLots*PipValue*(PL18S-PL0S+TZS)
              +(Vl1S*PipValue*(PL18S-PL1S+TZS))
              +(Vl2S*PipValue*(PL18S-PL2S+TZS))
              +(Vl3S*PipValue*(PL18S-PL3S+TZS))
              +(Vl4S*PipValue*(PL18S-PL4S+TZS))
              +(Vl5S*PipValue*(PL18S-PL5S+TZS))
              +(Vl6S*PipValue*(PL18S-PL6S+TZS))
              +(Vl7S*PipValue*(PL18S-PL7S+TZS))
              +(Vl8S*PipValue*(PL18S-PL8S+TZS))
              +(Vl8S*PipValue*(PL18S-PL9S+TZS))
              +(Vl9S*PipValue*(PL18S-PL9S+TZS))
              +(Vl10S*PipValue*(PL18S-PL10S+TZS))
              +(Vl11S*PipValue*(PL18S-PL11S+TZS))
              +(Vl12S*PipValue*(PL18S-PL12S+TZS))
              +(Vl13S*PipValue*(PL18S-PL13S+TZS))
              +(Vl14S*PipValue*(PL18S-PL14S+TZS))
              +(Vl15S*PipValue*(PL18S-PL15S+TZS))
              +(Vl16S*PipValue*(PL18S-PL16S+TZS))
              +(Vl17S*PipValue*(PL18S-PL17S+TZS));
      Vl18S=NormalizeDouble(MathAbs(Loss18S)/TZS/PipValue,decimalPlace);
     }
   if(CONTORS==2)
     {
      Loss18S=2*InpLots*PipValue*(PL18S-PL0S+TZS+step2S)
              +(Vl1S*PipValue*(PL18S-PL1S+TZS))
              +(Vl2S*PipValue*(PL18S-PL2S+TZS))
              +(Vl3S*PipValue*(PL18S-PL3S+TZS))
              +(Vl4S*PipValue*(PL18S-PL4S+TZS))
              +(Vl5S*PipValue*(PL18S-PL5S+TZS))
              +(Vl6S*PipValue*(PL18S-PL6S+TZS))
              +(Vl7S*PipValue*(PL18S-PL7S+TZS))
              +(Vl8S*PipValue*(PL18S-PL8S+TZS))
              +(Vl8S*PipValue*(PL18S-PL9S+TZS))
              +(Vl9S*PipValue*(PL18S-PL9S+TZS))
              +(Vl10S*PipValue*(PL18S-PL10S+TZS))
              +(Vl11S*PipValue*(PL18S-PL11S+TZS))
              +(Vl12S*PipValue*(PL18S-PL12S+TZS))
              +(Vl13S*PipValue*(PL18S-PL13S+TZS))
              +(Vl14S*PipValue*(PL18S-PL14S+TZS))
              +(Vl15S*PipValue*(PL18S-PL15S+TZS))
              +(Vl16S*PipValue*(PL18S-PL16S+TZS))
              +(Vl17S*PipValue*(PL18S-PL17S+TZS));
      Vl18S=NormalizeDouble(MathAbs(Loss18S)/TZS/PipValue,decimalPlace);
     }
   if(CONTORS==3)
     {
      Loss18S=3*InpLots*PipValue*(PL18S-PL0S+TZS+step3S)
              +(Vl1S*PipValue*(PL18S-PL1S+TZS))
              +(Vl2S*PipValue*(PL18S-PL2S+TZS))
              +(Vl3S*PipValue*(PL18S-PL3S+TZS))
              +(Vl4S*PipValue*(PL18S-PL4S+TZS))
              +(Vl5S*PipValue*(PL18S-PL5S+TZS))
              +(Vl6S*PipValue*(PL18S-PL6S+TZS))
              +(Vl7S*PipValue*(PL18S-PL7S+TZS))
              +(Vl8S*PipValue*(PL18S-PL8S+TZS))
              +(Vl8S*PipValue*(PL18S-PL9S+TZS))
              +(Vl9S*PipValue*(PL18S-PL9S+TZS))
              +(Vl10S*PipValue*(PL18S-PL10S+TZS))
              +(Vl11S*PipValue*(PL18S-PL11S+TZS))
              +(Vl12S*PipValue*(PL18S-PL12S+TZS))
              +(Vl13S*PipValue*(PL18S-PL13S+TZS))
              +(Vl14S*PipValue*(PL18S-PL14S+TZS))
              +(Vl15S*PipValue*(PL18S-PL15S+TZS))
              +(Vl16S*PipValue*(PL18S-PL16S+TZS))
              +(Vl17S*PipValue*(PL18S-PL17S+TZS));

      Vl18S=NormalizeDouble(MathAbs(Loss18S)/TZS/PipValue,decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss18S:", Loss18S, " Vl18S:", Vl18S);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_V19S()
  {
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTORS==1)
     {
      Loss19S=InpLots*PipValue*(PL19S-PL0S+TZS)
              +(Vl1S*PipValue*(PL19S-PL1S+TZS))
              +(Vl2S*PipValue*(PL19S-PL2S+TZS))
              +(Vl3S*PipValue*(PL19S-PL3S+TZS))
              +(Vl4S*PipValue*(PL19S-PL4S+TZS))
              +(Vl5S*PipValue*(PL19S-PL5S+TZS))
              +(Vl6S*PipValue*(PL19S-PL6S+TZS))
              +(Vl7S*PipValue*(PL19S-PL7S+TZS))
              +(Vl8S*PipValue*(PL19S-PL8S+TZS))
              +(Vl8S*PipValue*(PL19S-PL9S+TZS))
              +(Vl9S*PipValue*(PL19S-PL9S+TZS))
              +(Vl10S*PipValue*(PL19S-PL10S+TZS))
              +(Vl11S*PipValue*(PL19S-PL11S+TZS))
              +(Vl12S*PipValue*(PL19S-PL12S+TZS))
              +(Vl13S*PipValue*(PL19S-PL13S+TZS))
              +(Vl14S*PipValue*(PL19S-PL14S+TZS))
              +(Vl15S*PipValue*(PL19S-PL15S+TZS))
              +(Vl16S*PipValue*(PL19S-PL16S+TZS))
              +(Vl17S*PipValue*(PL19S-PL17S+TZS))
              +(Vl18S*PipValue*(PL19S-PL18S+TZS));
      Vl19S=NormalizeDouble(MathAbs(Loss19S)/TZS/PipValue,decimalPlace);
     }
   if(CONTORS==2)
     {
      Loss19S=2*InpLots*PipValue*(PL19S-PL0S+TZS+step2S)
              +(Vl1S*PipValue*(PL19S-PL1S+TZS))
              +(Vl2S*PipValue*(PL19S-PL2S+TZS))
              +(Vl3S*PipValue*(PL19S-PL3S+TZS))
              +(Vl4S*PipValue*(PL19S-PL4S+TZS))
              +(Vl5S*PipValue*(PL19S-PL5S+TZS))
              +(Vl6S*PipValue*(PL19S-PL6S+TZS))
              +(Vl7S*PipValue*(PL19S-PL7S+TZS))
              +(Vl8S*PipValue*(PL19S-PL8S+TZS))
              +(Vl8S*PipValue*(PL19S-PL9S+TZS))
              +(Vl9S*PipValue*(PL19S-PL9S+TZS))
              +(Vl10S*PipValue*(PL19S-PL10S+TZS))
              +(Vl11S*PipValue*(PL19S-PL11S+TZS))
              +(Vl12S*PipValue*(PL19S-PL12S+TZS))
              +(Vl13S*PipValue*(PL19S-PL13S+TZS))
              +(Vl14S*PipValue*(PL19S-PL14S+TZS))
              +(Vl15S*PipValue*(PL19S-PL15S+TZS))
              +(Vl16S*PipValue*(PL19S-PL16S+TZS))
              +(Vl17S*PipValue*(PL19S-PL17S+TZS))
              +(Vl18S*PipValue*(PL19S-PL18S+TZS));
      Vl19S=NormalizeDouble(MathAbs(Loss19S)/TZS/PipValue,decimalPlace);
     }
   if(CONTORS==3)
     {
      Loss19S=3*InpLots*PipValue*(PL19S-PL0S+TZS+step3S)
              +(Vl1S*PipValue*(PL19S-PL1S+TZS))
              +(Vl2S*PipValue*(PL19S-PL2S+TZS))
              +(Vl3S*PipValue*(PL19S-PL3S+TZS))
              +(Vl4S*PipValue*(PL19S-PL4S+TZS))
              +(Vl5S*PipValue*(PL19S-PL5S+TZS))
              +(Vl6S*PipValue*(PL19S-PL6S+TZS))
              +(Vl7S*PipValue*(PL19S-PL7S+TZS))
              +(Vl8S*PipValue*(PL19S-PL8S+TZS))
              +(Vl8S*PipValue*(PL19S-PL9S+TZS))
              +(Vl9S*PipValue*(PL19S-PL9S+TZS))
              +(Vl10S*PipValue*(PL19S-PL10S+TZS))
              +(Vl11S*PipValue*(PL19S-PL11S+TZS))
              +(Vl12S*PipValue*(PL19S-PL12S+TZS))
              +(Vl13S*PipValue*(PL19S-PL13S+TZS))
              +(Vl14S*PipValue*(PL19S-PL14S+TZS))
              +(Vl15S*PipValue*(PL19S-PL15S+TZS))
              +(Vl16S*PipValue*(PL19S-PL16S+TZS))
              +(Vl17S*PipValue*(PL19S-PL17S+TZS))
              +(Vl18S*PipValue*(PL19S-PL18S+TZS));
      Vl19S=NormalizeDouble(MathAbs(Loss19S)/TZS/PipValue,decimalPlace);
     }
   Print("PipValue:", PipValue, " Loss19S:", Loss19S, " Vl19S:", Vl19S);
  }

//+------------------------------------------------------------------+

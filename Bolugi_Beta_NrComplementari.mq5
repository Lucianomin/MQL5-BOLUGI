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
input group "--NumarComplemenatri(LONG)--";
input int InpNumberComplementariLong=3; //1 sau 2 sau 3
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
input group "--NumarComplemenatri(SHORT)--";
input int InpNumberComplementariShort=3;// 1 sau 2 sau 3
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
     }
     Print("TP1",TP1);
     Print("TP2",TP2);
     Print("TP3",TP3);
     Print("TP4",TP4);
     Print("TP5",TP5);
     Print("TP6",TP6);  
     Print("TP7",TP7);
     Print("TP8",TP8);
     Print("TP9",TP9);
   if(InpTPMode==true)
     {
      PL1=NormalizeDouble(PL0-((23.6*InpRangeM)/100*_Point+TP1*_Point),_Digits);
      PL2=NormalizeDouble(PL0-((38.2*InpRangeM)/100*_Point+TP2*_Point),_Digits);
      PL3=NormalizeDouble(PL0-((50*InpRangeM)/100*_Point+TP3*_Point),_Digits);
      PL4=NormalizeDouble(PL0-((61.8*InpRangeM)/100*_Point+TP4*_Point),_Digits);
      PL5=NormalizeDouble(PL0-((78.6*InpRangeM)/100*_Point+TP5*_Point),_Digits);
      PL6=NormalizeDouble(PL0-((88.2*InpRangeM)/100*_Point+TP6*_Point),_Digits);
      PL7=NormalizeDouble(PL0-(InpRangeM*_Point+TP7*_Point),_Digits);
      PL8=NormalizeDouble(PL0-((127.2*InpRangeM)/100*_Point+TP8*_Point),_Digits);
      PL9=NormalizeDouble(PL0-((161.8*InpRangeM)/100*_Point+TP9*_Point),_Digits);
     }
   else
     {
      PL1=NormalizeDouble(PL0-((23.6*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
      PL2=NormalizeDouble(PL0-((38.2*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
      PL3=NormalizeDouble(PL0-((50*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
      PL4=NormalizeDouble(PL0-((61.8*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
      PL5=NormalizeDouble(PL0-((78.6*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
      PL6=NormalizeDouble(PL0-((88.2*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
      PL7=NormalizeDouble(PL0-(InpRangeM*_Point+InpDistTakeProfit*_Point),_Digits);
      PL8=NormalizeDouble(PL0-((127.2*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
      PL9=NormalizeDouble(PL0-((161.8*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
     }
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
   if(CountOpenPositions()>=InpNumberComplementariLong+1 && medierebuy==false && CONTOR>=InpNumberComplementariLong+1)
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
      PL1S=NormalizeDouble(PL0S+((23.6*InpRangeMS)/100*_Point+TPS1*_Point),_Digits);
      PL2S=NormalizeDouble(PL0S+((38.2*InpRangeMS)/100*_Point+TPS2*_Point),_Digits);
      PL3S=NormalizeDouble(PL0S+((50*InpRangeMS)/100*_Point+TPS3*_Point),_Digits);
      PL4S=NormalizeDouble(PL0S+((61.8*InpRangeMS)/100*_Point+TPS4*_Point),_Digits);
      PL5S=NormalizeDouble(PL0S+((78.6*InpRangeMS)/100*_Point+TPS5*_Point),_Digits);
      PL6S=NormalizeDouble(PL0S+((88.2*InpRangeMS)/100*_Point+TPS6*_Point),_Digits);
      PL7S=NormalizeDouble(PL0S+(InpRangeMS*_Point+TPS7*_Point),_Digits);
      PL8S=NormalizeDouble(PL0S+((127.2*InpRangeMS)/100*_Point+TPS8*_Point),_Digits);
      PL9S=NormalizeDouble(PL0S+((161.8*InpRangeMS)/100*_Point+TPS9*_Point),_Digits);
     }
   else
     {
      PL1S=NormalizeDouble(PL0S+((23.6*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
      PL2S=NormalizeDouble(PL0S+((38.2*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
      PL3S=NormalizeDouble(PL0S+((50*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
      PL4S=NormalizeDouble(PL0S+((61.8*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
      PL5S=NormalizeDouble(PL0S+((78.6*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
      PL6S=NormalizeDouble(PL0S+((88.2*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
      PL7S=NormalizeDouble(PL0S+(InpRangeMS*_Point+InpDistTakeProfitS*_Point),_Digits);
      PL8S=NormalizeDouble(PL0S+((127.2*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
      PL9S=NormalizeDouble(PL0S+((161.8*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
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
   if(CountOpenPositions()>=InpNumberComplementariShort+1 && medieresell==false && CONTORS>=InpNumberComplementariShort+1)
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
      PL1=NormalizeDouble(PL0-((23.6*InpRangeM)/100*_Point+TP1*_Point),_Digits);
      PL2=NormalizeDouble(PL0-((38.2*InpRangeM)/100*_Point+TP2*_Point),_Digits);
      PL3=NormalizeDouble(PL0-((50*InpRangeM)/100*_Point+TP3*_Point),_Digits);
      PL4=NormalizeDouble(PL0-((61.8*InpRangeM)/100*_Point+TP4*_Point),_Digits);
      PL5=NormalizeDouble(PL0-((78.6*InpRangeM)/100*_Point+TP5*_Point),_Digits);
      PL6=NormalizeDouble(PL0-((88.2*InpRangeM)/100*_Point+TP6*_Point),_Digits);
      PL7=NormalizeDouble(PL0-(InpRangeM*_Point+TP7*_Point),_Digits);
      PL8=NormalizeDouble(PL0-((127.2*InpRangeM)/100*_Point+TP8*_Point),_Digits);
      PL9=NormalizeDouble(PL0-((161.8*InpRangeM)/100*_Point+TP9*_Point),_Digits);
     }
   else
     {
      PL1=NormalizeDouble(PL0-((23.6*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
      PL2=NormalizeDouble(PL0-((38.2*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
      PL3=NormalizeDouble(PL0-((50*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
      PL4=NormalizeDouble(PL0-((61.8*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
      PL5=NormalizeDouble(PL0-((78.6*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
      PL6=NormalizeDouble(PL0-((88.2*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
      PL7=NormalizeDouble(PL0-(InpRangeM*_Point+InpDistTakeProfit*_Point),_Digits);
      PL8=NormalizeDouble(PL0-((127.2*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
      PL9=NormalizeDouble(PL0-((161.8*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
     }
//SHORT PL0S
   if(InpTPSMode==true)
     {
      PL1S=NormalizeDouble(PL0S+((23.6*InpRangeMS)/100*_Point+TPS1*_Point),_Digits);
      PL2S=NormalizeDouble(PL0S+((38.2*InpRangeMS)/100*_Point+TPS2*_Point),_Digits);
      PL3S=NormalizeDouble(PL0S+((50*InpRangeMS)/100*_Point+TPS3*_Point),_Digits);
      PL4S=NormalizeDouble(PL0S+((61.8*InpRangeMS)/100*_Point+TPS4*_Point),_Digits);
      PL5S=NormalizeDouble(PL0S+((78.6*InpRangeMS)/100*_Point+TPS5*_Point),_Digits);
      PL6S=NormalizeDouble(PL0S+((88.2*InpRangeMS)/100*_Point+TPS6*_Point),_Digits);
      PL7S=NormalizeDouble(PL0S+(InpRangeMS*_Point+TPS7*_Point),_Digits);
      PL8S=NormalizeDouble(PL0S+((127.2*InpRangeMS)/100*_Point+TPS8*_Point),_Digits);
      PL9S=NormalizeDouble(PL0S+((161.8*InpRangeMS)/100*_Point+TPS9*_Point),_Digits);
     }
   else
     {
      PL1S=NormalizeDouble(PL0S+((23.6*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
      PL2S=NormalizeDouble(PL0S+((38.2*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
      PL3S=NormalizeDouble(PL0S+((50*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
      PL4S=NormalizeDouble(PL0S+((61.8*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
      PL5S=NormalizeDouble(PL0S+((78.6*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
      PL6S=NormalizeDouble(PL0S+((88.2*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
      PL7S=NormalizeDouble(PL0S+(InpRangeMS*_Point+InpDistTakeProfitS*_Point),_Digits);
      PL8S=NormalizeDouble(PL0S+((127.2*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
      PL9S=NormalizeDouble(PL0S+((161.8*InpRangeMS)/100*_Point+InpDistTakeProfitS*_Point),_Digits);
     }
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


   Comment("CONTOR:",CONTOR);
   Comment("CONTORS:",CONTORS);

   Comment("\n","NextBuyPrice: ",NextBuyPrice,"\n");
   Comment("\n","NexSellPrice: ",NextSellPrice,"\n");

//complementare buy
   if(CountOpenPositions()>=InpNumberComplementariLong+1 && medierebuy==false && CONTOR>=InpNumberComplementariLong+1)
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
   if(CountOpenPositions()>=InpNumberComplementariShort+1 && medieresell==false && CONTORS>=InpNumberComplementariShort+1)
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
void Calculate_V1()//Volum 1 Long
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

//+------------------------------------------------------------------+

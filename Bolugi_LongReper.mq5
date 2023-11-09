
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
input int InpConstantVolume=10;
input double InpLots=0.01; //fixed/additional lots/percent

input group "---->Range Inputs(Complementare)<----";
//stop loss mode

input int InpStopLoss=100; // InpStopLoss (pips / percent)
input int InpStepC=100; // InpStepC (pips)
input bool InpTrailMode=true; //TrailMode (true/false)
input int InpTrailStop=20; //InpTrailStop (pips)


input group "---->Range Inputs(Mediere)<----";

input int InpRangeM=1000;//InpRangeM (pips)
input int InpZTP=2;//InpZTP (pips)
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
MqlTick prevTick, lastTick;
CTrade trade;

int      PositionNumber=0;
int      PositionBuyNumber=0;
int      PositionSellNumber=0;
int      TotalBuyPositions=0;
int      TotalSellPositions=0;
double   MaxClose=0.0;
double   MaxSellClose=9999.0;
int      ContorM=0;
bool     medierebuy=false;
bool     complementarebuy=false;
bool     medieresell=false;
bool     complementaresell=true;
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
     Level17=false;
int      PositionMediereNumber=0;
int      ContorMC=0;
int      MediereNumber=0;
double   lossZetCopie=0;
double   RangeM=InpRangeM;
ulong    TicketNumber=-1;
ulong    TicketNumber1=-1;
double   PriceStartMB=0.0;
double   PriceZ=0.0;
double RangeMB0=0.0;
int CONTOR=0;
//+------------------------------------------------------------------+
//+VOLUME                                           |
//+------------------------------------------------------------------+
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
        Loss17=0.0;
        
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
         Vl17=0.0;
double 
       PL1,
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
       PL17;
double TZ=InpDistTakeProfit/InpZTP*_Point;
int decimalPlace=2;
double step2=(InpStepC/2)*_Point;
double step3=InpStepC*_Point;
double PL0;
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
   prevTick=lastTick;
   SymbolInfoTick(_Symbol,lastTick);
 
   if(InpBotMode==BOLUGI_LONG)
   {
   Bolugi_Long();
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
     Alert("InpStepC <=0");
     return false;
     }
     
  return true;
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
    CONTOR=0;
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

            double moneyVolumeStep= ((1250*_Point)/tickSize) * tickValue *volumeStep;
            lots=MathFloor(riskMoney/moneyVolumeStep)*volumeStep;

         return lots;
        }
        
        return lots;
        
}

//Bolugi long function
// contorizeaza la care mediere suntem cu un contor Med=1,2,3 dupa ce se inchide medierea sau complementarea!!!
void Bolugi_Long()
{
   //Print("Pipvalue:",CalculatePipValue()*0.01);
  //static next buy price
  static double NextBuyPrice;
  //static double PL0;
  //double ask =NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
  //sort
  ArraySetAsSeries(PriceInfo,true);
  int PriceData= CopyRates(_Symbol,_Period,0,3,PriceInfo);
  double Lots= CalculateLots(InpLots);
  double pipValue = CalculatePipValue()*0.01;
   if(CountOpenPositions()==0)
   {
   NextBuyPrice=0;
   trade.Buy(Lots,NULL,lastTick.ask,0,0,"COMPLEMENTARE BUY");
   TicketNumber1=trade.ResultOrder();
   RangeMB0=lastTick.ask;
  CONTOR=1;
  NextBuyPrice=RangeMB0+InpStepC*_Point;
   }
   for(int i=0;i<CountOpenPositions();i++)
     {
      ulong currTicket=PositionGetTicket(i);
      if(currTicket!=TicketNumber1)
      {
      Print("ticket!=TicketNumer1",currTicket);
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
         
     
   
   //Print("PL0  ",PL0);
   if(lastTick.ask>=NextBuyPrice  && medierebuy==false)
   {
      trade.Buy(Lots,NULL,lastTick.ask,0,0,"COMPLEMENTARE BUY");//a deschis poziti
      RangeMB0=lastTick.ask;
      NextBuyPrice=RangeMB0+InpStepC*_Point;// averificat range
      TicketNumber=trade.ResultDeal();
      CONTOR++;
   }
   Print("NextBuyPrice",NextBuyPrice);
   //+------------------------------------------------------------------+
//| LEVELE FIBONACCI                                             |
//+------------------------------------------------------------------+

   PL1=NormalizeDouble(PL0-((23.60*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL2=NormalizeDouble(PL0-((38.20*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL3=NormalizeDouble(PL0-((50.0*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL4=NormalizeDouble(PL0-((61.80*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL5=NormalizeDouble(PL0-((76.45*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
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
   PL15=NormalizeDouble(PL0-((427.20*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits); 
   PL16=NormalizeDouble(PL0-((461.80*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);
   PL17=NormalizeDouble(PL0-((500.00*InpRangeM)/100*_Point+InpDistTakeProfit*_Point),_Digits);    
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
   Calculate_V11();  
   Calculate_V12();  
   Calculate_V13(); 
   Calculate_V14();  
   Calculate_V15();  
   Calculate_V16();  
   Calculate_V17();     
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
  Print("PL11  ",PL11);
  Print("PL12  ",PL12);
  Print("PL13  ",PL13);
  Print("PL14  ",PL14);
  Print("PL15  ",PL15);
  Print("PL16  ",PL16);
  Print("PL17  ",PL17);
 
  Print("CONTOR:",CONTOR);
  // Draw_HLine(PL1,clrGold);
  // Draw_HLine(PL2,clrGold);
   //Draw_HLine(PL3,clrGold);
   //Draw_HLine(PL4,clrGold);
   //Draw_HLine(PL5,clrGold);
   //Draw_HLine(PL6,clrGold);
   //Draw_HLine(PL7,clrGold);                   
   //chart output
   Comment("Ask",lastTick.ask,"\n","NextBuyPrice: ",NextBuyPrice,"\n");
   //complementare buy
   if(CountOpenPositions()>=4 && medierebuy==false)
   {
   complementarebuy=true;
   if(PositionSelectByTicket(TicketNumber))
   {
   if(PositionGetDouble(POSITION_SL)==0)
   {
   trade.PositionModify(TicketNumber,(RangeMB0-(InpStopLoss*_Point)),0);
   }
   }
   
      /*   if(!PositionSelectByTicket(TicketNumber))
            {
            Print("Error couldnt get the ticket number",TicketNumber);
            }
            else
              {
              double currP=NormalizeDouble(PositionGetDouble(POSITION_PRICE_CURRENT),_Digits);
              double currSL=NormalizeDouble(PositionGetDouble(POSITION_SL),_Digits);
              double newSL=NormalizeDouble(currP+InpTrailStop*_Point,_Digits);
              if(newSL<currSL || NormalizeDouble(MathAbs(newSL-currSL),_Digits)<_Point)
              {
              Print("No new stop loss needed");
              }
               //trade.PositionModify(TicketNumber,newSL,0);
               long level=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
               if(level!=0 && MathAbs(currP-newSL)<=level*_Point)
               {
               Print("New stop loss inside the level");
               }
               if(!trade.PositionModify(TicketNumber,newSL,0))
                 {
                  Print("Failed to modify positon");
                 }
              }
         */
         
         
  /* double SL=NormalizeDouble(RangeMB0-InpTrailStop*_Point,_Digits);
   if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            {
               if(PositionSelectByTicket(TicketNumber))
                  {
                     double CurrStopLoss=PositionGetDouble(POSITION_SL);
                     if(CurrStopLoss<SL)
                     {
                     trade.PositionModify(TicketNumber,(CurrStopLoss+(InpTrailStop*_Point)),0);
                     }
                     
            
                  }
            }
   */
   /*trade.PositionModify(TicketNumber,(RangeMB0-(InpStopLoss*_Point)),0);
   if (PositionSelectByTicket(TicketNumber))
{
    double currentStopLoss = PositionGetDouble(POSITION_SL);
    double currentAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    
    if (currentStopLoss < (currentAsk - InpTrailStop * _Point))
    {
        double newStopLoss = RangeMB0 - InpTrailStop * _Point;
        if (trade.PositionModify(TicketNumber, newStopLoss, 0))
        {
            Print("Trailing stop loss modified to: ", newStopLoss);
        }
        else
        {
            Print("Error modifying stop loss: ", GetLastError());
        }
    }
}*/   
      
   /*int totalPositions = PositionsTotal();
   double RangePrice = RangeMB0; // Initialize with a default value
   double TrailPrice=RangePrice+InpTrailStop*_Point;
   NormalizeDouble(TrailPrice,_Digits);
   double ClosePrice=RangePrice-InpStopLoss*_Point; //calculeaza nivelul de stop loss
   NormalizeDouble(ClosePrice,_Digits);
      if(InpTrailMode==true)
      {
         while(lastTick.ask>=TrailPrice)
	      {
	       ClosePrice=ClosePrice+InpTrailStop*_Point;
		    TrailPrice=TrailPrice+InpTrailStop*_Point; 
		    if(ClosePrice>=MaxClose){MaxClose=ClosePrice;}
	      }
	     Draw_HLine(MaxClose,clrRed);
      }
      else
        {
         MaxClose=ClosePrice;
        }
        Draw_HLine(MaxClose,clrRed);
      if(lastTick.ask<=MaxClose)
         {
          CloseBuyPositions();// inchide toate pozitiile cand
          Delete_HLine();
          } */   
  
     }
      //afara din complementre if statementa
     if(medierebuy==false && complementarebuy==true)
     {
     double lastBuyStopLoss=0.0,lastBuyPosition=0.0,currP=0.0;
         if(PositionSelectByTicket(TicketNumber))
              {
                  if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
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
      
      //Print("LevelMediereContor:",CONTOR);
      //mediere buy
      if(Level1==false) ///LEVEL 1 Fibonacci
        {
        
        if(lastTick.ask<=PL1) 
            {
               
               if(trade.Buy(Vl1,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order1 & TP1"))
               {
               Level1=true;
               medierebuy=true;
               complementarebuy=false;
               TicketNumber=trade.ResultOrder();
               }
               else {Alert("ERROR, Check Volume!!!");}
            }  
             
        }
         else if(Level1==true && Level2==false)///LEVEL 2 Fibonacci
         {
               if(lastTick.ask<=PL2) 
                  {
               
               if(trade.Buy(Vl2,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order2 & TP2"))
               {
               Level2=true;
               ContorM=2;
               TicketNumber=trade.ResultOrder();
               }
               else {Alert("ERROR, Check Volume!!!");}
                  }   
         }
         
         else if(Level2==true && Level3==false)///LEVEL 3 Fibonacci
         {
               
               if(lastTick.ask<=PL3) 
                  {
             
               if(trade.Buy(Vl3,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order3 &Tp3"))
               {
               Level3=true;
               ContorM=3;
               TicketNumber=trade.ResultOrder();
               }
                else {Alert("ERROR, Check Volume!!!");}
                  }

         }
        else if(Level3==true && Level4==false)///LEVEL 4 Fibonacci
         {
         
           
               if(lastTick.ask<=PL4) 
                  {
                  
               if(trade.Buy(Vl4,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order4 &Tp4"))
               {
               Level4=true;
               ContorM=4;
               TicketNumber=trade.ResultOrder();
               }
               else {Alert("ERROR, Check Volume!!!");}
                  }

         }
         else if(Level4==true && Level5==false)///LEVEL 5 Fibonacci
         {
         
             
               if(lastTick.ask<=PL5) 
                  {
                  
               if(trade.Buy(Vl5,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order5 &Tp5"))
               {
               Level5=true;
               ContorM=5;
               TicketNumber=trade.ResultOrder();
               }
                else {Alert("ERROR, Check Volume!!!");}
                  }
             
            
         }
         else if(Level5==true && Level6==false)///LEVEL 6 Fibonacci
         {
               
               if(lastTick.ask<=PL6) 
                  {
                  
               if(trade.Buy(Vl6,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order6 &Tp6"))
               {
               Level6=true;
               ContorM=6;
               TicketNumber=trade.ResultOrder();
               }
               else {Alert("ERROR, Check Volume!!!");}
                   }
         
         }
         else if(Level6==true && Level7==false)///LEVEL 7 Fibonacci
         {
         
            
               if(lastTick.ask<=PL7) 
                  {
                 
               if(trade.Buy(Vl7,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order7 &Tp7"))
               {
               Level7=true;//ba e nevoie
               ContorM=7;
               TicketNumber=trade.ResultOrder();
               }
               else {Alert("ERROR, Check Volume!!!");}
                  }

         }
         else if(Level7==true && Level8==false)///LEVEL 7 Fibonacci
         {
         
            
               if(lastTick.ask<=PL8) 
                  {
                 
               if(trade.Buy(Vl8,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order8 &Tp8"))
               {
               Level8=true;//ba e nevoie
               ContorM=8;
               TicketNumber=trade.ResultOrder();
               }
               else {Alert("ERROR, Check Volume!!!");}
                  }

         }
         else if(Level8==true && Level9==false)///LEVEL 7 Fibonacci
         {
         
            
               if(lastTick.ask<=PL9) 
                  {
                 
               if(trade.Buy(Vl9,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order9 &Tp9"))
               {
               Level9=true;//ba e nevoie
               ContorM=9;
               TicketNumber=trade.ResultOrder();
               }
               else {Alert("ERROR, Check Volume!!!");}
                  }

         }
         else if(Level9==true && Level10==false)///LEVEL 7 Fibonacci
         {
         
            
               if(lastTick.ask<=PL10) 
                  {
                 
               if(trade.Buy(Vl10,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order10 &Tp10"))
               {
               Level10=true;//ba e nevoie
               ContorM=10;
               TicketNumber=trade.ResultOrder();
               }
               else {Alert("ERROR, Check Volume!!!");}
                  }

         }
         else if(Level10==true && Level11==false)///LEVEL 7 Fibonacci
         {
         
            
               if(lastTick.ask<=PL11) 
                  {
                 
               if(trade.Buy(Vl11,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order11 &Tp11"))
               {
               Level11=true;//ba e nevoie
               ContorM=11;
               TicketNumber=trade.ResultOrder();
               }
                else {Alert("ERROR, Check Volume!!!");}
                  }

         }
         else if(Level11==true && Level12==false)///LEVEL 7 Fibonacci
         {
         
            
               if(lastTick.ask<=PL12) 
                  {
                 
               if(trade.Buy(Vl12,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order12 &Tp12"))
               {
               Level12=true;//ba e nevoie
               ContorM=12;
               TicketNumber=trade.ResultOrder();
               }
               else {Alert("ERROR, Check Volume!!!");}
                  }

         }
         else if(Level12==true && Level13==false)///LEVEL 7 Fibonacci
         {
         
            
               if(lastTick.ask<=PL13) 
                  {
                 
               if(trade.Buy(Vl13,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order13 &Tp13"))
               {
               Level13=true;//ba e nevoie
               ContorM=13;
               TicketNumber=trade.ResultOrder();
               }
               else {Alert("ERROR, Check Volume!!!");}
                  }

         }
       
         else if(Level13==true && Level14==false)///LEVEL 7 Fibonacci
         {
         
            
               if(lastTick.ask<=PL14) 
                  {
                 
               if(trade.Buy(Vl14,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order14 &Tp14"))
               {
               Level14=true;//ba e nevoie
               ContorM=14;
               TicketNumber=trade.ResultOrder();
               }
               else {Alert("ERROR, Check Volume!!!");}
                  }

         }
         else if(Level14==true && Level15==false)///LEVEL 7 Fibonacci
         {
         
            
               if(lastTick.ask<=PL15) 
                  {
                 
               if(trade.Buy(Vl15,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order15 &Tp15"))
               {
               Level15=true;//ba e nevoie
               ContorM=15;
               TicketNumber=trade.ResultOrder();
               }
               else {Alert("ERROR, Check Volume!!!");}
                  }

         }
         else if(Level15==true && Level16==false)///LEVEL 7 Fibonacci
         {
         
            
               if(lastTick.ask<=PL16) 
                  {
                 
               if(trade.Buy(Vl16,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order16 &Tp16"))
               {
               Level16=true;//ba e nevoie
               ContorM=16;
               TicketNumber=trade.ResultOrder();
               }
               else {Alert("ERROR, Check Volume!!!");}
                  }

         }
         else if(Level16==true && Level17==false)///LEVEL 7 Fibonacci
         {
         
            
               if(lastTick.ask<=PL17) 
                  {
                 
               if(trade.Buy(Vl17,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order17 &Tp17"))
               {
               Level17=true;//ba e nevoie
               ContorM=17;
               TicketNumber=trade.ResultOrder();
               }
               else {Alert("ERROR, Check Volume!!!");}
                  }

         }
      if(medierebuy==true)
      {
      double lastBuyTakeProfit=0.0,lastBuyPosition=0.0;
      if(PositionSelectByTicket(TicketNumber))
         {
          if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
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
         }
      //CloseBuyPositionsOnLastTakeProfit();
      // CONTOR=0;
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
        ObjectSetInteger(0, stopLossObjectName, OBJPROP_WIDTH, 2); 
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

void Calculate_V1()
{
double PipValue=CalculatePipValue()*InpLots;
if(CONTOR==1)
   {
     Loss1=InpLots*PipValue*(PL1-PL0+TZ);//0.00436-1.27503+0.00100
     Loss1=MathAbs(Loss1);
     Vl1=NormalizeDouble(Loss1/TZ/PipValue,decimalPlace);
     
        }
   if(CONTOR==2)
     {
      Loss1=2*InpLots*PipValue*(PL1-PL0+TZ+step2);
     Loss1=MathAbs(Loss1);
     Vl1=NormalizeDouble(Loss1/TZ/PipValue,decimalPlace);
     }
     if(CONTOR==3)
         {
        Loss1=3*InpLots*PipValue*(PL1-PL0+TZ+step3);
     Loss1=MathAbs(Loss1);
     Vl1=NormalizeDouble(Loss1/TZ/PipValue,decimalPlace);
         }
         Print("PipValue:",PipValue," Loss1:",Loss1," Vl1:",Vl1);
}
void Calculate_V2()
{
double PipValue=CalculatePipValue()*InpLots;
if(CONTOR==1)
   {
     Loss2=InpLots*PipValue*(PL2-PL0+TZ)
     +(Vl1*PipValue*(PL2-PL1+TZ));
     Loss2=MathAbs(Loss2);
     Vl2=NormalizeDouble(Loss2/TZ/PipValue,decimalPlace);
     
        }
   if(CONTOR==2)
     {
      Loss2=2*InpLots*PipValue*(PL2-PL0+TZ+step2)
     +(Vl1*PipValue*(PL2-PL1+TZ));
     Loss2=MathAbs(Loss2);
     Vl2=NormalizeDouble(Loss2/TZ/PipValue,decimalPlace);
     }
     if(CONTOR==3)
         {
        Loss2=3*InpLots*PipValue*(PL2-PL0+TZ+step3)
     +(Vl1*PipValue*(PL2-PL1+TZ));
     Loss2=MathAbs(Loss2);
     Vl2=NormalizeDouble(Loss2/TZ/PipValue,decimalPlace);
         }
         Print("PipValue:",PipValue," Loss2:",Loss2," Vl2:",Vl2);
}
void Calculate_V3()
{
double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
   {
     Loss3=InpLots*PipValue*(PL3-PL0+TZ)
     +(Vl1*PipValue*(PL3-PL1+TZ))
     +(Vl2*PipValue*(PL3-PL2+TZ));
     Loss3=MathAbs(Loss3);
     Vl3=NormalizeDouble(Loss3/TZ/PipValue,decimalPlace);
     
        }
   if(CONTOR==2)
     {
      Loss3=2*InpLots*PipValue*(PL3-PL0+TZ+step2)
     +(Vl1*PipValue*(PL3-PL1+TZ))
     +(Vl2*PipValue*(PL3-PL2+TZ));
     Loss3=MathAbs(Loss3);
     Vl3=NormalizeDouble(Loss3/TZ/PipValue,decimalPlace);
     }
     if(CONTOR==3)
         {
        Loss3=3*InpLots*PipValue*(PL3-PL0+TZ+step3)
     +(Vl1*PipValue*(PL4-PL1+TZ))
     +(Vl2*PipValue*(PL4-PL2+TZ));
     Loss3=MathAbs(Loss3);
     Vl3=NormalizeDouble(Loss3/TZ/PipValue,decimalPlace);
         }
         Print("PipValue:",PipValue," Loss3:",Loss3," Vl3:",Vl3);
}
void Calculate_V4()
{
double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
   {
     Loss4=InpLots*PipValue*(PL4-PL0+TZ)
     +(Vl1*PipValue*(PL4-PL1+TZ))
     +(Vl2*PipValue*(PL4-PL2+TZ))
     +(Vl3*PipValue*(PL4-PL3+TZ));
     
     Loss4=MathAbs(Loss4);
     Vl4=NormalizeDouble(Loss4/TZ/PipValue,decimalPlace);
     
        }
   if(CONTOR==2)
     {
      Loss4=2*InpLots*PipValue*(PL4-PL0+TZ+step2)
     +(Vl1*PipValue*(PL4-PL1+TZ))
     +(Vl2*PipValue*(PL4-PL2+TZ))
     +(Vl3*PipValue*(PL4-PL3+TZ));
     Loss4=MathAbs(Loss4);
     Vl4=NormalizeDouble(Loss4/TZ/PipValue,decimalPlace);
     }
     if(CONTOR==3)
         {
        Loss4=3*InpLots*PipValue*(PL4-PL0+TZ+step3)
     +(Vl1*PipValue*(PL4-PL1+TZ))
     +(Vl2*PipValue*(PL4-PL2+TZ))
     +(Vl3*PipValue*(PL4-PL3+TZ));
     Loss4=MathAbs(Loss4);
     Vl4=NormalizeDouble(Loss4/TZ/PipValue,decimalPlace);
         }
         Print("PipValue:",PipValue," Loss4:",Loss4," Vl4:",Vl4);
}
void Calculate_V5()
{
double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
   {
     Loss5=InpLots*PipValue*(PL5-PL0+TZ)
     +(Vl1*PipValue*(PL5-PL1+TZ))
     +(Vl2*PipValue*(PL5-PL2+TZ))
     +(Vl3*PipValue*(PL5-PL3+TZ))
     +(Vl4*PipValue*(PL5-PL4+TZ));
     Loss5=MathAbs(Loss5);
     Vl5=NormalizeDouble(Loss5/TZ/PipValue,decimalPlace);
     
        }
   if(CONTOR==2)
     {
      Loss5=2*InpLots*PipValue*(PL5-PL0+TZ+step2)
     +(Vl1*PipValue*(PL5-PL1+TZ))
     +(Vl2*PipValue*(PL5-PL2+TZ))
     +(Vl3*PipValue*(PL5-PL3+TZ))
     +(Vl4*PipValue*(PL5-PL4+TZ));
     Loss5=MathAbs(Loss5);
     Vl5=NormalizeDouble(Loss5/TZ/PipValue,decimalPlace);
     }
     if(CONTOR==3)
         {
        Loss5=3*InpLots*PipValue*(PL5-PL0+TZ+step3)
     +(Vl1*PipValue*(PL5-PL1+TZ))
     +(Vl2*PipValue*(PL5-PL2+TZ))
     +(Vl3*PipValue*(PL5-PL3+TZ))
     +(Vl4*PipValue*(PL5-PL4+TZ));
     Loss5=MathAbs(Loss5);
     Vl5=NormalizeDouble(Loss5/TZ/PipValue,decimalPlace);
         }
         Print("PipValue:",PipValue," Loss5:",Loss5," Vl5:",Vl5);
}
void Calculate_V6()
{
double PipValue=CalculatePipValue()*InpLots;
      if(CONTOR==1)
   {
     Loss6=InpLots*PipValue*(PL6-PL0+TZ)
     +(Vl1*PipValue*(PL6-PL1+TZ))
     +(Vl2*PipValue*(PL6-PL2+TZ))
     +(Vl3*PipValue*(PL6-PL3+TZ))
     +(Vl4*PipValue*(PL6-PL4+TZ))
     +(Vl5*PipValue*(PL6-PL5+TZ));
     Loss6=MathAbs(Loss6);
     Vl6=NormalizeDouble(Loss6/TZ/PipValue,decimalPlace);
     
        }
   if(CONTOR==2)
     {
      Loss6=2*InpLots*PipValue*(PL6-PL0+TZ+step2)
     +(Vl1*PipValue*(PL6-PL1+TZ))
     +(Vl2*PipValue*(PL6-PL2+TZ))
     +(Vl3*PipValue*(PL6-PL3+TZ))
     +(Vl4*PipValue*(PL6-PL4+TZ))
     +(Vl5*PipValue*(PL6-PL5+TZ));
     Loss6=MathAbs(Loss6);
     Vl6=NormalizeDouble(Loss6/TZ/PipValue,decimalPlace);
     }
     if(CONTOR==3)
         {
            Loss6=3*InpLots*PipValue*(PL6-PL0+TZ+step3)
      +(Vl1*PipValue*(PL6-PL1+TZ))
     +(Vl2*PipValue*(PL6-PL2+TZ))
     +(Vl3*PipValue*(PL6-PL3+TZ))
     +(Vl4*PipValue*(PL6-PL4+TZ))
     +(Vl5*PipValue*(PL6-PL5+TZ));
     Loss6=MathAbs(Loss6);
     Vl6=NormalizeDouble(Loss6/TZ/PipValue,decimalPlace);
         }
         Print("PipValue:",PipValue," Loss6:",Loss6," Vl6:",Vl6);
}
void Calculate_V7()
{
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
   {
     Loss7=InpLots*PipValue*(PL7-PL0+TZ)
     +(Vl1*PipValue*(PL7-PL1+TZ))
     +(Vl2*PipValue*(PL7-PL2+TZ))
     +(Vl3*PipValue*(PL7-PL3+TZ))
     +(Vl4*PipValue*(PL7-PL4+TZ))
     +(Vl5*PipValue*(PL7-PL5+TZ))
     +(Vl6*PipValue*(PL7-PL6+TZ));
     Loss7=MathAbs(Loss7);
     Vl7=NormalizeDouble(Loss7/TZ/PipValue,decimalPlace);
     
        }
   if(CONTOR==2)
     {
      Loss7=2*InpLots*PipValue*(PL7-PL0+TZ+step2)
     +(Vl1*PipValue*(PL7-PL1+TZ))
     +(Vl2*PipValue*(PL7-PL2+TZ))
     +(Vl3*PipValue*(PL7-PL3+TZ))
     +(Vl4*PipValue*(PL7-PL4+TZ))
     +(Vl5*PipValue*(PL7-PL5+TZ))
     +(Vl6*PipValue*(PL7-PL6+TZ));
     Loss7=MathAbs(Loss7);
     Vl7=NormalizeDouble(Loss7/TZ/PipValue,decimalPlace);
     }
     if(CONTOR==3)
         {
            Loss7=3*InpLots*PipValue*(PL7-PL0+TZ+step3)
     +(Vl1*PipValue*(PL7-PL1+TZ))
     +(Vl2*PipValue*(PL7-PL2+TZ))
     +(Vl3*PipValue*(PL7-PL3+TZ))
     +(Vl4*PipValue*(PL7-PL4+TZ))
     +(Vl5*PipValue*(PL7-PL5+TZ))
     +(Vl6*PipValue*(PL7-PL6+TZ));
     Loss7=MathAbs(Loss7);
     Vl7=NormalizeDouble(Loss7/TZ/PipValue,decimalPlace);
         }
         Print("PipValue:",PipValue," Loss7:",Loss7," Vl7:",Vl7);
}

void Calculate_V8()
{
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
   {
     Loss8=InpLots*PipValue*(PL8-PL0+TZ)
     +(Vl1*PipValue*(PL8-PL1+TZ))
     +(Vl2*PipValue*(PL8-PL2+TZ))
     +(Vl3*PipValue*(PL8-PL3+TZ))
     +(Vl4*PipValue*(PL8-PL4+TZ))
     +(Vl5*PipValue*(PL8-PL5+TZ))
     +(Vl6*PipValue*(PL8-PL6+TZ))
     +(Vl7*PipValue*(PL8-PL7+TZ));
     Loss8=MathAbs(Loss8);
     Vl8=NormalizeDouble(Loss8/TZ/PipValue,decimalPlace);
     
        }
   if(CONTOR==2)
     {
      Loss8=2*InpLots*PipValue*(PL8-PL0+TZ+step2)
     +(Vl1*PipValue*(PL8-PL1+TZ))
     +(Vl2*PipValue*(PL8-PL2+TZ))
     +(Vl3*PipValue*(PL8-PL3+TZ))
     +(Vl4*PipValue*(PL8-PL4+TZ))
     +(Vl5*PipValue*(PL8-PL5+TZ))
     +(Vl6*PipValue*(PL8-PL6+TZ))
     +(Vl7*PipValue*(PL8-PL7+TZ));
     Loss8=MathAbs(Loss8);
     Vl8=NormalizeDouble(Loss8/TZ/PipValue,decimalPlace);
     }
     if(CONTOR==3)
         {
            Loss8=3*InpLots*PipValue*(PL8-PL0+TZ+step3)
     +(Vl1*PipValue*(PL8-PL1+TZ))
     +(Vl2*PipValue*(PL8-PL2+TZ))
     +(Vl3*PipValue*(PL8-PL3+TZ))
     +(Vl4*PipValue*(PL8-PL4+TZ))
     +(Vl5*PipValue*(PL8-PL5+TZ))
     +(Vl6*PipValue*(PL8-PL6+TZ))
     +(Vl7*PipValue*(PL8-PL7+TZ));
     Loss8=MathAbs(Loss8);
     Vl8=NormalizeDouble(Loss8/TZ/PipValue,decimalPlace);
         }
         Print("PipValue:",PipValue," Loss8:",Loss8," Vl8:",Vl8);
}

void Calculate_V9()
{
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
   {
     Loss9=InpLots*PipValue*(PL9-PL0+TZ)
     +(Vl1*PipValue*(PL9-PL1+TZ))
     +(Vl2*PipValue*(PL9-PL2+TZ))
     +(Vl3*PipValue*(PL9-PL3+TZ))
     +(Vl4*PipValue*(PL9-PL4+TZ))
     +(Vl5*PipValue*(PL9-PL5+TZ))
     +(Vl6*PipValue*(PL9-PL6+TZ))
     +(Vl7*PipValue*(PL9-PL7+TZ))
     +(Vl8*PipValue*(PL9-PL8+TZ));
     Loss9=MathAbs(Loss9);
     Vl9=NormalizeDouble(Loss9/TZ/PipValue,decimalPlace);
     
        }
   if(CONTOR==2)
     {
      Loss9=2*InpLots*PipValue*(PL9-PL0+TZ+step2)
     +(Vl1*PipValue*(PL9-PL1+TZ))
     +(Vl2*PipValue*(PL9-PL2+TZ))
     +(Vl3*PipValue*(PL9-PL3+TZ))
     +(Vl4*PipValue*(PL9-PL4+TZ))
     +(Vl5*PipValue*(PL9-PL5+TZ))
     +(Vl6*PipValue*(PL9-PL6+TZ))
     +(Vl7*PipValue*(PL9-PL7+TZ))
     +(Vl8*PipValue*(PL9-PL8+TZ));
     Loss9=MathAbs(Loss9);
     Vl9=NormalizeDouble(Loss9/TZ/PipValue,decimalPlace);
     }
     if(CONTOR==3)
         {
            Loss9=3*InpLots*PipValue*(PL9-PL0+TZ+step3)
     +(Vl1*PipValue*(PL9-PL1+TZ))
     +(Vl2*PipValue*(PL9-PL2+TZ))
     +(Vl3*PipValue*(PL9-PL3+TZ))
     +(Vl4*PipValue*(PL9-PL4+TZ))
     +(Vl5*PipValue*(PL9-PL5+TZ))
     +(Vl6*PipValue*(PL9-PL6+TZ))
     +(Vl7*PipValue*(PL9-PL7+TZ))
     +(Vl8*PipValue*(PL9-PL8+TZ));
     Loss9=MathAbs(Loss9);
     Vl9=NormalizeDouble(Loss9/TZ/PipValue,decimalPlace);
         }
         Print("PipValue:",PipValue," Loss9:",Loss9," Vl9:",Vl9);
}

void Calculate_V10()
{
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
   {
     Loss10=InpLots*PipValue*(PL10-PL0+TZ)
     +(Vl1*PipValue*(PL10-PL1+TZ))
     +(Vl2*PipValue*(PL10-PL2+TZ))
     +(Vl3*PipValue*(PL10-PL3+TZ))
     +(Vl4*PipValue*(PL10-PL4+TZ))
     +(Vl5*PipValue*(PL10-PL5+TZ))
     +(Vl6*PipValue*(PL10-PL6+TZ))
     +(Vl7*PipValue*(PL10-PL7+TZ))
     +(Vl8*PipValue*(PL10-PL8+TZ))
     +(Vl8*PipValue*(PL10-PL8+TZ))
     +(Vl9*PipValue*(PL10-PL9+TZ));
     Vl10=NormalizeDouble(MathAbs(Loss10)/TZ/PipValue,decimalPlace);
     
        }
   if(CONTOR==2)
     {
      Loss10=2*InpLots*PipValue*(PL10-PL0+TZ+step2)
     +(Vl1*PipValue*(PL10-PL1+TZ))
     +(Vl2*PipValue*(PL10-PL2+TZ))
     +(Vl3*PipValue*(PL10-PL3+TZ))
     +(Vl4*PipValue*(PL10-PL4+TZ))
     +(Vl5*PipValue*(PL10-PL5+TZ))
     +(Vl6*PipValue*(PL10-PL6+TZ))
     +(Vl7*PipValue*(PL10-PL7+TZ))
     +(Vl8*PipValue*(PL10-PL8+TZ))
     +(Vl8*PipValue*(PL10-PL8+TZ))
     +(Vl9*PipValue*(PL10-PL9+TZ));
     Vl10=NormalizeDouble(MathAbs(Loss10)/TZ/PipValue,decimalPlace);
     }
     if(CONTOR==3)
         {
            Loss10=3*InpLots*PipValue*(PL10-PL0+TZ+step3)
     +(Vl1*PipValue*(PL10-PL1+TZ))
     +(Vl2*PipValue*(PL10-PL2+TZ))
     +(Vl3*PipValue*(PL10-PL3+TZ))
     +(Vl4*PipValue*(PL10-PL4+TZ))
     +(Vl5*PipValue*(PL10-PL5+TZ))
     +(Vl6*PipValue*(PL10-PL6+TZ))
     +(Vl7*PipValue*(PL10-PL7+TZ))
     +(Vl8*PipValue*(PL10-PL8+TZ))
     +(Vl8*PipValue*(PL10-PL8+TZ))
     +(Vl9*PipValue*(PL10-PL9+TZ));
     Vl10=NormalizeDouble(MathAbs(Loss10)/TZ/PipValue,decimalPlace);
         }
         Print("PipValue:",PipValue," Loss10:",Loss10," Vl10:",Vl10);
}

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
            Loss11=3*InpLots*PipValue*(PL11-PL0+TZ+step3)
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
         Print("PipValue:",PipValue," Loss11:",Loss11," Vl11:",Vl11);
}

void Calculate_V12()
{
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
   {
     Loss12=InpLots*PipValue*(PL12-PL0+TZ)
     +(Vl1*PipValue*(PL12-PL1+TZ))
     +(Vl2*PipValue*(PL12-PL2+TZ))
     +(Vl3*PipValue*(PL12-PL3+TZ))
     +(Vl4*PipValue*(PL12-PL4+TZ))
     +(Vl5*PipValue*(PL12-PL5+TZ))
     +(Vl6*PipValue*(PL12-PL6+TZ))
     +(Vl7*PipValue*(PL12-PL7+TZ))
     +(Vl8*PipValue*(PL12-PL8+TZ))
     +(Vl8*PipValue*(PL12-PL9+TZ))
     +(Vl9*PipValue*(PL12-PL9+TZ))
     +(Vl10*PipValue*(PL12-PL10+TZ))
     +(Vl11*PipValue*(PL12-PL11+TZ));
     Vl12=NormalizeDouble(MathAbs(Loss12)/TZ/PipValue,decimalPlace);
     
        }
   if(CONTOR==2)
     {
      Loss12=2*InpLots*PipValue*(PL12-PL0+TZ+step2)
     +(Vl1*PipValue*(PL12-PL1+TZ))
     +(Vl2*PipValue*(PL12-PL2+TZ))
     +(Vl3*PipValue*(PL12-PL3+TZ))
     +(Vl4*PipValue*(PL12-PL4+TZ))
     +(Vl5*PipValue*(PL12-PL5+TZ))
     +(Vl6*PipValue*(PL12-PL6+TZ))
     +(Vl7*PipValue*(PL12-PL7+TZ))
     +(Vl8*PipValue*(PL12-PL8+TZ))
     +(Vl8*PipValue*(PL12-PL9+TZ))
     +(Vl9*PipValue*(PL12-PL9+TZ))
     +(Vl10*PipValue*(PL12-PL10+TZ))
     +(Vl11*PipValue*(PL12-PL11+TZ));
     Vl12=NormalizeDouble(MathAbs(Loss12)/TZ/PipValue,decimalPlace);
     }
     if(CONTOR==3)
         {
            Loss12=3*InpLots*PipValue*(PL12-PL0+TZ+step3)
    +(Vl1*PipValue*(PL12-PL1+TZ))
     +(Vl2*PipValue*(PL12-PL2+TZ))
     +(Vl3*PipValue*(PL12-PL3+TZ))
     +(Vl4*PipValue*(PL12-PL4+TZ))
     +(Vl5*PipValue*(PL12-PL5+TZ))
     +(Vl6*PipValue*(PL12-PL6+TZ))
     +(Vl7*PipValue*(PL12-PL7+TZ))
     +(Vl8*PipValue*(PL12-PL8+TZ))
     +(Vl8*PipValue*(PL12-PL9+TZ))
     +(Vl9*PipValue*(PL12-PL9+TZ))
     +(Vl10*PipValue*(PL12-PL10+TZ))
     +(Vl11*PipValue*(PL12-PL11+TZ));
     Vl12=NormalizeDouble(MathAbs(Loss12)/TZ/PipValue,decimalPlace);
         }
         Print("PipValue:",PipValue," Loss12:",Loss12," Vl12:",Vl12);
}

void Calculate_V13()
{
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
   {
     Loss13=InpLots*PipValue*(PL13-PL0+TZ)
     +(Vl1*PipValue*(PL13-PL1+TZ))
     +(Vl2*PipValue*(PL13-PL2+TZ))
     +(Vl3*PipValue*(PL13-PL3+TZ))
     +(Vl4*PipValue*(PL13-PL4+TZ))
     +(Vl5*PipValue*(PL13-PL5+TZ))
     +(Vl6*PipValue*(PL13-PL6+TZ))
     +(Vl7*PipValue*(PL13-PL7+TZ))
     +(Vl8*PipValue*(PL13-PL8+TZ))
     +(Vl8*PipValue*(PL13-PL9+TZ))
     +(Vl9*PipValue*(PL13-PL9+TZ))
     +(Vl10*PipValue*(PL13-PL10+TZ))
     +(Vl11*PipValue*(PL13-PL11+TZ))
     +(Vl12*PipValue*(PL13-PL12+TZ));
     Vl13=NormalizeDouble(MathAbs(Loss13)/TZ/PipValue,decimalPlace);
     
        }
   if(CONTOR==2)
     {
      Loss13=2*InpLots*PipValue*(PL13-PL0+TZ+step2)
     +(Vl1*PipValue*(PL13-PL1+TZ))
     +(Vl2*PipValue*(PL13-PL2+TZ))
     +(Vl3*PipValue*(PL13-PL3+TZ))
     +(Vl4*PipValue*(PL13-PL4+TZ))
     +(Vl5*PipValue*(PL13-PL5+TZ))
     +(Vl6*PipValue*(PL13-PL6+TZ))
     +(Vl7*PipValue*(PL13-PL7+TZ))
     +(Vl8*PipValue*(PL13-PL8+TZ))
     +(Vl8*PipValue*(PL13-PL9+TZ))
     +(Vl9*PipValue*(PL13-PL9+TZ))
     +(Vl10*PipValue*(PL13-PL10+TZ))
     +(Vl11*PipValue*(PL13-PL11+TZ))
     +(Vl12*PipValue*(PL13-PL12+TZ));
     Vl13=NormalizeDouble(MathAbs(Loss13)/TZ/PipValue,decimalPlace);
     }
     if(CONTOR==3)
         {
            Loss13=3*InpLots*PipValue*(PL13-PL0+TZ+step3)
    +(Vl1*PipValue*(PL13-PL1+TZ))
     +(Vl2*PipValue*(PL13-PL2+TZ))
     +(Vl3*PipValue*(PL13-PL3+TZ))
     +(Vl4*PipValue*(PL13-PL4+TZ))
     +(Vl5*PipValue*(PL13-PL5+TZ))
     +(Vl6*PipValue*(PL13-PL6+TZ))
     +(Vl7*PipValue*(PL13-PL7+TZ))
     +(Vl8*PipValue*(PL13-PL8+TZ))
     +(Vl8*PipValue*(PL13-PL9+TZ))
     +(Vl9*PipValue*(PL13-PL9+TZ))
     +(Vl10*PipValue*(PL13-PL10+TZ))
     +(Vl11*PipValue*(PL13-PL11+TZ))
     +(Vl12*PipValue*(PL13-PL12+TZ));
     Vl13=NormalizeDouble(MathAbs(Loss13)/TZ/PipValue,decimalPlace);
         }
         Print("PipValue:",PipValue," Loss13:",Loss13," Vl13:",Vl13);
}
void Calculate_V14()
{
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
   {
     Loss14=InpLots*PipValue*(PL14-PL0+TZ)
     +(Vl1*PipValue*(PL14-PL1+TZ))
     +(Vl2*PipValue*(PL14-PL2+TZ))
     +(Vl3*PipValue*(PL14-PL3+TZ))
     +(Vl4*PipValue*(PL14-PL4+TZ))
     +(Vl5*PipValue*(PL14-PL5+TZ))
     +(Vl6*PipValue*(PL14-PL6+TZ))
     +(Vl7*PipValue*(PL14-PL7+TZ))
     +(Vl8*PipValue*(PL14-PL8+TZ))
     +(Vl8*PipValue*(PL14-PL9+TZ))
     +(Vl9*PipValue*(PL14-PL9+TZ))
     +(Vl10*PipValue*(PL14-PL10+TZ))
     +(Vl11*PipValue*(PL14-PL11+TZ))
     +(Vl12*PipValue*(PL14-PL12+TZ))
     +(Vl13*PipValue*(PL14-PL13+TZ));
     Vl14=NormalizeDouble(MathAbs(Loss14)/TZ/PipValue,decimalPlace);
     
        }
   if(CONTOR==2)
     {
      Loss14=2*InpLots*PipValue*(PL14-PL0+TZ+step2)
     +(Vl1*PipValue*(PL14-PL1+TZ))
     +(Vl2*PipValue*(PL14-PL2+TZ))
     +(Vl3*PipValue*(PL14-PL3+TZ))
     +(Vl4*PipValue*(PL14-PL4+TZ))
     +(Vl5*PipValue*(PL14-PL5+TZ))
     +(Vl6*PipValue*(PL14-PL6+TZ))
     +(Vl7*PipValue*(PL14-PL7+TZ))
     +(Vl8*PipValue*(PL14-PL8+TZ))
     +(Vl8*PipValue*(PL14-PL9+TZ))
     +(Vl9*PipValue*(PL14-PL9+TZ))
     +(Vl10*PipValue*(PL14-PL10+TZ))
     +(Vl11*PipValue*(PL14-PL11+TZ))
     +(Vl12*PipValue*(PL14-PL12+TZ))
     +(Vl13*PipValue*(PL14-PL13+TZ));
     Vl14=NormalizeDouble(MathAbs(Loss14)/TZ/PipValue,decimalPlace);
     }
     if(CONTOR==3)
         {
            Loss14=3*InpLots*PipValue*(PL14-PL0+TZ+step3)
    +(Vl1*PipValue*(PL14-PL1+TZ))
     +(Vl2*PipValue*(PL14-PL2+TZ))
     +(Vl3*PipValue*(PL14-PL3+TZ))
     +(Vl4*PipValue*(PL14-PL4+TZ))
     +(Vl5*PipValue*(PL14-PL5+TZ))
     +(Vl6*PipValue*(PL14-PL6+TZ))
     +(Vl7*PipValue*(PL14-PL7+TZ))
     +(Vl8*PipValue*(PL14-PL8+TZ))
     +(Vl8*PipValue*(PL14-PL9+TZ))
     +(Vl9*PipValue*(PL14-PL9+TZ))
     +(Vl10*PipValue*(PL14-PL10+TZ))
     +(Vl11*PipValue*(PL14-PL11+TZ))
     +(Vl12*PipValue*(PL14-PL12+TZ))
     +(Vl13*PipValue*(PL14-PL13+TZ));
     Vl14=NormalizeDouble(MathAbs(Loss14)/TZ/PipValue,decimalPlace);
}
Print("PipValue:",PipValue," Loss14:",Loss14," Vl14:",Vl14);
}

void Calculate_V15()
{
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
   {
     Loss15=InpLots*PipValue*(PL15-PL0+TZ)
     +(Vl1*PipValue*(PL15-PL1+TZ))
     +(Vl2*PipValue*(PL15-PL2+TZ))
     +(Vl3*PipValue*(PL15-PL3+TZ))
     +(Vl4*PipValue*(PL15-PL4+TZ))
     +(Vl5*PipValue*(PL15-PL5+TZ))
     +(Vl6*PipValue*(PL15-PL6+TZ))
     +(Vl7*PipValue*(PL15-PL7+TZ))
     +(Vl8*PipValue*(PL15-PL8+TZ))
     +(Vl8*PipValue*(PL15-PL9+TZ))
     +(Vl9*PipValue*(PL15-PL9+TZ))
     +(Vl10*PipValue*(PL15-PL10+TZ))
     +(Vl11*PipValue*(PL15-PL11+TZ))
     +(Vl12*PipValue*(PL15-PL12+TZ))
     +(Vl13*PipValue*(PL15-PL13+TZ))
     +(Vl14*PipValue*(PL15-PL14+TZ));
     Vl15=NormalizeDouble(MathAbs(Loss15)/TZ/PipValue,decimalPlace);
     
        }
   if(CONTOR==2)
     {
      Loss15=2*InpLots*PipValue*(PL15-PL0+TZ+step2)
      +(Vl1*PipValue*(PL15-PL1+TZ))
     +(Vl2*PipValue*(PL15-PL2+TZ))
     +(Vl3*PipValue*(PL15-PL3+TZ))
     +(Vl4*PipValue*(PL15-PL4+TZ))
     +(Vl5*PipValue*(PL15-PL5+TZ))
     +(Vl6*PipValue*(PL15-PL6+TZ))
     +(Vl7*PipValue*(PL15-PL7+TZ))
     +(Vl8*PipValue*(PL15-PL8+TZ))
     +(Vl8*PipValue*(PL15-PL9+TZ))
     +(Vl9*PipValue*(PL15-PL9+TZ))
     +(Vl10*PipValue*(PL15-PL10+TZ))
     +(Vl11*PipValue*(PL15-PL11+TZ))
     +(Vl12*PipValue*(PL15-PL12+TZ))
     +(Vl13*PipValue*(PL15-PL13+TZ))
     +(Vl14*PipValue*(PL15-PL14+TZ));
     Vl15=NormalizeDouble(MathAbs(Loss15)/TZ/PipValue,decimalPlace);
     }
     if(CONTOR==3)
         {
            Loss15=3*InpLots*PipValue*(PL15-PL0+TZ+step3)
     +(Vl1*PipValue*(PL15-PL1+TZ))
     +(Vl2*PipValue*(PL15-PL2+TZ))
     +(Vl3*PipValue*(PL15-PL3+TZ))
     +(Vl4*PipValue*(PL15-PL4+TZ))
     +(Vl5*PipValue*(PL15-PL5+TZ))
     +(Vl6*PipValue*(PL15-PL6+TZ))
     +(Vl7*PipValue*(PL15-PL7+TZ))
     +(Vl8*PipValue*(PL15-PL8+TZ))
     +(Vl8*PipValue*(PL15-PL9+TZ))
     +(Vl9*PipValue*(PL15-PL9+TZ))
     +(Vl10*PipValue*(PL15-PL10+TZ))
     +(Vl11*PipValue*(PL15-PL11+TZ))
     +(Vl12*PipValue*(PL15-PL12+TZ))
     +(Vl13*PipValue*(PL15-PL13+TZ))
     +(Vl14*PipValue*(PL15-PL14+TZ));
     Vl15=NormalizeDouble(MathAbs(Loss15)/TZ/PipValue,decimalPlace);
         }
         Print("PipValue:",PipValue," Loss15:",Loss15," Vl15:",Vl15);
}

void Calculate_V16()
{
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
   {
     Loss16=InpLots*PipValue*(PL16-PL0+TZ)
     +(Vl1*PipValue*(PL16-PL1+TZ))
     +(Vl2*PipValue*(PL16-PL2+TZ))
     +(Vl3*PipValue*(PL16-PL3+TZ))
     +(Vl4*PipValue*(PL16-PL4+TZ))
     +(Vl5*PipValue*(PL16-PL5+TZ))
     +(Vl6*PipValue*(PL16-PL6+TZ))
     +(Vl7*PipValue*(PL16-PL7+TZ))
     +(Vl8*PipValue*(PL16-PL8+TZ))
     +(Vl8*PipValue*(PL16-PL9+TZ))
     +(Vl9*PipValue*(PL16-PL9+TZ))
     +(Vl10*PipValue*(PL16-PL10+TZ))
     +(Vl11*PipValue*(PL16-PL11+TZ))
     +(Vl12*PipValue*(PL16-PL12+TZ))
     +(Vl13*PipValue*(PL16-PL13+TZ))
     +(Vl14*PipValue*(PL16-PL14+TZ))
     +(Vl15*PipValue*(PL16-PL15+TZ));
     Vl16=NormalizeDouble(MathAbs(Loss16)/TZ/PipValue,decimalPlace);
     
        }
   if(CONTOR==2)
     {
      Loss16=2*InpLots*PipValue*(PL16-PL0+TZ+step2)
      +(Vl1*PipValue*(PL16-PL1+TZ))
     +(Vl2*PipValue*(PL16-PL2+TZ))
     +(Vl3*PipValue*(PL16-PL3+TZ))
     +(Vl4*PipValue*(PL16-PL4+TZ))
     +(Vl5*PipValue*(PL16-PL5+TZ))
     +(Vl6*PipValue*(PL16-PL6+TZ))
     +(Vl7*PipValue*(PL16-PL7+TZ))
     +(Vl8*PipValue*(PL16-PL8+TZ))
     +(Vl8*PipValue*(PL16-PL9+TZ))
     +(Vl9*PipValue*(PL16-PL9+TZ))
     +(Vl10*PipValue*(PL16-PL10+TZ))
     +(Vl11*PipValue*(PL16-PL11+TZ))
     +(Vl12*PipValue*(PL16-PL12+TZ))
     +(Vl13*PipValue*(PL16-PL13+TZ))
     +(Vl14*PipValue*(PL16-PL14+TZ))
     +(Vl15*PipValue*(PL16-PL15+TZ));
     Vl16=NormalizeDouble(MathAbs(Loss16)/TZ/PipValue,decimalPlace);
     }
     if(CONTOR==3)
         {
            Loss16=3*InpLots*PipValue*(PL16-PL0+TZ+step3)
     +(Vl1*PipValue*(PL16-PL1+TZ))
     +(Vl2*PipValue*(PL16-PL2+TZ))
     +(Vl3*PipValue*(PL16-PL3+TZ))
     +(Vl4*PipValue*(PL16-PL4+TZ))
     +(Vl5*PipValue*(PL16-PL5+TZ))
     +(Vl6*PipValue*(PL16-PL6+TZ))
     +(Vl7*PipValue*(PL16-PL7+TZ))
     +(Vl8*PipValue*(PL16-PL8+TZ))
     +(Vl8*PipValue*(PL16-PL9+TZ))
     +(Vl9*PipValue*(PL16-PL9+TZ))
     +(Vl10*PipValue*(PL16-PL10+TZ))
     +(Vl11*PipValue*(PL16-PL11+TZ))
     +(Vl12*PipValue*(PL16-PL12+TZ))
     +(Vl13*PipValue*(PL16-PL13+TZ))
     +(Vl14*PipValue*(PL16-PL14+TZ))
     +(Vl15*PipValue*(PL16-PL15+TZ));
     Vl16=NormalizeDouble(MathAbs(Loss16)/TZ/PipValue,decimalPlace);
         }
         Print("PipValue:",PipValue," Loss16:",Loss16," Vl16:",Vl16);
}

void Calculate_V17()
{
   double PipValue=CalculatePipValue()*InpLots;
   if(CONTOR==1)
   {
     Loss17=InpLots*PipValue*(PL17-PL0+TZ)
     +(Vl1*PipValue*(PL17-PL1+TZ))
     +(Vl2*PipValue*(PL17-PL2+TZ))
     +(Vl3*PipValue*(PL17-PL3+TZ))
     +(Vl4*PipValue*(PL17-PL4+TZ))
     +(Vl5*PipValue*(PL17-PL5+TZ))
     +(Vl6*PipValue*(PL17-PL6+TZ))
     +(Vl7*PipValue*(PL17-PL7+TZ))
     +(Vl8*PipValue*(PL17-PL8+TZ))
     +(Vl8*PipValue*(PL17-PL9+TZ))
     +(Vl9*PipValue*(PL17-PL9+TZ))
     +(Vl10*PipValue*(PL17-PL10+TZ))
     +(Vl11*PipValue*(PL17-PL11+TZ))
     +(Vl12*PipValue*(PL17-PL12+TZ))
     +(Vl13*PipValue*(PL17-PL13+TZ))
     +(Vl14*PipValue*(PL17-PL14+TZ))
     +(Vl15*PipValue*(PL17-PL15+TZ))
     +(Vl16*PipValue*(PL17-PL16+TZ));
     Vl17=NormalizeDouble(MathAbs(Loss17)/TZ/PipValue,decimalPlace);
     
        }
   if(CONTOR==2)
     {
      Loss17=2*InpLots*PipValue*(PL17-PL0+TZ+step2)
      +(Vl1*PipValue*(PL17-PL1+TZ))
     +(Vl2*PipValue*(PL17-PL2+TZ))
     +(Vl3*PipValue*(PL17-PL3+TZ))
     +(Vl4*PipValue*(PL17-PL4+TZ))
     +(Vl5*PipValue*(PL17-PL5+TZ))
     +(Vl6*PipValue*(PL17-PL6+TZ))
     +(Vl7*PipValue*(PL17-PL7+TZ))
     +(Vl8*PipValue*(PL17-PL8+TZ))
     +(Vl8*PipValue*(PL17-PL9+TZ))
     +(Vl9*PipValue*(PL17-PL9+TZ))
     +(Vl10*PipValue*(PL17-PL10+TZ))
     +(Vl11*PipValue*(PL17-PL11+TZ))
     +(Vl12*PipValue*(PL17-PL12+TZ))
     +(Vl13*PipValue*(PL17-PL13+TZ))
     +(Vl14*PipValue*(PL17-PL14+TZ))
     +(Vl15*PipValue*(PL17-PL15+TZ))
     +(Vl16*PipValue*(PL17-PL16+TZ));
     Vl17=NormalizeDouble(MathAbs(Loss17)/TZ/PipValue,decimalPlace);
     }
     if(CONTOR==3)
         {
      
            Loss16=3*InpLots*PipValue*(PL16-PL0+TZ+step3)
     +(Vl1*PipValue*(PL17-PL1+TZ))
     +(Vl2*PipValue*(PL17-PL2+TZ))
     +(Vl3*PipValue*(PL17-PL3+TZ))
     +(Vl4*PipValue*(PL17-PL4+TZ))
     +(Vl5*PipValue*(PL17-PL5+TZ))
     +(Vl6*PipValue*(PL17-PL6+TZ))
     +(Vl7*PipValue*(PL17-PL7+TZ))
     +(Vl8*PipValue*(PL17-PL8+TZ))
     +(Vl8*PipValue*(PL17-PL9+TZ))
     +(Vl9*PipValue*(PL17-PL9+TZ))
     +(Vl10*PipValue*(PL17-PL10+TZ))
     +(Vl11*PipValue*(PL17-PL11+TZ))
     +(Vl12*PipValue*(PL17-PL12+TZ))
     +(Vl13*PipValue*(PL17-PL13+TZ))
     +(Vl14*PipValue*(PL17-PL14+TZ))
     +(Vl15*PipValue*(PL17-PL15+TZ))
     +(Vl16*PipValue*(PL17-PL16+TZ));
     Vl17=NormalizeDouble(MathAbs(Loss17)/TZ/PipValue,decimalPlace);
         }
         Print("PipValue:",PipValue," Loss17:",Loss17," Vl17:",Vl17);
}

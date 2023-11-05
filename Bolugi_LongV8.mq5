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
ulong    TicketNumber1=-1;
double   PriceStartMB=0.0;
double   PriceZ=0.0;
double RangeMB0=0.0;
int CONTOR=0;

//+------------------------------------------------------------------+
//| LEVELE FIBONACCI                                             |
//+------------------------------------------------------------------+
double PriceLevel1=NormalizeDouble(InpDistTakeProfit*_Point+(23.60*InpRangeM)/100*_Point,_Digits);//PL1
double PriceLevel2=NormalizeDouble(InpDistTakeProfit*_Point+(38.20*InpRangeM)/100*_Point,_Digits);//PL2
double PriceLevel3=NormalizeDouble(InpDistTakeProfit*_Point+(50.00*InpRangeM)/100*_Point,_Digits);//PL3
double PriceLevel4=NormalizeDouble(InpDistTakeProfit*_Point+(61.80*InpRangeM)/100*_Point,_Digits);//PL4
double PriceLevel5=NormalizeDouble(InpDistTakeProfit*_Point+(76.45*InpRangeM)/100*_Point,_Digits);//PL5
double PriceLevel6=NormalizeDouble(InpDistTakeProfit*_Point+(88.20*InpRangeM)/100*_Point,_Digits);//PL6
double PriceLevel7=NormalizeDouble(InpDistTakeProfit*_Point+(100.00*InpRangeM)/100*_Point,_Digits);//PL7
//+------------------------------------------------------------------+
//+VOLUME                                           |
//+------------------------------------------------------------------+
double  Loss1=0.0,
        Loss2=0.0,
        Loss3=0.0,
        Loss4=0.0,
        Loss5=0.0,
        Loss6=0.0,
        Loss7=0.0;
        
double   Vl1=0.0,
         Vl2=0.0,
         Vl3=0.0,
         Vl4=0.0,
         Vl5=0.0,
         Vl6=0.0,
         Vl7=0.0;
double 
       PL1,
       PL2,
       PL3,
       PL4,
       PL5,
       PL6,
       PL7;
double TZ=InpDistTakeProfit/InpZTP*_Point;
int decimalPlace=2;
double step2=(InpStepC/2)*_Point;
double step3=InpStepC*_Point;
static double PL0;
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
   TicketNumber1=trade.ResultDeal();
   RangeMB0=lastTick.ask;
      if(PositionSelectByTicket(TicketNumber1))
         {
            PL0=PositionGetDouble(POSITION_PRICE_OPEN);
         }
  CONTOR=1;
  NextBuyPrice=RangeMB0+InpStepC*_Point;
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
   PL1=PL0-((23.60*InpRangeM)/100*_Point+InpDistTakeProfit*_Point);
   PL2=PL0-((38.20*InpRangeM)/100*_Point+InpDistTakeProfit*_Point);
   PL3=PL0-((50.0*InpRangeM)/100*_Point+InpDistTakeProfit*_Point);
   PL4=PL0-((61.80*InpRangeM)/100*_Point+InpDistTakeProfit*_Point);
   PL5=PL0-((76.45*InpRangeM)/100*_Point+InpDistTakeProfit*_Point);
   PL6=PL0-((88.20*InpRangeM)/100*_Point+InpDistTakeProfit*_Point);
   PL7=PL0-((100.00*InpRangeM)/100*_Point+InpDistTakeProfit*_Point);    
   Calculate_V1();
   Calculate_V2(); 
   Calculate_V3(); 
   Calculate_V4(); 
   Calculate_V5(); 
   Calculate_V6(); 
   Calculate_V7();   
   Print("PL1  ",PL1);  
   Print("PL2  ",PL2);
   Print("PL3  ",PL3);
   Print("PL4  ",PL4);
   Print("PL5  ",PL5);
   Print("PL6  ",PL6);
  Print("PL7  ",PL7);  
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
  /* if(PositionSelectByTicket(TicketNumber))
   {
   trade.PositionModify(TicketNumber,(RangeMB0-(InpStopLoss*_Point)),0);
   }
   
   double SL=NormalizeDouble(RangeMB0-InpTrailStop*_Point,_Digits);
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
   int totalPositions = PositionsTotal();
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
               
               trade.Buy(Vl1,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order1 & TP1");
               Level1=true;
               medierebuy=true;
               complementarebuy=false;
               TicketNumber=trade.ResultDeal();
            }  
             
        }
         else if(Level1==true && Level2==false)///LEVEL 2 Fibonacci
         {
               if(lastTick.ask<=PL2) 
                  {
               
               trade.Buy(Vl2,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order2 & TP2");
               Level2=true;
             
               TicketNumber=trade.ResultDeal();
                  }   
         }
         
         else if(Level2==true && Level3==false)///LEVEL 3 Fibonacci
         {
               
               if(lastTick.ask<=PL3) 
                  {
             
               trade.Buy(Vl3,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order3 &Tp3");
               Level3=true;
               ContorM=3;
               TicketNumber=trade.ResultDeal();
                  }

         }
        else if(Level3==true && Level4==false)///LEVEL 4 Fibonacci
         {
         
           
               if(lastTick.ask<=PL4) 
                  {
                  
               trade.Buy(Vl4,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order4 &Tp4");
               Level4=true;
               ContorM=4;
               TicketNumber=trade.ResultDeal();
                  }

         }
         else if(Level4==true && Level5==false)///LEVEL 5 Fibonacci
         {
         
             
               if(lastTick.ask<=PL5) 
                  {
                  
               trade.Buy(Vl5,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order5 &Tp5");
               Level5=true;
               ContorM=5;
               TicketNumber=trade.ResultDeal();
                  }
             
            
         }
         else if(Level5==true && Level6==false)///LEVEL 6 Fibonacci
         {
               
               if(lastTick.ask<=PL6) 
                  {
                  
               trade.Buy(Vl6,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order6 &Tp6");
               Level6=true;
               ContorM=6;
               TicketNumber=trade.ResultDeal();
                   }
         
         }
         else if(Level6==true && Level7==false)///LEVEL 7 Fibonacci
         {
         
            
               if(lastTick.ask<=PL7) 
                  {
                 
               trade.Buy(Vl7,NULL,lastTick.ask,0,lastTick.ask+InpDistTakeProfit*_Point,"Order7 &Tp7");
               Level7=true;//ba e nevoie
               ContorM=7;
               TicketNumber=trade.ResultDeal();
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
double PipValue=CalculatePipValue()*0.01;
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
double PipValue=CalculatePipValue()*0.01;
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
double PipValue=CalculatePipValue()*0.01;
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
double PipValue=CalculatePipValue()*0.01;
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
double PipValue=CalculatePipValue()*0.01;
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
double PipValue=CalculatePipValue()*0.01;
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
   double PipValue=CalculatePipValue()*0.01;
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

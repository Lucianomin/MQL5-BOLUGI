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
         MEDIERE_SELL
        };
        
input MEDIERE_MODE InpMediereMode= MEDIERE_BUY; //Mediere Mode
input int InpRangeM=1000;//(pips)
input int InpDistZ=300;//(pips)
input int InpDistTakeProfit=150;//(pips)


//+------------------------------------------------------------------+
//| Global D                                                        |
//+------------------------------------------------------------------+
MqlRates PriceInfo[];
MqlTick currTick;
CTrade trade;
string signal="";
int PositionNumber=0;
int PositionBuyNumber=0;
int PositionSellNumber=0;
int TotalBuyPositions=0;
int TotalSellPositions=0;
double MaxClose=0;
double MaxSellClose=9999;
int ContorM=0;
bool mediere=false;
bool Level1=false,
     Level2=false,
     Level3=false,
     Level4=false,
     Level5=false,
     Level6=false,
     Level7=false;
int  PositionMediereNumber=0;
int  ContorMC=0;
int  MediereNumber=0;
//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+

int OnInit()
  {

   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {

   
  }

void OnTick()
  {
   if(InpComplementareMode==COMPLEMENTARE_BUY && mediere==false)
     {
      Complementare_Buy();
     }
     double ask =NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
     if(PositionsTotal()<=3+ContorM)//ContorM setam pe 0 el se modifica la fiecare deschidere de mediere maxim 7
     {
      int totalPositions = PositionsTotal();
      double RangeM0 = 0.0; // Initialize with a default value
      //double LastBuyTP = 0.0;
       Print("---->",PositionNumber);
   
      int OpenBuySellTrades=PositionNumber+PositionMediereNumber;

      for (int i = OpenBuySellTrades+MediereNumber*2; i<OpenBuySellTrades+totalPositions+(MediereNumber*12)+2; i++) //testat optim??? putem si mai departe aprox 180 de complementari
      { 
      //Alert("ticket",i);
         if (PositionSelectByTicket(i)) 
         {
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) 
               {
                  RangeM0 = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN),_Digits); //pozitia 0 a rangeluiu
                  //LastBuyTP=NormalizeDouble(PositionGetDouble(POSITION_TP),_Digits);
                  //Print("RangePrice                   ",RangePrice);
               }
         }
         
      }
      Print("RangeM0->",RangeM0);
      
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
     
        
         double VolumeZ=InpLots;
         
         
        ///LEVEL 1 Fibonacci
       if(Level1==false)
        {
        
        PriceStartM=RangeM0-PriceLevel1;
               if(ask<=PriceStartM && ContorM==0) 
            {
               trade.Buy(VolumeZ,NULL,ask,0,ask+(InpDistTakeProfit+InpDistZ)*_Point,"TP4");
               Level1=true;
               mediere=true;
                ContorM=1;
            }
           
        }

               
         
         
         else if(Level1==true && Level2==false)///LEVEL 2 Fibonacci
         {
         
               PriceStartM=RangeM0-(PriceLevel2-PriceLevel1);
               if(ask<=PriceStartM && ContorM==1) 
            {
               trade.Buy(VolumeZ,NULL,ask,0,ask+(InpDistTakeProfit+InpDistZ)*_Point,"TP5");
               Level2=true;
               ContorM=2;
            }
            
         }
         
         else if(Level2==true && Level3==false)///LEVEL 3 Fibonacci
         {
         
               PriceStartM=RangeM0-(PriceLevel3-PriceLevel2);
               if(ask<=PriceStartM && ContorM==2) 
            {
               trade.Buy(VolumeZ,NULL,ask,0,ask+(InpDistTakeProfit+InpDistZ)*_Point,"TP6");
               Level3=true;
               ContorM=3;
            }
            
         }
        else if(Level3==true && Level4==false)///LEVEL 4 Fibonacci
         {
         
               PriceStartM=RangeM0-(PriceLevel4-PriceLevel3);
               if(ask<=PriceStartM && ContorM==3) 
            {
               trade.Buy(VolumeZ,NULL,ask,0,ask+(InpDistTakeProfit+InpDistZ)*_Point,"TP7");
               Level4=true;
               ContorM=4;
            }
            
         }
         else if(Level4==true && Level5==false)///LEVEL 5 Fibonacci
         {
         
               PriceStartM=RangeM0-(PriceLevel5-PriceLevel4);
               if(ask<=PriceStartM && ContorM==4) 
            {
               trade.Buy(VolumeZ,NULL,ask,0,ask+(InpDistTakeProfit+InpDistZ)*_Point,"TP8");
               Level5=true;
               ContorM=5;
            }
            
         }
         else if(Level5==true && Level6==false)///LEVEL 6 Fibonacci
         {
         
               PriceStartM=RangeM0-(PriceLevel6-PriceLevel5);
               if(ask<=PriceStartM && ContorM==5) 
            {
               trade.Buy(VolumeZ,NULL,ask,0,ask+(InpDistTakeProfit+InpDistZ)*_Point,"TP9");
               Level6=true;
               ContorM=6;
            }
            
         }
         else if(Level6==true && Level7==false)///LEVEL 7 Fibonacci
         {
         
               PriceStartM=RangeM0-(PriceLevel7-PriceLevel6);
               if(ask<=PriceStartM && ContorM==6) 
            {
               trade.Buy(VolumeZ,NULL,ask,0,ask+(InpDistTakeProfit+InpDistZ)*_Point,"TP10");
               Level7=true;//ba e nevoie
               ContorM=7;
            }
            //CloseBuyPositionsOnLastTakeProfit();
         }
         
      Print("PriceStartM->",PriceStartM);
      Print("LevelMediereContor",ContorM);
      //Print("Contor Pozitii", ContorMC);
      if(mediere==true)
      {
      CloseBuyPositionsOnLastTakeProfit();
      }
      Print(MediereNumber);
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
      mediere=false;
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
         Print("TICKsize", tickSize,"tickValue",tickValue,"volumestep",volumeStep);
         if(tickSize==0 || tickValue==0 || volumeStep==0)
         {
         Print(__FUNCTION__,"Can not calculate ticksize tickvalue volumestep");
         return 0;
         }
         double riskMoney=AccountInfoDouble(ACCOUNT_BALANCE)*InpLots*0.01;
         Print("risk Money",riskMoney);
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
      trade.Buy(Lots,NULL,ask,0,0,NULL);
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
   //Print("---->",PositionNumber);
   
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
	     Print("MaxClose   ",MaxClose);
	     Draw_HLine(MaxClose);
      }
      else
        {
         MaxClose=ClosePrice;
        }
        Draw_HLine(MaxClose);
      if(ask<=MaxClose)
         {
          CloseAllPositions();// inchide toate pozitiile cand
          Delete_HLine();
          }
      Print("TrailPrice ",TrailPrice);
    Print("ClosePrice ",ClosePrice);
  // Print("RangePrice ",RangePrice);
   //Comment("ClosePrice ",ClosePrice);
  
      // daca atinge stop loss-ul
      
      }
      
}
//draw stop loss
void Draw_HLine(double stopLossPrice) {
    // Define the stopLossObjectName
    string stopLossObjectName = "StopLossLine";
    
    // Color and other properties
    int stopLossColor = clrRed;
    
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
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

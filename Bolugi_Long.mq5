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
int      pos=0,posB=0;
double   RangeMB0=0.0;
double   PriceStartMB=0.0;
double   PriceZ=0.0;
//+------------------------------------------------------------------+
//| LEVELE FIBONACCI                                             |
//+------------------------------------------------------------------+
double PriceLevel1=NormalizeDouble(InpDistZ*_Point+InpDistTakeProfit*_Point+(23.60*InpRangeM)/100*_Point,_Digits);
double PriceLevel2=NormalizeDouble(InpDistZ*_Point+InpDistTakeProfit*_Point+(38.20*InpRangeM)/100*_Point,_Digits);
double PriceLevel3=NormalizeDouble(InpDistZ*_Point+InpDistTakeProfit*_Point+(50.00*InpRangeM)/100*_Point,_Digits);
double PriceLevel4=NormalizeDouble(InpDistZ*_Point+InpDistTakeProfit*_Point+(61.80*InpRangeM)/100*_Point,_Digits);
double PriceLevel5=NormalizeDouble(InpDistZ*_Point+InpDistTakeProfit*_Point+(76.45*InpRangeM)/100*_Point,_Digits);
double PriceLevel6=NormalizeDouble(InpDistZ*_Point+InpDistTakeProfit*_Point+(88.20*InpRangeM)/100*_Point,_Digits);
double PriceLevel7=NormalizeDouble(InpDistZ*_Point+InpDistTakeProfit*_Point+(100.00*InpRangeM)/100*_Point,_Digits);
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
    if(lastTick.ask>=lastBuyTakeProfit-3*_Point)
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

//Complementare function
void Bolugi_Long()
{
   
  //static next buy price
  static double NextBuyPrice;
  
  //double ask =NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
  //sort
  ArraySetAsSeries(PriceInfo,true);
  int PriceData= CopyRates(_Symbol,_Period,0,3,PriceInfo);
  double Lots= CalculateLots(InpLots);
  double VolumeZ=InpLots;
  double ValueZ;
  int decimalPlace=2;
  int ColorZ=clrGold;
  double pipValue = CalculatePipValue()*0.01;
   if(CountOpenPositions()==0)
   {NextBuyPrice=0;}
   
   if(lastTick.ask>=NextBuyPrice  && medierebuy==false)
   {
      trade.Buy(Lots,NULL,lastTick.ask,0,0,"COMPLEMENTARE BUY");//a deschis poziti
      NextBuyPrice=lastTick.ask+InpStepC*_Point;// averificat range
      TicketNumber=trade.ResultDeal();//a retinyut tucketul pozitie deshise anterior
      //val mediere buy
      RangeMB0=lastTick.ask; //seteaz rangeMB0
      PriceStartMB=RangeMB0-PriceLevel1; //seteaz PriceStartM
      PriceZ=PriceStartMB+InpDistZ*_Point;//seteaz PriceZ
      Draw_HLine(PriceZ,ColorZ);
      ValueZ=CalculateLossZetBuy(PriceZ,VolumeZ);//calculeaza valoare pierderii 
      VolumeZ=NormalizeDouble(ValueZ/InpDistZ/pipValue*InpConstantVolume,decimalPlace); //calculeaza volum
   }                             
   //chart output
   Comment("Ask",lastTick.ask,"\n","NextBuyPrice: ",NextBuyPrice,"\n");
   //complementare buy
   if(CountOpenPositions()>=4 && medierebuy==false)
   {
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
      if(RangeMB0==0.0)
        {
         Alert("Atentie range mediere buy e 0.0");
        }
      Print("RangeMB0:",RangeMB0);
      Print("PriceStartM->",PriceStartMB);
      Print("LevelMediereContor:",ContorM);
      //mediere buy
      if(Level1==false) ///LEVEL 1 Fibonacci
        {
        if(lastTick.ask<=PriceStartMB && ContorM==0) 
            {
               trade.Buy(VolumeZ,NULL,lastTick.ask,0,lastTick.ask+(InpDistTakeProfit+InpDistZ)*_Point,"Order1 & TP1");
               Level1=true;
               medierebuy=true;
               complementarebuy=false;
               ContorM=1;
               TicketNumber=trade.ResultDeal();
            }
      
                  
        }
         else if(Level1==true && Level2==false)///LEVEL 2 Fibonacci
         {
         
               PriceStartMB=RangeMB0-PriceLevel2;
               PriceZ=PriceStartMB+InpDistZ*_Point;
               Draw_HLine(PriceZ,ColorZ);
               ValueZ=CalculateLossZetBuy(PriceZ,VolumeZ);
               VolumeZ=NormalizeDouble(ValueZ/InpDistZ/pipValue*10,decimalPlace);
             
               if(lastTick.ask<=PriceStartMB && ContorM==1) 
                  {
               trade.Buy(VolumeZ,NULL,lastTick.ask,0,lastTick.ask+(InpDistTakeProfit+InpDistZ)*_Point,"Order2 & TP2");
               Level2=true;
               ContorM=2;
               TicketNumber=trade.ResultDeal();
                  }
            
            
         }
         
         else if(Level2==true && Level3==false)///LEVEL 3 Fibonacci
         {
         
               PriceStartMB=RangeMB0-PriceLevel3;
               PriceZ=PriceStartMB+InpDistZ*_Point;
               Draw_HLine(PriceZ,ColorZ);
               ValueZ=CalculateLossZetBuy(PriceZ,VolumeZ);
               VolumeZ=NormalizeDouble(ValueZ/InpDistZ/pipValue*10,decimalPlace);
              
               if(lastTick.ask<=PriceStartMB && ContorM==2) 
                  {
               trade.Buy(VolumeZ,NULL,lastTick.ask,0,lastTick.ask+(InpDistTakeProfit+InpDistZ)*_Point,"Order3 &Tp3");
               Level3=true;
               ContorM=3;
               TicketNumber=trade.ResultDeal();
                  }
      
            
         }
        else if(Level3==true && Level4==false)///LEVEL 4 Fibonacci
         {
         
               PriceStartMB=RangeMB0-PriceLevel4;
               PriceZ=PriceStartMB+InpDistZ*_Point;
               Draw_HLine(PriceZ,ColorZ);
               ValueZ=CalculateLossZetBuy(PriceZ,VolumeZ);
               VolumeZ=NormalizeDouble(ValueZ/InpDistZ/pipValue*10,decimalPlace);
               
               if(lastTick.ask<=PriceStartMB && ContorM==3) 
                  {
               trade.Buy(VolumeZ,NULL,lastTick.ask,0,lastTick.ask+(InpDistTakeProfit+InpDistZ)*_Point,"Order4 &Tp4");
               Level4=true;
               ContorM=4;
               TicketNumber=trade.ResultDeal();
                  }
          
            
         }
         else if(Level4==true && Level5==false)///LEVEL 5 Fibonacci
         {
         
               PriceStartMB=RangeMB0-PriceLevel5;
               PriceZ=PriceStartMB+InpDistZ*_Point;
               Draw_HLine(PriceZ,ColorZ);
               ValueZ=CalculateLossZetBuy(PriceZ,VolumeZ);
               VolumeZ=NormalizeDouble(ValueZ/InpDistZ/pipValue*10,decimalPlace);
              
                if(lastTick.ask<=PriceStartMB && ContorM==4) 
                  {
               trade.Buy(VolumeZ,NULL,lastTick.ask,0,lastTick.ask+(InpDistTakeProfit+InpDistZ)*_Point,"Order5 &Tp5");
               Level5=true;
               ContorM=5;
               TicketNumber=trade.ResultDeal();
                  }
             
            
         }
         else if(Level5==true && Level6==false)///LEVEL 6 Fibonacci
         {
               PriceStartMB=RangeMB0-PriceLevel6;
               PriceZ=PriceStartMB+InpDistZ*_Point;
               Draw_HLine(PriceZ,ColorZ);
               ValueZ=CalculateLossZetBuy(PriceZ,VolumeZ);
               VolumeZ=NormalizeDouble(ValueZ/InpDistZ/pipValue*10,decimalPlace);
              
               if(lastTick.ask<=PriceStartMB && ContorM==5) 
                  {
               trade.Buy(VolumeZ,NULL,lastTick.ask,0,lastTick.ask+(InpDistTakeProfit+InpDistZ)*_Point,"Order6 &Tp6");
               Level6=true;
               ContorM=6;
               TicketNumber=trade.ResultDeal();
                   }
         
         }
         else if(Level6==true && Level7==false)///LEVEL 7 Fibonacci
         {
         
               PriceStartMB=RangeMB0-PriceLevel7;
               PriceZ=PriceStartMB+InpDistZ*_Point;
               Draw_HLine(PriceZ,ColorZ);
               ValueZ=CalculateLossZetBuy(PriceZ,VolumeZ);
               VolumeZ=NormalizeDouble(ValueZ/InpDistZ/pipValue*10,decimalPlace);
               if(lastTick.ask<=PriceStartMB && ContorM==6) 
                  {
               trade.Buy(VolumeZ,NULL,lastTick.ask,0,lastTick.ask+(InpDistTakeProfit+InpDistZ)*_Point,"Order7 &Tp7");
               Level7=true;//ba e nevoie
               ContorM=7;
               TicketNumber=trade.ResultDeal();
                  }

         }
      if(medierebuy==true)
      {
      CloseBuyPositionsOnLastTakeProfit();
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
double CalculateLossZetBuy(double zetPrice, double volume) {//z1 e rezolvata /z2 volume
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

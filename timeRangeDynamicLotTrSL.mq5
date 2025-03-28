
#property copyright "MindaLucian"
#property link      "MindaLucian"
#property version   "1.00"
//+------------------------------------------------------------------+
//| includes                                  |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//|Global VAriables                            |
//+------------------------------------------------------------------+
struct RANGE_STRUCT
  {
   datetime start_time; //start of the range
   datetime end_time; // end of the range
   datetime close_time; //closew time
   double high; // high of the range
   double low; // low of the range
   bool f_entry; //entry flag if inside
   bool f_high_breakout;// flag if a high breakout occurred
   bool f_low_breakout;//flag if a low breakout occurred
   
   RANGE_STRUCT(): start_time(0),end_time(0),close_time(0),high(0),low(DBL_MAX),f_entry(false),f_high_breakout(false), f_low_breakout(false){};
  };
RANGE_STRUCT range;
MqlTick prevTick, lastTick;
CTrade trade;

//+------------------------------------------------------------------+
//|inputs Variables                              |
//+------------------------------------------------------------------+
input group "====General Inputs===="
input long InpMagicNumber=12345; //magicnumber

enum LOT_MODE_ENUM{
LOT_MODE_FIXED, //fixed lots
LOT_MODE_MONEY, // lots based on money
LOT_MODE_PCT_ACCOUNT // lots based on % account

};
input LOT_MODE_ENUM InpLotMode = LOT_MODE_FIXED;//lot mode

input double InpLots=0.01; //lots / money / percent

input int InpStopLoss=150; //stop loss in percent of the range (0-off)
input bool InpStopLossTrailing=false; //trailing stop loss
input int InpTakeProfit=200;//take profit in percent of the range (0-off)

input group "====Range Inputs===="
input int InpRangeStart=600; //range start time in minutes
input int InpRangeDuration=120; // range duartion in minutes
input int InpRangeClose=1200; //range close time in minutes(-1=off)


enum BREAKOUT_MODE_ENUM{
   ONE_SIGNAL,                //one breakout per range
   TWO_SIGNALS                // high and low brakout

};

input group "====Day of week filter===="
input BREAKOUT_MODE_ENUM InpBreakoutMode= ONE_SIGNAL; //breakout mode
input bool InpMonday=true;//range on monday
input bool InpTuesday=true;//range on Tuesday
input bool InpWednesday=true;//range on Wednesday
input bool InpThursday=true;//range on Thursday
input bool InpFriday=true;//range on Friday

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  //check for inputs
   if(!CheckInputs())
   {return INIT_PARAMETERS_INCORRECT;}
     //set maginumer
     trade.SetExpertMagicNumber(InpMagicNumber);
     
   //calculated new range if inoputs added
      if(_UninitReason==REASON_PARAMETERS && CountOpenPositions()==0) //no position open+++
        {
            CalculateRange();
        }
      //drawobjects for the new timeframe
      DrawObjects();  
        
        
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //deleteobjects
   ObjectsDeleteAll(NULL,"range");
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   //Get current tick
   prevTick=lastTick;
   SymbolInfoTick(_Symbol,lastTick);
   
   //range calculation
   if(lastTick.time >= range.start_time && lastTick.time <range.end_time)
     {
      //set flag
      range.f_entry=true;
      //new hugh
      if(lastTick.ask>range.high)
        {
         
         range.high=lastTick.ask;
         DrawObjects();
        }
        
        //new low
      if(lastTick.bid<range.low)
        {
         
         range.low=lastTick.bid;
         DrawObjects();
        }
     }
     
     //close new positions
     if(InpRangeClose>=0 &&lastTick.time>=range.close_time)
       {
        if(!ClosePositions()){return;}
        
        
       }
     
   
   //calculate new range
   if(((InpRangeClose>=0 && lastTick.time>=range.close_time)                //close time reached
      || (range.f_high_breakout && range.f_low_breakout)                   //both flags breakout are true
      || (range.end_time==0 )                                                //range not calculated yet
      || (range.end_time!=0 && lastTick.time>range.end_time && !range.f_entry))//there was a range calculated but not tick inside
      && CountOpenPositions()==0)
     {
      CalculateRange();
     }
   //check for breakouts
   CheckBreakouts();
   
   //uopdate stopp loss
   UpdateStopLoss();
   
  }
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
     
     if(InpLotMode==LOT_MODE_MONEY &&(InpLots<=0 || InpLots >1000))
     {
      Alert("lots<=0 or lots>1000" );
      return false;
     }
     if(InpLotMode==LOT_MODE_PCT_ACCOUNT &&(InpLots<=0 || InpLots >5))
     {
      Alert("lots<=0 or lots>5%" );
      return false;
     }
     
     if((InpLotMode==LOT_MODE_PCT_ACCOUNT || InpLotMode==LOT_MODE_MONEY) && InpStopLoss==0)
     {
      Alert("selected mode needs a stop loss" );
      return false;
     }
   
    if(InpStopLoss<0 || InpStopLoss>1000)
     {
      Alert("stop los incorrect");
      return false;
     }
     
     if(InpTakeProfit<0 || InpTakeProfit>1000)
     {
      Alert("take profit incorrect");
      return false;
     }
     
     if(InpRangeClose<0 && InpStopLoss==0)
     {
      Alert("Close time and sl is off");
      return false;
     }
   if(InpRangeStart<0 || InpRangeStart>=1440)
     {
      Alert("range start incorrect");
      return false;
     }
     
     if(InpRangeDuration<=0 || InpRangeDuration>=1440)
     {
      Alert("range duration incorrect");
      return false;
     }
     
     if(InpRangeClose>=1440 || (InpRangeStart+InpRangeDuration)%1440==InpRangeClose )
     {
      Alert("rnage close incorrect");
      return false;
     }
     
     if(InpMonday+InpTuesday+InpWednesday+InpThursday+InpFriday==0 )
     {
      Alert("range is prohibited on all days of weeks");
      return false;
     }
  
  return true;
}
  
  
//calculate a new range
void CalculateRange()
{
// reset range variables
range.start_time=0;
range.end_time=0;
range.close_time=0; 
range.high=0.0; 
range.low=DBL_MAX; 
range.f_entry=false; 
range.f_high_breakout=false;
range.f_low_breakout=false;

// calculate range start time
int time_cycle=86400;
range.start_time= (lastTick.time-(lastTick.time %time_cycle))+InpRangeStart* 60;
for(int i=0;i<8;i++)
  {
   MqlDateTime tmp;
   TimeToStruct(range.start_time,tmp);
   int dow=tmp.day_of_week;
   if(lastTick.time>=range.start_time || dow ==6 || dow==0 || (dow==1 && !InpMonday) || (dow==2 && !InpTuesday) || (dow==3 && !InpWednesday)
    || (dow==4 && !InpThursday) || (dow==5 && !InpFriday)){
   range.start_time +=time_cycle;
   }
  }
  
  //calculate range end time
  range.end_time=range.start_time+InpRangeDuration*60;
  for(int i=0;i<2;i++)
    {
     MqlDateTime tmp;
   TimeToStruct(range.end_time,tmp);
   int dow=tmp.day_of_week;
   if(dow==6 || dow==0)
     {
      range.end_time+=time_cycle;
     }
    }
    
    //calculate range close
    if(InpRangeClose>=0){
    range.close_time= (range.end_time-(range.end_time %time_cycle))+InpRangeClose* 60;
for(int i=0;i<3;i++)
  {
   MqlDateTime tmp;
   TimeToStruct(range.close_time,tmp);
   int dow=tmp.day_of_week;
   if(range.close_time<=range.end_time || dow ==6 || dow==0){
   range.close_time +=time_cycle;
   }
  }
  }
  //drawobjects
  DrawObjects();
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
//check breakouts
void CheckBreakouts()
{

   //check if we are the range end
   if(lastTick.time>=range.end_time && range.end_time>0 && range.f_entry)
     {
      
      //check for high breakout
      if(!range.f_high_breakout && lastTick.ask>=range.high)
        {
         range.f_high_breakout=true;
         if(InpBreakoutMode==ONE_SIGNAL){range.f_low_breakout=true;}
         
         //calculate stop loss and take profit
         double sl = InpStopLoss==0 ? 0 :NormalizeDouble( lastTick.bid-((range.high-range.low)*InpStopLoss*0.01),_Digits);
         double tp =InpTakeProfit==0 ? 0 :NormalizeDouble( lastTick.bid+((range.high-range.low)*InpTakeProfit*0.01),_Digits);
        
        //calculate lots
        double lots;
         if(!CalculateLots(lastTick.bid-sl,lots)){return;}
         //open buy pos
         trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,lots,lastTick.ask,sl,tp,"Time range EA" );
         
        }
      //check for low breakout
      if(!range.f_low_breakout && lastTick.bid<=range.low)
        {
         range.f_low_breakout=true;
         if(InpBreakoutMode==ONE_SIGNAL){range.f_high_breakout=true;}
         
         //calculate stop loss and take profit
         double sl =InpStopLoss==0 ? 0 :NormalizeDouble( lastTick.ask+((range.high-range.low)*InpStopLoss*0.01),_Digits);
         double tp =InpTakeProfit==0 ? 0 :NormalizeDouble( lastTick.ask-((range.high-range.low)*InpTakeProfit*0.01),_Digits);
         
         //calculate lots
         double lots;
         if(!CalculateLots(sl-lastTick.ask,lots)){return;}
         //open sell pos
         trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,lots,lastTick.bid,sl,tp,"Time range EA" );
         
        }
      
     }
}
//calculate lots
bool CalculateLots(double slDistance, double &lots){

   lots=0.0;
   if(InpLotMode==LOT_MODE_FIXED)
     {
      lots=InpLots;
     }
      else
        {
         double tickSize=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
         double tickValue=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
         double volumeStep=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
         
         double riskMoney=InpLotMode==LOT_MODE_MONEY ? InpLots : AccountInfoDouble(ACCOUNT_EQUITY)*InpLots*0.01;
         double moneyVolumeStep= (slDistance/tickSize) * tickValue *volumeStep;
         
         lots=MathFloor(riskMoney/moneyVolumeStep)*volumeStep;
        }
        
        //check calcukated lots
        if(!CheckLots(lots)){return false;}
   return true;
}
//check lots for min, max and step
bool CheckLots(double &lots)
{
   double min = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double max = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double step = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   
   if(lots<min)
     {
      Print("Lot size will be set to the minimu allowable volume");
      lots=min;
      return true;
     }
     
     if(lots>max)
       {
        Print("Lot size greater than the maximum allowable volumee. lots:",lots,"max:",max);
        return false;
       }
       lots = (int)MathFloor(lots/step)*step;
       
       
   return true;
}


//updatw stop loss
void UpdateStopLoss()
{
   //return if no stop loss or fixed stop loss
   if(InpStopLoss==0|| !InpStopLossTrailing)
     {
      return;
     }
     //loop throug open positions
     int total=PositionsTotal();
   for(int i=total-1;i>=0;i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket<=0)
        {
         Print("Failed to get position ticket");return;
        }
        if(!PositionSelectByTicket(ticket))
          {
           Print("Failed to select position by ticket");return;
          }
         ulong magicnumber;
         if(!PositionGetInteger(POSITION_MAGIC,magicnumber)){Print("Failed to get magicnumber");return;}
         if(InpMagicNumber==magicnumber){
        
         //get type
         long type;
         if(!PositionGetInteger(POSITION_TYPE,type)){Print("Failed to get position type");return;}
        
         //get current sl and tp
         double currSL, currTP;
         if(!PositionGetDouble(POSITION_SL,currSL))
           {
            Print("failed to get sl");return;
           }
         if(!PositionGetDouble(POSITION_TP,currTP))
           {
            Print("failed to get tp");return;
           }
         
         //calculaten new sl
         double currPrice = type==POSITION_TYPE_BUY ? lastTick.bid : lastTick.ask;
         int n            = type==POSITION_TYPE_BUY ? 1 : -1;
         double newSL     = NormalizeDouble(currPrice - ((range.high-range.low)*InpStopLoss*0.01*n),_Digits);
         
         // check if new stopp loss is closer to current price than existing stop loss
         if((newSL*n)<(currSL*n) || NormalizeDouble(MathAbs(newSL-currSL),_Digits)<_Point)
           {
           // Print("No new stop loss needed");
            continue;
           }
         //chech for stop lvel
         long level = SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
         if(level!=0 && MathAbs(currPrice-newSL)<=level*_Point)
           {
            Print("New stop inside stopp level");
            continue;
           }
         
         //modify positions with new stop loss
         if(!trade.PositionModify(ticket,newSL,currTP)){Print("Failed to modify the position, ticket:",(string)ticket,"currSL:",(string)currSL,
         "newSl:",(string)newSL,"currTP:",(string)currTP);
         return;
         }
         
         
         }
      
     }


}


// close positions
bool ClosePositions()
{
   int total = PositionsTotal();
   for(int i=total-1;i>=0;i--)
     {
      if(total!=PositionsTotal())
        {
         total=PositionsTotal();
         i=total;
         continue;
        }
      ulong ticket=PositionGetTicket(i); //selectpos
      if(ticket<=0){Print ("to get position ticket"); return false;}
      if(!PositionSelectByTicket(ticket)){Print("Failed to select position by ticket"); return false;}
      long magicnumber;
      if(!PositionGetInteger(POSITION_MAGIC,magicnumber)){Print("Failed to get positon magicnumber");return false;}
      if(magicnumber==InpMagicNumber){
      trade.PositionClose(ticket);
      if(trade.ResultRetcode()!=TRADE_RETCODE_DONE){
      Print("Failed to close position. Result: "+(string)trade.ResultRetcode()+":"+trade.ResultRetcodeDescription());
      return false;
      }
         
      }
         
     }
return true;

}



//drawobjects
void DrawObjects()
{
   //start time
   ObjectDelete(NULL,"range start");
   if(range.start_time>=0)
     {
      ObjectCreate(NULL,"range start",OBJ_VLINE,0,range.start_time,0);
      ObjectSetString(NULL,"range start",OBJPROP_TOOLTIP,"start of the the range \n"+TimeToString(range.start_time,TIME_DATE|TIME_MINUTES));
      ObjectSetInteger(NULL,"range start",OBJPROP_COLOR,clrBlue);
      ObjectSetInteger(NULL,"range start",OBJPROP_WIDTH,2);
      ObjectSetInteger(NULL,"range start",OBJPROP_BACK,true);
     }
     
     //end time
     ObjectDelete(NULL,"range end");
   if(range.end_time>=0)
     {
      ObjectCreate(NULL,"range end",OBJ_VLINE,0,range.end_time,0);
      ObjectSetString(NULL,"range end",OBJPROP_TOOLTIP,"end of the the range \n"+TimeToString(range.end_time,TIME_DATE|TIME_MINUTES));
      ObjectSetInteger(NULL,"range end",OBJPROP_COLOR,clrBlue);
      ObjectSetInteger(NULL,"range end",OBJPROP_WIDTH,2);
      ObjectSetInteger(NULL,"range end",OBJPROP_BACK,true);
     }
     
     //closetime  
     ObjectDelete(NULL,"range close");
   if(range.close_time>=0)
     {
      ObjectCreate(NULL,"range close",OBJ_VLINE,0,range.close_time,0);
      ObjectSetString(NULL,"range close",OBJPROP_TOOLTIP,"close of the the range \n"+TimeToString(range.close_time,TIME_DATE|TIME_MINUTES));
      ObjectSetInteger(NULL,"range close",OBJPROP_COLOR,clrRed);
      ObjectSetInteger(NULL,"range close",OBJPROP_WIDTH,2);
      ObjectSetInteger(NULL,"range close",OBJPROP_BACK,true);
     }
     
     //high 
     ObjectsDeleteAll(NULL,"range high");
   if(range.high>0)
     {
      ObjectCreate(NULL,"range high",OBJ_TREND,0,range.start_time,range.high,range.end_time,range.high);
      ObjectSetString(NULL,"range high",OBJPROP_TOOLTIP,"high of the the range \n"+DoubleToString(range.high,_Digits));
      ObjectSetInteger(NULL,"range high",OBJPROP_COLOR,clrBlue);
      ObjectSetInteger(NULL,"range high",OBJPROP_WIDTH,2);
      ObjectSetInteger(NULL,"range high",OBJPROP_BACK,true);
     
      ObjectCreate(NULL,"range high ",OBJ_TREND,0,range.end_time,range.high,InpRangeClose>=0 ? range.close_time:INT_MAX,range.high);
      ObjectSetString(NULL,"range high ",OBJPROP_TOOLTIP,"high of the the range \n"+DoubleToString(range.high,_Digits));
      ObjectSetInteger(NULL,"range high ",OBJPROP_COLOR,clrBlue);
      //ObjectSetInteger(NULL,"range high ",OBJPROP_WIDTH,2);
      ObjectSetInteger(NULL,"range high ",OBJPROP_BACK,true);
      ObjectSetInteger(NULL,"range high ",OBJPROP_STYLE,STYLE_DOT);
     }
    //low
     ObjectsDeleteAll(NULL,"range low");
   if(range.low<DBL_MAX)
     {
      ObjectCreate(NULL,"range low",OBJ_TREND,0,range.start_time,range.low,range.end_time,range.low);
      ObjectSetString(NULL,"range low",OBJPROP_TOOLTIP,"low of the the range \n"+DoubleToString(range.low,_Digits));
      ObjectSetInteger(NULL,"range low",OBJPROP_COLOR,clrBlue);
      ObjectSetInteger(NULL,"range low",OBJPROP_WIDTH,2);
      ObjectSetInteger(NULL,"range low",OBJPROP_BACK,true);
      
     
      ObjectCreate(NULL,"range low ",OBJ_TREND,0,range.end_time,range.low,InpRangeClose>=0 ? range.close_time:INT_MAX,range.low);
      ObjectSetString(NULL,"range low ",OBJPROP_TOOLTIP,"low of the the range \n"+DoubleToString(range.low,_Digits));
      ObjectSetInteger(NULL,"range low ",OBJPROP_COLOR,clrBlue);
      //ObjectSetInteger(NULL,"range low ",OBJPROP_WIDTH,2);
      ObjectSetInteger(NULL,"range low ",OBJPROP_BACK,true);
      ObjectSetInteger(NULL,"range low ",OBJPROP_STYLE,STYLE_DOT);
     
     
     }
     //refresh chart
     ChartRedraw();
}
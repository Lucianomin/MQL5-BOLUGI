#property copyright "MindaLucian"
#property link      "MindaLucian"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Includes 
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Global Variables
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Inputs
//+------------------------------------------------------------------+
input group "====General Inputs===="
input long InpMagicNumber=181105; //magicnumber

enum LOT_MODE_ENUM{
LOT_MODE_FIXED, //fixed lots
LOT_MODE_MONEY, // lots based on money
LOT_MODE_PCT_ACCOUNT // lots based on % account

};
input LOT_MODE_ENUM InpLotMode = LOT_MODE_FIXED;//lot mode

input double InpLots=0.01; //lots / money / percent
input int IntStepC=100; //pips
input int InpStopLoss=100;
input bool InpStopLossTrailing=false //on/off

//+------------------------------------------------------------------+
//| 
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
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
  
   
  }
  
  
//+------------------------------------------------------------------+
//| Functions
//+------------------------------------------------------------------+
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
   
  return true;
}

//+------------------------------------------------------------------+
//|Calculate Lots
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|check lots for min, max and step
//+------------------------------------------------------------------+


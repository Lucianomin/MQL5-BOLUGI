#include <Trade/trade.mqh>


input double PercentageRiskValue=0.5;
input double InpLots=0.1;

double MaxPositionLoss;
bool mediere=false;
CTrade trade;
int OnInit()
  {
  
  
  

   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
{
   
  }


void OnTick()
  {
   double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
  
  
  double Balance=AccountInfoDouble(ACCOUNT_BALANCE);
  
  if(PositionsTotal()<1)
  {
      trade.Buy(InpLots,NULL,Ask,0,0,NULL);
  }
  
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
   ulong ticket = PositionGetTicket(i);
   
   double   PositionProfit=PositionGetDouble(POSITION_PROFIT);
   
   MaxPositionLoss=0-(Balance/100*PercentageRiskValue);
   
   Print("### Position Profit: ",PositionProfit);
   Print("### MaxPositionStopLoss: ",MaxPositionLoss);
   
   if(PositionProfit<MaxPositionLoss)
   {
   //trade.PositionClose(ticket);
   double LotsVolume=InpLots*2;
   if(mediere==false)
     {
      trade.Buy(LotsVolume,NULL,Ask,0,0,NULL);
   mediere=true;
    }

   }
      if(Ask>Ask+50*_Point)
      {
      CloseAllPositions();
      mediere=false;
      }
   }
   Comment(
            "Balance: ",Balance," \n",
            "MaxPositionLoss:",MaxPositionLoss, " \n",
            "Percentage Risk Value: ",PercentageRiskValue,"%"
   
   
   
   );
  }

//CloseAllPOsitions
void CloseAllPositions()
{
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
   ulong ticket=PositionGetTicket(i);//get ticket
   trade.PositionClose(ticket,i);//close
  // PositionNumber=PositionNumber+2;
   
   }

}
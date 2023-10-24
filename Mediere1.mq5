//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <Trade/trade.mqh>


input double PercentageRiskValue=0.5;//percentage
input double InpLots=0.1;
input double InpStopLossM=50; //pips
double MaxPositionLoss;
bool mediere=false;
CTrade trade;
int OnInit()
  {




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
   double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Balance=NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE),_Digits);
   double Loss=NormalizeDouble(AccountInfoDouble(ACCOUNT_PROFIT),_Digits);
   MaxPositionLoss= MathFloor(0-(Balance/100*PercentageRiskValue));//mathfloor rotunjeste valorile
   
   if(PositionsTotal()<1)
     {
      trade.Buy(InpLots,NULL,Ask,0,0,NULL);
     }
    
      Print("### Position Profit: ",Loss);
      Print("### MaxPositionStopLoss: ",MaxPositionLoss);
double RangeMediere=0.0;
      if(Loss==MaxPositionLoss)
        {
         ///CloseAllPositions();
         mediere=true;
         double LotsVolume=InpLots*2;
         //PositionOpen++;
         trade.Buy(LotsVolume,NULL,Ask,0,0,NULL);
         //calcule acel Z;
        }
        if(mediere==true)
        {
        for(int i=0;i<=PositionsTotal()+2;i++)
         {
            if(PositionSelectByTicket(i))
            {
            
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
              {
               RangeMediere=NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN),_Digits);
               Print("medierePrice        ",RangeMediere);
         
              }
            }
         
         }
     double CloseMediere=RangeMediere+InpStopLossM*_Point; //calculeaza nivelul de stop loss
         Comment("ClosePrice ",CloseMediere);
         Print("medierePrice ",RangeMediere);
         Print("ClosePrice ",CloseMediere);
         if(Ask>=CloseMediere)
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
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      ulong ticket=PositionGetTicket(i);//get ticket
      trade.PositionClose(ticket,i);//close
      /// PositionNumber=PositionNumber+2;

     }

  }


#property copyright ""
#property link      ""
#property version   "1.00"
#property strict

#include <goldtm/Config.mqh>
#include <goldtm/Detector.mqh>
#include <goldtm/Logger.mqh>

PipBurstDetector detector;

int OnInit()
{
   EnsureLogOpened();
   EventSetTimer(1);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   CloseLogIfOpen();
}

void OnTick()
{
   MqlTick mtick;
   if(!SymbolInfoTick(_Symbol, mtick))
      return;

   Tick t;
   t.time_msc = mtick.time_msc;
   t.bid = mtick.bid;
   t.ask = mtick.ask;
   t.mid = (mtick.bid + mtick.ask)/2.0;

   BurstSignal sig = detector.OnTickDetect(t);
   int flag=0;
   if(sig==BurstLong) flag=1;
   else if(sig==BurstShort) flag=-1;

   LogLine(t, detector.LastDeltaPips(), detector.LastSpreadPips(), flag);
}

void OnTimer()
{
   // Get latest tick first; if unavailable, skip
   MqlTick mtick;
   if(!SymbolInfoTick(_Symbol, mtick))
      return;

   // Run 1s-window detection based on server ticks
   BurstSignal sig = detector.OnTimerDetect();

   Tick t;
   t.time_msc = mtick.time_msc;
   t.bid = mtick.bid;
   t.ask = mtick.ask;
   t.mid = (mtick.bid + mtick.ask)/2.0;

   int flag=0;
   if(sig==BurstLong) flag=1;
   else if(sig==BurstShort) flag=-1;

   LogLine(t, detector.LastDeltaPips(), detector.LastSpreadPips(), flag);
}

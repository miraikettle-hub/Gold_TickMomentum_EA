#property strict
#include "TickWindow.mqh"
#include "Points.mqh"
#include "Config.mqh"

class PipBurstDetector
{
private:
   RollingTickWindow m_win;
   long   m_lastFireMs;
   double m_lastDeltaPips;
   double m_lastSpreadPips;
   double m_pipMoveThreshold;
   double m_secondsWindow;
   int    m_minTicks;
   int    m_debounceMs;
   double m_maxSpreadPips;
public:
   PipBurstDetector()
   {
      m_lastFireMs     = 0;
      m_lastDeltaPips  = 0.0;
      m_lastSpreadPips = 0.0;
      m_pipMoveThreshold = GetPipMoveThreshold();
      m_secondsWindow    = GetSecondsWindow();
      m_minTicks         = GetMinTicksInWindow();
      m_debounceMs       = GetDebounceMs();
      m_maxSpreadPips    = GetMaxSpreadPips();
   }

   double LastDeltaPips() const { return m_lastDeltaPips; }
   double LastSpreadPips() const { return m_lastSpreadPips; }

   BurstSignal OnTickDetect(const Tick &t)
   {
      m_win.Push(t);
      long cutoff = t.time_msc - (long)(m_secondsWindow*1000.0);
      m_win.EvictOlderThan(cutoff);

      m_lastSpreadPips = (t.ask - t.bid) / _Point / PointsPerPip();
      if(m_lastSpreadPips > m_maxSpreadPips)
      {
         m_lastDeltaPips = 0.0;
         return BurstNone;
      }

      if(m_win.Ready(m_minTicks))
      {
         double deltaPoints = m_win.DeltaMid() / _Point;
         m_lastDeltaPips = MathAbs(PointsToPips(deltaPoints, _Symbol));
         if(m_lastDeltaPips >= m_pipMoveThreshold && (long)(t.time_msc - m_lastFireMs) >= (long)m_debounceMs)
         {
            m_lastFireMs = t.time_msc;
            return (m_win.DeltaMid()>0 ? BurstLong : BurstShort);
         }
      }
      else
      {
         m_lastDeltaPips = 0.0;
      }
      return BurstNone;
   }

   BurstSignal OnTimerDetect()
   {
      MqlTick latest;
      if(!SymbolInfoTick(_Symbol, latest))
      {
         m_lastDeltaPips=0.0;
         m_lastSpreadPips=0.0;
         return BurstNone;
      }

      long end_us   = (long)latest.time_msc * 1000;
      long start_us = end_us - (long)(m_secondsWindow*1000.0*1000.0);
      MqlTick ticks[];
      int cnt = CopyTicksRange(_Symbol, ticks, COPY_TICKS_ALL, start_us, end_us);
      if(cnt < m_minTicks || cnt <= 0)
      {
         m_lastDeltaPips=0.0;
         m_lastSpreadPips=0.0;
         return BurstNone;
      }

      double oldest_mid = ticks[0].bid + (ticks[0].ask - ticks[0].bid)/2.0;
      double newest_mid = ticks[cnt-1].bid + (ticks[cnt-1].ask - ticks[cnt-1].bid)/2.0;

      m_lastSpreadPips = (ticks[cnt-1].ask - ticks[cnt-1].bid) / _Point / PointsPerPip();
      if(m_lastSpreadPips > m_maxSpreadPips)
      {
         m_lastDeltaPips=0.0;
         return BurstNone;
      }

      double deltaPoints = (newest_mid - oldest_mid) / _Point;
      m_lastDeltaPips = MathAbs(PointsToPips(deltaPoints, _Symbol));
      if(m_lastDeltaPips >= m_pipMoveThreshold && latest.time_msc - m_lastFireMs >= m_debounceMs)
      {
         m_lastFireMs = latest.time_msc;
         return ((newest_mid - oldest_mid) > 0 ? BurstLong : BurstShort);
      }
      return BurstNone;
   }
};

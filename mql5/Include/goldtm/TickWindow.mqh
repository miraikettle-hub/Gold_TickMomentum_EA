#property strict
#include "TickTypes.mqh"

class ITickWindow
{
public:
   virtual void   Push(const Tick &t)            =0;
   virtual void   EvictOlderThan(long cutoff_msc)=0;
   virtual bool   Ready(int minTicks) const      =0;
   virtual double DeltaMid() const               =0;
   virtual const Tick& Oldest() const            =0;
   virtual const Tick& Newest() const            =0;
};

class RollingTickWindow : public ITickWindow
{
private:
   Tick m_ticks[];
public:
   void Push(const Tick &t)
   {
      int sz=ArraySize(m_ticks);
      ArrayResize(m_ticks,sz+1);
      m_ticks[sz]=t;
   }

   void EvictOlderThan(long cutoff_msc)
   {
      int sz=ArraySize(m_ticks);
      int start=0;
      while(start<sz && m_ticks[start].time_msc < cutoff_msc) start++;
      if(start>0)
      {
         for(int i=0;i<sz-start;i++) m_ticks[i]=m_ticks[i+start];
         ArrayResize(m_ticks,sz-start);
      }
   }

   bool Ready(int minTicks) const
   {
      return ArraySize(m_ticks) >= minTicks;
   }

   double DeltaMid() const
   {
      int sz=ArraySize(m_ticks);
      if(sz<2) return 0.0;
      return m_ticks[sz-1].mid - m_ticks[0].mid;
   }

   const Tick& Oldest() const { return m_ticks[0]; }

   const Tick& Newest() const
   {
      int sz=ArraySize(m_ticks);
      return m_ticks[sz-1];
   }
};

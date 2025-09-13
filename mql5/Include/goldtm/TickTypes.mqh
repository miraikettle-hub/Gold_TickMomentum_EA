#property strict

struct Tick
{
   long   time_msc;
   double bid;
   double ask;
   double mid;
};

enum BurstSignal
{
   BurstNone = 0,
   BurstLong = 1,
   BurstShort = -1
};

#property strict
#include "TickTypes.mqh"

int g_log_handle = INVALID_HANDLE;

void EnsureLogOpened()
{
   if(g_log_handle != INVALID_HANDLE) return;
   g_log_handle = FileOpen("delta.csv",
      FILE_READ|FILE_WRITE|FILE_CSV|FILE_SHARE_READ|FILE_SHARE_WRITE|FILE_ANSI);
   if(g_log_handle == INVALID_HANDLE) return;

   if(FileSize(g_log_handle) == 0)
      FileWrite(g_log_handle, "time_msc","bid","ask","mid","delta_pips","spread_pips","event_flag");
   else
      FileSeek(g_log_handle, 0, SEEK_END);
}

void LogLine(const Tick &t, double deltaPips, double spreadPips, int eventFlag)
{
   if(g_log_handle == INVALID_HANDLE) return;
   FileWrite(g_log_handle, t.time_msc, t.bid, t.ask, t.mid, deltaPips, spreadPips, eventFlag);
   FileFlush(g_log_handle);
}

void CloseLogIfOpen()
{
   if(g_log_handle != INVALID_HANDLE)
   {
      FileClose(g_log_handle);
      g_log_handle = INVALID_HANDLE;
   }
}

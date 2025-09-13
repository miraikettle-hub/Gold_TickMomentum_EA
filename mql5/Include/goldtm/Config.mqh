#property strict

input double PipMoveThreshold = 3.0;  // in pips
input double SecondsWindow    = 1.0;  // seconds
input int    MinTicksInWindow = 2;
input int    DebounceMs       = 150;
input double MaxSpreadPips    = 2.0;

double GetPipMoveThreshold() { return PipMoveThreshold; }
double GetSecondsWindow()    { return SecondsWindow; }
int    GetMinTicksInWindow() { return MinTicksInWindow; }
int    GetDebounceMs()       { return DebounceMs; }
double GetMaxSpreadPips()    { return MaxSpreadPips; }

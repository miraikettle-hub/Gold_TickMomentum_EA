#property strict

int PointsPerPip(const string sym=_Symbol)
{
   int digits=(int)SymbolInfoInteger(sym,SYMBOL_DIGITS);
   if(digits==3 || digits==5) return 10;
   return 1;
}

double PipsToPoints(double pips,const string sym=_Symbol)
{
   return pips*PointsPerPip(sym);
}

double PointsToPips(double points,const string sym=_Symbol)
{
   return points/PointsPerPip(sym);
}

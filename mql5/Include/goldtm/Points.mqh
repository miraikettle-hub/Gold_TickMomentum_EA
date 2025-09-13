#property strict

int PointsPerPip(const string sym=””)
{
   int digits=(int)SymbolInfoInteger(sym,SYMBOL_DIGITS);
   if(digits==3 || digits==5) return 10;
   return 1;
}

double PipsToPoints(double pips,const string sym=””)
{
   return pips*PointsPerPip(sym);
}

double PointsToPips(double points,const string sym=””)
{
   return points/PointsPerPip(sym);
}

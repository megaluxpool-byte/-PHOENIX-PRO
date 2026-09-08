#ifndef PHX_SIGNAL_QUALITY_TYPES_MQH
#define PHX_SIGNAL_QUALITY_TYPES_MQH

#include "../Signal/PHXSignalTypes.mqh"
#include "../Signal/PHXTrendTypes.mqh"

//+------------------------------------------------------------------+
//| Signal Quality Record                                            |
//+------------------------------------------------------------------+
struct SPHXSignalQualityRecord
{
   //--------------------------------------------------
   // Basic
   //--------------------------------------------------
   datetime Time;
   string Symbol;
   //--------------------------------------------------
   // Research Timeframe
   //--------------------------------------------------

   ENUM_TIMEFRAMES
   ResearchTF;
   //--------------------------------------------------
   // Signal
   //--------------------------------------------------
   ENUM_PHX_SIGNAL Signal;
   double EntryPrice;
   //--------------------------------------------------
   // Execution Quality Context
   //--------------------------------------------------
   ulong Ticket;
   
   double CandlePosition;

   ulong ExecutionDelayMS;

   double PriceVsCandleHigh;
   //--------------------------------------------------
   // Entry Market Snapshot
   //--------------------------------------------------

   // M5 candle
   datetime M5Time;
   double M5Open;
   double M5High;
   double M5Low;
   double M5Close;
   double M5Range;

   // M1 current/forming candle
   datetime M1Time0;
   double M1Open0;
   double M1High0;
   double M1Low0;
   double M1Close0;

   // M1 closed candles
   datetime M1Time1;
   double M1Open1;
   double M1High1;
   double M1Low1;
   double M1Close1;

   datetime M1Time2;
   double M1Open2;
   double M1High2;
   double M1Low2;
   double M1Close2;

   datetime M1Time3;
   double M1Open3;
   double M1High3;
   double M1Low3;
   double M1Close3;

   datetime M1Time4;
   double M1Open4;
   double M1High4;
   double M1Low4;
   double M1Close4;

   datetime M1Time5;
   double M1Open5;
   double M1High5;
   double M1Low5;
   double M1Close5;
   //--------------------------------------------------
   // Signal Decision Snapshot
   //--------------------------------------------------

   bool BuyAllowed;
   bool SellAllowed;

   bool BuyBlockTrend;
   bool BuyBlockEMA;
   bool BuyBlockRSI;
   bool BuyBlockVolume;
   bool BuyBlockCandle;
   bool BuyBlockNearHigh;
   bool BuyBlockNearLow;

   bool SellBlockTrend;
   bool SellBlockEMA;
   bool SellBlockRSI;
   bool SellBlockVolume;
   bool SellBlockCandle;
   bool SellBlockNearHigh;
   bool SellBlockNearLow;
   //--------------------------------------------------
// Market Phase Diagnostics
//--------------------------------------------------

ENUM_PHX_MARKET_PHASE MarketPhase;

bool BuyExhaustionRisk;
bool SellExhaustionRisk;

int M1BullSequence;
int M1BearSequence;

double RSIChange;
double EMASlopeChange;
   //--------------------------------------------------
   // Market Context
   //--------------------------------------------------
   ENUM_PHX_TREND Trend;
   int Score;
   //===============================================================
   // MULTI TIMEFRAME ALIGNMENT CONTEXT
   //===============================================================
   int MTFScore;
   int HigherTFTrend;
   int SignalTFTrend;
   int EntryTFTrend;
   double EntryEMASlope;
   double EntryEMADistance;
   //===============================================================
   // TREND SCORE COMPONENTS
   //===============================================================
   int EMAScore;
   int ATRScore;
   int RSIScore;
   int VolumeScore;
   int ADXScore;
   int MarketScore;
   //--------------------------------------------------
   // Local Indicators
   //
   // ATR here remains the existing local ATR.
   // It is retained for research diagnostics only.
   //--------------------------------------------------
   double RSI;
   //--------------------------------------------------
   // RSI Exit Research
   //--------------------------------------------------
   bool RSIExit70;
   bool RSIExit75;
   bool RSIExit78;
   double ADX;
   double ATR;
   //--------------------------------------------------
   // D1 Energy Context
   //
   // These values describe the D1 energy state
   // AT THE MOMENT THE SIGNAL WAS RECORDED.
   //--------------------------------------------------
   // Technical expected D1 range
   double DailyATR;
   // Actual High-Low range already travelled today
   double CurrentD1Range;
   // Percentage of expected D1 range already used
   double EnergyUsedPercent;
   // Percentage of expected D1 range still remaining
   double EnergyLeftPercent;
   //--------------------------------------------------
// PPO Divergence Research Context
//--------------------------------------------------

bool
   HasDivergence;

ENUM_PHX_DIVERGENCE_TYPE
   DivergenceType;

ENUM_PHX_DIVERGENCE_CONTEXT
   DivergenceContext;


//--------------------------------------------------
// Divergence Geometry
//--------------------------------------------------

double
   DivergencePriceDeltaNorm;

double
   DivergencePPODeltaNorm;

int
   DivergenceMatchOffset1Bars;

int
   DivergenceMatchOffset2Bars;


//--------------------------------------------------
// Divergence Confirmation Profile
//--------------------------------------------------

bool
   DivergenceProfileValid;

double
   DivergenceRSI;

double
   DivergenceADX;

ENUM_PHX_SERIES_DIRECTION
   DivergenceADXDirection;

double
   DivergenceRelativeVolume;

ENUM_PHX_SERIES_DIRECTION
   DivergenceVolumeDirection;


//--------------------------------------------------
// Divergence Structure Confirmation
//--------------------------------------------------

bool
   DivergenceStructureConfirmed;

double
   DivergenceBreakDistanceNorm;

int
   DivergenceConfirmationDelayBars;
   //--------------------------------------------------
   // Future Price Tracking
   //--------------------------------------------------
   double PriceAfter5;
   double PriceAfter10;
   double PriceAfter20;
   //--------------------------------------------------
   // Result
   //--------------------------------------------------
   double Change5;
   double Change10;
   double Change20;
   //--------------------------------------------------
   // State
   //--------------------------------------------------
   bool Completed5;
   bool Completed10;
   bool Completed20;
   //--------------------------------------------------
   // Reset
   //--------------------------------------------------
   void Reset()
   {
      //--------------------------------------------------
      // Basic
      //--------------------------------------------------
      Time = 0;
      Symbol = "";
      ResearchTF =
      PERIOD_CURRENT;
      //--------------------------------------------------
      // Signal
      //--------------------------------------------------
      Signal =
         PHX_SIGNAL_NONE;
      EntryPrice =
         0.0;
      Ticket = 0;   
     //--------------------------------------------------
     // Execution Quality Context
     //--------------------------------------------------
      CandlePosition =
         0.5;
      ExecutionDelayMS =
          0;
      PriceVsCandleHigh =
          0.0;
      //--------------------------------------------------
      // Entry Market Snapshot
      //--------------------------------------------------

      M5Time = 0;
      M5Open = 0.0;
      M5High = 0.0;
      M5Low = 0.0;
      M5Close = 0.0;
      M5Range = 0.0;

      M1Time0 = 0;
      M1Open0 = 0.0;
      M1High0 = 0.0;
      M1Low0 = 0.0;
      M1Close0 = 0.0;

      M1Time1 = 0;
      M1Open1 = 0.0;
      M1High1 = 0.0;
      M1Low1 = 0.0;
      M1Close1 = 0.0;

      M1Time2 = 0;
      M1Open2 = 0.0;
      M1High2 = 0.0;
      M1Low2 = 0.0;
      M1Close2 = 0.0;

      M1Time3 = 0;
      M1Open3 = 0.0;
      M1High3 = 0.0;
      M1Low3 = 0.0;
      M1Close3 = 0.0;

      M1Time4 = 0;
      M1Open4 = 0.0;
      M1High4 = 0.0;
      M1Low4 = 0.0;
      M1Close4 = 0.0;

      M1Time5 = 0;
      M1Open5 = 0.0;
      M1High5 = 0.0;
      M1Low5 = 0.0;
      M1Close5 = 0.0; 
      //--------------------------------------------------
      // Signal Decision Snapshot
      //--------------------------------------------------

      BuyAllowed = false;
      SellAllowed = false;

      BuyBlockTrend = false;
      BuyBlockEMA = false;
      BuyBlockRSI = false;
      BuyBlockVolume = false;
      BuyBlockCandle = false;
      BuyBlockNearHigh = false;
      BuyBlockNearLow = false;

      SellBlockTrend = false;
      SellBlockEMA = false;
      SellBlockRSI = false;
      SellBlockVolume = false;
      SellBlockCandle = false;
      SellBlockNearHigh = false;
      SellBlockNearLow = false;
      //--------------------------------------------------
      // Market Phase Diagnostics
      //--------------------------------------------------

      MarketPhase =
      0;

      BuyExhaustionRisk =
      false;

      SellExhaustionRisk =
      false;

      M1BullSequence =
      0;

      M1BearSequence =
      0;

      RSIChange =
      0.0;

      EMASlopeChange =
      0.0; 
      //--------------------------------------------------
      // Market Context
      //--------------------------------------------------
      Trend =
      PHX_TREND_UNKNOWN;
      Score =
      0;
      //--------------------------------------------------
      // Multi Timeframe Alignment
      //--------------------------------------------------
      MTFScore =
      0;
      HigherTFTrend =
      0;
      SignalTFTrend =
      0;
      EntryTFTrend =
      0;
      EntryEMASlope =
      0.0;
      EntryEMADistance =
      0.0;
      //===============================================================
      // TREND SCORE COMPONENTS
      //===============================================================
      EMAScore =
      0;
      ATRScore =
      0;
      RSIScore =
      0;
      VolumeScore =
      0;
      ADXScore =
      0;
      MarketScore =
      0;
      //--------------------------------------------------
      // Local Indicators
      //--------------------------------------------------
      RSI =
         0.0;
      RSIExit70 = false;
      RSIExit75 = false;
      RSIExit78 = false;   
      ADX =
         0.0;
      ATR =
         0.0;
      //--------------------------------------------------
      // D1 Energy Context
      //--------------------------------------------------
      DailyATR =
         0.0;
      CurrentD1Range =
         0.0;
      EnergyUsedPercent =
         0.0;
      EnergyLeftPercent =
         0.0;
         
     //--------------------------------------------------
     // PPO Divergence Research Context
     //-------------------------------------------------- 
      HasDivergence =
      false;
      DivergenceType =
      PHX_DIVERGENCE_NONE;
      DivergenceContext =
      PHX_DIVERGENCE_CONTEXT_NEUTRAL;
      //--------------------------------------------------
      // Divergence Geometry
      //--------------------------------------------------

      DivergencePriceDeltaNorm =
      0.0;

      DivergencePPODeltaNorm =
      0.0;

      DivergenceMatchOffset1Bars =
      0;

      DivergenceMatchOffset2Bars =
      0;


      //--------------------------------------------------
      // Divergence Confirmation Profile
      //--------------------------------------------------

      DivergenceProfileValid =
      false;

      DivergenceRSI =
      0.0;

      DivergenceADX =
      0.0;

      DivergenceADXDirection =
      PHX_SERIES_DIRECTION_FLAT;

      DivergenceRelativeVolume =
      0.0;

      DivergenceVolumeDirection =
      PHX_SERIES_DIRECTION_FLAT;


      //--------------------------------------------------
      // Divergence Structure Confirmation
      //--------------------------------------------------

      DivergenceStructureConfirmed =
      false;

      DivergenceBreakDistanceNorm =
      0.0;

      DivergenceConfirmationDelayBars =
      0;    
      //--------------------------------------------------
      // Future Price Tracking
      //--------------------------------------------------
      PriceAfter5 =
         0.0;
      PriceAfter10 =
         0.0;
      PriceAfter20 =
         0.0;
      //--------------------------------------------------
      // Result
      //--------------------------------------------------
      Change5 =
         0.0;
      Change10 =
         0.0;
      Change20 =
         0.0;
      //--------------------------------------------------
      // State
      //--------------------------------------------------
      Completed5 =
         false;
      Completed10 =
         false;
      Completed20 =
         false;
   }
};

#endif
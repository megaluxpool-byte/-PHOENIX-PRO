#ifndef PHX_SIGNAL_QUALITY_TRACKER_MQH
#define PHX_SIGNAL_QUALITY_TRACKER_MQH


//--------------------------------------------------
// Includes
//--------------------------------------------------

#include "PHXSignalQualityTypes.mqh"
#include "../Signal/PHXSignalTypes.mqh"
#include "../Indicators/PHXMTFAlignment.mqh"
#include "PHXTrendStatisticsTypes.mqh"
#include "PHXResearchJournal.mqh"

//+------------------------------------------------------------------+
//| Signal Quality Tracker                                           |
//+------------------------------------------------------------------+

class CPHXSignalQualityTracker
{
private:

  //===============================================================
  // PRIVATE MEMBERS
  //===============================================================
   CPHXMTFAlignment* m_mtfAlignment;
   //--------------------------------------------------
   // Quality Records
   //--------------------------------------------------
   SPHXSignalQualityRecord m_records[10000];
   int m_count;
   //--------------------------------------------------
   // Research Journal
   //--------------------------------------------------

   CPHXResearchJournal m_researchJournal;
   //--------------------------------------------------
   // Market Phase State
   //--------------------------------------------------

   double m_previousRSI;

   double m_previousEMASlope;

public:
//--------------------------------------------------
// Configure MTF Alignment
//--------------------------------------------------
void SetMTFAlignment(
   CPHXMTFAlignment* service
)
{
   m_mtfAlignment = service;
}

//--------------------------------------------------
// Add Confirmed Divergence Research Observation
//--------------------------------------------------
bool AddConfirmedDivergence(
   const SPHXDivergenceResult &divergence,
   const SPHXDivergenceConfirmationProfile &profile,
   const SPHXDivergenceConfirmation &confirmation,
   const ENUM_TIMEFRAMES researchTF
)

{
   //--------------------------------------------------
   // Capacity
   //--------------------------------------------------

   if(m_count >= 10000)
      return false;


   //--------------------------------------------------
   // Validate Divergence
   //--------------------------------------------------

   if(!divergence.Valid)
      return false;

   if(
      divergence.Status !=
      PHX_DIVERGENCE_STATUS_CONFIRMED
   )
      return false;

   if(
      divergence.Type !=
         PHX_DIVERGENCE_REGULAR_BULLISH
      &&
      divergence.Type !=
         PHX_DIVERGENCE_REGULAR_BEARISH
      &&
      divergence.Type !=
         PHX_DIVERGENCE_HIDDEN_BULLISH
      &&
      divergence.Type !=
         PHX_DIVERGENCE_HIDDEN_BEARISH
   )
      return false;

   if(!confirmation.Confirmed)
      return false;


   //--------------------------------------------------
   // Research Record
   //--------------------------------------------------
   SPHXSignalQualityRecord record;
   record.Reset();
   //--------------------------------------------------
   // Basic
   //--------------------------------------------------
   record.Time =
   confirmation.BreakTime;

   record.Symbol =
   _Symbol;

   record.ResearchTF =
   researchTF;

   record.EntryPrice =
   confirmation.BreakPrice;
   //--------------------------------------------------
   // Research Direction
   //--------------------------------------------------
   if(
      divergence.Type ==
         PHX_DIVERGENCE_REGULAR_BULLISH
      ||
      divergence.Type ==
         PHX_DIVERGENCE_HIDDEN_BULLISH
   )
   {
      record.Signal =
         PHX_SIGNAL_BUY;
   }
   else
   {
      record.Signal =
         PHX_SIGNAL_SELL;
   }
   //--------------------------------------------------
   // PPO Divergence Context
   //--------------------------------------------------
   record.HasDivergence =
      true;

   record.DivergenceType =
      divergence.Type;

   record.DivergenceContext =
      divergence.Context;
   //--------------------------------------------------
   // Divergence Geometry
   //--------------------------------------------------
   record.DivergencePriceDeltaNorm =
      divergence.PriceDeltaNorm;

   record.DivergencePPODeltaNorm =
      divergence.PPODeltaNorm;

   record.DivergenceMatchOffset1Bars =
      divergence.First.MatchOffsetBars;

   record.DivergenceMatchOffset2Bars =
      divergence.Second.MatchOffsetBars;
   //--------------------------------------------------
   // Confirmation Profile
   //--------------------------------------------------
   record.DivergenceProfileValid =
      profile.Valid;

   record.DivergenceRSI =
      profile.RSI;

   record.DivergenceADX =
      profile.ADXLevel;

   record.DivergenceADXDirection =
      profile.ADXDirection;

   record.DivergenceRelativeVolume =
      profile.RelativeVolume;

   record.DivergenceVolumeDirection =
      profile.VolumeDirection;
   //--------------------------------------------------
   // Structure Confirmation
   //--------------------------------------------------
   record.DivergenceStructureConfirmed =
      confirmation.Confirmed;

   record.DivergenceBreakDistanceNorm =
      confirmation.BreakDistanceNorm;

   record.DivergenceConfirmationDelayBars =
      confirmation.ConfirmationDelayBars;
   //--------------------------------------------------
   // Store
   //--------------------------------------------------
   m_records[m_count] =
      record;

   m_count++;
   //--------------------------------------------------
   // Diagnostics
   //--------------------------------------------------

   Print(
      "PHX QUALITY TRACKER DIVERGENCE: ",
      "Type=",
      (int)record.DivergenceType,
      " Context=",
      (int)record.DivergenceContext,
      " Signal=",
      (int)record.Signal,
      " Price=",
      DoubleToString(
         record.EntryPrice,
         _Digits
      ),
      " ProfileValid=",
      record.DivergenceProfileValid,
      " BreakNorm=",
      DoubleToString(
         record.DivergenceBreakDistanceNorm,
         3
      ),
      " Count=",
      m_count
   );


   return true;
}
//--------------------------------------------------
// Add Decision Snapshot
//
// Research-only.
// Does NOT add record to m_records[].
// Does NOT wait for +5/+10/+20.
// Writes immediately to PHXResearchEntryJournal.
//--------------------------------------------------
bool AddDecisionSnapshot(
   const SPHXSignal &signal,
   const SPHXTrendSnapshot &snapshot,
   double dailyATR,
   double currentD1Range,
   double energyUsedPercent,
   double energyLeftPercent
)
{
   SPHXSignalQualityRecord record;
   record.Reset();

   //--------------------------------------------------
   // Basic
   //--------------------------------------------------

   record.Time =
      signal.time;

   record.Symbol =
      _Symbol;

   record.ResearchTF =
      _Period;

   //--------------------------------------------------
   // Decision state
   //--------------------------------------------------

   record.Signal =
      signal.signal;

   record.EntryPrice =
      signal.price;

   record.BuyAllowed =
      signal.BuyAllowed;

   record.SellAllowed =
      signal.SellAllowed;

   record.BuyBlockTrend =
      signal.BuyBlockTrend;

   record.BuyBlockEMA =
      signal.BuyBlockEMA;

   record.BuyBlockRSI =
      signal.BuyBlockRSI;

   record.BuyBlockVolume =
      signal.BuyBlockVolume;

   record.BuyBlockCandle =
      signal.BuyBlockCandle;

   record.BuyBlockNearHigh =
      signal.BuyBlockNearHigh;

   record.BuyBlockNearLow =
      signal.BuyBlockNearLow;

   record.SellBlockTrend =
      signal.SellBlockTrend;

   record.SellBlockEMA =
      signal.SellBlockEMA;

   record.SellBlockRSI =
      signal.SellBlockRSI;

   record.SellBlockVolume =
      signal.SellBlockVolume;

   record.SellBlockCandle =
      signal.SellBlockCandle;

   record.SellBlockNearHigh =
      signal.SellBlockNearHigh;

   record.SellBlockNearLow =
      signal.SellBlockNearLow;

   //--------------------------------------------------
   // Indicators / context
   //--------------------------------------------------

   record.Trend =
      snapshot.Trend;

   record.Score =
      snapshot.Score.Total;

   record.EMAScore =
      snapshot.Score.EMA.Total;

   record.ATRScore =
      snapshot.Score.ATR.Total;

   record.RSIScore =
      snapshot.Score.RSI.Total;

   record.VolumeScore =
      snapshot.Score.Volume.Total;

   record.ADXScore =
      snapshot.Score.ADX.Total;

   record.MarketScore =
      snapshot.Score.Market.Total;

   record.RSI =
      snapshot.RSI;

   record.ADX =
      snapshot.ADX;

   record.ATR =
      snapshot.ATR;

   record.RSIExit70 =
      signal.RSIExit70;

   record.RSIExit75 =
      signal.RSIExit75;

   record.RSIExit78 =
      signal.RSIExit78;

   //--------------------------------------------------
   // D1 Energy Context
   //--------------------------------------------------

   record.DailyATR =
      dailyATR;

   record.CurrentD1Range =
      currentD1Range;

   record.EnergyUsedPercent =
      energyUsedPercent;

   record.EnergyLeftPercent =
      energyLeftPercent;

   //--------------------------------------------------
   // MTF Alignment
   //--------------------------------------------------

   if(m_mtfAlignment != NULL)
   {
      SPHXMTFAlignmentResult mtf;

      ENUM_PHX_MTF_DIRECTION direction;

      // Decision snapshot may still have Signal == NONE.
      // Evaluate the side which is currently allowed.
      if(signal.SellAllowed && !signal.BuyAllowed)
         direction = PHX_MTF_SELL;
      else
         direction = PHX_MTF_BUY;

      if(
         m_mtfAlignment.Calculate(
            record.Symbol,
            PERIOD_M15,
            PERIOD_M5,
            PERIOD_M1,
            direction,
            mtf
         )
      )
      {
         record.MTFScore =
            mtf.TotalScore;

         record.HigherTFTrend =
            mtf.HigherTrend;

         record.SignalTFTrend =
            mtf.SignalTrend;

         record.EntryTFTrend =
            mtf.EntryTrend;

         record.EntryEMASlope =
            mtf.EntryEMASlope;

         record.EntryEMADistance =
            mtf.EntryEMADistance;
      }
   }

   //--------------------------------------------------
   // M5 current/forming candle
   //--------------------------------------------------

   MqlRates m5Rates[1];

   if(
      CopyRates(
         _Symbol,
         PERIOD_M5,
         0,
         1,
         m5Rates
      ) == 1
   )
   {
      record.M5Time =
         m5Rates[0].time;

      record.M5Open =
         m5Rates[0].open;

      record.M5High =
         m5Rates[0].high;

      record.M5Low =
         m5Rates[0].low;

      record.M5Close =
         m5Rates[0].close;

      record.M5Range =
         m5Rates[0].high -
         m5Rates[0].low;
   }

   //--------------------------------------------------
   // M1 current + five closed candles
   //--------------------------------------------------

   MqlRates m1Rates[6];

   if(
      CopyRates(
         _Symbol,
         PERIOD_M1,
         0,
         6,
         m1Rates
      ) == 6
   )
   {
      record.M1Time0  = m1Rates[5].time;
      record.M1Open0  = m1Rates[5].open;
      record.M1High0  = m1Rates[5].high;
      record.M1Low0   = m1Rates[5].low;
      record.M1Close0 = m1Rates[5].close;

      record.M1Time1  = m1Rates[4].time;
      record.M1Open1  = m1Rates[4].open;
      record.M1High1  = m1Rates[4].high;
      record.M1Low1   = m1Rates[4].low;
      record.M1Close1 = m1Rates[4].close;

      record.M1Time2  = m1Rates[3].time;
      record.M1Open2  = m1Rates[3].open;
      record.M1High2  = m1Rates[3].high;
      record.M1Low2   = m1Rates[3].low;
      record.M1Close2 = m1Rates[3].close;

      record.M1Time3  = m1Rates[2].time;
      record.M1Open3  = m1Rates[2].open;
      record.M1High3  = m1Rates[2].high;
      record.M1Low3   = m1Rates[2].low;
      record.M1Close3 = m1Rates[2].close;

      record.M1Time4  = m1Rates[1].time;
      record.M1Open4  = m1Rates[1].open;
      record.M1High4  = m1Rates[1].high;
      record.M1Low4   = m1Rates[1].low;
      record.M1Close4 = m1Rates[1].close;

      record.M1Time5  = m1Rates[0].time;
      record.M1Open5  = m1Rates[0].open;
      record.M1High5  = m1Rates[0].high;
      record.M1Low5   = m1Rates[0].low;
      record.M1Close5 = m1Rates[0].close;
   }
   
 //--------------------------------------------------
// RSI Dynamics
//--------------------------------------------------

record.RSIChange =
   record.RSI -
   m_previousRSI;

m_previousRSI =
   record.RSI; 
   
record.EMASlopeChange =
   record.EntryEMASlope -
   m_previousEMASlope;

m_previousEMASlope =
   record.EntryEMASlope;    
//--------------------------------------------------
// Market Phase Diagnostics v2
//--------------------------------------------------

record.MarketPhase =
   PHX_PHASE_UNKNOWN;

record.BuyExhaustionRisk =
   false;

record.SellExhaustionRisk =
   false;


//--------------------------------------------------
// M1 direction
//--------------------------------------------------

bool m1Bullish =
(
   record.M1Close1 > record.M1Close2 &&
   record.M1Close2 >= record.M1Close3
);


bool m1Bearish =
(
   record.M1Close1 < record.M1Close2 &&
   record.M1Close2 <= record.M1Close3
);


//--------------------------------------------------
// Early bearish reversal
//--------------------------------------------------

if(
   record.Trend > 0 &&
   m1Bearish &&
   (
      record.RSIChange < 0.0 ||
      record.EMASlopeChange < 0.0
   )
)
{
   record.MarketPhase =
      PHX_PHASE_EARLY_BEAR_REVERSAL;

   record.SellExhaustionRisk =
      true;
}


//--------------------------------------------------
// Early bullish reversal
//--------------------------------------------------

if(
   record.Trend < 0 &&
   m1Bullish &&
   (
      record.RSIChange > 0.0 ||
      record.EMASlopeChange > 0.0
   )
)
{
   record.MarketPhase =
      PHX_PHASE_EARLY_BULL_REVERSAL;

   record.BuyExhaustionRisk =
      true;
}


//--------------------------------------------------
// Normal trend
//--------------------------------------------------

if(
   record.MarketPhase ==
   PHX_PHASE_UNKNOWN
)
{
   if(
      record.Trend > 0 &&
      record.M1BullSequence >= 2
   )
   {
      record.MarketPhase =
         PHX_PHASE_TREND_UP;
   }


   if(
      record.Trend < 0 &&
      record.M1BearSequence >= 2
   )
   {
      record.MarketPhase =
         PHX_PHASE_TREND_DOWN;
   }
}
   //--------------------------------------------------
   // Immediate Research Journal
   //--------------------------------------------------

   if(
      !m_researchJournal.WriteEntrySnapshot(
         record
      )
   )
   {
      Print(
         "PHX QUALITY TRACKER ERROR: ",
         "Entry snapshot write failed"
      );

      return false;
   }

   return true;
}
//--------------------------------------------------
// Add Signal From Snapshot
//--------------------------------------------------
bool AddSignal(
   const SPHXSignal &signal,
   const SPHXTrendSnapshot &snapshot,
   double dailyATR,
   double currentD1Range,
   double energyUsedPercent,
   double energyLeftPercent
)
{
Print(
 "PHX ADD SIGNAL: ",
 "Time=",
 TimeToString(signal.time),
 " CountBefore=",
 IntegerToString(m_count)
);
   if(m_count >= 10000)
      return false;
   SPHXSignalQualityRecord record;
   record.Reset();
   //--------------------------------------------------
   // Basic
   //--------------------------------------------------
   record.Time =
      signal.time;
   record.Symbol =
      _Symbol;
   record.ResearchTF =
   _Period;   
   //--------------------------------------------------
   // Signal
   //--------------------------------------------------
   record.Signal =
      signal.signal;
   record.EntryPrice =
      signal.price;
   //--------------------------------------------------
   // Market Context
   //--------------------------------------------------
   record.Trend =
      snapshot.Trend;
   record.Score =
      snapshot.Score.Total;
      
   //--------------------------------------------------
   // Multi Timeframe Alignment
   //--------------------------------------------------

if(m_mtfAlignment != NULL)
{
   SPHXMTFAlignmentResult mtf;
   ENUM_PHX_MTF_DIRECTION direction;
   if(record.Signal == PHX_SIGNAL_BUY)
      direction = PHX_MTF_BUY;
   else
      direction = PHX_MTF_SELL;
   if(
      m_mtfAlignment.Calculate(
         record.Symbol,
         PERIOD_M15,
         PERIOD_M5,
         PERIOD_M1,
         direction,
         mtf
      )
   )
   {
      record.MTFScore =
         mtf.TotalScore;
      record.HigherTFTrend =
         mtf.HigherTrend;
      record.SignalTFTrend =
         mtf.SignalTrend;
      record.EntryTFTrend =
         mtf.EntryTrend;
      record.EntryEMASlope =
         mtf.EntryEMASlope;
      record.EMASlopeChange =
      record.EntryEMASlope -
      m_previousEMASlope;
      m_previousEMASlope =
      record.EntryEMASlope;    
      record.EntryEMADistance =
         mtf.EntryEMADistance;
   }
} 
//--------------------------------------------------
// MTF Alignment Diagnostics
//--------------------------------------------------

Print(
   "PHX MTF ALIGNMENT: ",
   "Signal=",
   IntegerToString(record.Signal),
   " M15=",
   IntegerToString(record.HigherTFTrend),
   " M5=",
   IntegerToString(record.SignalTFTrend),
   " M1=",
   IntegerToString(record.EntryTFTrend),
   " Slope=",
   DoubleToString(record.EntryEMASlope,6),
   " Distance=",
   DoubleToString(record.EntryEMADistance,6),
   " Score=",
   IntegerToString(record.MTFScore)
);
   //===============================================================
   // TREND SCORE COMPONENTS
   //===============================================================
   record.EMAScore =
   snapshot.Score.EMA.Total;

   record.ATRScore =
   snapshot.Score.ATR.Total;

   record.RSIScore =
   snapshot.Score.RSI.Total;

   record.VolumeScore =
   snapshot.Score.Volume.Total;

   record.ADXScore =
   snapshot.Score.ADX.Total;

   record.MarketScore =
   snapshot.Score.Market.Total;
   //--------------------------------------------------
   // Local Indicators
   //--------------------------------------------------
   record.RSI =
      snapshot.RSI;
      
   //--------------------------------------------------
   // RSI / EMA slope dynamics
   //--------------------------------------------------

record.RSIChange =
   record.RSI -
   m_previousRSI;

m_previousRSI =
   record.RSI;   
   //--------------------------------------------------
   // RSI Exit Research
   //--------------------------------------------------
   record.RSIExit70 =
   signal.RSIExit70;

   record.RSIExit75 =
   signal.RSIExit75;

   record.RSIExit78 =
   signal.RSIExit78;
   
   //--------------------------------------------------
   // Signal Decision Snapshot
   //--------------------------------------------------

   record.BuyAllowed =
   signal.BuyAllowed;

   record.SellAllowed =
   signal.SellAllowed;

   record.BuyBlockTrend =
   signal.BuyBlockTrend;

   record.BuyBlockEMA =
   signal.BuyBlockEMA;

   record.BuyBlockRSI =
   signal.BuyBlockRSI;

   record.BuyBlockVolume =
   signal.BuyBlockVolume;

   record.BuyBlockCandle =
   signal.BuyBlockCandle;

   record.BuyBlockNearHigh =
   signal.BuyBlockNearHigh;

   record.BuyBlockNearLow =
   signal.BuyBlockNearLow;

   record.SellBlockTrend =
   signal.SellBlockTrend;

   record.SellBlockEMA =
   signal.SellBlockEMA;

   record.SellBlockRSI =
   signal.SellBlockRSI;

   record.SellBlockVolume =
   signal.SellBlockVolume;

   record.SellBlockCandle =
   signal.SellBlockCandle;

   record.SellBlockNearHigh =
   signal.SellBlockNearHigh;

   record.SellBlockNearLow =
   signal.SellBlockNearLow;
   //--------------------------------------------------
   // Entry Market Snapshot
   // M5 current candle + M1 current and 5 closed candles
   //--------------------------------------------------

   MqlRates m5Rates[1];
   MqlRates m1Rates[6];

   //--- M5 current/forming candle
   if(CopyRates(_Symbol, PERIOD_M5, 0, 1, m5Rates) == 1)
   {
      record.M5Time =
         m5Rates[0].time;

      record.M5Open =
         m5Rates[0].open;

      record.M5High =
         m5Rates[0].high;

      record.M5Low =
         m5Rates[0].low;

      record.M5Close =
         m5Rates[0].close;

      record.M5Range =
         m5Rates[0].high - m5Rates[0].low;
   }

   //--- M1 current/forming candle + 5 previous closed candles
   
   if(CopyRates(_Symbol, PERIOD_M1, 0, 6, m1Rates) == 6)
{
   record.M1Time0  = m1Rates[5].time;
   record.M1Open0  = m1Rates[5].open;
   record.M1High0  = m1Rates[5].high;
   record.M1Low0   = m1Rates[5].low;
   record.M1Close0 = m1Rates[5].close;

   record.M1Time1  = m1Rates[4].time;
   record.M1Open1  = m1Rates[4].open;
   record.M1High1  = m1Rates[4].high;
   record.M1Low1   = m1Rates[4].low;
   record.M1Close1 = m1Rates[4].close;

   record.M1Time2  = m1Rates[3].time;
   record.M1Open2  = m1Rates[3].open;
   record.M1High2  = m1Rates[3].high;
   record.M1Low2   = m1Rates[3].low;
   record.M1Close2 = m1Rates[3].close;

   record.M1Time3  = m1Rates[2].time;
   record.M1Open3  = m1Rates[2].open;
   record.M1High3  = m1Rates[2].high;
   record.M1Low3   = m1Rates[2].low;
   record.M1Close3 = m1Rates[2].close;

   record.M1Time4  = m1Rates[1].time;
   record.M1Open4  = m1Rates[1].open;
   record.M1High4  = m1Rates[1].high;
   record.M1Low4   = m1Rates[1].low;
   record.M1Close4 = m1Rates[1].close;

   record.M1Time5  = m1Rates[0].time;
   record.M1Open5  = m1Rates[0].open;
   record.M1High5  = m1Rates[0].high;
   record.M1Low5   = m1Rates[0].low;
   record.M1Close5 = m1Rates[0].close;
}
      
   record.ADX =
      snapshot.ADX;
   record.ATR =
      snapshot.ATR;
   //--------------------------------------------------
   // D1 Energy Context
   //
   // IMPORTANT:
   // Values are frozen at signal creation time.
   //--------------------------------------------------
   record.DailyATR =
      dailyATR;
   record.CurrentD1Range =
      currentD1Range;
   record.EnergyUsedPercent =
      energyUsedPercent;
   record.EnergyLeftPercent =
      energyLeftPercent;
   //--------------------------------------------------
   // Store
   //--------------------------------------------------
   m_records[m_count] =
      record;
   m_count++;
   //--------------------------------------------------
   // Research diagnostics
   //--------------------------------------------------
   Print(
      "PHX QUALITY TRACKER D1: ",
      "Signal=",
      IntegerToString(record.Signal),
      " D1ATR=",
      DoubleToString(record.DailyATR,2),
      " D1Range=",
      DoubleToString(record.CurrentD1Range,2),
      " Used=",
      DoubleToString(record.EnergyUsedPercent,2),
      "%",
      " Left=",
      DoubleToString(record.EnergyLeftPercent,2),
      "%",
      " Count=",
      IntegerToString(m_count)
   );
   return true; 
}
//===============================================================
// CONSTRUCTOR
//===============================================================

CPHXSignalQualityTracker()
{
   m_count = 0;
   
   m_previousRSI =
   0.0;

   m_previousEMASlope =
   0.0;

   Reset();

   //--------------------------------------------------
   // Research Journal
   //--------------------------------------------------

   if(!m_researchJournal.Initialize())
   {
      Print(
         "PHX QUALITY TRACKER ERROR: Research Journal initialization failed"
      );
   }
}
   //--------------------------------------------------
   // Reset
   //--------------------------------------------------
   void Reset()
   {
      for(int i = 0; i < 10000; i++)
      {
         m_records[i].Reset();
      }
      m_count = 0;
   }
   //--------------------------------------------------
   // Add Signal
   //--------------------------------------------------
   bool AddSignal(
      const SPHXSignalQualityRecord &record
   )
   {
   Print(
 "PHX ADD RECORD: ",
 "Time=",
 TimeToString(record.Time),
 " CountBefore=",
 IntegerToString(m_count)
);
      if(m_count >= 10000)
         return false;
      m_records[m_count] = record;
      m_count++;
      return true;
   }
   //--------------------------------------------------
   // Add Signal With D1 Energy Context
   //--------------------------------------------------
   bool AddSignal(
   const SPHXSignal &signal,
   double dailyATR,
   double currentD1Range,
   double energyUsedPercent,
   double energyLeftPercent
)
{
Print(
 "PHX ADD SIGNAL: ",
 "Time=",
 TimeToString(signal.time),
 " CountBefore=",
 IntegerToString(m_count)
);
   if(m_count >= 10000)
      return false;
   SPHXSignalQualityRecord record;
   record.Reset();
   //--------------------------------------------------
   // Basic
   //--------------------------------------------------
   record.Time =
      signal.time;
   record.Symbol =
      _Symbol;
   record.ResearchTF =
   _Period;   
      
   //--------------------------------------------------
   // Signal
   //--------------------------------------------------
   record.Signal =
      signal.signal;
   record.EntryPrice =
      signal.price;
   //--------------------------------------------------
   // Indicators available directly in signal
   //--------------------------------------------------
   record.RSI =
      signal.rsi;
   record.ATR =
      signal.ATR;
   //--------------------------------------------------
   // D1 Energy Context
   //--------------------------------------------------
   record.DailyATR =
      dailyATR;
   record.CurrentD1Range =
      currentD1Range;
   record.EnergyUsedPercent =
      energyUsedPercent;
   record.EnergyLeftPercent =
      energyLeftPercent;
   //--------------------------------------------------
   // Store
   //--------------------------------------------------
   m_records[m_count] =
      record;
   m_count++;
   Print(
      "##################################################"
   );
   Print(
      "          PHX QUALITY TRACKER SIGNAL"
   );
   Print(
      "Signal=",
      IntegerToString(record.Signal),
      " Price=",
      DoubleToString(
         record.EntryPrice,
         _Digits
      ),
      " RSI=",
      DoubleToString(
         record.RSI,
         2
      ),
      " ATR=",
      DoubleToString(
         record.ATR,
         3
      ),
      " Count=",
      IntegerToString(m_count)
   );
   Print(
   "PHX QUALITY TRACKER CONTEXT: ",
   "ADX=",
   DoubleToString(
      record.ADX,
      2
   ),
   " Trend=",
   IntegerToString(
      (int)record.Trend
   ),
   " Score=",
   IntegerToString(
      record.Score
   )
);
   Print(
      "PHX QUALITY TRACKER D1: ",
      "D1ATR=",
      DoubleToString(
         record.DailyATR,
         3
      ),
      " D1Range=",
      DoubleToString(
         record.CurrentD1Range,
         3
      ),
      " Used=",
      DoubleToString(
         record.EnergyUsedPercent,
         2
      ),
      "%",
      " Left=",
      DoubleToString(
         record.EnergyLeftPercent,
         2
      ),
      "%"
   );
   Print(
      "##################################################"
   );
   return true;
}
   //--------------------------------------------------
   // Add Signal From PHX Signal
   //--------------------------------------------------
   bool AddSignal(
   const SPHXSignal &signal
)
{
Print(
 "PHX ADD SIGNAL: ",
 "Time=",
 TimeToString(signal.time),
 " CountBefore=",
 IntegerToString(m_count)
);
   if(m_count >= 10000)
      return false;
   SPHXSignalQualityRecord record;
   record.Reset();  
   //--------------------------------------------------
   // Basic
   //--------------------------------------------------
   record.Time =
      signal.time;

   record.Symbol =
      _Symbol;
      
   record.ResearchTF =
   _Period;   
   //--------------------------------------------------
   // Signal
   //--------------------------------------------------
   record.Signal =
      signal.signal;
   record.EntryPrice =
      signal.price;
   //--------------------------------------------------
   // Indicators
   //--------------------------------------------------
   record.RSI =
      signal.rsi;
 
      
   record.ATR =
      signal.ATR; 
   //--------------------------------------------------
   // MTF Alignment Diagnostics
   //--------------------------------------------------
Print(
   "PHX MTF ALIGNMENT: ",
   "Signal=",
   IntegerToString(
      record.Signal
   ),
   " M15=",
   IntegerToString(
      record.HigherTFTrend
   ),
   " M5=",
   IntegerToString(
      record.SignalTFTrend
   ),
   " M1=",
   IntegerToString(
      record.EntryTFTrend
   ),
   " Slope=",
   DoubleToString(
      record.EntryEMASlope,
      6
   ),
   " Distance=",
   DoubleToString(
      record.EntryEMADistance,
      6
   ),
   " Score=",
   IntegerToString(
      record.MTFScore
   )
);      
   //--------------------------------------------------
   // Store
   //--------------------------------------------------
   m_records[m_count] =
      record;
   m_count++;
   Print(
   "##################################################"
);
Print(
   "          PHX QUALITY TRACKER SIGNAL"
);
Print(
   "Signal=",
   IntegerToString(record.Signal),
   " Price=",
   DoubleToString(record.EntryPrice,_Digits),
   " RSI=",
   DoubleToString(record.RSI,2),
   " ATR=",
   DoubleToString(record.ATR,3),
   " Count=",
   IntegerToString(m_count)
);
Print(
   "##################################################"
);
   return true;
}
   //--------------------------------------------------
   // Count
   //--------------------------------------------------
   int Count() const
   {
      return m_count;
   }
   //--------------------------------------------------
   // Get Record
   //--------------------------------------------------
   bool GetRecord(
      int index,
      SPHXSignalQualityRecord &record
   ) const
   {
      if(index < 0 ||
         index >= m_count)
         return false;
      record =
         m_records[index];
      return true;
   }
   //--------------------------------------------------
   // Print Quality Summary
   //--------------------------------------------------
   void PrintSummary()
{
   int buySignals  = 0;
   int sellSignals = 0;

   int buy5Count   = 0;
   int buy10Count  = 0;
   int buy20Count  = 0;

   int sell5Count  = 0;
   int sell10Count = 0;
   int sell20Count = 0;

   int buy5Wins    = 0;
   int buy10Wins   = 0;
   int buy20Wins   = 0;

   int sell5Wins   = 0;
   int sell10Wins  = 0;
   int sell20Wins  = 0;

   double buy5Sum   = 0.0;
   double buy10Sum  = 0.0;
   double buy20Sum  = 0.0;

   double sell5Sum  = 0.0;
   double sell10Sum = 0.0;
   double sell20Sum = 0.0;
   //--------------------------------------------------
   // Collect statistics
   //--------------------------------------------------
   for(int i = 0; i < m_count; i++)
   {
      //--------------------------------------------------
      // BUY
      //--------------------------------------------------
      if(m_records[i].Signal == PHX_SIGNAL_BUY)
      {
         buySignals++;

         if(m_records[i].Completed5)
         {
            buy5Count++;
            buy5Sum += m_records[i].Change5;

            if(m_records[i].Change5 > 0.0)
               buy5Wins++;
         }
         if(m_records[i].Completed10)
         {
            buy10Count++;
            buy10Sum += m_records[i].Change10;

            if(m_records[i].Change10 > 0.0)
               buy10Wins++;
         }
         if(m_records[i].Completed20)
         {
            buy20Count++;
            buy20Sum += m_records[i].Change20;

            if(m_records[i].Change20 > 0.0)
               buy20Wins++;
         }
      }

      //--------------------------------------------------
      // SELL
      //--------------------------------------------------
      if(m_records[i].Signal == PHX_SIGNAL_SELL)
      {
         sellSignals++;
         if(m_records[i].Completed5)
         {
            sell5Count++;
            sell5Sum += m_records[i].Change5;

            if(m_records[i].Change5 > 0.0)
               sell5Wins++;
         }
         if(m_records[i].Completed10)
         {
            sell10Count++;
            sell10Sum += m_records[i].Change10;

            if(m_records[i].Change10 > 0.0)
               sell10Wins++;
         }
         if(m_records[i].Completed20)
         {
            sell20Count++;
            sell20Sum += m_records[i].Change20;

            if(m_records[i].Change20 > 0.0)
               sell20Wins++;
         }
      }
   }

   //--------------------------------------------------
   // Calculate BUY statistics
   //--------------------------------------------------
   double buy5WinRate =
      (buy5Count > 0)
      ? ((double)buy5Wins / buy5Count) * 100.0
      : 0.0;
   double buy10WinRate =
      (buy10Count > 0)
      ? ((double)buy10Wins / buy10Count) * 100.0
      : 0.0;
   double buy20WinRate =
      (buy20Count > 0)
      ? ((double)buy20Wins / buy20Count) * 100.0
      : 0.0;
   double buy5Average =
      (buy5Count > 0)
      ? buy5Sum / buy5Count
      : 0.0;
   double buy10Average =
      (buy10Count > 0)
      ? buy10Sum / buy10Count
      : 0.0;
   double buy20Average =
      (buy20Count > 0)
      ? buy20Sum / buy20Count
      : 0.0;
   //--------------------------------------------------
   // Calculate SELL statistics
   //--------------------------------------------------
   double sell5WinRate =
      (sell5Count > 0)
      ? ((double)sell5Wins / sell5Count) * 100.0
      : 0.0;
   double sell10WinRate =
      (sell10Count > 0)
      ? ((double)sell10Wins / sell10Count) * 100.0
      : 0.0;
   double sell20WinRate =
      (sell20Count > 0)
      ? ((double)sell20Wins / sell20Count) * 100.0
      : 0.0;
   double sell5Average =
      (sell5Count > 0)
      ? sell5Sum / sell5Count
      : 0.0;

   double sell10Average =
      (sell10Count > 0)
      ? sell10Sum / sell10Count
      : 0.0;
   double sell20Average =
      (sell20Count > 0)
      ? sell20Sum / sell20Count
      : 0.0;
   //--------------------------------------------------
   // Report
   //--------------------------------------------------
   Print(
      "##################################################"
   );
   Print(
      "          PHX QUALITY SUMMARY"
   );
   Print(
      "Total Records=",
      IntegerToString(m_count)
   );
   Print(
      "BUY Signals=",
      IntegerToString(buySignals)
   );
   Print(
      "BUY +5: Completed=",
      IntegerToString(buy5Count),
      " Wins=",
      IntegerToString(buy5Wins),
      " WinRate=",
      DoubleToString(buy5WinRate,1),
      "% AvgChange=",
      DoubleToString(buy5Average,_Digits)
   );
   Print(
      "BUY +10: Completed=",
      IntegerToString(buy10Count),
      " Wins=",
      IntegerToString(buy10Wins),
      " WinRate=",
      DoubleToString(buy10WinRate,1),
      "% AvgChange=",
      DoubleToString(buy10Average,_Digits)
   );
   Print(
      "BUY +20: Completed=",
      IntegerToString(buy20Count),
      " Wins=",
      IntegerToString(buy20Wins),
      " WinRate=",
      DoubleToString(buy20WinRate,1),
      "% AvgChange=",
      DoubleToString(buy20Average,_Digits)
   );
   Print(
      "SELL Signals=",
      IntegerToString(sellSignals)
   );
   Print(
      "SELL +5: Completed=",
      IntegerToString(sell5Count),
      " Wins=",
      IntegerToString(sell5Wins),
      " WinRate=",
      DoubleToString(sell5WinRate,1),
      "% AvgChange=",
      DoubleToString(sell5Average,_Digits)
   );
   Print(
      "SELL +10: Completed=",
      IntegerToString(sell10Count),
      " Wins=",
      IntegerToString(sell10Wins),
      " WinRate=",
      DoubleToString(sell10WinRate,1),
      "% AvgChange=",
      DoubleToString(sell10Average,_Digits)
   );
   Print(
      "SELL +20: Completed=",
      IntegerToString(sell20Count),
      " Wins=",
      IntegerToString(sell20Wins),
      " WinRate=",
      DoubleToString(sell20WinRate,1),
      "% AvgChange=",
      DoubleToString(sell20Average,_Digits)
   );
   Print(
      "##################################################"
   );
}
//--------------------------------------------------
// Update
//--------------------------------------------------
void Update()
{
   //--------------------------------------------------
   // Nothing to process
   //--------------------------------------------------
   if(m_count <= 0)
      return;
//--------------------------------------------------
// Quality Update Diagnostics
//--------------------------------------------------

static datetime lastDebugBar = 0;

datetime debugBar =
   iTime(
      _Symbol,
      PERIOD_CURRENT,
      0
   );

if(debugBar != lastDebugBar)
{
   lastDebugBar = debugBar;

   int debugShift =
   iBarShift(
      m_records[0].Symbol,
      m_records[0].ResearchTF,
      m_records[0].Time,
      false
   );

   Print(
      "PHX QUALITY UPDATE DEBUG: ",
      "Count=",
      IntegerToString(m_count),
      " SignalTime=",
      TimeToString(
         m_records[0].Time,
         TIME_DATE | TIME_SECONDS
      ),
      " Shift=",
      IntegerToString(debugShift),
      " C5=",
      m_records[0].Completed5,
      " C10=",
      m_records[0].Completed10,
      " C20=",
      m_records[0].Completed20
   );
}
   //--------------------------------------------------
   // Process all stored signals
   //--------------------------------------------------
   for(int i = 0; i < m_count; i++)
   {
   Print(
   "PHX TRACKER LOOP: ",
   "i=",
   IntegerToString(i),
   " Count=",
   IntegerToString(m_count),
   " Time=",
   TimeToString(
      m_records[i].Time,
      TIME_DATE | TIME_SECONDS
   ),
   " Symbol=",
   m_records[i].Symbol
);
      //--------------------------------------------------
      // Already fully completed
      //--------------------------------------------------
      if(m_records[i].Completed20)
         continue;
      //--------------------------------------------------
      // Invalid record
      //--------------------------------------------------
      if(
         m_records[i].Time <= 0 ||
         m_records[i].EntryPrice <= 0.0 ||
         m_records[i].Signal == PHX_SIGNAL_NONE
      )
      {
         continue;
      }
      //--------------------------------------------------
      // Find signal bar
      //--------------------------------------------------
      ENUM_TIMEFRAMES researchTF =
   m_records[i].ResearchTF;

int signalShift =
   iBarShift(
      m_records[i].Symbol,
      researchTF,
      m_records[i].Time,
      false
   );
   Print(
   "PHX +20 CHECK: ",
   "Index=",
   i,
   " Time=",
   TimeToString(
      m_records[i].Time,
      TIME_DATE|TIME_SECONDS
   ),
   " Shift=",
   signalShift,
   " C20=",
   m_records[i].Completed20
);
   Print(
   "PHX RECORD CHECK: ",
   "Index=",
   IntegerToString(i),
   " Symbol=",
   m_records[i].Symbol,
   " Time=",
   TimeToString(
      m_records[i].Time,
      TIME_DATE | TIME_SECONDS
   ),
   " Shift=",
   IntegerToString(signalShift),
   " C5=",
   m_records[i].Completed5,
   " C10=",
   m_records[i].Completed10,
   " C20=",
   m_records[i].Completed20
);
      if(signalShift < 0)
         continue;
      //--------------------------------------------------
      // We need CLOSED bars after signal
      //
      // signalShift:
      // 0 = signal is on current bar
      // 1 = one completed bar since signal
      // 5 = five completed bars since signal
      //--------------------------------------------------

      //--------------------------------------------------
      // +5 bars
      //--------------------------------------------------
      if(
         !m_records[i].Completed5 &&
         signalShift >= 6
      )
      {
         double priceAfter5 =
         iClose(
         m_records[i].Symbol,
         researchTF,
         signalShift - 5
         );
         if(priceAfter5 > 0.0)
         {
            m_records[i].PriceAfter5 =
               priceAfter5;
            if(
               m_records[i].Signal ==
               PHX_SIGNAL_BUY
            )
            {
               m_records[i].Change5 =
                  priceAfter5 -
                  m_records[i].EntryPrice;
            }
            else
            if(
               m_records[i].Signal ==
               PHX_SIGNAL_SELL
            )
            {
               m_records[i].Change5 =
                  m_records[i].EntryPrice -
                  priceAfter5;
            }
            m_records[i].Completed5 =
               true;
            Print(
               "PHX QUALITY +5: ",
               "Signal=",
               IntegerToString(
                  m_records[i].Signal
               ),
               " Entry=",
               DoubleToString(
                  m_records[i].EntryPrice,
                  _Digits
               ),
               " Price=",
               DoubleToString(
                  m_records[i].PriceAfter5,
                  _Digits
               ),
               " Change=",
               DoubleToString(
                  m_records[i].Change5,
                  _Digits
               )
            );
         }
      }

      //--------------------------------------------------
      // +10 bars
      //--------------------------------------------------
      if(
         !m_records[i].Completed10 &&
         signalShift >= 11
      )
      {
         double priceAfter10 =
         iClose(
         m_records[i].Symbol,
         researchTF,
         signalShift - 10
         );
         if(priceAfter10 > 0.0)
         {
            m_records[i].PriceAfter10 =
               priceAfter10;
            if(
               m_records[i].Signal ==
               PHX_SIGNAL_BUY
            )
            {
               m_records[i].Change10 =
                  priceAfter10 -
                  m_records[i].EntryPrice;
            }
            else
            if(
               m_records[i].Signal ==
               PHX_SIGNAL_SELL
            )
            {
               m_records[i].Change10 =
                  m_records[i].EntryPrice -
                  priceAfter10;
            }
            m_records[i].Completed10 =
               true;
            Print(
               "PHX QUALITY +10: ",
               "Signal=",
               IntegerToString(
                  m_records[i].Signal
               ),
               " Entry=",
               DoubleToString(
                  m_records[i].EntryPrice,
                  _Digits
               ),
               " Price=",
               DoubleToString(
                  m_records[i].PriceAfter10,
                  _Digits
               ),
               " Change=",
               DoubleToString(
                  m_records[i].Change10,
                  _Digits
               )
            );
         }
      }

       //--------------------------------------------------
      // +20 bars
      //--------------------------------------------------
      if(
         !m_records[i].Completed20 &&
         signalShift >= 21
      )
      {
         double priceAfter20 =
         iClose(
         m_records[i].Symbol,
         researchTF,
         signalShift - 20
         );

Print(
   "PHX +20 EXEC: ",
   "Shift=",
   IntegerToString(signalShift),
   " Bar=",
   IntegerToString(signalShift-20),
   " Price=",
   DoubleToString(priceAfter20,_Digits)
);
         if(priceAfter20 > 0.0)
         {
            m_records[i].PriceAfter20 =
               priceAfter20;

            if(
               m_records[i].Signal ==
               PHX_SIGNAL_BUY
            )
            {
               m_records[i].Change20 =
                  priceAfter20 -
                  m_records[i].EntryPrice;
            }
            else
            if(
               m_records[i].Signal ==
               PHX_SIGNAL_SELL
            )
            {
               m_records[i].Change20 =
                  m_records[i].EntryPrice -
                  priceAfter20;
            }


            //--------------------------------------------------
            // Mark +20 as completed
            //--------------------------------------------------

            m_records[i].Completed20 =
               true;


            //--------------------------------------------------
            // Research Journal
            //--------------------------------------------------

            if(
               !m_researchJournal.Write(
                  m_records[i]
               )
            )
            {
               Print(
                  "PHX QUALITY TRACKER ERROR: ",
                  "Research Journal write failed"
               );
            }


            //--------------------------------------------------
            // +20 diagnostics
            //--------------------------------------------------

            Print(
               "PHX QUALITY +20: ",
               "Signal=",
               IntegerToString(
                  m_records[i].Signal
               ),
               " Entry=",
               DoubleToString(
                  m_records[i].EntryPrice,
                  _Digits
               ),
               " Price=",
               DoubleToString(
                  m_records[i].PriceAfter20,
                  _Digits
               ),
               " Change=",
               DoubleToString(
                  m_records[i].Change20,
                  _Digits
               )
            );


            //--------------------------------------------------
            // Print accumulated quality summary
            //--------------------------------------------------

            PrintSummary();
         }
      }
   }
}
//+------------------------------------------------------------------+
//| Attach Execution Data                                            |
//+------------------------------------------------------------------+
bool AttachExecutionData(
   ulong ticket,
   double candlePosition,
   ulong executionDelayMS,
   double priceVsCandleHigh
)
{
   if(m_count <= 0)
      return false;


   int index = m_count - 1;


   m_records[index].Ticket =
      ticket;

   m_records[index].CandlePosition =
      candlePosition;

   m_records[index].ExecutionDelayMS =
      executionDelayMS;

   m_records[index].PriceVsCandleHigh =
      priceVsCandleHigh;
Print(
   "PHX EXECUTION QUALITY ATTACHED: ",
   "Ticket=",
   ticket,
   " CandlePos=",
   DoubleToString(
      candlePosition,
      3
   ),
   " DelayMS=",
   IntegerToString(
      (int)executionDelayMS
   ),
   " PriceVsHigh=",
   DoubleToString(
      priceVsCandleHigh,
      3
   )
);

   return true;
}

};

#endif
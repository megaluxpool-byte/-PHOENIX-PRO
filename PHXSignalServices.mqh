#ifndef __PHX_SIGNAL_SERVICES_MQH__
#define __PHX_SIGNAL_SERVICES_MQH__


//--------------------------------------------------
// Includes
//--------------------------------------------------

#include "PHXSignalTypes.mqh"
#include "PHXSignalState.mqh"
#include "PHXSignalHistory.mqh"
#include "PHXSignalMarker.mqh"
#include "PHXPriceStructure.mqh"
#include "PHXD1TrendContext.mqh"
#include "PHXDivergenceMatcher.mqh"
#include "PHXDivergenceClassifier.mqh"
#include "PHXDivergenceDetector.mqh"
#include "PHXDivergenceEngine.mqh"

#include "../Indicators/PHXPPO.mqh"

#include "..\Indicators\PHXIndicatorServices.mqh"
#include "..\Indicators\PHXATREnergy.mqh"
#include "..\Market\PHXMarketServices.mqh"
#include "..\Core\PHXATRMomentum.mqh"
#include "../Statistics/PHXSignalQualityTracker.mqh"
#include "../Core/PHXConfigTypes.mqh"
//+------------------------------------------------------------------+
//| Signal Services                                                  |
//+------------------------------------------------------------------+
class CPHXSignalQualityTracker;
//+------------------------------------------------------------------+
//| Signal Services                                                  |
//+------------------------------------------------------------------+
class CPHXSignalServices
{
private:
   //--------------------------------------------------
   // Indicator dependency
   //--------------------------------------------------
   CPHXIndicatorServices* m_indicators;   
   CPHXSignalState* m_state;   
   CPHXSignalHistory* m_history; 
   //--------------------------------------------------
   // Signal Quality Tracker
   //--------------------------------------------------
   CPHXSignalQualityTracker* m_qualityTracker;
   //--------------------------------------------------
   // Current Trend Snapshot
   //--------------------------------------------------
   SPHXTrendSnapshot m_trendSnapshot;
   CPHXSignalMarker* m_marker;   
   CPHXMarketServices* m_marketServices;   
   CPHXATRMomentum* m_atrMomentum;   
   CPHXATREnergy* m_atrEnergy; 
   //--------------------------------------------------
   // Divergence Core
   //--------------------------------------------------
   CPHXPPO*              m_ppo;
   CPHXPriceStructure*   m_priceStructure;
   CPHXDivergenceEngine* m_divergenceEngine;
   //---------------------------------------------------------------
   // D1 Trend Context
   //---------------------------------------------------------------
   CPHXD1TrendContext*   m_d1TrendContext; 
   //---------------------------------------------------------------
   // Active Divergence Lifecycle State
   //---------------------------------------------------------------
   SPHXDivergenceResult   m_activeDivergence;

   SPHXDivergenceConfirmation   m_activeDivergenceConfirmation;

   SPHXDivergenceConfirmationProfile   m_activeDivergenceProfile;

   SPHXPriceExtreme   m_activeIntermediateExtreme;

   bool   m_activeDivergenceWaiting;
   //--------------------------------------------------
   // Divergence Configuration
   //--------------------------------------------------
   SPHXDivergenceConfig  m_divergenceConfig;
   //--------------------------------------------------
   // Divergence History
   //--------------------------------------------------

   bool                  m_divergenceHistoryReady;
   datetime              m_divergenceHistoryStartTime;
   //--------------------------------------------------
   // Divergence Live State
   //--------------------------------------------------
   datetime              m_lastDivergenceClosedBarTime;
   //--------------------------------------------------
   // State
   //--------------------------------------------------
   bool m_initialized;
   datetime m_lastResearchM1Bar;
   //--------------------------------------------------
   // Signal result
   //--------------------------------------------------

   SPHXSignal m_signal;
   
   //--------------------------------------------------
   // Set Primary Block Reason
   //--------------------------------------------------

   void SetPrimaryBlock(
   ENUM_PHX_PRIMARY_BLOCK block
)
{
   if(m_signal.PrimaryBlock == PHX_PRIMARY_NONE)
   {
      m_signal.PrimaryBlock = block;
   }
}
   
public:

   CPHXSignalServices();

   ~CPHXSignalServices();

public:
   bool Initialize();
   void Shutdown();
   void Reset();
   bool Update();
   bool IsInitialized() const;

public:

   SPHXSignal GetSignal() const;  
   void SetIndicators(
   CPHXIndicatorServices* indicators
);
   void SetMarketServices(
   CPHXMarketServices* marketServices
);   
   void SetQualityTracker(
   CPHXSignalQualityTracker* tracker
);
   void SetTrendSnapshot(
   const SPHXTrendSnapshot &snapshot
);
   void SetATREnergy(
   CPHXATREnergy* atrEnergy
);
   void SetDivergenceConfig(
      const SPHXDivergenceConfig &config
   );
private:
    bool PrepareDivergenceHistory();

   bool LoadDivergenceHistory(
      MqlRates &rates[]
   );

   bool CalculateDivergenceAvgRange(
      const MqlRates &rates[],
      const int currentIndex,
      double &avgRange
   );

   bool ReplayDivergencePriceStructure(
      const MqlRates &rates[]
   );
   bool UpdateDivergencePriceStructure();
   bool DetectNewConfirmedPriceExtreme(
      const SPHXPriceExtreme &highBefore,
      const SPHXPriceExtreme &lowBefore,
      SPHXPriceExtreme &newExtreme
   );
   bool BuildDivergenceStructuralPair(
      const SPHXPriceExtreme &newExtreme,
      SPHXPriceExtreme &firstExtreme,
      SPHXPriceExtreme &intermediateExtreme,
      SPHXPriceExtreme &secondExtreme
   );     
      bool AnalyzeDivergenceStructuralPair(
      const SPHXPriceExtreme &firstExtreme,
      const SPHXPriceExtreme &secondExtreme,
      SPHXDivergenceResult &result
   );
   //---------------------------------------------------------------
// Divergence Context Classification
//---------------------------------------------------------------

ENUM_PHX_DIVERGENCE_CONTEXT
ClassifyDivergenceContext(
   const ENUM_PHX_DIVERGENCE_TYPE divergenceType
) const;
//---------------------------------------------------------------
// Divergence RSI Snapshot
//---------------------------------------------------------------

      bool CaptureActiveDivergenceRSI();
//---------------------------------------------------------------
// Divergence ADX Snapshot
//---------------------------------------------------------------

      bool CaptureActiveDivergenceADX();
//---------------------------------------------------------------
// Divergence Volume Snapshot
//---------------------------------------------------------------

      bool CaptureActiveDivergenceVolume();     

      bool UpdateActiveDivergenceConfirmation(
      const int barIndex,
      const MqlRates &bar
   );

};
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPHXSignalServices::CPHXSignalServices()
{
   m_indicators = NULL;   
   m_atrEnergy = NULL;   
   m_atrMomentum = NULL;   
   m_state = NULL;   
   m_history = NULL;
   m_qualityTracker = NULL;   
   m_marker = NULL;  
   m_marketServices = NULL;
   //--------------------------------------------------
   // Divergence Core
   //--------------------------------------------------
   m_ppo = NULL;
   m_priceStructure = NULL;
   m_divergenceEngine = NULL;
   //---------------------------------------------------------------
   // D1 Trend Context
   //---------------------------------------------------------------
   m_d1TrendContext = NULL;
   //--------------------------------------------------
   // Divergence Configuration
   //--------------------------------------------------
   m_divergenceConfig.Reset();
   //--------------------------------------------------
   // Divergence History
   //--------------------------------------------------
   m_divergenceHistoryReady = false;
   m_divergenceHistoryStartTime =
      0;
   //---------------------------------------------------------------
   // Active Divergence Lifecycle State
   //---------------------------------------------------------------
   m_activeDivergence.Reset();
   m_activeDivergenceConfirmation.Reset();
   m_activeDivergenceProfile.Reset();
   m_activeIntermediateExtreme.Reset();
   m_activeDivergenceWaiting = false; 
   //--------------------------------------------------
   // Divergence Live State
   //--------------------------------------------------

   m_lastDivergenceClosedBarTime =
      0;
   m_initialized = false;
   m_lastResearchM1Bar = 0;
   m_signal.Reset();
   m_trendSnapshot.Reset();
}
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPHXSignalServices::~CPHXSignalServices()
{
   Shutdown();
}
//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CPHXSignalServices::Initialize()
{
   if(m_initialized)
      return true;
   m_signal.Reset();
   //--------------------------------------------------
   // Signal State
   //--------------------------------------------------
   m_state = new CPHXSignalState();
   if(m_state == NULL)
      return false;
   //--------------------------------------------------
   // Signal History
   //--------------------------------------------------
   m_history = new CPHXSignalHistory();
   if(m_history == NULL)
{
   Shutdown();
   return false;
}
   //--------------------------------------------------
   // Signal Market
   //--------------------------------------------------
   m_marker = new CPHXSignalMarker();
   if(m_marker == NULL)
{
   Shutdown();
   return false;
}
   //--------------------------------------------------
   // ATR Energy
   //--------------------------------------------------
   m_atrEnergy = new CPHXATREnergy();
   if(m_atrEnergy == NULL)
   {
      Shutdown();
      return false;
   }
   //--------------------------------------------------
   // ATR Momentum
   //--------------------------------------------------
   m_atrMomentum = new CPHXATRMomentum();
   if(m_atrMomentum == NULL)
   {
      Shutdown();
      return false;
   }
   //--------------------------------------------------
   // PPO
   //--------------------------------------------------
   m_ppo = new CPHXPPO();
   if(m_ppo == NULL)
   {
      Shutdown();
      return false;
   }
   //--------------------------------------------------
   // Price Structure
   //--------------------------------------------------
   m_priceStructure = new CPHXPriceStructure();
   if(m_priceStructure == NULL)
   {
      Shutdown();
      return false;
   }
   //--------------------------------------------------
   // Divergence Engine
   //--------------------------------------------------
   m_divergenceEngine = new CPHXDivergenceEngine();
   if(m_divergenceEngine == NULL)
   {
      Shutdown();
      return false;
   }
   //---------------------------------------------------------------
   // D1 Trend Context
   //---------------------------------------------------------------
   m_d1TrendContext = new CPHXD1TrendContext;
   if(m_d1TrendContext == NULL)
   {
      Print(
         "PHXSignalServices ERROR: ",
         "D1 Trend Context allocation failed"
      );
      return false;
   }
   //---------------------------------------------------------------
   // Build Historical D1 Trend Structure
   //---------------------------------------------------------------
   if(
      !(*m_d1TrendContext).Build(
         m_divergenceConfig.HistoryD1Bars,
         m_divergenceConfig.AvgRangePeriod
      )
   )
   {
      Print(
         "PHXSignalServices ERROR: ",
         "D1 Trend Context build failed"
      );
      return false;
   }
   //--------------------------------------------------
   // Initialize PPO Only When Divergence Is Enabled
   //--------------------------------------------------
      if(m_divergenceConfig.UseDivergence)
   {
      //------------------------------------------------------------
      // Divergence Historical Data
      //------------------------------------------------------------
      MqlRates divergenceHistory[];
      //------------------------------------------------------------
      // Determine Historical Horizon
      //------------------------------------------------------------
      if(!PrepareDivergenceHistory())
      {
         Print(
            "PHXSignalServices ERROR: ",
            "Divergence history preparation failed"
         );
         Shutdown();
         return false;
      }
      //------------------------------------------------------------
      // Load Closed DivergenceTF Historical Bars
      //------------------------------------------------------------
      if(
         !LoadDivergenceHistory(
            divergenceHistory
         )
      )
      {
         Print(
            "PHXSignalServices ERROR: ",
            "Divergence TF history loading failed"
         );

         Shutdown();
         return false;
      }
      //------------------------------------------------------------
      // Determine Divergence Timeframe
      //------------------------------------------------------------
      ENUM_TIMEFRAMES divergenceTF =
         PERIOD_CURRENT;
      if(m_divergenceConfig.UseDivergenceTF)
      {
         divergenceTF =
            m_divergenceConfig.DivergenceTF;
      }
      //------------------------------------------------------------
      // Initialize PPO
      //
      // PPO must be ready before historical Price Structure replay,
      // because confirmed historical price extremes will later be
      // matched against PPO extremes from the same market period.
      //------------------------------------------------------------

      if(
         !(*m_ppo).Initialize(
            _Symbol,
            divergenceTF,
            m_divergenceConfig.PPOFastPeriod,
            m_divergenceConfig.PPOSlowPeriod
         )
      )
      {
         Print(
            "PHXSignalServices ERROR: PPO initialization failed"
         );

         Shutdown();
         return false;
      }

      //------------------------------------------------------------
      // Replay Historical Price Structure
      //------------------------------------------------------------

      if(
         !ReplayDivergencePriceStructure(
            divergenceHistory
         )
      )
      {
         Print(
            "PHXSignalServices ERROR: ",
            "Divergence Price Structure replay failed"
         );

         Shutdown();
         return false;
      }

      //------------------------------------------------------------
      // Remember Last Historically Processed Closed Bar
      //------------------------------------------------------------

      int divergenceHistoryCount =
         ArraySize(divergenceHistory);

      if(divergenceHistoryCount <= 0)
      {
         Shutdown();
         return false;
      }

      m_lastDivergenceClosedBarTime =
         divergenceHistory[
            divergenceHistoryCount - 1
         ].time;
   }
   
   //--------------------------------------------------
   // Initialized
   //--------------------------------------------------
   m_initialized =
      true;
   return true;
}
//+------------------------------------------------------------------+
//| Shutdown                                                         |
//+------------------------------------------------------------------+
   void CPHXSignalServices::Shutdown()
{
//--------------------------------------------------
// Divergence Statistics Report
//--------------------------------------------------

if(m_divergenceEngine != NULL)
{
   (*m_divergenceEngine).PrintStatistics();
}

   //--------------------------------------------------
   // Divergence Engine
   //--------------------------------------------------
   if(m_divergenceEngine != NULL)
   {
      delete m_divergenceEngine;
      m_divergenceEngine = NULL;
   }
   //---------------------------------------------------------------
   // D1 Trend Context
   //---------------------------------------------------------------
   if(m_d1TrendContext != NULL)
   {
      (*m_d1TrendContext).Reset();
      delete m_d1TrendContext;
      m_d1TrendContext = NULL;
   }
   //--------------------------------------------------
   // Price Structure
   //--------------------------------------------------
   if(m_priceStructure != NULL)
   {
      delete m_priceStructure;
      m_priceStructure = NULL;
   }
   //--------------------------------------------------
   // PPO
   //--------------------------------------------------

   if(m_ppo != NULL)
   {
      (*m_ppo).Shutdown();
      delete m_ppo;
      m_ppo = NULL;
   }
   Print(
   "PHXSignalServices Shutdown: ",
   "ATR Energy=",
   (m_atrEnergy != NULL),
   " ATR Momentum=",
   (m_atrMomentum != NULL)
);
   //--------------------------------------------------
   // Signal History
   //--------------------------------------------------
  Print("PHXSignalServices: Shutdown START");//врем
   if(m_history != NULL)
   {
      delete m_history;
      m_history = NULL;
      Print(
         "PHXSignalServices: History released"
      );
   }
   //--------------------------------------------------
   // ATR Momentum
   //--------------------------------------------------
   if(m_atrMomentum != NULL)
   {
   Print("PHXSignalServices: delete ATR Momentum");//врем
      delete m_atrMomentum;
      m_atrMomentum = NULL;
      Print(
         "PHXSignalServices: ATR Momentum released"
      );
   }
   //--------------------------------------------------
   // ATR Energy
   //--------------------------------------------------
   if(m_atrEnergy != NULL)
   {
   Print("PHXSignalServices: delete ATR Energy");//врем
      delete m_atrEnergy;
      m_atrEnergy = NULL;
      Print(
         "PHXSignalServices: ATR Energy released"
      );
   }
   //--------------------------------------------------
   // Signal State
   //--------------------------------------------------
   if(m_state != NULL)
   {
   Print("PHXSignalServices: delete State");//врем
      delete m_state;
      m_state = NULL;
      Print(
         "PHXSignalServices: State released"
      );
   }
   if(m_marker != NULL)
   {
   delete m_marker;
   m_marker = NULL;
     
   }
   //--------------------------------------------------
   // Divergence History
   //--------------------------------------------------

   m_divergenceHistoryReady =
      false;

   m_divergenceHistoryStartTime =
      0;
   //--------------------------------------------------
   // Divergence Live State
   //--------------------------------------------------

   m_lastDivergenceClosedBarTime =
      0;
      
   m_initialized = false;
   Print(
      "PHXSignalServices: Shutdown END"//врем
   );
   //---------------------------------------------------------------
   // Active Divergence Lifecycle State
   //---------------------------------------------------------------

   m_activeDivergence.Reset();
   m_activeDivergenceConfirmation.Reset();
   m_activeDivergenceProfile.Reset();
   m_activeIntermediateExtreme.Reset();
   m_activeDivergenceWaiting = false;
}
//+------------------------------------------------------------------+
//| Reset                                                            |
//+------------------------------------------------------------------+
void CPHXSignalServices::Reset()
{
   m_signal.Reset();
   m_trendSnapshot.Reset();
   m_lastResearchM1Bar = 0;
}
//+------------------------------------------------------------------+
//| Update                                                           |
//+------------------------------------------------------------------+
bool CPHXSignalServices::Update()
{
   //---------------------------------------------------------------
   // D1 Trend Context Live Update
   //---------------------------------------------------------------

   if(m_d1TrendContext == NULL)
   {
      Print(
         "PHXSignalServices ERROR: ",
         "D1 Trend Context is NULL"
      );

      return false;
   }

   if(!(*m_d1TrendContext).Update())
   {
      Print(
         "PHXSignalServices ERROR: ",
         "D1 Trend Context update failed"
      );

      return false;
   }
   //--------------------------------------------------
   // Divergence Price Structure LIVE
   //--------------------------------------------------

   if(m_divergenceConfig.UseDivergence)
   {
      if(!UpdateDivergencePriceStructure())
      {
         Print(
            "PHXSignalServices ERROR: ",
            "Divergence Price Structure LIVE update failed"
         );
      }
   }
   if(!m_initialized)
   {
      return false;
  }  
   //--------------------------------------------------
   // Clear previous signal
   //--------------------------------------------------
   m_signal.Reset(); 
   
   m_signal.State =
   PHX_SIGNAL_NO_SETUP;

   m_signal.BlockReason =
   PHX_BLOCK_NONE;
   //--------------------------------------------------
   // Signal calculation
   //--------------------------------------------------
   if(m_indicators == NULL)
{
   m_signal.Reset();
   return false;
}
   if(m_marketServices == NULL)
{
   m_signal.signal = PHX_SIGNAL_NONE;
   return false;
}
   // Получаем данные индикаторов
   //--------------------------------------------------
   // Current ATR
   //--------------------------------------------------
   CPHXATR* currentATRService =
   (*m_indicators).GetCurrentATR();
   //--------------------------------------------------
   // Base ATR
   //--------------------------------------------------
   CPHXATR* baseATRService =
   (*m_indicators).GetBaseATR();
   //--------------------------------------------------
   // ATR services protection
   //--------------------------------------------------
   if(currentATRService == NULL ||
   baseATRService == NULL)
{
   Print(
      "PHX ATR Energy: ATR services unavailable"
   );
   m_signal.signal = PHX_SIGNAL_NONE;
   return false;
}
   //--------------------------------------------------
   // ATR values
   //--------------------------------------------------
   double currentATR =
   (*currentATRService).GetValue();
   double previousATR =
   (*currentATRService).GetPreviousValue();
   double baseATR =
   (*baseATRService).GetValue();
   if(m_atrEnergy == NULL)
{
   Print(
      "PHX ATR Energy: Energy service NULL"
   );
   m_signal.signal = PHX_SIGNAL_NONE;
   return false;
}
//--------------------------------------------------
// ATR Local Diagnostics
// M30 / H1 DO NOT affect trading decision
//--------------------------------------------------

double energyPercent = 0.0;

if(baseATR > 0.0)
{
   energyPercent =
      (currentATR / baseATR) * 100.0;
}

if(m_atrEnergy != NULL)
{
   (*m_atrEnergy).PrintLocalATRDiagnostics(
      currentATR,
      baseATR
   );
}


//--------------------------------------------------
// D1 ATR Energy Filter
//--------------------------------------------------

//--------------------------------------------------
// Technical D1 ATR
//--------------------------------------------------
double technicalDailyATR =
   (*m_indicators).DailyATR();


//--------------------------------------------------
// D1 Energy Calculation
//--------------------------------------------------
bool atrEnergyOK =
   (*m_atrEnergy).IsEnergyEnough(
      technicalDailyATR
   );


//--------------------------------------------------
// D1 Energy Snapshot
//--------------------------------------------------
double currentD1Range =
   (*m_atrEnergy).GetCurrentDailyRange();

double energyUsedPercent =
   (*m_atrEnergy).GetUsedRatio() * 100.0;

double energyLeftPercent =
   (*m_atrEnergy).GetRemainingRatio() * 100.0;


//--------------------------------------------------
// D1 Energy Diagnostics
//--------------------------------------------------
if(PHX_VERBOSE_DEBUG)
{
Print(
   "PHX SIGNAL D1 ENERGY: ",
   "TechnicalATR=",
   DoubleToString(
      technicalDailyATR,
      3
   ),
   " CurrentRange=",
   DoubleToString(
      currentD1Range,
      3
   ),
   " Used=",
   DoubleToString(
      energyUsedPercent,
      2
   ),
   "%",
   " Left=",
   DoubleToString(
      energyLeftPercent,
      2
   ),
   "%",
   " Allowed=",
   atrEnergyOK
);
}
//--------------------------------------------------
// ATR Momentum Filter
//--------------------------------------------------
bool atrMomentumOK =
(*m_atrMomentum).IsMomentumPositive(
   currentATR,
   previousATR
);

//--------------------------------------------------
// ATR Momentum Confidence
//--------------------------------------------------
double atrConfidence = 1.0;

if(!atrMomentumOK)
{
   atrConfidence = 0.75;
}
else
{
   atrConfidence = 1.0;
}
   //--------------------------------------------------
   // Indicator services
   //--------------------------------------------------
   CPHXMovingAverage* maService =
   (*m_indicators).GetMA();

   CPHXRSI* rsiService =
   (*m_indicators).GetRSI();
   
   CPHXADX* adxService =
   (*m_indicators).GetADX();
 
   CPHXVolumeAnalyzer* volumeService =
   (*m_indicators).GetVolume();

   double ma = 0.0;
   double rsi = 0.0;
   double previousRSI = 0.0;
   double adx = 0.0;
   double volume = 0.0;
   double averageVolume = 0.0;

   if(currentATRService != NULL)
{
   currentATR = (*currentATRService).GetValue();
}
   if(maService != NULL)
{
   ma = (*maService).GetValue();
}
   if(rsiService != NULL)
{
   rsi = (*rsiService).GetValue();
}
   if(rsiService != NULL)
{
   previousRSI =
      (*rsiService).GetPreviousValue();
}
   if(adxService != NULL)
{
   adx =
      (*adxService).GetADX();
}
   if(volumeService != NULL)
{
   volume =
      (double)(*volumeService).GetCurrentVolume();

   averageVolume =
      (*volumeService).GetAverageVolume();
}
   // Текущая цена

   double price = SymbolInfoDouble(
   _Symbol,
   SYMBOL_BID
);

//--------------------------------------------------
// Entry Quality Filter
//--------------------------------------------------

MqlRates candle[];

ArraySetAsSeries(
   candle,
   true
);

double candlePosition = 0.5;

bool nearCandleHigh = false;
bool nearCandleLow  = false;

bool candleDataReady = false;

int candleCopied =
   CopyRates(
      _Symbol,
      PERIOD_CURRENT,
      1,
      1,
      candle
   );

if(candleCopied == 1)
{
   candleDataReady = true;

   double range =
      candle[0].high -
      candle[0].low;

   if(range > 0.0)
   {
      candlePosition =
      (
         price -
         candle[0].low
      )
      /
      range;
   }

   if(candlePosition > 1.0)
      candlePosition = 1.0;

   if(candlePosition < 0.0)
      candlePosition = 0.0;

   //--------------------------------------------------
   // Near Candle High Protection
   //--------------------------------------------------

   if(
      candle[0].high - price <
      currentATR * 0.10
   )
   {
      nearCandleHigh = true;
   }

   //--------------------------------------------------
   // Near Candle Low Protection
   //--------------------------------------------------

   if(
      price - candle[0].low <
      currentATR * 0.10
   )
   {
      nearCandleLow = true;
   }
}
   // Сохраняем снимок

   m_signal.price = price; 
   m_signal.ATR = currentATR;
   m_signal.ma = ma;
   m_signal.rsi = rsi;
   m_signal.volume = volume;
   m_signal.averageVolume = averageVolume;
   datetime phxTimeCurrent =
   TimeCurrent();

datetime phxTimeTradeServer =
   TimeTradeServer();

Print(
   "PHX SIGNAL TIME DEBUG: ",
   "Symbol=", _Symbol,
   " TF=", EnumToString(_Period),
   " TimeCurrent=",
   TimeToString(
      phxTimeCurrent,
      TIME_DATE | TIME_SECONDS
   ),
   " TimeTradeServer=",
   TimeToString(
      phxTimeTradeServer,
      TIME_DATE | TIME_SECONDS
   ),
   " Bar0=",
   TimeToString(
      iTime(
         _Symbol,
         _Period,
         0
      ),
      TIME_DATE | TIME_SECONDS
   )
);
   m_signal.time = TimeCurrent();
   
//--------------------------------------------------
// Trend Exhaustion Filter
//--------------------------------------------------
   bool buyExhaustion = true;
   bool sellExhaustion = true;
   MqlRates exhaustionCandle[];

   ArraySetAsSeries(
   exhaustionCandle,
   true
);
   int exhaustionCopied =
   CopyRates(
      _Symbol,
      PERIOD_CURRENT,
      1,
      1,
      exhaustionCandle
   );
   if(exhaustionCopied == 1)
{
   double lastRange =
      exhaustionCandle[0].high -
      exhaustionCandle[0].low;
   //--------------------------------------------------
   // BUY exhaustion
   //--------------------------------------------------
   if(
      exhaustionCandle[0].close < ma &&
      lastRange > currentATR * 0.8
   )
   {
      buyExhaustion = true;
   }
   //--------------------------------------------------
   // SELL exhaustion
   //--------------------------------------------------
   if(
      exhaustionCandle[0].close > ma &&
      lastRange > currentATR * 0.8
   )
   {
      sellExhaustion = true;
   }
}
   //--------------------------------------------------
// Current Candle Momentum Filter
//--------------------------------------------------
   bool bullishMomentum = true;
   bool bearishMomentum = true;
   MqlRates momentum[];
   ArraySetAsSeries(
   momentum,
   true
);
   int momentumCopied =
   CopyRates(
      _Symbol,
      PERIOD_CURRENT,
      1,
      3,
      momentum
   );
   if(momentumCopied == 3)
{
   int bullishCount = 0;
   int bearishCount = 0;
   for(int i = 0; i < 3; i++)
   {
      if(momentum[i].close > momentum[i].open)
      {
         bullishCount++;
      }
      if(momentum[i].close < momentum[i].open)
      {
         bearishCount++;
      }
   }
   if(
   bullishCount >= 2 &&
   momentum[0].close >= momentum[0].open
)
{
   bullishMomentum = true;
}
   if(
   bearishCount >= 2 &&
   momentum[0].close <= momentum[0].open
)
{
   bearishMomentum = true;
}
}
  if(PHX_VERBOSE_DEBUG)
{
   Print(
      "PHX Momentum Filter: ",
      "Bull=",
      bullishMomentum,
      " Bear=",
      bearishMomentum
   );
}
//--------------------------------------------------
// Weak Trend Protection
//--------------------------------------------------
   bool weakBullTrend = true;
   bool weakBearTrend = true;
//--------------------------------------------------
// Weak BUY protection
//--------------------------------------------------
   if(
   price > ma &&
   bearishMomentum &&
   rsi < 60 &&
   volume < averageVolume
)
{
   weakBullTrend = true;
}
//--------------------------------------------------
// Weak SELL protection
//--------------------------------------------------
   if(
   price < ma &&
   bullishMomentum &&
   rsi > 40 &&
   volume < averageVolume
)
{
   weakBearTrend = true;
}
if(PHX_VERBOSE_DEBUG)
{
   Print(
   "PHX Weak Trend Protection: ",
   "WeakBull=",
   weakBullTrend,
   " WeakBear=",
   weakBearTrend
);
}
//--------------------------------------------------
// RSI Market Context Diagnostics
//--------------------------------------------------
   string marketMode =
   "NEUTRAL";
   if(adx > 25.0)
{
   marketMode =
      "TREND";
}
   else
   if(adx < 20.0)
{
   marketMode =
      "RANGE";
}
if(PHX_VERBOSE_DEBUG)
{
   Print(
   "PHX RSI Context: ",
   "ADX=",
   DoubleToString(adx,2),
   " Mode=",
   marketMode,
   " RSI=",
   DoubleToString(rsi,2),
   " PreviousRSI=",
   DoubleToString(previousRSI,2)
);
}
//--------------------------------------------------
// Range RSI Reversal Diagnostics
//--------------------------------------------------
   bool rangeBuyRSI =
(
   previousRSI < 30.0 &&
   rsi > 30.0
);
   bool rangeSellRSI =
(
   previousRSI > 70.0 &&
   rsi < 70.0
);
//--------------------------------------------------
// RSI Exit Research
//
// Research only.
// Does NOT participate in trade validation.
//--------------------------------------------------
m_signal.RSIExit70 =
(
   previousRSI > 70.0 &&
   rsi <= 70.0
);

m_signal.RSIExit75 =
(
   previousRSI > 75.0 &&
   rsi <= 75.0
);

m_signal.RSIExit78 =
(
   previousRSI > 78.0 &&
   rsi <= 78.0
);
//--------------------------------------------------
// Early RSI + M1 Reversal Detection
//
// Purpose:
// Detect bullish reversal before RSI reaches 50.
//--------------------------------------------------

bool earlyBuyRSI =
   false;

bool m1BullishReversal =
   false;

double rsiRise =
   rsi - previousRSI;

MqlRates m1ReversalRates[3];

if(
   CopyRates(
      _Symbol,
      PERIOD_M1,
      1,
      3,
      m1ReversalRates
   ) == 3
)
{
   // Static array:
   // [0] = oldest
   // [1] = middle
   // [2] = latest closed M1

   int bullishM1Count =
      0;

   for(int i = 0; i < 3; i++)
   {
      if(
         m1ReversalRates[i].close >
         m1ReversalRates[i].open
      )
      {
         bullishM1Count++;
      }
   }

   bool latestM1Bullish =
   (
      m1ReversalRates[2].close >
      m1ReversalRates[2].open
   );

   bool risingM1Closes =
   (
      m1ReversalRates[2].close >
      m1ReversalRates[1].close
   );

   if(
      bullishM1Count >= 2 &&
      latestM1Bullish &&
      risingM1Closes
   )
   {
      m1BullishReversal =
         true;
   }
}

//--------------------------------------------------
// Early BUY RSI confirmation
//--------------------------------------------------

if(
   rsi >= 35.0 &&
   rsi < 45.0 &&
   rsiRise >= 1.0 &&
   price > ma &&
   m1BullishReversal
)
{
   earlyBuyRSI =
      true;
}
//--------------------------------------------------
// RSI Entry Timing Filter
//--------------------------------------------------
bool buyRSIOK =
(
   (
      rsi > 45.0 &&
      rsi < 75.0
   )
   ||
   earlyBuyRSI
);
   bool sellRSIOK =
(
   rsi < 60 &&
   rsi > 25
);
//--------------------------------------------------
// Final RSI Context Filter
//--------------------------------------------------

bool finalBuyRSIOK = false;

bool finalSellRSIOK = false;


if(marketMode == "TREND")
{
   finalBuyRSIOK =
      buyRSIOK;

   finalSellRSIOK =
      sellRSIOK;
}
else
{
   // Пока сохраняем текущую трендовую модель
   finalBuyRSIOK =
      buyRSIOK;

   finalSellRSIOK =
      sellRSIOK;
}
if(PHX_VERBOSE_DEBUG)
{
Print(
   "PHX RSI Entry Filter: ",
   "Mode=",
   marketMode,
   " ADX=",
   DoubleToString(adx,2),
   " RSI=",
   DoubleToString(rsi,2),
   " PrevRSI=",
   DoubleToString(previousRSI,2),
   " BUY=",
   buyRSIOK,
   " SELL=",
   sellRSIOK,
   " FinalBUY=",
   finalBuyRSIOK,
   " FinalSELL=",
   finalSellRSIOK
);
}
//--------------------------------------------------
// Candle Protection Final Filter
//--------------------------------------------------

bool candleProtectionBuyBlock = false;
bool candleProtectionSellBlock = false;
bool PHX_RAW_MODE = true;


//--------------------------------------------------
// BUY protection
//--------------------------------------------------

// Не покупаем:
// 1. в нижней зоне свечи
// 2. в верхних 10% свечи
// 3. выше High сигнальной свечи

bool strongTrendBuy =
(
   m_trendSnapshot.Trend ==
      PHX_TREND_UP
   &&
   m_signal.adx >= 30.0
);

if(
   (
      candlePosition < 0.10 ||
      candlePosition > 0.90
   )
   &&
   !strongTrendBuy
)
{
   candleProtectionBuyBlock = true;
}

if(
   candleDataReady &&
   price > candle[0].high &&
   !strongTrendBuy
)
{
   candleProtectionBuyBlock = true;
}

//--------------------------------------------------
// SELL protection
//--------------------------------------------------

// Не продаём:
// SELL запрещён:
//   <10%
//   >90%

if(
   candlePosition < 0.10 ||
   candlePosition > 0.90
)
{
   candleProtectionSellBlock = true;
}

if(
   candleDataReady &&
   price < candle[0].low
)
{
   candleProtectionSellBlock = true;
}

//--------------------------------------------------
// Candle Filter Diagnostics
//--------------------------------------------------

string candleBlockReason = "NONE";

if(candlePosition < 0.10)
   candleBlockReason = "LOW_ZONE";

if(candlePosition > 0.90)
   candleBlockReason = "HIGH_ZONE";

if(
   candleDataReady &&
   price < candle[0].low
)
{
   candleBlockReason = "BELOW_LOW";
}


Print(
   "PHX CANDLE FILTER DEBUG: ",
   "CandlePosition=",
   DoubleToString(candlePosition,3),

   " NearHigh=",
   (nearCandleHigh ? "true" : "false"),

   " NearLow=",
   (nearCandleLow ? "true" : "false"),

   " BuyBlock=",
   (candleProtectionBuyBlock ? "true" : "false"),

   " SellBlock=",
   (candleProtectionSellBlock ? "true" : "false"),

   " Reason=",
   candleBlockReason
);
//--------------------------------------------------
// Debug
//--------------------------------------------------

if(PHX_VERBOSE_DEBUG)
{
   Print(
      "PHX Candle Final Protection: ",
      "BUY_BLOCK=",
      candleProtectionBuyBlock,
      " SELL_BLOCK=",
      candleProtectionSellBlock,
      " CandlePos=",
      DoubleToString(candlePosition,2)
   );
}
//--------------------------------------------------
// Reset Signal Before Final Entry Validation
//--------------------------------------------------

m_signal.signal =
   PHX_SIGNAL_NONE;

m_signal.confidence =
   0.0;
//--------------------------------------------------
// Signal Decision Snapshot
//--------------------------------------------------
m_signal.BuyBlockEMA =
   !(price > ma);

m_signal.BuyBlockRSI =
   !finalBuyRSIOK;

m_signal.BuyBlockVolume =
   !(volume >= averageVolume * 0.8);

m_signal.BuyBlockCandle =
   candleProtectionBuyBlock;


m_signal.BuyBlockNearHigh =
(
   nearCandleHigh &&
   !strongTrendBuy
);

m_signal.BuyBlockNearLow =
   nearCandleLow;
//--------------------------------------------------
// SELL
//--------------------------------------------------
m_signal.SellBlockEMA =
   !(price < ma);

m_signal.SellBlockRSI =
   !finalSellRSIOK;

m_signal.SellBlockVolume =
   !(volume >= averageVolume * 0.8);

m_signal.SellBlockCandle =
   candleProtectionSellBlock;

m_signal.SellBlockNearHigh =
   nearCandleHigh;

m_signal.SellBlockNearLow =
   nearCandleLow;
//--------------------------------------------------
// Final Decision
//--------------------------------------------------
m_signal.BuyAllowed =
(
   !m_signal.BuyBlockEMA &&
   !m_signal.BuyBlockRSI &&
   !m_signal.BuyBlockVolume &&
   !m_signal.BuyBlockCandle &&
   !m_signal.BuyBlockNearHigh
);

m_signal.SellAllowed =
(
   !m_signal.SellBlockEMA &&
   !m_signal.SellBlockRSI &&
   !m_signal.SellBlockVolume &&
   !m_signal.SellBlockCandle &&
   !m_signal.SellBlockNearLow
);
//--------------------------------------------------
// Research Decision Snapshot
// One snapshot per M1 bar
//--------------------------------------------------

datetime researchM1Bar =
   iTime(
      _Symbol,
      PERIOD_M1,
      0
   );

if(
   researchM1Bar > 0 &&
   researchM1Bar != m_lastResearchM1Bar
)
{
   if(m_qualityTracker != NULL)
   {
      if(
         (*m_qualityTracker).AddDecisionSnapshot(
            m_signal,
            m_trendSnapshot,
            technicalDailyATR,
            currentD1Range,
            energyUsedPercent,
            energyLeftPercent
         )
      )
      {
         m_lastResearchM1Bar =
            researchM1Bar;
      }
   }
}  
if(PHX_VERBOSE_DEBUG)
{
Print(
   "PHX BUY FILTER: ",
   "Price=",
   DoubleToString(price,_Digits),
   " MA=",
   DoubleToString(ma,_Digits),
   " ATR=",
   DoubleToString(currentATR,_Digits),
   " RSI_OK=",
   buyRSIOK,
   " Volume=",
   DoubleToString(volume,0),
   " Avg=",
   DoubleToString(averageVolume,0),
   " CandlePos=",
   DoubleToString(candlePosition,2)
);
}
Print(
"PHX BUY DEBUG: ",
"PriceMA=",
(price > ma),
" RSI=",
finalBuyRSIOK,
" Volume=",
(volume >= averageVolume * 0.8),
"CandleBlock=",
candleProtectionBuyBlock,
" NearHigh=",
nearCandleHigh
);
Print(
   "PHX SIGNAL BEFORE ENTRY BLOCK: ",
   "BuyResult=",
   IntegerToString(m_trendSnapshot.BuyResult),
   " SellResult=",
   IntegerToString(m_trendSnapshot.SellResult),
   " CurrentSignal=",
   IntegerToString(m_signal.signal)
);
//--------------------------------------------------
// PHX BUY WEAK MOMENTUM PROTECTION
//--------------------------------------------------

bool blockBuyWeakMomentum =
(
   m_trendSnapshot.Trend ==
      PHX_TREND_UP

   &&

   m_trendSnapshot.MomentumDirection <= 0

   &&

   m_trendSnapshot.M1BullSequence < 2

   &&

   m_trendSnapshot.RSIChange < 0

   &&

   m_trendSnapshot.EMASlopeChange <= 0.02
);


if(blockBuyWeakMomentum)
{
   Print(
      "PHX BUY BLOCK: Weak UP momentum ",
      "Momentum=",
      IntegerToString(
         m_trendSnapshot.MomentumDirection
      ),
      " M1Bull=",
      IntegerToString(
         m_trendSnapshot.M1BullSequence
      ),
      " RSIChange=",
      DoubleToString(
         m_trendSnapshot.RSIChange,
         4
      ),
      " EMASlopeChange=",
      DoubleToString(
         m_trendSnapshot.EMASlopeChange,
         4
      )
   );

   m_trendSnapshot.BuyResult =
      PHX_RESULT_FALSE;
}
//--------------------------------------------------
// PHX FINAL BUY VALIDATION GATE
//--------------------------------------------------

bool finalBuyAllowed = true;


// Trend validation
if(
   m_trendSnapshot.BuyResult !=
      PHX_RESULT_TRUE
)
{
   finalBuyAllowed = false;
}


// Momentum validation
if(
   m_trendSnapshot.MomentumDirection <= 0
)
{
   finalBuyAllowed = false;
}


// M1 confirmation
if(
   m_trendSnapshot.M1BullSequence < 2
)
{
   finalBuyAllowed = false;
}


// ADX protection

if(
   adx < 20.0
)
{
   finalBuyAllowed = false;
}


if(!finalBuyAllowed)
{
   Print(
      "PHX FINAL BUY BLOCK: ",
      "TrendResult=",
      IntegerToString(
         m_trendSnapshot.BuyResult
      ),
      " Momentum=",
      IntegerToString(
         m_trendSnapshot.MomentumDirection
      ),
      " M1Bull=",
      IntegerToString(
         m_trendSnapshot.M1BullSequence
      ),
      " ADX=",
      DoubleToString(
         adx,
         2
      )
   );

   m_signal.signal =
      PHX_SIGNAL_NONE;
}
//--------------------------------------------------
// BUY
//--------------------------------------------------
if(
   m_trendSnapshot.BuyResult ==
      PHX_RESULT_TRUE
   &&
   (price > ma) &&
finalBuyRSIOK &&
(volume >= averageVolume * 0.8) &&
(
   !candleProtectionBuyBlock &&
   !nearCandleHigh
)

)

{
Print(
"PHX BUY RSI HARD CHECK: ",
"RSI=",
DoubleToString(rsi,2),
" buyRSIOK=",
buyRSIOK,
" finalBuyRSIOK=",
finalBuyRSIOK
);

Print(
"PHX BUY FINAL CHECK: ",
"NearHigh=",
nearCandleHigh,
" CandleBlock=",
candleProtectionBuyBlock,
" CandlePos=",
DoubleToString(candlePosition,2)
);

   m_signal.signal = PHX_SIGNAL_BUY;
   m_signal.State = PHX_SIGNAL_READY;
   m_signal.BlockReason = PHX_BLOCK_NONE;
   m_signal.confidence = 0.75 * atrConfidence;
   m_signal.reason = PHX_REASON_ALL_FILTERS;
   m_signal.rsi = rsi;
   m_signal.ma = ma;
   m_signal.ATR = currentATR;
   m_signal.volume = volume;
   m_signal.averageVolume = averageVolume;
   Print(
   "PHX ENTRY APPROVED: ",
   "Direction=",
   IntegerToString(m_signal.signal),
   " CandlePosition=",
   DoubleToString(candlePosition,2),
   " RSI=",
   DoubleToString(rsi,2),
   " ATR=",
   DoubleToString(currentATR,3)
);
} // BUY
// SELL condition debug

Print(
   "PHX SELL DEBUG: ",
   "PriceMA=",
   (price < ma),
   " RSI=",
   finalSellRSIOK,
   " Volume=",
   (volume >= averageVolume * 0.8),
   " CandleBlock=",
   candleProtectionSellBlock,
   " NearLow=",
   nearCandleLow
);
//--------------------------------------------------
// Reversal SELL from overextended exhaustion
//--------------------------------------------------
bool reversalSell =
(
   m_trendSnapshot.MarketPhase ==
      PHX_PHASE_EXHAUSTION_UP
   &&
   price > ma
   &&
   candlePosition > 0.60
   &&
   m_trendSnapshot.RSIChange < 0.0
   &&
   m_trendSnapshot.M1BearSequence >= 3
   &&
   m_trendSnapshot.EMASlopeChange < 0
   &&
   m_trendSnapshot.MomentumDirection < 0
);

Print(
   "PHX REV SELL CHECK: ",
   "Phase=",
   EnumToString(m_trendSnapshot.MarketPhase),
   " PriceMA=",
   (price > ma),
   " CandlePos=",
   DoubleToString(candlePosition,2),
   " RSIChange=",
   DoubleToString(m_trendSnapshot.RSIChange,4),
   " M1Bear=",
   IntegerToString(m_trendSnapshot.M1BearSequence)
);
//--------------------------------------------------
// SELL
// Normal SELL with UP trend protection
//--------------------------------------------------
bool trendSell =
(
   price < ma
   &&
   finalSellRSIOK
   &&
   (
      m_trendSnapshot.Trend != PHX_TREND_UP
      ||
      (
         m_trendSnapshot.MomentumDirection < 0
         &&
         m_trendSnapshot.M1BearSequence >= 3
      )
   )
);


Print(
   "PHX TREND SELL FILTER: ",
   "Trend=",
   EnumToString(m_trendSnapshot.Trend),
   " Momentum=",
   IntegerToString(m_trendSnapshot.MomentumDirection),
   " M1Bear=",
   IntegerToString(m_trendSnapshot.M1BearSequence),
   " RSIChange=",
   DoubleToString(m_trendSnapshot.RSIChange,4),
   " EMASlopeChange=",
   DoubleToString(m_trendSnapshot.EMASlopeChange,4),
   " Result=",
   trendSell
);

Print(
   "PHX SELL CONDITION DEBUG: ",
   "trendSell=",
   trendSell,
   " reversalSell=",
   reversalSell,
   " price<ma=",
   (price < ma),
   " finalSellRSIOK=",
   finalSellRSIOK,
   " volumeOK=",
   (volume >= averageVolume * 0.8),
   " candleBlock=",
   candleProtectionSellBlock,
   " nearLow=",
   nearCandleLow
);

//--------------------------------------------------
// PHX SELL AGAINST UP TREND PROTECTION
//--------------------------------------------------

bool blockSellAgainstUpTrend =
(
   m_trendSnapshot.Trend ==
      PHX_TREND_UP

   &&

   m_trendSnapshot.MomentumDirection <= 0

   &&

   m_trendSnapshot.M1BearSequence < 3

   &&

   m_trendSnapshot.RSIChange <= 0

   &&

   m_trendSnapshot.EMASlopeChange <= 0
);


if(blockSellAgainstUpTrend)
{
   Print(
      "PHX SELL BLOCK: Weak reversal against UP trend ",
      "Trend=",
      EnumToString(m_trendSnapshot.Trend),
      " Momentum=",
      IntegerToString(m_trendSnapshot.MomentumDirection),
      " M1Bear=",
      IntegerToString(m_trendSnapshot.M1BearSequence),
      " RSIChange=",
      DoubleToString(m_trendSnapshot.RSIChange,4),
      " EMASlopeChange=",
      DoubleToString(m_trendSnapshot.EMASlopeChange,4)
   );

   trendSell=false;
   reversalSell=false;
}
//--------------------------------------------------
// PHX FINAL SELL VALIDATION GATE
//--------------------------------------------------

bool finalSellAllowed = true;


//--------------------------------------------------
// Validation result
//--------------------------------------------------

if(
   m_trendSnapshot.SellResult !=
      PHX_RESULT_TRUE
)
{
   finalSellAllowed = false;
}


//--------------------------------------------------
// Do not SELL against active UP trend
//--------------------------------------------------

if(
   m_trendSnapshot.Trend ==
      PHX_TREND_UP
)
{
   finalSellAllowed = false;
}


//--------------------------------------------------
// Momentum confirmation
//--------------------------------------------------

if(
   m_trendSnapshot.MomentumDirection >= 0
)
{
   finalSellAllowed = false;
}


//--------------------------------------------------
// M1 bearish confirmation
//--------------------------------------------------

if(
   m_trendSnapshot.M1BearSequence < 2
)
{
   finalSellAllowed = false;
}


//--------------------------------------------------
// ADX protection
//--------------------------------------------------

if(
   adx < 20.0
)
{
   finalSellAllowed = false;
}


//--------------------------------------------------
// Final SELL block
//--------------------------------------------------

if(!finalSellAllowed)
{
   Print(
      "PHX FINAL SELL BLOCK: ",
      "TrendResult=",
      IntegerToString(
         m_trendSnapshot.SellResult
      ),

      " Trend=",
      EnumToString(
         m_trendSnapshot.Trend
      ),

      " Momentum=",
      IntegerToString(
         m_trendSnapshot.MomentumDirection
      ),

      " M1Bear=",
      IntegerToString(
         m_trendSnapshot.M1BearSequence
      ),

      " ADX=",
      DoubleToString(
         adx,
         2
      )
   );


   trendSell=false;
   reversalSell=false;
}
if(
   (
      trendSell
      ||
      reversalSell
   )
   &&
   (volume >= averageVolume * 0.8)
   &&
   (
      !candleProtectionSellBlock
      &&
      !nearCandleLow
   )
)
{
   if(reversalSell)
   {
      Print(
         "PHX REVERSAL SELL: ",
         "MarketPhase=EXHAUSTION_UP ",
         "RSIChange=",
         DoubleToString(m_trendSnapshot.RSIChange,4),
         " M1Bear=",
         IntegerToString(m_trendSnapshot.M1BearSequence)
      );
   }

   m_signal.signal = PHX_SIGNAL_SELL;
   m_signal.State = PHX_SIGNAL_READY;
   m_signal.BlockReason = PHX_BLOCK_NONE;

   m_signal.confidence =
      0.75 * atrConfidence;

   m_signal.reason = PHX_REASON_ALL_FILTERS;
   m_signal.rsi = rsi;
   m_signal.ma = ma;
   m_signal.ATR = currentATR;
   m_signal.volume = volume;
   m_signal.averageVolume = averageVolume;

   Print(
      "PHX ENTRY APPROVED: ",
      "Direction=",
      IntegerToString(m_signal.signal),
      " CandlePosition=",
      DoubleToString(candlePosition,2),
      " RSI=",
      DoubleToString(rsi,2),
      " ATR=",
      DoubleToString(currentATR,3)
   );
}
// SELL
   
//--------------------------------------------------
// M1 Entry Confirmation
//--------------------------------------------------
bool m1Confirmation = false;
MqlRates m1Rates[];
ArraySetAsSeries(
   m1Rates,
   true
);
int m1Copied =
   CopyRates(
      _Symbol,
      PERIOD_M1,
      0,
      3,
      m1Rates
   );
if(m1Copied >= 3)
{
   double m1Open =
      m1Rates[1].open;
   double m1Close =
      m1Rates[1].close;
   if(m_signal.signal == PHX_SIGNAL_BUY)
   {
      if(m1Close > m1Open)
      {
         m1Confirmation = true;
      }
   }
   if(m_signal.signal == PHX_SIGNAL_SELL)
   {
      if(m1Close < m1Open)
      {
         m1Confirmation = true;
      }
   }
}
Print(
   "PHX M1 Confirmation: ",
   "Signal=",
   IntegerToString(m_signal.signal),
   " Result=",
   m1Confirmation
);
//--------------------------------------------------
// M1 Confirmation Weight
//--------------------------------------------------
if(m_signal.signal == PHX_SIGNAL_BUY)
{
   if(m1Confirmation)
   {
      m_signal.confidence *= 1.10;
      Print(
         "PHX M1 BUY CONFIRMED: Confidence increased"
      );
   }
   else
   {
      m_signal.confidence *= 0.90;

      Print(
         "PHX M1 BUY NOT CONFIRMED: Confidence reduced"
      );
   }
}
if(m_signal.signal == PHX_SIGNAL_SELL)
{
   if(m1Confirmation)
   {
      m_signal.confidence *= 1.10;
      Print(
         "PHX M1 SELL CONFIRMED: Confidence increased"
      );
   }
   else
   {
      m_signal.confidence *= 0.90;
      Print(
         "PHX M1 SELL NOT CONFIRMED: Confidence reduced"
      );
   }
}
//--------------------------------------------------
// Prevent repeated signal on same candle
//--------------------------------------------------
static datetime lastSignalBar = 0;

static ENUM_PHX_SIGNAL
   lastSignalDirection =
   PHX_SIGNAL_NONE;
   
   datetime currentBar =
   iTime(
      _Symbol,
      PERIOD_CURRENT,
      0
   );
if(m_signal.signal != PHX_SIGNAL_NONE)
{
   if(
   currentBar == lastSignalBar
   &&
   m_signal.signal ==
      lastSignalDirection
)
   { 
   Print(
         "PHX SIGNAL BLOCKED: Same direction duplicate"
      );
      m_signal.signal = PHX_SIGNAL_NONE;
      m_signal.confidence = 0.0;
   }
}
//--------------------------------------------------
// Process New Final Signal
//--------------------------------------------------
bool isNewSignal = false;
if(
   m_state != NULL &&
   (
      m_signal.signal == PHX_SIGNAL_BUY ||
      m_signal.signal == PHX_SIGNAL_SELL
   )
)
{
   isNewSignal =
      (*m_state).IsNewSignal(m_signal);
}
if(isNewSignal)
{
   //--------------------------------------------------
   // Remember final signal
   //--------------------------------------------------
   lastSignalBar =
      currentBar;

   lastSignalDirection =
      m_signal.signal;
   //--------------------------------------------------
   // Fixed Signal Marker
   //--------------------------------------------------
   if(m_marker != NULL)
   {
      if(m_signal.signal == PHX_SIGNAL_BUY)
      {
         (*m_marker).DrawBuy(
            m_signal.time,
            m_signal.price
         );

         Print(
            "PHX FIXED BUY SIGNAL ",
            _Symbol,
            " Price=",
            DoubleToString(
               m_signal.price,
               _Digits
            )
         );
      }
      else
      if(m_signal.signal == PHX_SIGNAL_SELL)
      {
         (*m_marker).DrawSell(
            m_signal.time,
            m_signal.price
         );
         Print(
            "PHX FIXED SELL SIGNAL ",
            _Symbol,
            " Price=",
            DoubleToString(
               m_signal.price,
               _Digits
            )
         );
      }
   }
   //--------------------------------------------------
   // Save Signal To History
   //--------------------------------------------------
   if(m_history != NULL)
   {
      SPHXSignalRecord record;
      record.Reset();
      record.time =
         m_signal.time;
      record.symbol =
         _Symbol;
      record.signal =
         m_signal.signal;
      record.price =
         m_signal.price;
      record.rsi =
         m_signal.rsi;
      record.ma =
         m_signal.ma;
      record.atrEnergy =
      energyLeftPercent;
      record.atrMomentum =
         currentATR - previousATR;
      record.spread =
         0;
      (*m_history).Add(
         record
      );

      Print(
         "PHX Signal History: stored ",
         _Symbol
      );
   }
  //--------------------------------------------------
// Signal Quality Tracking
//--------------------------------------------------
if(m_qualityTracker != NULL)
{
   Print(
      "PHX QUALITY TRACKER: CONNECTED"
   );

   (*m_qualityTracker).AddSignal(
   m_signal,
   m_trendSnapshot,
   technicalDailyATR,
   currentD1Range,
   energyUsedPercent,
   energyLeftPercent
);
}
else
{
   Print(
      "PHX QUALITY TRACKER: NULL"
   );
}
   //--------------------------------------------------
   // Update Signal State
   // IMPORTANT: only after all consumers
   //--------------------------------------------------
   (*m_state).Update(
      m_signal
   );
}
   //--------------------------------------------------
   // NO SIGNAL
   //--------------------------------------------------
if(
   m_signal.signal != PHX_SIGNAL_BUY &&
   m_signal.signal != PHX_SIGNAL_SELL
)
{
   m_signal.signal =
      PHX_SIGNAL_NONE;
}
return true;
}
   //+------------------------------------------------------------------+
   //| Is Initialized                                                   |
   //+------------------------------------------------------------------+
   bool CPHXSignalServices::IsInitialized() const
{
   return m_initialized;
}
   //+------------------------------------------------------------------+
   //| Get Signal                                                        |
   //+------------------------------------------------------------------+
   SPHXSignal CPHXSignalServices::GetSignal() const
{
   return m_signal;
}
   //+------------------------------------------------------------------+
   //| Set Indicators                                                   |
   //+------------------------------------------------------------------+
   void CPHXSignalServices::SetIndicators(
   CPHXIndicatorServices* indicators
)
{
   m_indicators = indicators;
}
   //+------------------------------------------------------------------+
   //| Set Market Services                                              |
   //+------------------------------------------------------------------+
   void CPHXSignalServices::SetMarketServices(
   CPHXMarketServices* marketServices
)
{
   m_marketServices = marketServices;
} 
   //--------------------------------------------------
   // Set Quality Tracker
   //--------------------------------------------------

   void CPHXSignalServices::SetQualityTracker(
   CPHXSignalQualityTracker* tracker
)
{
   m_qualityTracker = tracker;
}
   //+------------------------------------------------------------------+
   //| Set ATR Energy                                                   |
   //+------------------------------------------------------------------+
   void CPHXSignalServices::SetATREnergy(
   CPHXATREnergy* atrEnergy
)
{
   m_atrEnergy = atrEnergy;
}
   //+------------------------------------------------------------------+
   //| Set Divergence Configuration                                     |
   //+------------------------------------------------------------------+
   void CPHXSignalServices::SetDivergenceConfig(
   const SPHXDivergenceConfig &config
)
{
   m_divergenceConfig =
      config;
}//+------------------------------------------------------------------+
//| Prepare Divergence Historical Horizon                            |
//+------------------------------------------------------------------+
bool CPHXSignalServices::PrepareDivergenceHistory()
{
   //---------------------------------------------------------------
   // Reset State
   //---------------------------------------------------------------

   m_divergenceHistoryReady =
      false;

   m_divergenceHistoryStartTime =
      0;

   //---------------------------------------------------------------
   // Validate Configuration
   //---------------------------------------------------------------

   if(m_divergenceConfig.HistoryD1Bars <= 0)
      return false;

   //---------------------------------------------------------------
   // Load Completed D1 Bars Only
   //
   // shift 0 = current unfinished D1 bar
   // shift 1 = last completed D1 bar
   //---------------------------------------------------------------

   MqlRates dailyRates[];

   int copied =
      CopyRates(
         _Symbol,
         PERIOD_D1,
         1,
         m_divergenceConfig.HistoryD1Bars,
         dailyRates
      );

   //---------------------------------------------------------------
   // We Require Full Historical Context
   //---------------------------------------------------------------

   if(
      copied !=
      m_divergenceConfig.HistoryD1Bars
   )
   {
      Print(
         "PHX Divergence History: insufficient D1 history. Required=",
         m_divergenceConfig.HistoryD1Bars,
         " Copied=",
         copied
      );

      return false;
   }

   //---------------------------------------------------------------
   // CopyRates places the oldest requested bar at index 0
   //---------------------------------------------------------------

   if(ArraySize(dailyRates) <= 0)
      return false;

   datetime startTime =
      dailyRates[0].time;

   if(startTime <= 0)
      return false;

   //---------------------------------------------------------------
   // History Ready
   //---------------------------------------------------------------

   m_divergenceHistoryStartTime =
      startTime;

   m_divergenceHistoryReady =
      true;

   Print(
      "PHX Divergence History READY: D1Bars=",
      m_divergenceConfig.HistoryD1Bars,
      " StartTime=",
      TimeToString(
         m_divergenceHistoryStartTime,
         TIME_DATE | TIME_MINUTES
      )
   );

   return true;
}
//+------------------------------------------------------------------+
//| Load Divergence Timeframe History                                |
//+------------------------------------------------------------------+
bool CPHXSignalServices::LoadDivergenceHistory(
   MqlRates &rates[]
)
{
   //---------------------------------------------------------------
   // Reset Output
   //---------------------------------------------------------------

   ArrayFree(rates);

   //---------------------------------------------------------------
   // History Must Be Prepared First
   //---------------------------------------------------------------

   if(!m_divergenceHistoryReady)
      return false;

   if(m_divergenceHistoryStartTime <= 0)
      return false;
    
   //---------------------------------------------------------------
   // Determine Divergence Timeframe
   //---------------------------------------------------------------

   ENUM_TIMEFRAMES divergenceTF =
      PERIOD_CURRENT;

   if(m_divergenceConfig.UseDivergenceTF)
   {
      divergenceTF =
         m_divergenceConfig.DivergenceTF;
   }

   //---------------------------------------------------------------
   // Last Completed DivergenceTF Bar
   //---------------------------------------------------------------

   datetime lastClosedBarTime =
      iTime(
         _Symbol,
         divergenceTF,
         1
      );

   if(lastClosedBarTime <= 0)
      return false;

   //---------------------------------------------------------------
   // Validate Historical Interval
   //---------------------------------------------------------------

   if(
      lastClosedBarTime <
      m_divergenceHistoryStartTime
   )
   {
      return false;
   }

   //---------------------------------------------------------------
   // Load From Oldest D1 Context Boundary
   // Through Last Completed DivergenceTF Bar
   //---------------------------------------------------------------

   int copied =
      CopyRates(
         _Symbol,
         divergenceTF,
         m_divergenceHistoryStartTime,
         lastClosedBarTime,
         rates
      );

   if(copied <= 0)
   {
      ArrayFree(rates);

      return false;
   }

   //---------------------------------------------------------------
   // CopyRates Physical Storage:
   // oldest bar is stored at index 0
   //---------------------------------------------------------------

   int available =
      ArraySize(rates);

   if(available <= 0)
   {
      ArrayFree(rates);

      return false;
   }

   //---------------------------------------------------------------
   // Defensive Validation
   //---------------------------------------------------------------

   if(rates[0].time < m_divergenceHistoryStartTime)
   {
      ArrayFree(rates);

      return false;
   }

   if(
      rates[available - 1].time >
      lastClosedBarTime
   )
   {
      ArrayFree(rates);

      return false;
   }

   //---------------------------------------------------------------
   // History Loaded
   //---------------------------------------------------------------

   Print(
      "PHX Divergence TF History READY: Bars=",
      available,
      " First=",
      TimeToString(
         rates[0].time,
         TIME_DATE | TIME_MINUTES
      ),
      " Last=",
      TimeToString(
         rates[available - 1].time,
         TIME_DATE | TIME_MINUTES
      )
   );

   return true;
}
//+------------------------------------------------------------------+
//| Calculate Divergence Rolling Average Range                       |
//+------------------------------------------------------------------+
bool CPHXSignalServices::CalculateDivergenceAvgRange(
   const MqlRates &rates[],
   const int currentIndex,
   double &avgRange
)
{
   //---------------------------------------------------------------
   // Reset Output
   //---------------------------------------------------------------

   avgRange =
      0.0;

   //---------------------------------------------------------------
   // Validate Configuration
   //---------------------------------------------------------------

   int period =
      m_divergenceConfig.AvgRangePeriod;

   if(period <= 0)
      return false;

   //---------------------------------------------------------------
   // Validate Source
   //---------------------------------------------------------------

   int total =
      ArraySize(rates);

   if(total <= 0)
      return false;

   if(
      currentIndex < 0 ||
      currentIndex >= total
   )
   {
      return false;
   }

   //---------------------------------------------------------------
   // We Need A Full Rolling Window
   //---------------------------------------------------------------

   if(
      currentIndex + 1 <
      period
   )
   {
      return false;
   }

   //---------------------------------------------------------------
   // Window Contains Only Current And Earlier Closed Bars
   //
   // Example:
   //
   // period       = 20
   // currentIndex = 19
   //
   // window = bars [0 ... 19]
   //
   // currentIndex = 20
   //
   // window = bars [1 ... 20]
   //
   // No future bars are used.
   //---------------------------------------------------------------

   int firstIndex =
      currentIndex - period + 1;

   double rangeSum =
      0.0;

   for(
      int i = firstIndex;
      i <= currentIndex;
      i++
   )
   {
      double range =
         rates[i].high -
         rates[i].low;

      if(range < 0.0)
         return false;

      rangeSum +=
         range;
   }

   //---------------------------------------------------------------
   // Average Range
   //---------------------------------------------------------------

   avgRange =
      rangeSum /
      (double)period;

   if(avgRange <= 0.0)
   {
      avgRange =
         0.0;

      return false;
   }

   return true;
}
//+------------------------------------------------------------------+
//| Replay Divergence Price Structure                                |
//+------------------------------------------------------------------+
bool CPHXSignalServices::ReplayDivergencePriceStructure(
   const MqlRates &rates[]
)
{
   //---------------------------------------------------------------
   // Validation
   //---------------------------------------------------------------

   if(m_priceStructure == NULL)
      return false;

   int total =
      ArraySize(rates);

   if(total <= 0)
      return false;

   if(m_divergenceConfig.AvgRangePeriod <= 0)
      return false;

   //---------------------------------------------------------------
   // Start From Clean Structure State
   //---------------------------------------------------------------

   (*m_priceStructure).Reset();

   //---------------------------------------------------------------
   // Chronological Replay
   //
   // rates[0] = oldest closed bar
   // rates[N] = newest closed bar
   //---------------------------------------------------------------

   for(
      int i = 0;
      i < total;
      i++
   )
   {
      //------------------------------------------------------------
      // AvgRange Is Not Ready During Warm-Up
      //------------------------------------------------------------

      double avgRange =
         0.0;

      if(
         !CalculateDivergenceAvgRange(
            rates,
            i,
            avgRange
         )
      )
      {
         continue;
      }

      //------------------------------------------------------------
      // Give PriceStructure Only The Value Available At Bar i
      //------------------------------------------------------------

      if(
         !(*m_priceStructure).SetAvgRange(
            avgRange
         )
      )
      {
         return false;
      }
      //------------------------------------------------------------
      // Confirmed Extremes Before Processing
      //------------------------------------------------------------

      SPHXPriceExtreme highBefore =
         (*m_priceStructure).GetLastConfirmedHigh();

      SPHXPriceExtreme lowBefore =
         (*m_priceStructure).GetLastConfirmedLow();
      //------------------------------------------------------------
      // Process This Closed Bar
      //------------------------------------------------------------

      if(
         !(*m_priceStructure).ProcessClosedBar(
            i,
            rates[i]
         )
      )
      {
         return false;
      }
      
      //------------------------------------------------------------
      // Detect Newly Confirmed Price Extreme
      //------------------------------------------------------------

      SPHXPriceExtreme newExtreme;

      if(
         DetectNewConfirmedPriceExtreme(
            highBefore,
            lowBefore,
            newExtreme
         )
      )
      {
         
         //---------------------------------------------------------
         // Build Structural Divergence Pair
         //---------------------------------------------------------

         SPHXPriceExtreme firstExtreme;
         SPHXPriceExtreme intermediateExtreme;
         SPHXPriceExtreme secondExtreme;

         if(
            BuildDivergenceStructuralPair(
               newExtreme,
               firstExtreme,
               intermediateExtreme,
               secondExtreme
            )
         )
         {
            
           
            //------------------------------------------------------
            // Analyze Divergence
            //------------------------------------------------------

            SPHXDivergenceResult divergenceResult;

            if(
               AnalyzeDivergenceStructuralPair(
                  firstExtreme,
                  secondExtreme,
                  divergenceResult
               )
            )
            {
               if(divergenceResult.Valid)
               {
                  
                  //------------------------------------------------------
// Divergence Lifecycle Start
//------------------------------------------------------

bool fullDivergence =
   (
      divergenceResult.Type ==
      PHX_DIVERGENCE_REGULAR_BULLISH
      ||
      divergenceResult.Type ==
      PHX_DIVERGENCE_REGULAR_BEARISH
      ||
      divergenceResult.Type ==
      PHX_DIVERGENCE_HIDDEN_BULLISH
      ||
      divergenceResult.Type ==
      PHX_DIVERGENCE_HIDDEN_BEARISH
   );

if(fullDivergence)
{
   divergenceResult.Status =
      PHX_DIVERGENCE_STATUS_DETECTED;
      
  
   Print(
      "PHX Divergence DETECTED: ",
      "Type=",
      (int)divergenceResult.Type,
      " Status=",
      (int)divergenceResult.Status,
      " Extreme1=",
      TimeToString(
         firstExtreme.ExtremeTime,
         TIME_DATE | TIME_MINUTES
      ),
      " Extreme2=",
      TimeToString(
         secondExtreme.ExtremeTime,
         TIME_DATE | TIME_MINUTES
      ),
      " StructuralLevel=",
      DoubleToString(
         intermediateExtreme.ExtremePrice,
         _Digits
      )
   );
}
               }
            }
         }
   }
}   
 
   //---------------------------------------------------------------
   // At Minimum AvgRange Must Be Ready
   //---------------------------------------------------------------
   if(
      !(*m_priceStructure).IsAvgRangeReady()
   )
   {
      return false;
   }
   Print(
      "PHX Divergence Price Structure REPLAY READY: Bars=",
      total,
      " AvgRange=",
      DoubleToString(
         (*m_priceStructure).GetAvgRange(),
         _Digits
      ),
      " StructureReady=",
      (*m_priceStructure).IsPriceStructureReady(),
      " TypicalSwingReady=",
      (*m_priceStructure).IsTypicalSwingReady()
   );
   return true;
}
//+------------------------------------------------------------------+
//| Detect New Confirmed Price Extreme                               |
//+------------------------------------------------------------------+
bool CPHXSignalServices::DetectNewConfirmedPriceExtreme(
   const SPHXPriceExtreme &highBefore,
   const SPHXPriceExtreme &lowBefore,
   SPHXPriceExtreme &newExtreme
)
{
   //---------------------------------------------------------------
   // Reset Output
   //---------------------------------------------------------------
   newExtreme.Reset();
   //---------------------------------------------------------------
   // Validate Price Structure
   //---------------------------------------------------------------
   if(m_priceStructure == NULL)
      return false;
   //---------------------------------------------------------------
   // Current Confirmed Extremes
   //---------------------------------------------------------------
   SPHXPriceExtreme highAfter =
      (*m_priceStructure).GetLastConfirmedHigh();
   SPHXPriceExtreme lowAfter =
      (*m_priceStructure).GetLastConfirmedLow();
      //---------------------------------------------------------------
   // Detect New Confirmed High
   //---------------------------------------------------------------
   bool newHigh =
      (
         highAfter.Type ==
         PHX_EXTREMUM_HIGH
         &&
         (
            highBefore.Type !=
            PHX_EXTREMUM_HIGH
            ||
            highAfter.ExtremeTime !=
            highBefore.ExtremeTime
         )
      );
   //---------------------------------------------------------------
   // Detect New Confirmed Low
   //---------------------------------------------------------------
   bool newLow =
      (
         lowAfter.Type ==
         PHX_EXTREMUM_LOW
         &&
         (
            lowBefore.Type !=
            PHX_EXTREMUM_LOW
            ||
            lowAfter.ExtremeTime !=
            lowBefore.ExtremeTime
         )
      );
   //---------------------------------------------------------------
   // No New Confirmed Extreme
   //---------------------------------------------------------------
   if(
      !newHigh &&
      !newLow
   )
   {
      return false;
   }
   //---------------------------------------------------------------
   // Structural State Machine Should Confirm Only One New Extreme
   // Per Processed Closed Bar.
   //
   // If both appear simultaneously, do not invent ordering.
   //---------------------------------------------------------------
   if(
      newHigh &&
      newLow
   )
   {
      Print(
         "PHX Divergence Structure WARNING: ",
         "HIGH and LOW confirmed on the same processed bar"
      );
      return false;
   }
   //---------------------------------------------------------------
   // Return New High
   //---------------------------------------------------------------
   if(newHigh)
   {
      newExtreme =
         highAfter;
      return true;
   }
   //---------------------------------------------------------------
   // Return New Low
   //---------------------------------------------------------------
   newExtreme =
      lowAfter;
   return true;
}
//+------------------------------------------------------------------+
//| Build Divergence Structural Pair                                 |
//+------------------------------------------------------------------+
bool CPHXSignalServices::BuildDivergenceStructuralPair(
   const SPHXPriceExtreme &newExtreme,
   SPHXPriceExtreme &firstExtreme,
   SPHXPriceExtreme &intermediateExtreme,
   SPHXPriceExtreme &secondExtreme
)
{
   //---------------------------------------------------------------
   // Reset Outputs
   //---------------------------------------------------------------
   firstExtreme.Reset();
   intermediateExtreme.Reset();
   secondExtreme.Reset();
   //---------------------------------------------------------------
   // Validate Price Structure
   //---------------------------------------------------------------
   if(m_priceStructure == NULL)
      return false;
   //---------------------------------------------------------------
   // HIGH Pair
   //
   // H1 -> L1 -> H2
   //---------------------------------------------------------------
   if(
      newExtreme.Type ==
      PHX_EXTREMUM_HIGH
   )
   {
      firstExtreme =
         (*m_priceStructure).GetPreviousConfirmedHigh();
      intermediateExtreme =
         (*m_priceStructure).GetIntermediateLowForHighPair();
      secondExtreme =
         (*m_priceStructure).GetLastConfirmedHigh();
      //------------------------------------------------------------
      // Validate Types
      //------------------------------------------------------------
      if(
         firstExtreme.Type !=
         PHX_EXTREMUM_HIGH
      )
      {
         return false;
      }
      if(
         intermediateExtreme.Type !=
         PHX_EXTREMUM_LOW
      )
      {
         return false;
      }
      if(
         secondExtreme.Type !=
         PHX_EXTREMUM_HIGH
      )
      {
         return false;
      }
   }
   //---------------------------------------------------------------
   // LOW Pair
   //
   // L1 -> H1 -> L2
   //---------------------------------------------------------------
   else
   if(
      newExtreme.Type ==
      PHX_EXTREMUM_LOW
   )
   {
      firstExtreme =
         (*m_priceStructure).GetPreviousConfirmedLow();
      intermediateExtreme =
         (*m_priceStructure).GetIntermediateHighForLowPair();
      secondExtreme =
         (*m_priceStructure).GetLastConfirmedLow();
      //------------------------------------------------------------
      // Validate Types
      //------------------------------------------------------------
      if(
         firstExtreme.Type !=
         PHX_EXTREMUM_LOW
      )
      {
         return false;
      }
      if(
         intermediateExtreme.Type !=
         PHX_EXTREMUM_HIGH
      )
      {
         return false;
      }
      if(
         secondExtreme.Type !=
         PHX_EXTREMUM_LOW
      )
      {
         return false;
      }
   }
   //---------------------------------------------------------------
   // Unknown Extreme Type
   //---------------------------------------------------------------
   else
   {
      return false;
   }
   //---------------------------------------------------------------
   // Validate Chronological Order
   //---------------------------------------------------------------
   if(
      firstExtreme.ExtremeTime >=
      intermediateExtreme.ExtremeTime
   )
   {
      return false;
   }
   if(
      intermediateExtreme.ExtremeTime >=
      secondExtreme.ExtremeTime
   )
   {
      return false;
   }
   //---------------------------------------------------------------
   // Second Extreme Must Be The Newly Confirmed Extreme
   //---------------------------------------------------------------
   if(
      secondExtreme.ExtremeTime !=
      newExtreme.ExtremeTime
   )
   {
      return false;
   }
   return true;
}
//+------------------------------------------------------------------+
//| Analyze Structural Price Pair                                    |
//+------------------------------------------------------------------+
bool CPHXSignalServices::AnalyzeDivergenceStructuralPair(
   const SPHXPriceExtreme &firstExtreme,
   const SPHXPriceExtreme &secondExtreme,
   SPHXDivergenceResult &result
)
{
   //---------------------------------------------------------------
   // Reset Output
   //---------------------------------------------------------------

   result.Reset();

   //---------------------------------------------------------------
   // Validate Services
   //---------------------------------------------------------------

   if(m_ppo == NULL)
      return false;

   if(!(*m_ppo).IsInitialized())
      return false;

   if(m_divergenceEngine == NULL)
      return false;

   if(m_priceStructure == NULL)
      return false;

   //---------------------------------------------------------------
   // Validate Structural Pair
   //---------------------------------------------------------------

   if(
      firstExtreme.Type !=
      secondExtreme.Type
   )
   {
      return false;
   }

   if(
      firstExtreme.Type != PHX_EXTREMUM_HIGH &&
      firstExtreme.Type != PHX_EXTREMUM_LOW
   )
   {
      return false;
   }

   if(
      firstExtreme.ExtremeTime <= 0 ||
      secondExtreme.ExtremeTime <= 0
   )
   {
      return false;
   }

   if(
      firstExtreme.ExtremeTime >=
      secondExtreme.ExtremeTime
   )
   {
      return false;
   }

   //---------------------------------------------------------------
   // Current Causal Price Background
   //---------------------------------------------------------------

   double avgRange =
      (*m_priceStructure).GetAvgRange();

   if(avgRange <= 0.0)
      return false;

   //---------------------------------------------------------------
   // Analyze Price <-> PPO Pair
   //---------------------------------------------------------------

   if(
      !(*m_divergenceEngine).AnalyzePair(
         m_ppo,
         firstExtreme,
         secondExtreme,
         m_divergenceConfig.DivergenceMatchToleranceBars,
         m_divergenceConfig.ExtremumLocalDepthBars,
         m_divergenceConfig.PPOChangePeriod,
         avgRange,
         m_divergenceConfig.PriceFlatThreshold,
         m_divergenceConfig.PPOFlatThreshold,
         result
      )
   )
   {
      return false;
   }

   return true;
}

//+------------------------------------------------------------------+
//| Classify Divergence Context                                      |
//+------------------------------------------------------------------+
ENUM_PHX_DIVERGENCE_CONTEXT
CPHXSignalServices::ClassifyDivergenceContext(
   const ENUM_PHX_DIVERGENCE_TYPE divergenceType
) const
{
   //---------------------------------------------------------------
   // D1 Trend Context Must Exist
   //---------------------------------------------------------------

   if(m_d1TrendContext == NULL)
      return PHX_DIVERGENCE_CONTEXT_NEUTRAL;

   if(!(*m_d1TrendContext).IsReady())
      return PHX_DIVERGENCE_CONTEXT_NEUTRAL;

   //---------------------------------------------------------------
   // Current D1 Trend State
   //---------------------------------------------------------------

   SPHXD1TrendContext d1Context =
      (*m_d1TrendContext).GetContext();

   ENUM_PHX_D1_TREND_STATE d1Trend =
      d1Context.CurrentTrend;

   //---------------------------------------------------------------
   // D1 BULLISH
   //---------------------------------------------------------------

   if(
      d1Trend ==
      PHX_D1_TREND_BULLISH
   )
   {
      if(
         divergenceType ==
         PHX_DIVERGENCE_HIDDEN_BULLISH
      )
      {
         return
            PHX_DIVERGENCE_CONTEXT_CONTINUATION;
      }

      if(
         divergenceType ==
         PHX_DIVERGENCE_REGULAR_BEARISH
      )
      {
         return
            PHX_DIVERGENCE_CONTEXT_REVERSAL_WARNING;
      }
   }

   //---------------------------------------------------------------
   // D1 BEARISH
   //---------------------------------------------------------------

   if(
      d1Trend ==
      PHX_D1_TREND_BEARISH
   )
   {
      if(
         divergenceType ==
         PHX_DIVERGENCE_HIDDEN_BEARISH
      )
      {
         return
            PHX_DIVERGENCE_CONTEXT_CONTINUATION;
      }

      if(
         divergenceType ==
         PHX_DIVERGENCE_REGULAR_BULLISH
      )
      {
         return
            PHX_DIVERGENCE_CONTEXT_REVERSAL_WARNING;
      }
   }

   //---------------------------------------------------------------
   // D1 TRANSITION DOWN
   //---------------------------------------------------------------

   if(
      d1Trend ==
      PHX_D1_TREND_TRANSITION_DOWN
   )
   {
      if(
         divergenceType ==
         PHX_DIVERGENCE_REGULAR_BEARISH
      )
      {
         return
            PHX_DIVERGENCE_CONTEXT_TREND_CHANGE_CONFIRMATION;
      }

      if(
         divergenceType ==
         PHX_DIVERGENCE_HIDDEN_BULLISH
      )
      {
         return
            PHX_DIVERGENCE_CONTEXT_CONFLICT;
      }
   }

   //---------------------------------------------------------------
   // D1 TRANSITION UP
   //---------------------------------------------------------------

   if(
      d1Trend ==
      PHX_D1_TREND_TRANSITION_UP
   )
   {
      if(
         divergenceType ==
         PHX_DIVERGENCE_REGULAR_BULLISH
      )
      {
         return
            PHX_DIVERGENCE_CONTEXT_TREND_CHANGE_CONFIRMATION;
      }

      if(
         divergenceType ==
         PHX_DIVERGENCE_HIDDEN_BEARISH
      )
      {
         return
            PHX_DIVERGENCE_CONTEXT_CONFLICT;
      }
   }

   //---------------------------------------------------------------
   // Research Default
   //---------------------------------------------------------------

   return
      PHX_DIVERGENCE_CONTEXT_NEUTRAL;
}
//+------------------------------------------------------------------+
//| Capture Active Divergence RSI                                    |
//+------------------------------------------------------------------+
bool CPHXSignalServices::CaptureActiveDivergenceRSI()
{
   //---------------------------------------------------------------
   // Validate Indicator Services
   //---------------------------------------------------------------

   if(m_indicators == NULL)
      return false;

   //---------------------------------------------------------------
   // Existing RSI Service
   //---------------------------------------------------------------

   CPHXRSI* rsiService =
      (*m_indicators).GetRSI();

   if(rsiService == NULL)
      return false;

   //---------------------------------------------------------------
   // Read Existing RSI Value
   //---------------------------------------------------------------

   double rsi =
      (*rsiService).GetValue();

   if(rsi <= 0.0)
      return false;

   //---------------------------------------------------------------
   // Store Snapshot
   //---------------------------------------------------------------

   m_activeDivergenceProfile.RSI =
      rsi;

   Print(
      "PHX Divergence RSI SNAPSHOT: ",
      "Type=",
      (int)m_activeDivergence.Type,
      " RSI=",
      DoubleToString(
         m_activeDivergenceProfile.RSI,
         2
      )
   );

   return true;
}
//+------------------------------------------------------------------+
//| Capture Active Divergence ADX                                    |
//+------------------------------------------------------------------+
bool CPHXSignalServices::CaptureActiveDivergenceADX()
{
   //---------------------------------------------------------------
   // Validate Indicator Services
   //---------------------------------------------------------------

   if(m_indicators == NULL)
      return false;

   //---------------------------------------------------------------
   // Existing ADX Service
   //---------------------------------------------------------------

   CPHXADX* adxService =
      (*m_indicators).GetADX();

   if(adxService == NULL)
      return false;

   if(!(*adxService).IsInitialized())
      return false;

   //---------------------------------------------------------------
   // Read Existing ADX Value
   //---------------------------------------------------------------

   double adx =
      (*adxService).GetADX();

   if(adx <= 0.0)
      return false;

   //---------------------------------------------------------------
   // Store Snapshot
   //---------------------------------------------------------------

   m_activeDivergenceProfile.ADXLevel =
      adx;

   //---------------------------------------------------------------
   // Previous ADX
   //---------------------------------------------------------------

   double previousADX =
   (*adxService).GetPreviousADX();

   if(previousADX <= 0.0)
   return false;


   //---------------------------------------------------------------
   // ADX Direction
   //---------------------------------------------------------------

   if(adx > previousADX)
{
   m_activeDivergenceProfile.ADXDirection =
      PHX_SERIES_DIRECTION_RISING;
}
else
   if(adx < previousADX)
{
   m_activeDivergenceProfile.ADXDirection =
      PHX_SERIES_DIRECTION_FALLING;
}
else
{
   m_activeDivergenceProfile.ADXDirection =
      PHX_SERIES_DIRECTION_FLAT;
}

   Print(
      "PHX Divergence ADX SNAPSHOT: ",
      "Type=",
      (int)m_activeDivergence.Type,
      " ADX=",
      DoubleToString(
         m_activeDivergenceProfile.ADXLevel,
         2
      ),
      " Direction=",
      (int)m_activeDivergenceProfile.ADXDirection
   );

   return true;
}
//+------------------------------------------------------------------+
//| Capture Active Divergence Volume                                 |
//+------------------------------------------------------------------+
bool CPHXSignalServices::CaptureActiveDivergenceVolume()
{
   //---------------------------------------------------------------
   // Validate Indicator Services
   //---------------------------------------------------------------

   if(m_indicators == NULL)
      return false;

   //---------------------------------------------------------------
   // Existing Volume Service
   //---------------------------------------------------------------
   CPHXVolumeAnalyzer* volumeService =
      (*m_indicators).GetVolume();
   if(volumeService == NULL)
      return false;
   //---------------------------------------------------------------
   // Read Existing Volume Data
   //---------------------------------------------------------------
   double volume =
      (double)(*volumeService).GetCurrentVolume();
   double averageVolume =
      (*volumeService).GetAverageVolume();
   if(volume <= 0.0)
      return false;
   if(averageVolume <= 0.0)
      return false;
   //---------------------------------------------------------------
   // Store Snapshot
   //---------------------------------------------------------------
   m_activeDivergenceProfile.Volume =
      volume;
   m_activeDivergenceProfile.AverageVolume =
      averageVolume;
   m_activeDivergenceProfile.RelativeVolume =
      volume / averageVolume;
   //---------------------------------------------------------------
   // Previous Volume
   //---------------------------------------------------------------
   double previousVolume =
   (double)(*volumeService).GetPreviousVolume();
   if(previousVolume <= 0.0)
   return false;
//---------------------------------------------------------------
// Volume Direction
//---------------------------------------------------------------
if(volume > previousVolume)
{
   m_activeDivergenceProfile.VolumeDirection =
      PHX_SERIES_DIRECTION_RISING;
}
else
if(volume < previousVolume)
{
   m_activeDivergenceProfile.VolumeDirection =
      PHX_SERIES_DIRECTION_FALLING;
}
else
{
   m_activeDivergenceProfile.VolumeDirection =
      PHX_SERIES_DIRECTION_FLAT;
}

   Print(
      "PHX Divergence VOLUME SNAPSHOT: ",
      "Type=",
      (int)m_activeDivergence.Type,
      " Volume=",
      DoubleToString(
         m_activeDivergenceProfile.Volume,
         0
      ),
      " Average=",
      DoubleToString(
         m_activeDivergenceProfile.AverageVolume,
         0
      ),
      " Relative=",
      DoubleToString(
         m_activeDivergenceProfile.RelativeVolume,
         2
      )
   );
   return true;
}
//+------------------------------------------------------------------+
//| Update Active Divergence Confirmation                            |
//+------------------------------------------------------------------+
bool CPHXSignalServices::UpdateActiveDivergenceConfirmation(
   const int barIndex,
   const MqlRates &bar
)
{
   //---------------------------------------------------------------
   // No Active Divergence
   //---------------------------------------------------------------
   if(!m_activeDivergenceWaiting)
      return true;
   //---------------------------------------------------------------
   // Validate Active State
   //---------------------------------------------------------------
   if(
      !m_activeDivergence.Valid ||
      m_activeDivergence.Status !=
      PHX_DIVERGENCE_STATUS_WAITING_CONFIRMATION
   )
   {
      return false;
   }

   if(
      m_activeDivergenceConfirmation.BreakLevel <=
      0.0
   )
   {
      return false;
   }
   //---------------------------------------------------------------
   // Do Not Confirm On Or Before The Second Price Extreme
   //---------------------------------------------------------------

   datetime secondExtremeTime =
      m_activeDivergence.Second.Price.ExtremeTime;

   if(secondExtremeTime <= 0)
      return false;

   if(bar.time <= secondExtremeTime)
      return true;

   //---------------------------------------------------------------
   // Determine Divergence Direction
   //---------------------------------------------------------------

   bool bullish =
      (
         m_activeDivergence.Type ==
         PHX_DIVERGENCE_REGULAR_BULLISH
         ||
         m_activeDivergence.Type ==
         PHX_DIVERGENCE_HIDDEN_BULLISH
      );

   bool bearish =
      (
         m_activeDivergence.Type ==
         PHX_DIVERGENCE_REGULAR_BEARISH
         ||
         m_activeDivergence.Type ==
         PHX_DIVERGENCE_HIDDEN_BEARISH
      );

   if(
      !bullish &&
      !bearish
   )
   {
      return false;
   }
   //---------------------------------------------------------------
   // Invalidate Only By CLOSED Price
   //---------------------------------------------------------------

   double secondExtremePrice =
      m_activeDivergence.Second.Price.ExtremePrice;

   if(secondExtremePrice <= 0.0)
      return false;

   bool invalidated =
      false;

   //---------------------------------------------------------------
   // Bullish Divergence Invalidation
   //
   // Close below second LOW destroys bullish hypothesis.
   //---------------------------------------------------------------

   if(
      bullish &&
      bar.close < secondExtremePrice
   )
   {
      invalidated =
         true;
   }

   //---------------------------------------------------------------
   // Bearish Divergence Invalidation
   //
   // Close above second HIGH destroys bearish hypothesis.
   //---------------------------------------------------------------

   if(
      bearish &&
      bar.close > secondExtremePrice
   )
   {
      invalidated =
         true;
   }

   //---------------------------------------------------------------
   // Finalize Invalidated Lifecycle
   //---------------------------------------------------------------

   if(invalidated)
   {
      m_activeDivergence.Status =
         PHX_DIVERGENCE_STATUS_INVALIDATED;
         
         m_divergenceEngine.AddInvalidated();

      m_activeDivergenceWaiting =
         false;

      Print(
         "PHX Divergence INVALIDATED: ",
         "Type=",
         (int)m_activeDivergence.Type,
         " SecondExtremePrice=",
         DoubleToString(
            secondExtremePrice,
            _Digits
         ),
         " Close=",
         DoubleToString(
            bar.close,
            _Digits
         ),
         " Time=",
         TimeToString(
            bar.time,
            TIME_DATE | TIME_MINUTES
         )
      );

      return true;
   }
   //---------------------------------------------------------------
   // Confirm Only By CLOSED Price
   //---------------------------------------------------------------

   bool confirmed =
      false;

   double breakDistance =
      0.0;

   if(
      bullish &&
      bar.close >
      m_activeDivergenceConfirmation.BreakLevel
   )
   {
      confirmed =
         true;

      breakDistance =
         bar.close -
         m_activeDivergenceConfirmation.BreakLevel;
   }

   if(
      bearish &&
      bar.close <
      m_activeDivergenceConfirmation.BreakLevel
   )
   {
      confirmed =
         true;

      breakDistance =
         m_activeDivergenceConfirmation.BreakLevel -
         bar.close;
   }

   //---------------------------------------------------------------
   // Intrabar Penetration Is NOT Confirmation
   //---------------------------------------------------------------

   if(!confirmed)
      return true;

   //---------------------------------------------------------------
   // AvgRange For Normalized Break Strength
   //---------------------------------------------------------------

   if(m_priceStructure == NULL)
      return false;

   double avgRange =
      (*m_priceStructure).GetAvgRange();

   if(avgRange <= 0.0)
      return false;

   //---------------------------------------------------------------
   // Store Confirmation
   //---------------------------------------------------------------

   m_activeDivergenceConfirmation.BreakBar =
      barIndex;

   m_activeDivergenceConfirmation.BreakTime =
      bar.time;

   m_activeDivergenceConfirmation.BreakPrice =
      bar.close;

   m_activeDivergenceConfirmation.BreakDistance =
      breakDistance;

   m_activeDivergenceConfirmation.BreakDistanceNorm =
      breakDistance / avgRange;

   //---------------------------------------------------------------
   // Confirmation Delay
   //
   // Use TIME -> SHIFT conversion because LIVE rolling barIndex
   // is not a global chronological bar number.
   //---------------------------------------------------------------

   ENUM_TIMEFRAMES divergenceTF =
      PERIOD_CURRENT;

   if(m_divergenceConfig.UseDivergenceTF)
   {
      divergenceTF =
         m_divergenceConfig.DivergenceTF;
   }

   int secondExtremeShift =
      iBarShift(
         _Symbol,
         divergenceTF,
         secondExtremeTime,
         true
      );

   int breakShift =
      iBarShift(
         _Symbol,
         divergenceTF,
         bar.time,
         true
      );

   if(
      secondExtremeShift > 0 &&
      breakShift > 0
   )
   {
      m_activeDivergenceConfirmation.ConfirmationDelayBars =
         secondExtremeShift -
         breakShift;
   }
   else
   {
      m_activeDivergenceConfirmation.ConfirmationDelayBars =
         0;
   }

   //---------------------------------------------------------------
   // Finalize Lifecycle
   //---------------------------------------------------------------

   m_activeDivergenceConfirmation.Confirmed =
      true;

   m_activeDivergence.Status =
      PHX_DIVERGENCE_STATUS_CONFIRMED;
      
      m_divergenceEngine.AddConfirmed();

   m_activeDivergenceWaiting =
      false;
  
   //---------------------------------------------------------------
   // Divergence Research Timeframe
   //---------------------------------------------------------------

   ENUM_TIMEFRAMES divergenceResearchTF =
   PERIOD_CURRENT;

   if(m_divergenceConfig.UseDivergenceTF)
{
   divergenceResearchTF =
      m_divergenceConfig.DivergenceTF;
}     
   //---------------------------------------------------------------
   // Research Quality Tracking
   //---------------------------------------------------------------

   if(m_qualityTracker != NULL)
{
   if(
   !(*m_qualityTracker).AddConfirmedDivergence(
      m_activeDivergence,
      m_activeDivergenceProfile,
      m_activeDivergenceConfirmation,
      divergenceResearchTF
   )
   )
   {
      Print(
         "PHX Divergence WARNING: ",
         "Quality Tracker rejected confirmed divergence"
      );
   }
}
else
{
   Print(
      "PHX Divergence WARNING: ",
      "Quality Tracker is NULL"
   );
}   
      

   //---------------------------------------------------------------
   // Diagnostics
   //---------------------------------------------------------------

   Print(
      "PHX Divergence CONFIRMED: ",
      "Type=",
      (int)m_activeDivergence.Type,
      " BreakLevel=",
      DoubleToString(
         m_activeDivergenceConfirmation.BreakLevel,
         _Digits
      ),
      " Close=",
      DoubleToString(
         bar.close,
         _Digits
      ),
      " BreakDistance=",
      DoubleToString(
         m_activeDivergenceConfirmation.BreakDistance,
         _Digits
      ),
      " BreakDistanceNorm=",
      DoubleToString(
         m_activeDivergenceConfirmation.BreakDistanceNorm,
         4
      ),
      " DelayBars=",
      m_activeDivergenceConfirmation.ConfirmationDelayBars
   );

   return true;
}
//+------------------------------------------------------------------+
//| Update Divergence Price Structure                                |
//+------------------------------------------------------------------+
bool CPHXSignalServices::UpdateDivergencePriceStructure()
{
   //---------------------------------------------------------------
   // Divergence Disabled
   //---------------------------------------------------------------

   if(!m_divergenceConfig.UseDivergence)
      return true;

   //---------------------------------------------------------------
   // Validate Service
   //---------------------------------------------------------------

   if(m_priceStructure == NULL)
      return false;

   //---------------------------------------------------------------
   // Validate Live State
   //---------------------------------------------------------------

   if(m_lastDivergenceClosedBarTime <= 0)
      return false;

   //---------------------------------------------------------------
   // Determine Divergence Timeframe
   //---------------------------------------------------------------

   ENUM_TIMEFRAMES divergenceTF =
      PERIOD_CURRENT;

   if(m_divergenceConfig.UseDivergenceTF)
   {
      divergenceTF =
         m_divergenceConfig.DivergenceTF;
   }

   //---------------------------------------------------------------
   // Current Last Closed Bar
   //---------------------------------------------------------------

   datetime latestClosedBarTime =
      iTime(
         _Symbol,
         divergenceTF,
         1
      );

   if(latestClosedBarTime <= 0)
      return false;

   //---------------------------------------------------------------
   // Nothing New
   //---------------------------------------------------------------

   if(
      latestClosedBarTime <=
      m_lastDivergenceClosedBarTime
   )
   {
      return true;
   }

   //---------------------------------------------------------------
   // Validate AvgRange Period
   //---------------------------------------------------------------

   int period =
      m_divergenceConfig.AvgRangePeriod;

   if(period <= 0)
      return false;

   //---------------------------------------------------------------
   // Determine First Unprocessed Closed Bar
   //
   // We ask for the bar immediately AFTER the last processed bar.
   //---------------------------------------------------------------

   datetime firstUnprocessedTime =
      m_lastDivergenceClosedBarTime + 1;

   //---------------------------------------------------------------
   // Load All Missing Closed Bars
   //---------------------------------------------------------------

   MqlRates missingRates[];

   int missingCount =
      CopyRates(
         _Symbol,
         divergenceTF,
         firstUnprocessedTime,
         latestClosedBarTime,
         missingRates
      );

   if(missingCount <= 0)
      return false;

   if(ArraySize(missingRates) != missingCount)
      return false;

   //---------------------------------------------------------------
   // CopyRates physical storage:
   // oldest bar = index 0
   // newest bar = index missingCount - 1
   //---------------------------------------------------------------

   for(
      int i = 0;
      i < missingCount;
      i++
   )
   {
      datetime barTime =
         missingRates[i].time;

      //------------------------------------------------------------
      // Defensive Duplicate Protection
      //------------------------------------------------------------

      if(
         barTime <=
         m_lastDivergenceClosedBarTime
      )
      {
         continue;
      }

      //------------------------------------------------------------
      // Find Shift Of This Historical Closed Bar
      //------------------------------------------------------------

      int barShift =
         iBarShift(
            _Symbol,
            divergenceTF,
            barTime,
            true
         );

      if(barShift <= 0)
         return false;

      //------------------------------------------------------------
      // Load Rolling Window Ending At This Bar
      //
      // For example:
      // barShift = 5
      // period   = 20
      //
      // CopyRates(..., 5, 20, ...)
      //
      // loads this closed bar plus 19 older closed bars.
      //------------------------------------------------------------

      MqlRates rollingRates[];

      int copied =
         CopyRates(
            _Symbol,
            divergenceTF,
            barShift,
            period,
            rollingRates
         );

      if(copied != period)
         return false;

      if(ArraySize(rollingRates) != period)
         return false;

      //------------------------------------------------------------
      // Oldest -> Newest physical order
      //------------------------------------------------------------

      int currentIndex =
         period - 1;

      if(
         rollingRates[currentIndex].time !=
         barTime
      )
      {
         return false;
      }

      //------------------------------------------------------------
      // Calculate Causal AvgRange
      //------------------------------------------------------------

      double avgRange =
         0.0;

      if(
         !CalculateDivergenceAvgRange(
            rollingRates,
            currentIndex,
            avgRange
         )
      )
      {
         return false;
      }

      //------------------------------------------------------------
      // Update Price Structure AvgRange
      //------------------------------------------------------------

      if(
         !(*m_priceStructure).SetAvgRange(
            avgRange
         )
      )
      {
         return false;
      }
      //------------------------------------------------------------
      // Confirmed Extremes Before Processing
      //------------------------------------------------------------

      SPHXPriceExtreme highBefore =
         (*m_priceStructure).GetLastConfirmedHigh();

      SPHXPriceExtreme lowBefore =
         (*m_priceStructure).GetLastConfirmedLow();
          //------------------------------------------------------------
      // Process Missing Closed Bar
      //------------------------------------------------------------

      if(
         !(*m_priceStructure).ProcessClosedBar(
            currentIndex,
            rollingRates[currentIndex]
         )
      )
      {
         return false;
      }

      //------------------------------------------------------------
      // Update Active Divergence Confirmation
      //------------------------------------------------------------
      //------------------------------------------------------------
      // Update Active Divergence Confirmation
      //------------------------------------------------------------

      if(
         !UpdateActiveDivergenceConfirmation(
            currentIndex,
            rollingRates[currentIndex]
         )
      )
      {
         Print(
            "PHXSignalServices ERROR: ",
            "Active Divergence confirmation update failed"
         );

         return false;
      }
      //------------------------------------------------------------
      // Detect Newly Confirmed Price Extreme
      //------------------------------------------------------------

      SPHXPriceExtreme newExtreme;

      if(
         DetectNewConfirmedPriceExtreme(
            highBefore,
            lowBefore,
            newExtreme
         )
      )
      {         
         //---------------------------------------------------------
         // Build Structural Divergence Pair
         //---------------------------------------------------------

         SPHXPriceExtreme firstExtreme;
         SPHXPriceExtreme intermediateExtreme;
         SPHXPriceExtreme secondExtreme;

         if(
            BuildDivergenceStructuralPair(
               newExtreme,
               firstExtreme,
               intermediateExtreme,
               secondExtreme
            )
         )
         {                 
            //------------------------------------------------------
            // Analyze Divergence
            //------------------------------------------------------

            SPHXDivergenceResult divergenceResult;

            if(
               AnalyzeDivergenceStructuralPair(
                  firstExtreme,
                  secondExtreme,
                  divergenceResult
               )
            )
            {
               if(divergenceResult.Valid)
               {                  
            //------------------------------------------------------
            // Divergence Lifecycle Start
            //------------------------------------------------------
bool fullDivergence =
   (
      divergenceResult.Type ==
      PHX_DIVERGENCE_REGULAR_BULLISH
      ||
      divergenceResult.Type ==
      PHX_DIVERGENCE_REGULAR_BEARISH
      ||
      divergenceResult.Type ==
      PHX_DIVERGENCE_HIDDEN_BULLISH
      ||
      divergenceResult.Type ==
      PHX_DIVERGENCE_HIDDEN_BEARISH
   );

if(fullDivergence)
{
   //------------------------------------------------------
   // New Divergence Detected
   //------------------------------------------------------
   divergenceResult.Status =
      PHX_DIVERGENCE_STATUS_DETECTED;

   Print(
      "PHX Divergence DETECTED: ",
      "Type=",
      (int)divergenceResult.Type,
      " Status=",
      (int)divergenceResult.Status,
      " Extreme1=",
      TimeToString(
         firstExtreme.ExtremeTime,
         TIME_DATE | TIME_MINUTES
      ),
      " Extreme2=",
      TimeToString(
         secondExtreme.ExtremeTime,
         TIME_DATE | TIME_MINUTES
      ),
      " StructuralLevel=",
      DoubleToString(
         intermediateExtreme.ExtremePrice,
         _Digits
      )
   );
   //------------------------------------------------------
   // D1 Divergence Context
   //------------------------------------------------------
   ENUM_PHX_DIVERGENCE_CONTEXT divergenceContext =
      ClassifyDivergenceContext(
         divergenceResult.Type
      );
   //------------------------------------------------------
   // Store D1 Context In Divergence Result
   //------------------------------------------------------
   divergenceResult.Context =
      divergenceContext;
   SPHXD1TrendContext d1Context =
      (*m_d1TrendContext).GetContext();

   Print(
      "PHX Divergence CONTEXT: ",
      "D1Trend=",
      (int)d1Context.CurrentTrend,
      " DivergenceType=",
      (int)divergenceResult.Type,
      " Context=",
      (int)divergenceResult.Context
   );
   //------------------------------------------------------
   // Determine New Divergence Structural Direction
   //------------------------------------------------------
   bool newBullish =
      (
         divergenceResult.Type ==
         PHX_DIVERGENCE_REGULAR_BULLISH
         ||
         divergenceResult.Type ==
         PHX_DIVERGENCE_HIDDEN_BULLISH
      );
   bool newBearish =
      (
         divergenceResult.Type ==
         PHX_DIVERGENCE_REGULAR_BEARISH
         ||
         divergenceResult.Type ==
         PHX_DIVERGENCE_HIDDEN_BEARISH
      );
   //------------------------------------------------------
   // By Default New Divergence May Become Active
   //------------------------------------------------------
   bool activateNewDivergence =
      true;
   //------------------------------------------------------
   // Existing Divergence Is Still Waiting
   //------------------------------------------------------
   if(m_activeDivergenceWaiting)
   {
      bool activeBullish =
         (
            m_activeDivergence.Type ==
            PHX_DIVERGENCE_REGULAR_BULLISH
            ||
            m_activeDivergence.Type ==
            PHX_DIVERGENCE_HIDDEN_BULLISH
         );

      bool activeBearish =
         (
            m_activeDivergence.Type ==
            PHX_DIVERGENCE_REGULAR_BEARISH
            ||
            m_activeDivergence.Type ==
            PHX_DIVERGENCE_HIDDEN_BEARISH
         );
      //---------------------------------------------------
      // Same Structural Direction
      //
      // New divergence replaces the older hypothesis.
      //---------------------------------------------------
      bool sameDirection =
         (
            (activeBullish && newBullish)
            ||
            (activeBearish && newBearish)
         );

      if(sameDirection)
      {
         m_activeDivergence.Status =
            PHX_DIVERGENCE_STATUS_SUPERSEDED;
            
            m_divergenceEngine.AddSuperseded();
            
         Print(
            "PHX Divergence SUPERSEDED: ",
            "OldType=",
            (int)m_activeDivergence.Type,
            " NewType=",
            (int)divergenceResult.Type,
            " OldBreakLevel=",
            DoubleToString(
               m_activeDivergenceConfirmation.BreakLevel,
               _Digits
            ),
            " NewBreakLevel=",
            DoubleToString(
               intermediateExtreme.ExtremePrice,
               _Digits
            )
         );
      }
      //---------------------------------------------------
      // Opposite Structural Direction
      //
      // INVALIDATED semantics are not implemented yet.
      // Do not silently overwrite the active hypothesis.
      //---------------------------------------------------
      else
      {
         activateNewDivergence =
            false;

         Print(
            "PHX Divergence OPPOSITE DETECTED: ",
            "ActiveType=",
            (int)m_activeDivergence.Type,
            " NewType=",
            (int)divergenceResult.Type,
            " Active divergence remains WAITING"
         );
      }
   }
   //------------------------------------------------------
   // Activate New Divergence
   //------------------------------------------------------
   if(activateNewDivergence)
   {
      m_activeDivergence =
         divergenceResult;
      m_activeIntermediateExtreme =
         intermediateExtreme;
      m_activeDivergenceConfirmation.Reset();      
      m_activeDivergenceProfile.Reset();
      m_activeDivergenceConfirmation.BreakLevel =
         intermediateExtreme.ExtremePrice;
      m_activeDivergence.Status =
         PHX_DIVERGENCE_STATUS_WAITING_CONFIRMATION;
      m_activeDivergenceWaiting =
         true;
   //------------------------------------------------------------
   // Divergence Statistics
   // Lifecycle: WAITING CONFIRMATION
   //------------------------------------------------------------
      m_divergenceEngine.AddWaiting();              
   //---------------------------------------------------
   // Confirmation Profile Snapshot
   //---------------------------------------------------
   bool rsiSnapshotOK =
   CaptureActiveDivergenceRSI();

   bool adxSnapshotOK =
   CaptureActiveDivergenceADX();

   bool volumeSnapshotOK =
   CaptureActiveDivergenceVolume();
   //---------------------------------------------------
   // Snapshot Diagnostics
   //---------------------------------------------------
   if(!rsiSnapshotOK)
{
   Print(
      "PHX Divergence WARNING: ",
      "RSI snapshot unavailable"
   );
}
   if(!adxSnapshotOK)
{
   Print(
      "PHX Divergence WARNING: ",
      "ADX snapshot unavailable"
   );
}
if(!volumeSnapshotOK)
{
   Print(
      "PHX Divergence WARNING: ",
      "Volume snapshot unavailable"
   );
}
//---------------------------------------------------
// Confirmation Profile State
//---------------------------------------------------

m_activeDivergenceProfile.Valid =
   (
      rsiSnapshotOK
      &&
      adxSnapshotOK
      &&
      volumeSnapshotOK
   );
Print(
   "PHX Divergence PROFILE: ",
   "Valid=",
   m_activeDivergenceProfile.Valid,
   " RSI=",
   DoubleToString(
      m_activeDivergenceProfile.RSI,
      2
   ),
   " ADX=",
   DoubleToString(
      m_activeDivergenceProfile.ADXLevel,
      2
   ),
   " ADXDirection=",
   (int)m_activeDivergenceProfile.ADXDirection,
   " RelativeVolume=",
   DoubleToString(
      m_activeDivergenceProfile.RelativeVolume,
      2
   ),
   " VolumeDirection=",
   (int)m_activeDivergenceProfile.VolumeDirection
);
      Print(
         "PHX Divergence WAITING CONFIRMATION: ",
         "Type=",
         (int)m_activeDivergence.Type,
         " BreakLevel=",
         DoubleToString(
            m_activeDivergenceConfirmation.BreakLevel,
            _Digits
         ),
         " SecondExtremeTime=",
         TimeToString(
            secondExtreme.ExtremeTime,
            TIME_DATE | TIME_MINUTES
         )
      );
   }
}
               }
            }
               }
            }       
        
  
      //------------------------------------------------------------
      // Mark This Bar As Processed
      //------------------------------------------------------------

      m_lastDivergenceClosedBarTime =
         barTime;
   }

   return true;
}
   //+------------------------------------------------------------------+
   //| Set Trend Snapshot                                               |
   //+------------------------------------------------------------------+
   void CPHXSignalServices::SetTrendSnapshot(
   const SPHXTrendSnapshot &snapshot
)
{
   m_trendSnapshot =
      snapshot;

  Print(
      "PHX SIGNAL SNAPSHOT RECEIVED: ",
      "Trend=",
      EnumToString(m_trendSnapshot.Trend),
      " Momentum=",
      IntegerToString(m_trendSnapshot.MomentumDirection),
      " Phase=",
      EnumToString(m_trendSnapshot.MarketPhase),
      " BuyResult=",
      IntegerToString(m_trendSnapshot.BuyResult),
      " SellResult=",
      IntegerToString(m_trendSnapshot.SellResult)
   );
}
#endif // __PHX_SIGNAL_SERVICES_MQH__
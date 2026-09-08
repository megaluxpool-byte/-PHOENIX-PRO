#ifndef __PHX_SIGNAL_TYPES_MQH__
#define __PHX_SIGNAL_TYPES_MQH__


//+------------------------------------------------------------------+
//| Signal Direction                                                 |
//+------------------------------------------------------------------+
enum ENUM_PHX_SIGNAL
{
   PHX_SIGNAL_NONE = 0,
   PHX_SIGNAL_BUY  = 1,
   PHX_SIGNAL_SELL = -1
};
//+------------------------------------------------------------------+
//| Signal Reason                                                    |
//+------------------------------------------------------------------+
enum ENUM_PHX_SIGNAL_REASON
{
   PHX_REASON_NONE = 0,
   // Trend
   PHX_REASON_TREND_BUY,
   PHX_REASON_TREND_SELL,
   // RSI
   PHX_REASON_RSI_CONFIRM,
   // Volume
   PHX_REASON_VOLUME_CONFIRM,
   // ADX
   PHX_REASON_ADX_CONFIRM,
   // Combined
   PHX_REASON_ALL_FILTERS
};
//+------------------------------------------------------------------+
//| Signal Block Reason                                              |
//+------------------------------------------------------------------+
enum ENUM_PHX_SIGNAL_BLOCK_REASON
{
   PHX_BLOCK_NONE = 0,
   // Candle
   PHX_BLOCK_CANDLE_HIGH,
   PHX_BLOCK_CANDLE_LOW,
   // Trend
   PHX_BLOCK_TREND,
   // RSI
   PHX_BLOCK_RSI,
   // Volume
   PHX_BLOCK_VOLUME,
   // Momentum
   PHX_BLOCK_MOMENTUM,
   // ATR
   PHX_BLOCK_ATR,
   // Risk
   PHX_BLOCK_RISK
};
//+------------------------------------------------------------------+
//| Primary Block Reason                                             |
//+------------------------------------------------------------------+

enum ENUM_PHX_PRIMARY_BLOCK
{
   PHX_PRIMARY_NONE = 0,

   PHX_PRIMARY_RISK,

   PHX_PRIMARY_TIME,

   PHX_PRIMARY_SPREAD,

   PHX_PRIMARY_TREND,
   
   PHX_PRIMARY_MA2,

   PHX_PRIMARY_RSI,

   PHX_PRIMARY_MOMENTUM,

   PHX_PRIMARY_VOLUME,

   PHX_PRIMARY_CANDLE
};
//+------------------------------------------------------------------+
//| Signal Validation Result                                         |
//+------------------------------------------------------------------+
   //+------------------------------------------------------------------+
   //| Signal State                                                     |
   //+------------------------------------------------------------------+
   enum ENUM_PHX_SIGNAL_STATE
{
   PHX_SIGNAL_STATE_NONE = 0,
   // Signal ready for execution
   PHX_SIGNAL_READY,
   // Signal exists but blocked by filter
   PHX_SIGNAL_BLOCKED,
   // No valid market setup
   PHX_SIGNAL_NO_SETUP,
   // Blocked by risk module
   PHX_SIGNAL_RISK_BLOCKED
}; 
   //--------------------------------------------------
// Market Phase Diagnostics v2
//--------------------------------------------------

enum ENUM_PHX_MARKET_PHASE
{
   PHX_PHASE_UNKNOWN = 0,

   PHX_PHASE_TREND_UP,

   PHX_PHASE_OVEREXTENDED_UP,

   PHX_PHASE_EXHAUSTION_UP,

   PHX_PHASE_EARLY_BEAR_REVERSAL,

   PHX_PHASE_TREND_DOWN,

   PHX_PHASE_OVEREXTENDED_DOWN,

   PHX_PHASE_EXHAUSTION_DOWN,

   PHX_PHASE_EARLY_BULL_REVERSAL
};
//+------------------------------------------------------------------+
//| Signal Result                                                    |
//+------------------------------------------------------------------+
struct SPHXSignal
{
   //--------------------------------------------------
   // Direction
   //--------------------------------------------------
   ENUM_PHX_SIGNAL signal;
   //--------------------------------------------------
   // Confidence score
   //--------------------------------------------------
   double confidence;
   //--------------------------------------------------
   // Price information
   //--------------------------------------------------
   double price;
   //--------------------------------------------------
   // Indicator snapshot
   //--------------------------------------------------
   double ATR;
   
   double ma;

   double rsi;
   
   //--------------------------------------------------
   // RSI Exit Research
   //--------------------------------------------------
   bool RSIExit70;
   bool RSIExit75;
   bool RSIExit78;
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

   double adx;

   double volume;

   double averageVolume;
   //--------------------------------------------------
   // Reason
   //--------------------------------------------------
   ENUM_PHX_SIGNAL_REASON reason;
   ENUM_PHX_SIGNAL_STATE State;
   ENUM_PHX_SIGNAL_BLOCK_REASON BlockReason;
   ENUM_PHX_PRIMARY_BLOCK PrimaryBlock;


   //--------------------------------------------------
   // Time
   //--------------------------------------------------
   datetime time;
   //--------------------------------------------------
   // Reset
   //--------------------------------------------------
   void Reset()
   {
      signal = PHX_SIGNAL_NONE;
      confidence = 0.0;
      price = 0.0;
      ATR = 0.0;     
      ma = 0.0;
      rsi = 0.0;
      RSIExit70 = false;
      RSIExit75 = false;
      RSIExit78 = false;
      
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
      adx = 0.0;
      volume = 0.0;
      averageVolume = 0.0;
      reason = PHX_REASON_NONE;      
      BlockReason = PHX_BLOCK_NONE;
      PrimaryBlock = PHX_PRIMARY_NONE;
      State = PHX_SIGNAL_STATE_NONE; 
      time = 0;
   }
};
//--------------------------------------------------
// Signal History Record  
//--------------------------------------------------
struct SPHXSignalRecord
{
   datetime time;
   string symbol;
   ENUM_PHX_SIGNAL signal;
   double price;
   double rsi;
   double ma;
   double currentATR;
   double baseATR;
   double atrEnergy;
   double atrMomentum;
   double spread;
   void Reset()
   {
      time = 0;
      symbol = "";
      signal = PHX_SIGNAL_NONE;    
     
      price = 0.0;
      rsi = 0.0;
      ma = 0.0;
      currentATR = 0.0;
      baseATR = 0.0;
      atrEnergy = 0.0;
      atrMomentum = 0.0;
      spread = 0.0;
   }

};
//+------------------------------------------------------------------+
//| Divergence Extremum Type                                         |
//+------------------------------------------------------------------+
enum ENUM_PHX_EXTREMUM_TYPE
{
   PHX_EXTREMUM_NONE = 0,
   PHX_EXTREMUM_HIGH,
   PHX_EXTREMUM_LOW
};

//+------------------------------------------------------------------+
//| Divergence Direction                                             |
//+------------------------------------------------------------------+
enum ENUM_PHX_DIVERGENCE_DIRECTION
{
   PHX_DIVERGENCE_DIRECTION_FLAT = 0,
   PHX_DIVERGENCE_DIRECTION_UP,
   PHX_DIVERGENCE_DIRECTION_DOWN
};

//+------------------------------------------------------------------+
//| PPO Divergence Type                                              |
//+------------------------------------------------------------------+
enum ENUM_PHX_DIVERGENCE_TYPE
{
   PHX_DIVERGENCE_NONE = 0,

   PHX_DIVERGENCE_REGULAR_BULLISH,
   PHX_DIVERGENCE_REGULAR_BEARISH,

   PHX_DIVERGENCE_HIDDEN_BULLISH,
   PHX_DIVERGENCE_HIDDEN_BEARISH,

   PHX_DIVERGENCE_BORDERLINE_BULLISH,
   PHX_DIVERGENCE_BORDERLINE_BEARISH
};
//+------------------------------------------------------------------+
//| PPO Divergence Status                                            |
//+------------------------------------------------------------------+
enum ENUM_PHX_DIVERGENCE_STATUS
{
   PHX_DIVERGENCE_STATUS_NONE = 0,

   PHX_DIVERGENCE_STATUS_DETECTED,
   PHX_DIVERGENCE_STATUS_WAITING_CONFIRMATION,
   PHX_DIVERGENCE_STATUS_CONFIRMED,
   PHX_DIVERGENCE_STATUS_SUPERSEDED,
   PHX_DIVERGENCE_STATUS_INVALIDATED
};
//+------------------------------------------------------------------+
//| D1 Trend State                                                   |
//+------------------------------------------------------------------+
enum ENUM_PHX_D1_TREND_STATE
{
   PHX_D1_TREND_UNKNOWN = 0,

   PHX_D1_TREND_BULLISH,
   PHX_D1_TREND_BEARISH,

   PHX_D1_TREND_TRANSITION_UP,
   PHX_D1_TREND_TRANSITION_DOWN
};

//+------------------------------------------------------------------+
//| Divergence Context                                               |
//+------------------------------------------------------------------+
enum ENUM_PHX_DIVERGENCE_CONTEXT
{
   PHX_DIVERGENCE_CONTEXT_NEUTRAL = 0,

   PHX_DIVERGENCE_CONTEXT_CONTINUATION,
   PHX_DIVERGENCE_CONTEXT_REVERSAL_WARNING,
   PHX_DIVERGENCE_CONTEXT_TREND_CHANGE_CONFIRMATION,
   PHX_DIVERGENCE_CONTEXT_CONFLICT
};
//+------------------------------------------------------------------+
//| Series Direction                                                 |
//+------------------------------------------------------------------+
enum ENUM_PHX_SERIES_DIRECTION
{
   PHX_SERIES_DIRECTION_FLAT = 0,
   PHX_SERIES_DIRECTION_RISING,
   PHX_SERIES_DIRECTION_FALLING
};
//+------------------------------------------------------------------+
//| Price Structure State                                            |
//+------------------------------------------------------------------+
enum ENUM_PHX_PRICE_STRUCTURE_STATE
{
   PHX_PRICE_STRUCTURE_UNINITIALIZED = 0,

   PHX_PRICE_STRUCTURE_SEARCH_HIGH,
   PHX_PRICE_STRUCTURE_SEARCH_LOW
};
//+------------------------------------------------------------------+
//| Price Structural Extreme                                         |
//+------------------------------------------------------------------+
struct SPHXPriceExtreme
{
   ENUM_PHX_EXTREMUM_TYPE Type;

   int      ExtremeBar;
   datetime ExtremeTime;
   double   ExtremePrice;

   int      ConfirmationBar;

   double   ReversalAmplitude;
   double   ReversalRangeRatio;
   double   ReversalSwingRatio;

   void Reset()
   {
      Type = PHX_EXTREMUM_NONE;

      ExtremeBar   = -1;
      ExtremeTime  = 0;
      ExtremePrice = 0.0;

      ConfirmationBar = -1;

      ReversalAmplitude  = 0.0;
      ReversalRangeRatio = 0.0;
      ReversalSwingRatio = 0.0;
   }
};

//+------------------------------------------------------------------+
//| PPO Structural Extreme                                           |
//+------------------------------------------------------------------+
struct SPHXPPOExtreme
{
   ENUM_PHX_EXTREMUM_TYPE Type;

   int      ExtremeBar;
   datetime ExtremeTime;
   double   Value;

   double   Prominence;

   void Reset()
   {
      Type = PHX_EXTREMUM_NONE;

      ExtremeBar  = -1;
      ExtremeTime = 0;
      Value       = 0.0;

      Prominence = 0.0;
   }
};
//+------------------------------------------------------------------+
//| Price <-> PPO Divergence Match                                   |
//+------------------------------------------------------------------+
struct SPHXDivergenceMatch
{
   SPHXPriceExtreme Price;
   SPHXPPOExtreme   PPO;

   int  MatchOffsetBars;
   bool Matched;

   void Reset()
   {
      Price.Reset();
      PPO.Reset();

      MatchOffsetBars = 0;
      Matched         = false;
   }
};
//+------------------------------------------------------------------+
//| PPO Divergence Result                                            |
//+------------------------------------------------------------------+
struct SPHXDivergenceResult
{
   ENUM_PHX_DIVERGENCE_TYPE      Type;
   ENUM_PHX_DIVERGENCE_STATUS    Status;
   ENUM_PHX_DIVERGENCE_CONTEXT   Context;

   SPHXDivergenceMatch First;
   SPHXDivergenceMatch Second;

   ENUM_PHX_DIVERGENCE_DIRECTION PriceDirection;
   ENUM_PHX_DIVERGENCE_DIRECTION PPODirection;

   double PriceDelta;
   double PriceDeltaNorm;

   double PPODelta;
   double PPODeltaNorm;

   bool Valid;

   void Reset()
   {
      Type = PHX_DIVERGENCE_NONE;
      Status = PHX_DIVERGENCE_STATUS_NONE;
      Context = PHX_DIVERGENCE_CONTEXT_NEUTRAL;
      First.Reset();
      Second.Reset();

      PriceDirection = PHX_DIVERGENCE_DIRECTION_FLAT;
      PPODirection   = PHX_DIVERGENCE_DIRECTION_FLAT;

      PriceDelta     = 0.0;
      PriceDeltaNorm = 0.0;

      PPODelta     = 0.0;
      PPODeltaNorm = 0.0;

      Valid = false;
   }
};
//+------------------------------------------------------------------+
//| Divergence Structure Confirmation                                |
//+------------------------------------------------------------------+
struct SPHXDivergenceConfirmation
{
   double   BreakLevel;

   int      BreakBar;
   datetime BreakTime;
   double   BreakPrice;

   double   BreakDistance;
   double   BreakDistanceNorm;

   int      ConfirmationDelayBars;

   bool     Confirmed;

   void Reset()
   {
      BreakLevel = 0.0;

      BreakBar   = -1;
      BreakTime  = 0;
      BreakPrice = 0.0;

      BreakDistance     = 0.0;
      BreakDistanceNorm = 0.0;

      ConfirmationDelayBars = 0;

      Confirmed = false;
   }
};
//+------------------------------------------------------------------+
//| Divergence Confirmation Profile                                  |
//+------------------------------------------------------------------+
struct SPHXDivergenceConfirmationProfile
{
   //--------------------------------------------------
   // RSI
   //--------------------------------------------------

   double RSI;

   //--------------------------------------------------
   // ADX
   //--------------------------------------------------

   double ADXLevel;

   ENUM_PHX_SERIES_DIRECTION
      ADXDirection;

   //--------------------------------------------------
   // Volume
   //--------------------------------------------------

   double Volume;

   double AverageVolume;

   double RelativeVolume;

   ENUM_PHX_SERIES_DIRECTION
      VolumeDirection;

   //--------------------------------------------------
   // State
   //--------------------------------------------------

   bool Valid;

   //--------------------------------------------------
   // Reset
   //--------------------------------------------------

   void Reset()
   {
      RSI =
         0.0;

      ADXLevel =
         0.0;

      ADXDirection =
         PHX_SERIES_DIRECTION_FLAT;

      Volume =
         0.0;

      AverageVolume =
         0.0;

      RelativeVolume =
         0.0;

      VolumeDirection =
         PHX_SERIES_DIRECTION_FLAT;

      Valid =
         false;
   }
};
//+------------------------------------------------------------------+
//| D1 Trend Context                                                 |
//+------------------------------------------------------------------+
struct SPHXD1TrendContext
{
   ENUM_PHX_D1_TREND_STATE PreviousTrend;
   ENUM_PHX_D1_TREND_STATE CurrentTrend;

   SPHXPriceExtreme PreviousConfirmedHigh;
   SPHXPriceExtreme LastConfirmedHigh;

   SPHXPriceExtreme PreviousConfirmedLow;
   SPHXPriceExtreme LastConfirmedLow;

   bool     StructureBreakDetected;
   int      StructureBreakBar;
   datetime StructureBreakTime;

   bool     TrendChangeConfirmed;
   int      TrendChangeBar;
   datetime TrendChangeTime;

   int      TrendAgeBars;

   void Reset()
   {
      PreviousTrend = PHX_D1_TREND_UNKNOWN;
      CurrentTrend  = PHX_D1_TREND_UNKNOWN;

      PreviousConfirmedHigh.Reset();
      LastConfirmedHigh.Reset();

      PreviousConfirmedLow.Reset();
      LastConfirmedLow.Reset();

      StructureBreakDetected = false;
      StructureBreakBar      = -1;
      StructureBreakTime     = 0;

      TrendChangeConfirmed = false;
      TrendChangeBar       = -1;
      TrendChangeTime      = 0;

      TrendAgeBars = 0;
   }
};
//+------------------------------------------------------------------+
//| Completed Price Swing                                            |
//+------------------------------------------------------------------+
struct SPHXCompletedSwing
{
   ENUM_PHX_EXTREMUM_TYPE StartType;
   ENUM_PHX_EXTREMUM_TYPE EndType;

   int      StartBar;
   int      EndBar;

   datetime StartTime;
   datetime EndTime;

   double   StartPrice;
   double   EndPrice;

   double   Amplitude;
   int      DurationBars;

   double   AmplitudeRangeRatio;
   double   AmplitudeSwingRatio;

   void Reset()
   {
      StartType = PHX_EXTREMUM_NONE;
      EndType   = PHX_EXTREMUM_NONE;

      StartBar = -1;
      EndBar   = -1;

      StartTime = 0;
      EndTime   = 0;

      StartPrice = 0.0;
      EndPrice   = 0.0;

      Amplitude    = 0.0;
      DurationBars = 0;

      AmplitudeRangeRatio = 0.0;
      AmplitudeSwingRatio = 0.0;
   }
};
#endif // __PHX_SIGNAL_TYPES_MQH__
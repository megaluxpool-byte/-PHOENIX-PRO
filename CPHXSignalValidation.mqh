#ifndef PHX_SIGNAL_VALIDATION_MQH
#define PHX_SIGNAL_VALIDATION_MQH

//--------------------------------------------------
// Includes
//--------------------------------------------------
#include "IPHXSignalValidationProvider.mqh"
#include "PHXSignalTypes.mqh"
#include "../Statistics/PHXTrendStatisticsTypes.mqh"
//+------------------------------------------------------------------+
//| Signal Validation Engine                                         |
//+------------------------------------------------------------------+
class CPHXSignalValidation :
   public IPHXSignalValidationProvider
{
private:
   //--------------------------------------------------
   // Results
   //--------------------------------------------------
   ENUM_PHX_SIGNAL_RESULT m_buyResult;
   ENUM_PHX_SIGNAL_RESULT m_sellResult;
   ENUM_PHX_PRIMARY_BLOCK m_buyBlock;
   ENUM_PHX_PRIMARY_BLOCK m_sellBlock;  
   //--------------------------------------------------
   // Trend Snapshot
   //--------------------------------------------------   
   SPHXTrendSnapshot m_snapshot;  
   //--------------------------------------------------
   // Market Phase diagnostics state
   //--------------------------------------------------
   ENUM_PHX_MARKET_PHASE m_lastLoggedMarketPhase; 
   //--------------------------------------------------
   // Confidence
   //--------------------------------------------------
   double CalculateConfidence(
      const SPHXTrendSnapshot &snapshot
   );
public:   
   //--------------------------------------------------
   // Constructor
   //--------------------------------------------------
   CPHXSignalValidation();
   bool Initialize();
   void Shutdown();
   //--------------------------------------------------
   // Reset
   //--------------------------------------------------
   void Reset();   
    //--------------------------------------------------
   // Snapshot Provider
   //--------------------------------------------------
   void SetSnapshot(
      const SPHXTrendSnapshot &snapshot
   );
   //--------------------------------------------------
   // Validation
   //--------------------------------------------------   
   bool ValidateBuy(const SPHXTrendSnapshot &snapshot);
   bool ValidateSell(const SPHXTrendSnapshot &snapshot);   
   bool Calculate(SPHXSignal &signal) override;
   //--------------------------------------------------
   // Results
   //--------------------------------------------------
   ENUM_PHX_SIGNAL_RESULT BuyResult() const override;
   ENUM_PHX_SIGNAL_RESULT SellResult() const override;
};
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPHXSignalValidation::CPHXSignalValidation()
{
   Reset();
   m_snapshot.Reset();
}
//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CPHXSignalValidation::Initialize()
{
m_lastLoggedMarketPhase =
      PHX_PHASE_UNKNOWN;

   Reset();
   m_snapshot.Reset();
   return true;
}
//+------------------------------------------------------------------+
//| Reset                                                            |
//+------------------------------------------------------------------+
void CPHXSignalValidation::Reset()
{
   m_buyResult  = PHX_RESULT_UNKNOWN;
   m_sellResult = PHX_RESULT_UNKNOWN;

   m_buyBlock =
      PHX_PRIMARY_NONE;

   m_sellBlock =
      PHX_PRIMARY_NONE; 
   
}
//--------------------------------------------------
// Set Snapshot
//--------------------------------------------------
void CPHXSignalValidation::SetSnapshot(
   const SPHXTrendSnapshot &snapshot
)
{
   m_snapshot = snapshot;
}
//+------------------------------------------------------------------+
//| Calculate                                                        |
//+------------------------------------------------------------------+
bool CPHXSignalValidation::Calculate(
   SPHXSignal &signal
)
{
   Reset();
   signal.Reset();
   //--------------------------------------------------
   // BUY Validation
   //--------------------------------------------------
   if(ValidateBuy(m_snapshot))
   {
      m_buyResult = PHX_RESULT_TRUE;    
   }
 
   
   else
   {
      m_buyResult = PHX_RESULT_FALSE;
   }
     Print(
   "PHX BUY RESULT AFTER VALIDATION: ",
   "Result=",
   IntegerToString(m_buyResult)
);
   //--------------------------------------------------
   // SELL Validation
   //--------------------------------------------------
   if(ValidateSell(m_snapshot))
   {
      m_sellResult = PHX_RESULT_TRUE;
   }

   else
   {
      m_sellResult = PHX_RESULT_FALSE;
   }
      Print(
   "PHX SELL RESULT AFTER VALIDATION: ",
   "Result=",
   IntegerToString(m_sellResult)
);
   //--------------------------------------------------
   // Build Signal
   //--------------------------------------------------
   if(m_buyResult == PHX_RESULT_TRUE)
   {
      signal.signal = PHX_SIGNAL_BUY;
      signal.rsi = m_snapshot.RSI;
signal.ma  = m_snapshot.MA2;
signal.ATR = m_snapshot.ATR;

signal.volume =
   (double)m_snapshot.Volume;

signal.averageVolume =
   m_snapshot.AverageVolume;
      signal.confidence =
      CalculateConfidence(m_snapshot);
      signal.reason = PHX_REASON_NONE;

      return true;
   }


   if(m_sellResult == PHX_RESULT_TRUE)
   {
   signal.signal = PHX_SIGNAL_SELL;
   signal.rsi = m_snapshot.RSI;
   signal.ma  = m_snapshot.MA2;
   signal.ATR = m_snapshot.ATR;

   signal.volume =
   (double)m_snapshot.Volume;

   signal.averageVolume =
   m_snapshot.AverageVolume;
   signal.confidence =
   CalculateConfidence(m_snapshot);
   signal.reason = PHX_REASON_NONE;

      return true;
   }
   signal.signal = PHX_SIGNAL_NONE;
 
   Print(
   "##################################################"
);

Print(
   "          PHX VALIDATION DECISION REPORT"
);

Print(
   "Signal=",
   IntegerToString(signal.signal),
   " State=",
   IntegerToString(signal.State),
   " PrimaryBlock=",
   IntegerToString(signal.PrimaryBlock)
);

Print(
   "BUY_BLOCK=",
   IntegerToString(m_buyBlock),
   " SELL_BLOCK=",
   IntegerToString(m_sellBlock)
);

Print(
   "##################################################"
);

signal.confidence = 0.0;
signal.reason = PHX_REASON_NONE;
   
// keep diagnostics snapshot

signal.rsi = m_snapshot.RSI;

signal.ma = m_snapshot.MA2;

signal.ATR = m_snapshot.ATR;

signal.volume = (double)m_snapshot.Volume;

signal.averageVolume = m_snapshot.AverageVolume;

signal.State = PHX_SIGNAL_BLOCKED;

signal.PrimaryBlock =
   (m_buyBlock != PHX_PRIMARY_NONE)
   ?
   m_buyBlock
   :
   m_sellBlock;

   return true;
}

//+------------------------------------------------------------------+
//| Validate Buy                                                     |
//+------------------------------------------------------------------+

bool CPHXSignalValidation::ValidateBuy(
   const SPHXTrendSnapshot &snapshot
)
{
Print(
   "PHX Validate BUY: ",
   "Trend=",
   IntegerToString(snapshot.Trend),
   " EMA=",
   IntegerToString(snapshot.Score.EMA.Total),
   " RSI=",
   IntegerToString(snapshot.Score.RSI.Total),
   " Volume=",
   IntegerToString(snapshot.Score.Volume.Total),
   " Session=",
   IntegerToString(snapshot.SessionOpen)
);
//--------------------------------------------------
// BUY Decision Diagnostics
//--------------------------------------------------

Print(
   "PHX BUY Decision: ",
   "Close=",
   DoubleToString(snapshot.Close,_Digits),
   " MA2=",
   DoubleToString(snapshot.MA2,_Digits),
   " Trend=",
   IntegerToString(snapshot.Trend),
   " Score=",
   IntegerToString(snapshot.Score.Total),
   " ADX=",
   DoubleToString(snapshot.ADX,2),
   " ADXScore=",
   IntegerToString(snapshot.Score.ADX.Total)
);
//--------------------------------------------------
// Block BUY during Early Bearish Transition
//--------------------------------------------------

if(
   snapshot.MarketPhase ==
      PHX_PHASE_EARLY_BEAR_REVERSAL
)
{
   m_buyBlock =
      PHX_PRIMARY_TREND;

   Print(
      "PHX BUY BLOCK: EARLY_BEAR_REVERSAL",
      " Trend=",
      EnumToString(
         (ENUM_PHX_TREND)snapshot.Trend
      ),
      " RSI=",
      DoubleToString(
         snapshot.RSI,
         2
      ),
      " RSIChange=",
      DoubleToString(
         snapshot.RSIChange,
         4
      ),
      " EMASlope=",
      DoubleToString(
         snapshot.EMASlope,
         8
      ),
      " EMASlopeChange=",
      DoubleToString(
         snapshot.EMASlopeChange,
         8
      )
   );

   return false;
}

//--------------------------------------------------
// Market Phase diagnostics
//--------------------------------------------------

if(
   snapshot.MarketPhase ==
      PHX_PHASE_EXHAUSTION_UP
   &&
   m_lastLoggedMarketPhase !=
      PHX_PHASE_EXHAUSTION_UP
)
{
   Print(
      "PHX BUY WARNING: EXHAUSTION_UP ",
      "RSI=",
      DoubleToString(snapshot.RSI,2),
      " RSIChange=",
      DoubleToString(snapshot.RSIChange,4),
      " EMASlopeChange=",
      DoubleToString(snapshot.EMASlopeChange,6),
      " M1Bear=",
      IntegerToString(snapshot.M1BearSequence)
   );
}


m_lastLoggedMarketPhase =
   snapshot.MarketPhase;

Print(
   "PHX EARLY MOMENTUM CHECK: ",
   
   "Trend=",
   EnumToString(
      (ENUM_PHX_TREND)snapshot.Trend
   ),

   " MomentumDirection=",
   IntegerToString(
      snapshot.MomentumDirection
   ),

   " RSIChange=",
   DoubleToString(
      snapshot.RSIChange,
      4
   ),

   " EMASlopeChange=",
   DoubleToString(
      snapshot.EMASlopeChange,
      6
   ),

   " M1Bull=",
   IntegerToString(
      snapshot.M1BullSequence
   ),

   " M1Bear=",
   IntegerToString(
      snapshot.M1BearSequence
   ),

   " ATR=",
   DoubleToString(
      snapshot.ATR,
      3
   )
);
//--------------------------------------------------
// PHX BUY Momentum Quality Protection
//--------------------------------------------------

bool weakBuyMomentum =
(
   snapshot.MomentumDirection <= 0
   &&
   snapshot.M1BearSequence >= 2
   &&
   snapshot.EMASlopeChange < 0
   &&
   snapshot.RSIChange < 0
);


if(weakBuyMomentum)
{
   m_buyBlock =
      PHX_PRIMARY_TREND;

   Print(
      "PHX BUY BLOCK: Weak Momentum",
      " Momentum=",
      IntegerToString(snapshot.MomentumDirection),
      " M1Bear=",
      IntegerToString(snapshot.M1BearSequence),
      " RSIChange=",
      DoubleToString(snapshot.RSIChange,4),
      " EMASlopeChange=",
      DoubleToString(snapshot.EMASlopeChange,6)
   );

   return false;
}
   bool normalBuyTrend =
(
   snapshot.Trend ==
      PHX_TREND_UP
);


bool momentumBullish =
(
   snapshot.MomentumDirection == 1
   &&
   snapshot.M1BullSequence >= 1
   &&
   snapshot.EMASlopeChange >= 0
);


if(
   !normalBuyTrend
   &&
   !momentumBullish
)
{
   m_buyBlock =
      PHX_PRIMARY_TREND;

   Print(
      "PHX BUY BLOCK: ",
      "Trend=",
      EnumToString(
         (ENUM_PHX_TREND)snapshot.Trend
      ),
      " MomentumDirection=",
      IntegerToString(
         snapshot.MomentumDirection
      )
   );

   return false;
}


//--------------------------------------------------
// Momentum override
//--------------------------------------------------

bool momentumBuy =
(
   snapshot.MomentumDirection == 1
);


//--------------------------------------------------
// Classic Trend Validation
//--------------------------------------------------

if(!momentumBuy)
{
   if(snapshot.Score.EMA.Total <= 0)
      return false;


   if(snapshot.Score.RSI.Total <= 0)
      return false;


   if(snapshot.Score.Volume.Total <= 0)
      return false;
}
else
{
// Momentum entry
// EMA / RSI score already confirmed
// by momentum engine

   Print(
      "PHX BUY MOMENTUM OVERRIDE"
   );
}
      
//--------------------------------------------------
// MA2 Filter
//--------------------------------------------------

bool ma2BuyOK =
(
   snapshot.Close > snapshot.MA2
);


bool momentumMa2OK =
(
   snapshot.MomentumDirection == 1
   &&
   snapshot.Close >=
      snapshot.MA2 -
      snapshot.ATR * 0.07
);


if(
   !ma2BuyOK
   &&
   !momentumMa2OK
)
{
   m_buyBlock =
      PHX_PRIMARY_MA2;
Print(
   "PHX BUY MA2 CHECK: ",
   "Close=",
   DoubleToString(snapshot.Close,_Digits),
   " MA2=",
   DoubleToString(snapshot.MA2,_Digits),
   " ATR=",
   DoubleToString(snapshot.ATR,_Digits),
   " Limit=",
   DoubleToString(
      snapshot.ATR*0.07,
      _Digits
   ),
   " Momentum=",
   IntegerToString(snapshot.MomentumDirection)
);
   
   return false;
}


if(!snapshot.SessionOpen)
{
   Print(
      "PHX BUY BLOCK: SESSION",
      " MomentumDirection=",
      IntegerToString(snapshot.MomentumDirection)
   );

   return false;
}


   return true;

}

//+------------------------------------------------------------------+
//| Validate Sell                                                    |
//+------------------------------------------------------------------+

bool CPHXSignalValidation::ValidateSell(
   const SPHXTrendSnapshot &snapshot
)
{
 Print(
   "PHX Validate SELL: ",
   "Trend=",
   IntegerToString(snapshot.Trend),
   " EMA=",
   IntegerToString(snapshot.Score.EMA.Total),
   " RSI=",
   IntegerToString(snapshot.Score.RSI.Total),
   " Volume=",
   IntegerToString(snapshot.Score.Volume.Total),
   " Session=",
   IntegerToString(snapshot.SessionOpen)
);
//--------------------------------------------------
// SELL Decision Diagnostics
//--------------------------------------------------

 Print(
   "PHX SELL Decision: ",
   "Close=",
   DoubleToString(snapshot.Close,_Digits),
   " MA2=",
   DoubleToString(snapshot.MA2,_Digits),
   " Trend=",
   IntegerToString(snapshot.Trend),
   " Score=",
   IntegerToString(snapshot.Score.Total),
   " ADX=",
   DoubleToString(snapshot.ADX,2),
   " ADXScore=",
   IntegerToString(snapshot.Score.ADX.Total)
);
//--------------------------------------------------
// SELL Trend / Early Bearish Transition
//--------------------------------------------------

bool normalSellTrend =
(
   snapshot.Trend ==
      PHX_TREND_DOWN
);


bool earlyBearishTransition =
(
   snapshot.MarketPhase ==
      PHX_PHASE_EARLY_BEAR_REVERSAL
);


bool exhaustionSell =
(
   snapshot.MarketPhase ==
      PHX_PHASE_EXHAUSTION_UP
);
//--------------------------------------------------
// PHX SELL Exhaustion Protection
//--------------------------------------------------

if(
   exhaustionSell &&
   snapshot.Trend == PHX_TREND_UP
)
{
   m_sellBlock =
      PHX_PRIMARY_TREND;

   Print(
      "PHX SELL BLOCK: Exhaustion UP with UP Trend ",
      "RSI=",
      DoubleToString(snapshot.RSI,2),
      " RSIChange=",
      DoubleToString(snapshot.RSIChange,4),
      " M1Bear=",
      IntegerToString(snapshot.M1BearSequence),
      " EMASlopeChange=",
      DoubleToString(snapshot.EMASlopeChange,6)
   );

   return false;
}

if(
   !normalSellTrend &&
   !earlyBearishTransition &&
   !exhaustionSell
)
{
   m_sellBlock =
      PHX_PRIMARY_TREND;

   Print(
      "PHX SELL BLOCK: Trend=",
      EnumToString(
         (ENUM_PHX_TREND)snapshot.Trend
      ),
      " MarketPhase=",
      IntegerToString(
         (int)snapshot.MarketPhase
      )
   );

   return false;
}

//--------------------------------------------------
// SELL Score Validation
//--------------------------------------------------

if(snapshot.Score.EMA.Total < 0)
{
   m_sellBlock =
      PHX_PRIMARY_TREND;

   Print(
      "PHX SELL BLOCK: EMA=",
      IntegerToString(snapshot.Score.EMA.Total)
   );

   return false;
}


if(snapshot.Score.RSI.Total < 0)
{
   m_sellBlock =
      PHX_PRIMARY_RSI;

   Print(
      "PHX SELL BLOCK: RSI=",
      IntegerToString(snapshot.Score.RSI.Total)
   );

   return false;
}


if(snapshot.Score.Volume.Total < 0)
{
   m_sellBlock =
      PHX_PRIMARY_VOLUME;

   Print(
      "PHX SELL BLOCK: Volume=",
      IntegerToString(snapshot.Score.Volume.Total)
   );

   return false;
}
      
//--------------------------------------------------
// MA2 Filter
//--------------------------------------------------

if(
   snapshot.Close <= snapshot.MA2
   &&
   snapshot.MomentumDirection != 1
)
{
   m_sellBlock =
      PHX_PRIMARY_MA2;

   return false;
}



if(!snapshot.SessionOpen)
{
   Print(
      "PHX SELL BLOCK: Session"
   );
if(earlyBearishTransition)
{
   Print(
      "PHX EARLY SELL BLOCK: SESSION",
      " SessionOpen=",
      IntegerToString(
         (int)snapshot.SessionOpen
      )
   );
}
   return false;
}


//--------------------------------------------------
// Validation Diagnostics
//--------------------------------------------------

Print(
   "PHX Validation Result: BUY=",
   IntegerToString(m_buyResult),
   " SELL=",
   IntegerToString(m_sellResult)
);

Print(
"PHX Validation Components:",
" Trend=",IntegerToString(snapshot.Trend),
" EMA=",IntegerToString(snapshot.Score.EMA.Total),
" RSI=",IntegerToString(snapshot.Score.RSI.Total),
" Volume=",IntegerToString(snapshot.Score.Volume.Total),
" Session=",IntegerToString(snapshot.SessionOpen)
);

if(earlyBearishTransition)
{
   Print(
      "PHX EARLY SELL PASS",
      " Trend=",
      EnumToString(
         (ENUM_PHX_TREND)snapshot.Trend
      ),
      " MarketPhase=",
      IntegerToString(
         (int)snapshot.MarketPhase
      ),
      " BearSeq=",
      IntegerToString(
         snapshot.M1BearSequence
      ),
      " RSIChange=",
      DoubleToString(
         snapshot.RSIChange,
         4
      ),
      " EMASlope=",
      DoubleToString(
         snapshot.EMASlope,
         8
      ),
      " EMASlopeChange=",
      DoubleToString(
         snapshot.EMASlopeChange,
         8
      )
   );
}
   return true;

}

//+------------------------------------------------------------------+
//| Calculate Confidence                                             |
//+------------------------------------------------------------------+

double CPHXSignalValidation::CalculateConfidence(
   const SPHXTrendSnapshot &snapshot
)
{

   double score = 0.0;


   //--------------------------------------------------
   // Trend
   //--------------------------------------------------

   if(snapshot.Trend != PHX_TREND_FLAT)
      score += 0.25;


   //--------------------------------------------------
   // EMA
   //--------------------------------------------------

   if(snapshot.Score.EMA.Total != 0)
      score += 0.20;


   //--------------------------------------------------
   // RSI
   //--------------------------------------------------

   if(snapshot.Score.RSI.Total != 0)
      score += 0.20;


   //--------------------------------------------------
   // Volume
   //--------------------------------------------------

   if(snapshot.Score.Volume.Total != 0)
      score += 0.15;


   //--------------------------------------------------
   // ADX
   //--------------------------------------------------

   if(MathAbs(snapshot.Score.ADX.Total) > 0)
      score += 0.20;


   if(score > 1.0)
      score = 1.0;


   return score;

}

//+------------------------------------------------------------------+
//| Buy Result                                                       |
//+------------------------------------------------------------------+

ENUM_PHX_SIGNAL_RESULT CPHXSignalValidation::BuyResult() const
{
   return m_buyResult;
}


//+------------------------------------------------------------------+
//| Sell Result                                                      |
//+------------------------------------------------------------------+

ENUM_PHX_SIGNAL_RESULT CPHXSignalValidation::SellResult() const
{
   return m_sellResult;
}

//+------------------------------------------------------------------+
//| Shutdown                                                        |
//+------------------------------------------------------------------+

void CPHXSignalValidation::Shutdown()
{
   Reset();

   m_snapshot.Reset();
}

#endif // PHX_SIGNAL_VALIDATION_MQH
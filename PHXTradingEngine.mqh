#ifndef PHX_TRADING_ENGINE_MQH
#define PHX_TRADING_ENGINE_MQH

//--------------------------------------------------
// Includes
//--------------------------------------------------
#include "../Market/IPHXMarketSnapshotProvider.mqh"
#include "../Market/IPHXMarketPriceProvider.mqh"
#include "../Indicators/IPHXMarketIndicatorProvider.mqh"
#include "../Indicators/PHXIndicatorServices.mqh"
#include "../Indicators/PHXATREnergy.mqh"
#include "../Signal/IPHXSignalValidationProvider.mqh"
#include "../Signal/IPHXTrendScoreProvider.mqh"
#include "../Signal/PHXSignalServices.mqh"
#include "../Statistics/PHXSignalQualityTracker.mqh"
#include "../Trade/IPHXTradeDecisionProvider.mqh"
#include "../Trade/IPHXTradeExecutor.mqh"
#include "../Risk/IPHXRiskProvider.mqh"
#include "../Risk/PHXRiskSnapshotBuilder.mqh"
#include "../Position/IPHXPositionManagerProvider.mqh"
#include "../Risk/PHXRiskTypes.mqh"
//+------------------------------------------------------------------+
//| PHX Trading Engine                                               |
//+------------------------------------------------------------------+
class CPHXTradingEngine
{
private:
//--------------------------------------------------
// Providers
//--------------------------------------------------
IPHXMarketSnapshotProvider       *m_marketProvider;
IPHXMarketPriceProvider          *m_priceProvider;
IPHXMarketIndicatorProvider      *m_indicatorProvider;
IPHXTrendScoreProvider           *m_trendProvider;
IPHXSignalValidationProvider     *m_signalProvider;
CPHXSignalServices               *m_signalServices;
CPHXSignalQualityTracker         *m_qualityTracker;
CPHXIndicatorServices            *m_indicatorServices;
CPHXATREnergy                    *m_atrEnergy;
IPHXTradeDecisionProvider        *m_tradeDecisionProvider;
IPHXRiskProvider                 *m_riskProvider;
CPHXRiskSnapshotBuilder          *m_riskSnapshotBuilder;
IPHXPositionManagerProvider      *m_positionProvider;
IPHXTradeExecutor                * m_tradeExecutor;
//--------------------------------------------------
// Last Executed Signal Context
//--------------------------------------------------

SPHXSignal m_lastExecutedSignal;
//--------------------------------------------------
// Position Limits
//--------------------------------------------------
int m_maxPositions;
double m_profitTarget;
//--------------------------------------------------
// Profit Calculation
//--------------------------------------------------
double CalculateTotalProfit();
private:
bool IsTradingTimeAllowed();
void CheckPositionReversal();
//--------------------------------------------------
// Entry Quality Filter
//--------------------------------------------------
bool CheckEntryQuality(
   ENUM_PHX_TRADE_DIRECTION direction
);
//--------------------------------------------------
// State
//--------------------------------------------------
bool m_initialized;

public:
//--------------------------------------------------
// Constructor / Destructor
//--------------------------------------------------
CPHXTradingEngine();

~CPHXTradingEngine();
//--------------------------------------------------
// Initialize
//--------------------------------------------------
bool Initialize();
//--------------------------------------------------
// Dependency Injection
//--------------------------------------------------
void SetMarketProvider(
   IPHXMarketSnapshotProvider *provider
);
void SetMarketPriceProvider(
   IPHXMarketPriceProvider *provider
);
void SetIndicatorProvider(
   IPHXMarketIndicatorProvider *provider
);
void SetTrendProvider(
   IPHXTrendScoreProvider *provider
);
void SetSignalProvider(
   IPHXSignalValidationProvider *provider
);
void SetSignalServices(
   CPHXSignalServices *services
);
void SetQualityTracker(
   CPHXSignalQualityTracker *tracker
);
void SetIndicatorServices(
   CPHXIndicatorServices *services
);
void SetATREnergy(
   CPHXATREnergy *atrEnergy
);
void SetTradeDecisionProvider(
   IPHXTradeDecisionProvider *provider
);
void SetRiskProvider(
   IPHXRiskProvider *provider
);
void SetRiskSnapshotBuilder(
   CPHXRiskSnapshotBuilder *builder
);
void SetPositionProvider(
   IPHXPositionManagerProvider *provider
);
void SetTradeExecutor(
   IPHXTradeExecutor *executor
);
//--------------------------------------------------
// Trading Cycle
//--------------------------------------------------
bool Process();
//--------------------------------------------------
// Reset
//--------------------------------------------------
void Reset();
};
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPHXTradingEngine::CPHXTradingEngine()
{
m_maxPositions = 3;
Reset();
}
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPHXTradingEngine::~CPHXTradingEngine()
{
Reset();
}
//+------------------------------------------------------------------+
//| Reset                                                            |
//+------------------------------------------------------------------+
void CPHXTradingEngine::Reset()
{
m_marketProvider = NULL;
m_priceProvider = NULL;
m_indicatorProvider = NULL;
m_trendProvider = NULL;
m_signalProvider = NULL;
m_signalServices = NULL;
m_indicatorServices = NULL;
m_atrEnergy = NULL;
m_tradeDecisionProvider = NULL;
m_riskProvider = NULL;
m_riskSnapshotBuilder = NULL;
m_positionProvider = NULL;
m_tradeExecutor = NULL;
m_profitTarget = 5.0;
m_lastExecutedSignal.Reset();
m_initialized = false;
}
//+------------------------------------------------------------------+
//| Calculate Total Profit                                           |
//+------------------------------------------------------------------+
double CPHXTradingEngine::CalculateTotalProfit()
{
   double totalProfit = 0.0;

   int total =
      PositionsTotal();

   for(int i = 0; i < total; i++)
   {
      ulong ticket =
         PositionGetTicket(i);

      if(ticket == 0)
         continue;

      if(!PositionSelectByTicket(ticket))
         continue;

      long magic =
         PositionGetInteger(
            POSITION_MAGIC
         );

      if(magic != PHX_DEFAULT_MAGIC)
         continue;

      totalProfit +=
         PositionGetDouble(
            POSITION_PROFIT
         );
   }
   return totalProfit;
}
//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CPHXTradingEngine::Initialize()
{
m_initialized = true;
return true;
}
//+------------------------------------------------------------------+
//| Set Market Provider                                              |
//+------------------------------------------------------------------+
void CPHXTradingEngine::SetMarketProvider(
IPHXMarketSnapshotProvider *provider
)
{
m_marketProvider = provider;
}
//+------------------------------------------------------------------+
//| Set Market Price Provider                                              |
//+------------------------------------------------------------------+
void CPHXTradingEngine::SetMarketPriceProvider(
   IPHXMarketPriceProvider *provider
)
{
   m_priceProvider = provider;
}
//+------------------------------------------------------------------+
//| Set Indicator Provider                                           |
//+------------------------------------------------------------------+
void CPHXTradingEngine::SetIndicatorProvider(
   IPHXMarketIndicatorProvider *provider
)
{
   m_indicatorProvider = provider;
}
//+------------------------------------------------------------------+
//| Set Trend Provider                                               |
//+------------------------------------------------------------------+
void CPHXTradingEngine::SetTrendProvider(
IPHXTrendScoreProvider *provider
)
{
m_trendProvider = provider;
}
//+------------------------------------------------------------------+
//| Set Signal Provider                                              |
//+------------------------------------------------------------------+
void CPHXTradingEngine::SetSignalProvider(
IPHXSignalValidationProvider *provider
)
{
m_signalProvider = provider;
}
//+------------------------------------------------------------------+
//| Set Signal Service                                              |
//+------------------------------------------------------------------+
void CPHXTradingEngine::SetSignalServices(
   CPHXSignalServices *services
)
{
   m_signalServices = services;
}
//+------------------------------------------------------------------+
//| Set Quality Tracker                                            |
//+------------------------------------------------------------------+
void CPHXTradingEngine::SetQualityTracker(
   CPHXSignalQualityTracker *tracker
)
{
   m_qualityTracker = tracker;
}
//+------------------------------------------------------------------+
//| Set Indicator Services                                           |
//+------------------------------------------------------------------+
void CPHXTradingEngine::SetIndicatorServices(
   CPHXIndicatorServices *services
)
{
   m_indicatorServices =
      services;
}
//+------------------------------------------------------------------+
//| Set ATR Energy                                                   |
//+------------------------------------------------------------------+
void CPHXTradingEngine::SetATREnergy(
   CPHXATREnergy *atrEnergy
)
{
   m_atrEnergy =
      atrEnergy;
}
//+------------------------------------------------------------------+
//| Set Trade Decision Provider                                      |
//+------------------------------------------------------------------+
void CPHXTradingEngine::SetTradeDecisionProvider(
IPHXTradeDecisionProvider *provider
)
{
m_tradeDecisionProvider = provider;
}
//+------------------------------------------------------------------+
//| Set Risk Provider                                                 |
//+------------------------------------------------------------------+
void CPHXTradingEngine::SetRiskProvider(
IPHXRiskProvider *provider
)
{
m_riskProvider = provider;
}
//+------------------------------------------------------------------+
//| Set Position Provider                                             |
//+------------------------------------------------------------------+
void CPHXTradingEngine::SetPositionProvider(
IPHXPositionManagerProvider *provider
)
{
m_positionProvider = provider;
}
void CPHXTradingEngine::SetTradeExecutor(
IPHXTradeExecutor *executor
)
{
   m_tradeExecutor = executor;
}
//+------------------------------------------------------------------+
//| Set Risk Snapshot Builder                                        |
//+------------------------------------------------------------------+
void CPHXTradingEngine::SetRiskSnapshotBuilder(
   CPHXRiskSnapshotBuilder *builder
)
{
   m_riskSnapshotBuilder = builder;
}
//+------------------------------------------------------------------+
//| Process Trading Cycle                                            |
//+------------------------------------------------------------------+
bool CPHXTradingEngine::Process()
{
//--------------------------------------------------
// Cycle Trace
//--------------------------------------------------

static ulong phxCycle = 0;

phxCycle++;

//--------------------------------------------------
// Engine State
//--------------------------------------------------
   if(!m_initialized)
   return false;
//--------------------------------------------------
// Stage 1
// Market Validation Layer
//--------------------------------------------------
   if(m_marketProvider == NULL)
   return false;
//--------------------------------------------------
// Read Market Data
//--------------------------------------------------
   double open  = (*m_marketProvider).Open();
   double high  = (*m_marketProvider).High();
   double low   = (*m_marketProvider).Low();
   double close = (*m_marketProvider).Close();
//--------------------------------------------------
// Validate Market Data
//--------------------------------------------------
   if(open <= 0.0)
   return false;

   if(high <= 0.0)
   return false;

   if(low <= 0.0)
   return false;

   if(close <= 0.0)
   return false;
//--------------------------------------------------
// Market Layer completed
//--------------------------------------------------

//--------------------------------------------------
// Stage 2
// Trend Layer
//--------------------------------------------------
SPHXTrendScore trendScore;
trendScore =
   (*m_trendProvider).GetScore();
//--------------------------------------------------
// Validate Trend
//--------------------------------------------------
if(trendScore.Total == 0)
{
   Print(
      "PHXTradingEngine: Trend neutral"
   );
}
//--------------------------------------------------
// Trend Layer completed
//--------------------------------------------------

//--------------------------------------------------
// Stage 3
// Signal Layer
//--------------------------------------------------
SPHXSignal signal;
signal.Reset();
//--------------------------------------------------
// Read Signal Services Result
//--------------------------------------------------
if(m_signalServices != NULL)
{
   signal = (*m_signalServices).GetSignal();   

}
else
{
   if(m_signalProvider == NULL)
   {
      Print(
         "PHXTradingEngine: Signal provider NULL"
      );
      return false;
   }
   if(!(*m_signalProvider).Calculate(signal))
   {
      Print(
         "PHXTradingEngine: Signal calculation failed"
      );
      return false;
   }
}

//--------------------------------------------------
// Read Results
//--------------------------------------------------
ENUM_PHX_SIGNAL_RESULT buyResult;
ENUM_PHX_SIGNAL_RESULT sellResult;

buyResult  = (*m_signalProvider).BuyResult();
sellResult = (*m_signalProvider).SellResult();
//--------------------------------------------------
// Signal Layer completed
//--------------------------------------------------

//--------------------------------------------------
// Stage 4
// Trade Decision Layer
//--------------------------------------------------
if(m_tradeDecisionProvider == NULL)
{
   Print(
   "PHX Engine ERROR: TradeDecisionProvider NULL"
   );
   return false;
}
//--------------------------------------------------
// Calculate Trade Decision
//--------------------------------------------------
SPHXTrendSnapshot decisionSnapshot;

decisionSnapshot.Reset();

if(m_trendProvider == NULL)
{
   Print(
      "PHX Engine ERROR: TrendProvider NULL"
   );
   return false;
}
//--------------------------------------------------
// Get Current Trend Snapshot
//--------------------------------------------------

decisionSnapshot =
   (*m_trendProvider).GetSnapshot();

//--------------------------------------------------
// Calculate Decision
//--------------------------------------------------

if(!(*m_tradeDecisionProvider).Calculate(
      decisionSnapshot,
      signal
   ))
{
   return false;
}

//--------------------------------------------------
// Get Direction
//--------------------------------------------------
ENUM_PHX_TRADE_DIRECTION direction;

direction =
   (*m_tradeDecisionProvider).Direction();
   
   if(PHX_VERBOSE_DEBUG)
{
   Print(
   "PHX CYCLE #",
   IntegerToString(phxCycle),
   " DIRECTION=",
   IntegerToString(direction)
);
}
   if(PHX_VERBOSE_DEBUG)
{
   Print(
      "PHX Engine: Direction=",
      IntegerToString(direction)
   );
}

//--------------------------------------------------
// Trade Decision completed
//--------------------------------------------------

//--------------------------------------------------
// Risk Snapshot Build
//--------------------------------------------------
   SPHXRiskSnapshot riskSnapshot;
   riskSnapshot.Reset();

   if(m_riskSnapshotBuilder != NULL)
{
   if(!(*m_riskSnapshotBuilder).Build(
         riskSnapshot
      ))
   {
      Print(
         "PHX Engine: Risk Snapshot build failed"
      );
      return false;
   }
}
   else
{
   Print(
      "PHX Engine ERROR: Risk Snapshot Builder NULL"
   );
   return false;
}
//--------------------------------------------------
// Position Diagnostics
//--------------------------------------------------
int positions =
   (*m_positionProvider).PositionsCount();
   
if(PHX_VERBOSE_DEBUG)
{
   Print(
      "PHX Engine: Positions=",
      IntegerToString(positions)
   );
}

//--------------------------------------------------
// Profit Target Check
//--------------------------------------------------
if(positions > 0)
{
   double totalProfit =
      CalculateTotalProfit();

   if(PHX_VERBOSE_DEBUG)
{
   Print(
      "PHX Engine: Total Profit=",
      DoubleToString(totalProfit,2),
      " Target=",
      DoubleToString(m_profitTarget,2)
   );
}
   if(totalProfit >= m_profitTarget)
   {
      Print(
         "PHX Engine: Profit Target reached"
      );
      if(m_tradeExecutor != NULL)
      {
         if(m_tradeExecutor.CloseAll())
         {
            Print(
               "PHX Engine: All positions closed by Profit Target"
            );
         }
         else
         {
            Print(
               "PHX Engine: CloseAll failed"
            );
         }
      }
      return true;
   }
}

//--------------------------------------------------
// BreakEven Management
//--------------------------------------------------
if(positions > 0)
{
   for(int i = 0; i < positions; i++)
   {
      SPHXPositionSnapshot position;
      position.Reset();

      if(!(*m_positionProvider).Get(
            i,
            position
         ))
      {
         continue;
      }
      //--------------------------------------------------
      // Already moved?
      //--------------------------------------------------
      if((*m_positionProvider).IsBreakEvenMoved(
            position.Ticket
         ))
      {
         continue;
      }
      double currentPrice = 0.0;
      double movement = 0.0;

      //--------------------------------------------------
      // BUY
      //--------------------------------------------------
      if(position.Direction == PHX_POSITION_BUY)
      {
         currentPrice =
            (*m_priceProvider).Bid();

         movement =
            currentPrice -
            position.OpenPrice;
      }
      //--------------------------------------------------
      // SELL
      //--------------------------------------------------
      if(position.Direction == PHX_POSITION_SELL)
      {
         currentPrice =
            (*m_priceProvider).Ask();

         movement =
            position.OpenPrice -
            currentPrice;

      }
      //--------------------------------------------------
      // Daily ATR
      //--------------------------------------------------
      double dailyATR =
         riskSnapshot.DailyATR;

      if(dailyATR <= 0)
      {
         Print(
            "PHX Engine: Daily ATR invalid for BreakEven"
         );
         continue;
      }
      //--------------------------------------------------
      // BreakEven Trigger
      //--------------------------------------------------
      double breakEvenATR = 1.5;

      if(m_riskProvider != NULL)
      {
         breakEvenATR =
            (*m_riskProvider).GetBreakEvenTriggerATR();
      }
      double breakEvenDistance =
         dailyATR *
         breakEvenATR;
      //--------------------------------------------------
      // Diagnostics
      //--------------------------------------------------
      if(PHX_VERBOSE_DEBUG)
{
   Print(
      "PHX BreakEven Check: ",
      "Ticket=",
      IntegerToString(position.Ticket),
      " Open=",
      DoubleToString(position.OpenPrice,_Digits),
      " Price=",
      DoubleToString(currentPrice,_Digits),
      " Move=",
      DoubleToString(movement,_Digits),
      " Required=",
      DoubleToString(breakEvenDistance,_Digits),
      " ATR=",
      DoubleToString(dailyATR,_Digits)
   );
}
      //--------------------------------------------------
      // Trigger check
      //--------------------------------------------------
      if(movement < breakEvenDistance)
      {
         continue;
      }
      Print(
         "PHX Engine: BreakEven trigger Ticket=",
         IntegerToString(position.Ticket)
      );
      //--------------------------------------------------
      // BreakEven Offset
      //--------------------------------------------------
      double breakEvenOffsetATR = 0.05;

      if(m_riskProvider != NULL)
      {
         breakEvenOffsetATR =
            (*m_riskProvider).GetBreakEvenOffsetATR();
      }
      double breakEvenOffset =
         dailyATR *
         breakEvenOffsetATR;
      //--------------------------------------------------
      // New SL calculation
      //--------------------------------------------------
      double newStopLoss =
         position.OpenPrice;
      if(position.Direction == PHX_POSITION_BUY)
      {
         newStopLoss =
            position.OpenPrice +
            breakEvenOffset;
      }
      if(position.Direction == PHX_POSITION_SELL)
      {
         newStopLoss =
            position.OpenPrice -
            breakEvenOffset;
      }
      //--------------------------------------------------
      // SL improvement protection
      //--------------------------------------------------
      if(position.Direction == PHX_POSITION_BUY)
      {
         if(position.StopLoss > 0 &&
            newStopLoss <= position.StopLoss)
         {
            Print(
               "PHX Engine: BE skipped. BUY SL already better"
            );
            continue;
         }
      }
      if(position.Direction == PHX_POSITION_SELL)
      {
         if(position.StopLoss > 0 &&
            newStopLoss >= position.StopLoss)
         {
            Print(
               "PHX Engine: BE skipped. SELL SL already better"
            );
            continue;
         }
      }
      //--------------------------------------------------
      // Modify SL
      //--------------------------------------------------
      if(PHX_VERBOSE_DEBUG)
{
   Print(
      "PHX Engine: BE Modify ",
      "Ticket=",
      IntegerToString(position.Ticket),
      " OldSL=",
      DoubleToString(position.StopLoss,_Digits),
      " NewSL=",
      DoubleToString(newStopLoss,_Digits)
   );
}
      bool modified =
         (*m_tradeExecutor).Modify(
            position.Ticket,
            newStopLoss,
            position.TakeProfit
         );
      if(modified)
      {
         (*m_positionProvider).SetBreakEvenMoved(
            position.Ticket
         );
         Print(
            "PHX Engine: BreakEven completed Ticket=",
            IntegerToString(position.Ticket)
         );
      }
      else
      {
         Print(
            "PHX Engine: BreakEven modify failed Ticket=",
            IntegerToString(position.Ticket)
         );
      }
   }
}
//--------------------------------------------------
// Profit Protection Management
//--------------------------------------------------
if(positions > 0)
{
   for(int i = 0; i < positions; i++)
   {
      SPHXPositionSnapshot position;
      position.Reset();
      if(!(*m_positionProvider).Get(
            i,
            position
         ))
      {
         continue;
      }
      //--------------------------------------------------
      // Already activated?
      //--------------------------------------------------
      if((*m_positionProvider).IsProfitProtectionActivated(
            position.Ticket
         ))
      {
         continue;
      }
      double dailyATR =
         riskSnapshot.DailyATR;
      if(dailyATR <= 0)
      {
         Print(
            "PHX Engine: Daily ATR invalid for Profit Protection"
         );
         continue;
      }
      double triggerATR = 2.5;
      double lockATR    = 0.5;
      if(m_riskProvider != NULL)
      {
         triggerATR =
            (*m_riskProvider).GetProfitProtectionTriggerATR();
         lockATR =
            (*m_riskProvider).GetProfitProtectionLockATR();
      }
      double trigger =
         dailyATR * triggerATR;
      double lockDistance =
         dailyATR * lockATR;
      double currentPrice = 0.0;
      double movement     = 0.0;
      double newStopLoss  = 0.0;
         //--------------------------------------------------
         // BUY
         //--------------------------------------------------
         if(position.Direction == PHX_POSITION_BUY)
         {
            currentPrice =
               m_priceProvider.Bid();
            movement =
               currentPrice -
               position.OpenPrice;
            if(movement >= trigger)
            {
               newStopLoss =
                  position.OpenPrice +
                  lockDistance;
            }
         }
         //--------------------------------------------------
         // SELL
         //--------------------------------------------------
         if(position.Direction == PHX_POSITION_SELL)
         {
            currentPrice =
               m_priceProvider.Ask();
            movement =
               position.OpenPrice -
               currentPrice;
            if(movement >= trigger)
            {
               newStopLoss =
                  position.OpenPrice -
                  lockDistance;
            }
         }
         if(newStopLoss > 0)
         {
            Print(
               "PHX Engine: Profit Protection trigger Ticket=",
               IntegerToString(position.Ticket),
               " NewSL=",
               DoubleToString(newStopLoss,_Digits)
            );
   double newStopLoss = position.OpenPrice;

   if(position.Direction == PHX_POSITION_BUY)
{
   newStopLoss =
      position.OpenPrice +
      lockDistance;
}
   if(position.Direction == PHX_POSITION_SELL)
{
   newStopLoss =
      position.OpenPrice -
      lockDistance;
}
   bool modified =
   (*m_tradeExecutor).Modify(
      position.Ticket,
      newStopLoss,
      position.TakeProfit
   );
            if(modified)
            {
               (*m_positionProvider).SetProfitProtectionActivated(position.Ticket)
               ;
               Print(
                  "PHX Engine: Profit Protection activated Ticket=",
                  IntegerToString(position.Ticket)
               );
            }
            else
            {
               Print(
                  "PHX Engine: Profit Protection modify failed"
               );
            }        
      }
   }
}
//--------------------------------------------------
// Trailing Stop Management
//--------------------------------------------------
if(positions > 0)
{
   if(m_riskProvider != NULL)
   {
   //--------------------------------------------------
   // Trailing Configuration Diagnostics
   //--------------------------------------------------
   Print(
   "PHX TRAILING CONFIG: ",
   "Enabled=",
   (*m_riskProvider).TrailingEnabled(),
   " Points=",
   DoubleToString(
      (*m_riskProvider).TrailingStopPoints(),
      0
   ),
   " Symbol=",
   _Symbol,
   " Point=",
   DoubleToString(
      SymbolInfoDouble(
         _Symbol,
         SYMBOL_POINT
      ),
      _Digits
   )
);
      if((*m_riskProvider).TrailingEnabled())
      {
         double trailingPoints =
            (*m_riskProvider).TrailingStopPoints();
         if(trailingPoints > 0)
         {
            double point =
               SymbolInfoDouble(
                  _Symbol,
                  SYMBOL_POINT
               );
            double trailingDistance =
               trailingPoints *
               point;
            for(int i = 0; i < positions; i++)
            {
               SPHXPositionSnapshot position;
               position.Reset();
               if(!(*m_positionProvider).Get(
                     i,
                     position
                  ))
               {
                  continue;
               }
               double currentPrice = 0.0;
               double newStopLoss = 0.0;
               //--------------------------------------------------
               // BUY
               //--------------------------------------------------
               if(position.Direction == PHX_POSITION_BUY)
               {
                  currentPrice =
                     (*m_priceProvider).Bid();
                  newStopLoss =
                     currentPrice -
                     trailingDistance;
                  Print(
                     "PHX Trailing BUY Check: ",
                     "Ticket=",
                     IntegerToString(position.Ticket),
                     " Open=",
                     DoubleToString(
                        position.OpenPrice,
                        _Digits
                     ),
                     " Current=",
                     DoubleToString(
                        currentPrice,
                        _Digits
                     ),
                     " OldSL=",
                     DoubleToString(
                        position.StopLoss,
                        _Digits
                     ),
                     " NewSL=",
                     DoubleToString(
                        newStopLoss,
                        _Digits
                     )
                  );
                  //--------------------------------------------------
                  // Never worsen BUY StopLoss
                  //--------------------------------------------------
                  if(
                     position.StopLoss > 0 &&
                     newStopLoss <= position.StopLoss
                  )
                  {
                     continue;
                  }
               }
               //--------------------------------------------------
               // SELL
               //--------------------------------------------------
               if(position.Direction == PHX_POSITION_SELL)
               {
                  currentPrice =
                     (*m_priceProvider).Ask();
                  newStopLoss =
                     currentPrice +
                     trailingDistance;
                  Print(
                     "PHX Trailing SELL Check: ",
                     "Ticket=",
                     IntegerToString(position.Ticket),
                     " Open=",
                     DoubleToString(
                        position.OpenPrice,
                        _Digits
                     ),
                     " Current=",
                     DoubleToString(
                        currentPrice,
                        _Digits
                     ),
                     " OldSL=",
                     DoubleToString(
                        position.StopLoss,
                        _Digits
                     ),
                     " NewSL=",
                     DoubleToString(
                        newStopLoss,
                        _Digits
                     )
                  );
                  //--------------------------------------------------
                  // Never worsen SELL StopLoss
                  //--------------------------------------------------
                  if(
                     position.StopLoss > 0 &&
                     newStopLoss >= position.StopLoss
                  )
                  {
                     continue;
                  }
               }
               //--------------------------------------------------
               // Validate New StopLoss
               //--------------------------------------------------
               if(newStopLoss <= 0)
               {
                  continue;
               }
               //--------------------------------------------------
               // Modify StopLoss
               //--------------------------------------------------
               if(PHX_VERBOSE_DEBUG)
{
   Print(
      "PHX Engine: Trailing Modify ",
      "Ticket=",
      IntegerToString(position.Ticket),
      " OldSL=",
      DoubleToString(position.StopLoss,_Digits),
      " NewSL=",
      DoubleToString(newStopLoss,_Digits)
   );
}
               if(!(*m_tradeExecutor).Modify(
                     position.Ticket,
                     newStopLoss,
                     position.TakeProfit
                  ))
               {
                  Print(
                     "PHX Engine: Trailing modify failed Ticket=",
                     IntegerToString(
                        position.Ticket
                     )
                  );
               }
               else
               {
                  Print(
                     "PHX Engine: Trailing modified Ticket=",
                     IntegerToString(
                        position.Ticket
                     )
                  );
               }
            }
         }
      }
   }
}
// Build Snapshot
//--------------------------------------------------
// No Trade Direction Protection
//--------------------------------------------------

if(direction == PHX_DIRECTION_NONE)
{
   if(PHX_VERBOSE_DEBUG)
{
   Print(
      "PHX Engine: No trade direction - cycle completed"
   );
}

   return true;
}
//--------------------------------------------------
// Risk Calculation
//--------------------------------------------------
   SPHXRiskResult riskResult;
   riskResult.Reset();

   if(m_riskProvider == NULL)
{
   Print(
      "PHX Engine ERROR: Risk Provider NULL"
   );
   return false;
}
   if(!(*m_riskProvider).Calculate(
      riskSnapshot
   ))
{
   Print(
      "PHX Engine: Risk calculation failed"
   );
   return false;
}
   riskResult =
   (*m_riskProvider).GetResult();

// Calculate Risk

//--------------------------------------------------
// Normal Risk Block
//--------------------------------------------------
if(riskResult.Result != PHX_RISK_ALLOWED)
{
   Print(
      "PHX Engine: Risk rejected trade Reason=",
      IntegerToString(
         riskResult.Reason
      )
   );
   return true;
}
//--------------------------------------------------
// ATR Pyramid Context
//--------------------------------------------------
double pyramidATR =
   riskSnapshot.DailyATR;
Print(
   "PHX Engine: Pyramid ATR=",
   DoubleToString(
      pyramidATR,
      _Digits
   )
);
//--------------------------------------------------
// Risk Layer completed
//--------------------------------------------------

//--------------------------------------------------
// Stage 6
// Position Management
//--------------------------------------------------
Print(
   "PHX Engine: Stage 6 Position Layer START"
);
if(m_positionProvider == NULL)
{
   Print(
      "PHX Engine ERROR: PositionProvider NULL"
   );
   return false;
}


//--------------------------------------------------
// Position Limit Guard
//--------------------------------------------------
if(positions >= m_maxPositions)
{
   Print(
      "PHX Engine: Position limit reached. Positions=",
      IntegerToString(positions),
      " Max=",
      IntegerToString(m_maxPositions)
   );
   return true;
}
//--------------------------------------------------
// Last Position Diagnostics
//--------------------------------------------------

//--------------------------------------------------
// ATR Pyramid Guard
//--------------------------------------------------
if(positions > 0)
{
   SPHXPositionSnapshot lastPosition;
   lastPosition.Reset();

   if((*m_positionProvider).GetLastPosition(
         lastPosition
      ))
   {
      double currentPrice = 0.0;
      if(direction == PHX_DIRECTION_BUY)
      {
         currentPrice =
         m_priceProvider.Bid();
            
         double distance =
            lastPosition.OpenPrice -
            currentPrice;
Print(
   "PHX Engine: Pyramid Check ",
   "LastOpen=",
   DoubleToString(lastPosition.OpenPrice,_Digits),
   " Current=",
   DoubleToString(currentPrice,_Digits),
   " Distance=",
   DoubleToString(distance,_Digits),
   " ATR=",
   DoubleToString(pyramidATR,_Digits)
);
         if(distance < pyramidATR)
         {
            Print(
               "PHX Engine: BUY pyramid blocked. Distance=",
               DoubleToString(
                  distance,
                  _Digits
               ),
               " ATR=",
               DoubleToString(
                  pyramidATR,
                  _Digits
               )
            );
            return true;
         }
      }
      if(direction == PHX_DIRECTION_SELL)
      {
         currentPrice =
         m_priceProvider.Ask();     

         double distance =
            currentPrice -
            lastPosition.OpenPrice;
Print(
   "PHX Engine: Pyramid Check ",
   "LastOpen=",
   DoubleToString(lastPosition.OpenPrice,_Digits),
   " Current=",
   DoubleToString(currentPrice,_Digits),
   " Distance=",
   DoubleToString(distance,_Digits),
   " ATR=",
   DoubleToString(pyramidATR,_Digits)
);
         if(distance < pyramidATR)
         {
            Print(
               "PHX Engine: SELL pyramid blocked. Distance=",
               DoubleToString(
                  distance,
                  _Digits
               ),
               " ATR=",
               DoubleToString(
                  pyramidATR,
                  _Digits
               )
            );
            return true;
         }
      }
   }
}
//--------------------------------------------------
// Prepare Position Snapshot
//--------------------------------------------------
SPHXPositionSnapshot positionSnapshot;
positionSnapshot.Reset();
//--------------------------------------------------
// Calculate Position Decision
//--------------------------------------------------
if(!(*m_positionProvider).Calculate(
      positionSnapshot
))
{
   Print(
      "PHXTradingEngine: Position decision rejected"
   );
   return true;
}
//--------------------------------------------------
// Get Position Decision
//--------------------------------------------------
SPHXPositionDecision positionDecision;
positionDecision =
   (*m_positionProvider).GetDecision();
   
   Print(
   "PHX Engine: Position Layer OK"
);

/*
   TEST CLOSE POSITION

if(positions > 0)
{
   SPHXPositionSnapshot testPosition;

   testPosition.Reset();

   if((*m_positionProvider).Get(
         0,
         testPosition
      ))
   {
      Print(
         "PHX Engine TEST: Closing Ticket=",
         IntegerToString(
            testPosition.Ticket
         )
      );
      if(m_tradeExecutor != NULL)
      {
         bool closed =
            m_tradeExecutor.Close(
               testPosition.Ticket
            );
         if(closed)
         {
            Print(
               "PHX Engine TEST: Position closed"
            );   
                 return true;
         }
         else
         {
            Print(
               "PHX Engine TEST: Close failed"
            );
         }
      }Print(
   "PHX Engine TEST: Closing Ticket=",
   IntegerToString(testPosition.Ticket),
   " Profit=",
   DoubleToString(testPosition.Profit,2)
);
   }
}
*/
//--------------------------------------------------
// Position Layer completed
//--------------------------------------------------

//--------------------------------------------------
// Trading Schedule Check
//--------------------------------------------------
if(!IsTradingTimeAllowed())
{
   Print(
      "PHX Engine: Trading time blocked. New entries disabled."
   );
   return true;
}
//--------------------------------------------------
// Entry Quality Filter
//--------------------------------------------------
if(!CheckEntryQuality(direction))
{
   Print(
      "PHX Engine: Entry rejected by Quality Filter"
   );
   return true;
}
//--------------------------------------------------
// Trend Diagnostics
//--------------------------------------------------
Print(
   "PHX Reversal Check: ",
   "Positions=",
   positions,
   " TrendTotal=",
   trendScore.Total,
   " EMA=",
   trendScore.EMA.Total,
   " RSI=",
   trendScore.RSI.Total,
   " ADX=",
   trendScore.ADX.Total,
   " ATR=",
   trendScore.ATR.Total,
   " Volume=",
   trendScore.Volume.Total
);
//--------------------------------------------------
// Preserve signal context for executed trade
//--------------------------------------------------

m_lastExecutedSignal = signal;
//--------------------------------------------------
// Stage 7
// Trade Execution Layer
//--------------------------------------------------
if(direction == PHX_DIRECTION_NONE)
{
   Print(
      "PHX Engine: No trade direction"
   );

   return true;
}


//--------------------------------------------------
// FINAL D1 ENERGY HARD GATE
//--------------------------------------------------

if(m_atrEnergy == NULL)
{
   Print(
      "PHX HARD GATE ERROR: ATREnergy=NULL"
   );

   // Fail-safe:
   // new trade is forbidden if D1 Energy is unavailable
   return true;
}


if(m_indicatorServices == NULL)
{
   Print(
      "PHX HARD GATE ERROR: IndicatorServices=NULL"
   );

   return true;
}


//--------------------------------------------------
// Existing PHX Technical Daily ATR
//--------------------------------------------------

double technicalDailyATR =
   (*m_indicatorServices).DailyATR();


if(technicalDailyATR <= 0.0)
{
   Print(
      "PHX HARD GATE ERROR: ",
      "Technical DailyATR invalid=",
      DoubleToString(
         technicalDailyATR,
         3
      )
   );

   return true;
}


//--------------------------------------------------
// Final D1 Energy Decision
//--------------------------------------------------

bool d1EnergyOK =
   (*m_atrEnergy).IsEnergyEnough(
      technicalDailyATR
   );


//--------------------------------------------------
// D1 ENERGY RESEARCH MODE
//
// D1 Energy is calculated and preserved for
// research/statistics, but DOES NOT block trading.
//--------------------------------------------------

if(!d1EnergyOK)
{
   Print(
      "PHX D1 ENERGY RESEARCH: ",
      "Remaining=",
      DoubleToString(
         (*m_atrEnergy).GetRemainingRatio()
         * 100.0,
         2
      ),
      "%",
      " DecisionImpact=NONE"
   );
}

   

//--------------------------------------------------
// HARD GATE PASSED
//--------------------------------------------------

Print(
   "PHX HARD D1 ENERGY GATE PASSED: ",
   "Remaining=",
   DoubleToString(
      (*m_atrEnergy).GetRemainingRatio()
      * 100.0,
      2
   ),
   "%"
);


Print(
   "PHX Engine: Stage 7 Trade Execution START"
);

//--------------------------------------------------
// Validate Executor
//--------------------------------------------------
if(m_tradeExecutor == NULL)
{
   Print(
      "PHX Engine ERROR: TradeExecutor NULL"
   );
   return false;
}
Print(
   "PHX SCORE DEBUG: ",
   "TrendScore=",
   DoubleToString(trendScore.Total,2),
   " Direction=",
   IntegerToString(direction)
);
//--------------------------------------------------
// Signal Score Protection
//--------------------------------------------------

const double MinSignalScore = 0.0;

if(trendScore.Total < MinSignalScore)
{
   Print(
      "PHX TRADE BLOCKED: SCORE=",
      DoubleToString(trendScore.Total,2),
      " MIN=",
      DoubleToString(MinSignalScore,2)
   );

   return false;
}
//--------------------------------------------------
// PHX Early Entry RSI Evaluation
//--------------------------------------------------

double rsiQuality = 0.0;

if(direction == PHX_DIRECTION_BUY)
{
   if(trendScore.RSI.Total > 0)
      rsiQuality += 1.0;
   else
      rsiQuality -= 0.5;
}


if(direction == PHX_DIRECTION_SELL)
{
   if(trendScore.RSI.Total < 0)
      rsiQuality += 1.0;
   else
      rsiQuality -= 0.5;
}


Print(
   "PHX RSI QUALITY: ",
   DoubleToString(rsiQuality,2)
);
//--------------------------------------------------
// Prepare Trade Request
//--------------------------------------------------
SPHXTradeRequest tradeRequest;
tradeRequest.Reset();
tradeRequest.Direction =
   direction;
tradeRequest.Action =
   PHX_TRADE_OPEN; 
//--------------------------------------------------
// Apply Risk Parameters
//--------------------------------------------------
tradeRequest.Volume =
   riskResult.Lot;
   
Print(
   "PHX Engine: TradeRequest Volume=",
   DoubleToString(
      tradeRequest.Volume,
      2
   )
);  
//--------------------------------------------------
// Validate Price Provider
//--------------------------------------------------
if(m_priceProvider == NULL)
{
   Print(
      "PHX Engine ERROR: Price Provider NULL"
   );
   return false;
}
//--------------------------------------------------
// Convert Risk SL to Price Level
//--------------------------------------------------
double stopLossPrice = 0.0;
//--------------------------------------------------
// Normalize ATR distance to MT5 points
//--------------------------------------------------
//--------------------------------------------------
// Convert Risk SL to Price Level
//--------------------------------------------------
Print(
   "PHX DEBUG RiskResult StopLoss=",
   DoubleToString(
      riskResult.StopLoss,
      _Digits
   )
);
double slDistance =
   riskResult.StopLoss; 
//--------------------------------------------------
// Minimum StopLoss Protection
//--------------------------------------------------

double point =
   SymbolInfoDouble(
      _Symbol,
      SYMBOL_POINT
   );


long spreadPoints =
   SymbolInfoInteger(
      _Symbol,
      SYMBOL_SPREAD
   );


long stopsLevelPoints =
   SymbolInfoInteger(
      _Symbol,
      SYMBOL_TRADE_STOPS_LEVEL
   );


double spreadDistance =
   spreadPoints *
   point;


double brokerStopDistance =
   stopsLevelPoints *
   point;


//--------------------------------------------------
// Small safety buffer
//--------------------------------------------------

double safetyDistance =
   point * 2.0;


//--------------------------------------------------
// Absolute minimum SL distance
//--------------------------------------------------

double minimumSLDistance =
   MathMax(
      spreadDistance,
      brokerStopDistance
   )
   +
   safetyDistance;


//--------------------------------------------------
// Protect initial StopLoss
//--------------------------------------------------

if(slDistance < minimumSLDistance)
{
   Print(
      "PHX SL PROTECTION: ",
      "Calculated=",
      DoubleToString(
         slDistance,
         _Digits
      ),
      " Spread=",
      DoubleToString(
         spreadDistance,
         _Digits
      ),
      " BrokerMin=",
      DoubleToString(
         brokerStopDistance,
         _Digits
      ),
      " CorrectedSL=",
      DoubleToString(
         minimumSLDistance,
         _Digits
      )
   );


   slDistance =
      minimumSLDistance;
}   
 
Print(
   "PHX TEST RiskResult.StopLoss=",
   DoubleToString(
      riskResult.StopLoss,
      5
   )
);
Print(
   "PHX TEST slDistance=",
   DoubleToString(
      slDistance,
      5
   )
);
if(direction == PHX_DIRECTION_BUY)
{
   stopLossPrice =
      (*m_priceProvider).Ask()
      - slDistance;
}
if(direction == PHX_DIRECTION_SELL)
{
   stopLossPrice =
      (*m_priceProvider).Bid()
      + slDistance;
}
//--------------------------------------------------
// Normalize Price
//--------------------------------------------------
Print(
   "PHX SL Calculation: ",
   "Raw=",
   DoubleToString(riskResult.StopLoss,_Digits),
   " Distance=",
   DoubleToString(slDistance,_Digits),
   " Digits=",
   _Digits,
   " FinalSL=",
   DoubleToString(stopLossPrice,_Digits)
);
tradeRequest.StopLoss =
   NormalizeDouble(
      stopLossPrice,
      _Digits
   );

tradeRequest.TakeProfit =
   riskResult.TakeProfit;
//--------------------------------------------------
// Trade Identity
//--------------------------------------------------
tradeRequest.Symbol =
   _Symbol;

tradeRequest.Magic =
   260826;
//--------------------------------------------------
// Execute
//--------------------------------------------------
SPHXTradeResult tradeResult;

tradeResult.Reset();

if(PHX_VERBOSE_DEBUG)
{
 Print(
   "PHX CYCLE #",
   IntegerToString(phxCycle),
   " EXECUTE REQUEST ",
   "Symbol=",
   tradeRequest.Symbol,
   " Direction=",
   IntegerToString(tradeRequest.Direction),
   " Volume=",
   DoubleToString(tradeRequest.Volume,2)
);  
}

Print(
"##################################################"
);

Print(
"### PHX ORDER EXECUTION START"
);

Print(
"### Direction=",
IntegerToString(direction),
" Volume=",
DoubleToString(tradeRequest.Volume,2)
);

Print(
"##################################################"
);

if(!(*m_tradeExecutor).Execute(
      tradeRequest,
      tradeResult
   ))
{
   Print(
      "##################################################"
   );

   Print(
      "PHX Engine ERROR: Trade execution FAILED",
      " Success=",
      tradeResult.Success,
      " Message=",
      tradeResult.Message
   );

   Print(
      "##################################################"
   );

   return false;
}


//--------------------------------------------------
// Execution successful
//--------------------------------------------------

Print(
   "##################################################"
);

Print(
   "### PHX ORDER OPENED SUCCESSFULLY"
);

Print(
   "### Ticket=",
   IntegerToString(tradeResult.Ticket)
);

Print(
   "##################################################"
);
//--------------------------------------------------
// Attach Execution Quality Data
//--------------------------------------------------

if(m_qualityTracker != NULL)
{
   (*m_qualityTracker).AttachExecutionData(
      tradeResult.Ticket,
      tradeResult.CandlePosition,
      tradeResult.ExecutionDelayMS,
      tradeResult.PriceVsCandleHigh
   );
}

//--------------------------------------------------
// Execution completed
//--------------------------------------------------

return true;
}
//+------------------------------------------------------------------+
//| Trading Time Check                                               |
//+------------------------------------------------------------------+
bool CPHXTradingEngine::IsTradingTimeAllowed()
{
   if(m_riskProvider == NULL)
      return false;

   if(!(*m_riskProvider).TradingTimeEnabled())
      return true;

   MqlDateTime tm;

   TimeToStruct(
      TimeCurrent(),
      tm
   );

   int currentMinutes =
      tm.hour * 60 +
      tm.min;

   int startMinutes =
      (*m_riskProvider).TradingStartHour() * 60 +
      (*m_riskProvider).TradingStartMinute();

   int endMinutes =
      (*m_riskProvider).TradingEndHour() * 60 +
      (*m_riskProvider).TradingEndMinute();
   //--------------------------------------------------
   // Normal interval
   //--------------------------------------------------
   if(startMinutes < endMinutes)
   {
      if(
         currentMinutes >= startMinutes &&
         currentMinutes < endMinutes
      )
         return true;
   }
   //--------------------------------------------------
   // Interval crossing midnight
   //--------------------------------------------------
   else
   {
      if(
         currentMinutes >= startMinutes ||
         currentMinutes < endMinutes
      )
         return true;
   }
   return false;
}
//+------------------------------------------------------------------+
//| Entry Quality Filter                                             |
//+------------------------------------------------------------------+
bool CPHXTradingEngine::CheckEntryQuality(
   ENUM_PHX_TRADE_DIRECTION direction
)
{
   if(m_priceProvider == NULL)
      return true;

   double high =
      iHigh(
         _Symbol,
         PERIOD_CURRENT,
         0
      );
   double low =
      iLow(
         _Symbol,
         PERIOD_CURRENT,
         0
      );
   if(high <= low)
      return true;

   double price = 0.0;

Print(
   "PHX PRICE DEBUG: Provider=",
   (m_priceProvider != NULL),
   " Bid=",
   DoubleToString((*m_priceProvider).Bid(),_Digits),
   " Ask=",
   DoubleToString((*m_priceProvider).Ask(),_Digits)
);

   if(direction == PHX_DIRECTION_BUY)
   {
      price =
         (*m_priceProvider).Ask();
   }

   if(direction == PHX_DIRECTION_SELL)
   {
      price =
         (*m_priceProvider).Bid();
   }
   double candlePosition = 0.5;
//--------------------------------------------------
// Safe Candle Position Calculation
//--------------------------------------------------
if(high > low)
{
   candlePosition =
      (price - low) /
      (high - low);
}
//--------------------------------------------------
// Clamp value
//--------------------------------------------------
if(candlePosition < 0.0)
   candlePosition = 0.0;


if(candlePosition > 1.0)
   candlePosition = 1.0;
//--------------------------------------------------
// Debug
//--------------------------------------------------
Print(
   "PHX Entry Quality DEBUG: ",
   "Price=",
   DoubleToString(price,_Digits),
   " High=",
   DoubleToString(high,_Digits),
   " Low=",
   DoubleToString(low,_Digits),
   " Position=",
   DoubleToString(candlePosition,2)
);

Print(
   "PHX Entry Quality: Direction=",
   IntegerToString(direction),
   " CandlePosition=",
   DoubleToString(candlePosition,2)
);


//--------------------------------------------------
// Entry Quality Filter
// Direction already validated by SignalServices
//--------------------------------------------------

Print(
   "PHX Entry Quality: Signal already validated. ",
   "Direction=",
   IntegerToString(direction),
   " CandlePosition=",
   DoubleToString(candlePosition,2)
);
Print(
 "PHX Entry Quality PASS: ",
 "Direction=",
 IntegerToString(direction),
 " CandlePosition=",
 DoubleToString(candlePosition,2)
);
// No candle position blocking here.
// SignalServices owns entry geometry.

//--------------------------------------------------
// Candle Direction Filter
//--------------------------------------------------
double open =
   iOpen(
      _Symbol,
      PERIOD_CURRENT,
      0
   );
double close =
   iClose(
      _Symbol,
      PERIOD_CURRENT,
      0
   );
double candleSize =
   MathAbs(close - open);
double atr = 0.0;
if(m_indicatorProvider != NULL)
{
   atr =
      (*m_indicatorProvider).ATR();
}
//--------------------------------------------------
// SELL against bullish impulse
//--------------------------------------------------
if(direction == PHX_DIRECTION_SELL)
{
   if(
      close > open &&
      atr > 0 &&
      candleSize > atr * 0.5
   )
   {
      Print(
         "PHX Entry Quality BLOCK SELL: Bullish candle impulse ",
         "Size=",
         DoubleToString(candleSize,_Digits),
         " ATR=",
         DoubleToString(atr,_Digits)
      );
      return false;
   }
}
//--------------------------------------------------
// BUY against bearish impulse
//--------------------------------------------------
if(direction == PHX_DIRECTION_BUY)
{
   if(
      close < open &&
      atr > 0 &&
      candleSize > atr * 0.5
   )
   {
      Print(
         "PHX Entry Quality BLOCK BUY: Bearish candle impulse ",
         "Size=",
         DoubleToString(candleSize,_Digits),
         " ATR=",
         DoubleToString(atr,_Digits)
      );
      return false;
   }
}
return true;
}
//+------------------------------------------------------------------+
//| Check Position Reversal                                          |
//+------------------------------------------------------------------+
void CPHXTradingEngine::CheckPositionReversal()
{
   if(m_trendProvider == NULL)
      return;
   Print(
      "PHX Reversal Check: Trend provider available"
   );
}

#endif // PHX_TRADING_ENGINE_MQH
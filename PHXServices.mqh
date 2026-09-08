//+------------------------------------------------------------------+
//|                                              PHXServices.mqh     |
//|                  PHOENIX PRO Trading Framework                   |
//|           Central Static Service Container (Infrastructure)      |
//+------------------------------------------------------------------+
#ifndef __PHX_SERVICES_MQH__
#define __PHX_SERVICES_MQH__

//==================================================================
// Core
//==================================================================

#include "IPHXService.mqh"
#include "../Signal/CPHXSignalValidation.mqh"
#include "Logger/PHXLogger.mqh"
#include "PHXConfigManager.mqh"
#include "../Infrastructure/PHXStateManager.mqh"
#include "../Infrastructure/PHXPerformanceMonitor.mqh"
#include "../Infrastructure/PHXClock.mqh"
#include "../Infrastructure/PHXEventBus.mqh"
#include "../Infrastructure/PHXDiagnostics.mqh"
#include "../Infrastructure/PHXBuildInfo.mqh"

//==================================================================
// Market
//==================================================================

#include "../Market/PHXMarketServices.mqh"
#include "../Market/PHXMarketStateProvider.mqh"
#include "../Statistics/PHXTrendSnapshotBuilder.mqh"
#include "../Market/PHXMarketIndicatorProvider.mqh"

//==================================================================
// Indicators
//==================================================================

#include "../Indicators/PHXIndicatorServices.mqh"
#include "../Indicators/PHXATREnergy.mqh"
#include "../Indicators/PHXEMAProvider.mqh"

//==================================================================
// Signal
//==================================================================

#include "../Signal/PHXSignalServices.mqh"
#include "../Signal/PHXSignalState.mqh"
#include "../Signal/PHXTrendServices.mqh"

//==================================================================
// Position
//==================================================================
#include "../Position/CPHXPositionManager.mqh"
#include "../Position/CPHXPositionStatistics.mqh"
//==================================================================
// Risk
//==================================================================
#include "../Risk/CPHXRiskManager.mqh"
#include "../Risk/PHXRiskSnapshotBuilder.mqh"
//==================================================================
// Trade
//==================================================================
#include "../Trade/PHXTradeServices.mqh"
#include "../Trade/CPHXTradeExecutor.mqh"
//==================================================================
// Static Service Container
//==================================================================
#include "../Statistics/PHXSignalQualityTracker.mqh"
//==================================================================
// Utils
//==================================================================
#include "../Utils/PHXInfoPanel.mqh"

class CPHXServices
{
private:
   CPHXMarketServices* m_marketServices;
   CPHXIndicatorServices* m_indicatorService;     
   CPHXEMAProvider* m_emaProvider;   
   CPHXMarketStateProvider* m_marketStateProvider;   
   //--------------------------------------------------
   // Trend Services
   //--------------------------------------------------
   CPHXTrendServices m_trend;   
   CPHXTrendSnapshotBuilder m_trendSnapshotBuilder;
   //--------------------------------------------------
   // Trend transition state
   //--------------------------------------------------

   ENUM_PHX_TREND m_previousTrend;

   int m_barsSinceTrendChange;

   datetime m_lastTrendTransitionBarTime;


   //--------------------------------------------------
   // Market Phase memory
   //--------------------------------------------------

   int m_exhaustionUpBars;
   //--------------------------------------------------
   // Market Services
   //--------------------------------------------------
   CPHXMarketIndicatorProvider* m_marketIndicatorProvider;
   //--------------------------------------------------
   // Signal Services
   //--------------------------------------------------
   CPHXSignalServices* m_signalServices;
   CPHXSignalValidation* m_signalValidation;
   CPHXATREnergy* m_atrEnergy;
   CPHXSignalState* m_signalState;   
   CPHXTradeServices* m_tradeServices;   
   CPHXTradeExecutor* m_tradeExecutor; 
   CPHXSignalQualityTracker* m_signalQualityTracker; 
   //--------------------------------------------------
   // Information Panel
   //--------------------------------------------------
   CPHXInfoPanel m_infoPanel; 
   //--------------------------------------------------
   // Risk Services
   //--------------------------------------------------
   CPHXRiskManager* m_riskManager;   
   SPHXRiskConfig m_riskConfig;   
   CPHXRiskSnapshotBuilder* m_riskSnapshotBuilder;   
   //--------------------------------------------------
   // Position Services
   //--------------------------------------------------
   CPHXPositionManager* m_positionManager;        
   CPHXPositionStatistics* m_positionStatistics;   
   bool m_initialized;
   bool m_started;
   bool m_initializing;   
   //---------------------------------------------------------------
   // Infrastructure
   //---------------------------------------------------------------
   CPHXLogger                 m_logger;
   CPHXConfigManager          m_config;
   CPHXStateManager           m_state;
   CPHXPerformanceMonitor     m_performance;
   CPHXClock                  m_clock;
   CPHXEventBus               m_eventBus;
   CPHXDiagnostics            m_diagnostics;
   CPHXBuildInfo              m_buildInfo;
  
public:
   //---------------------------------------------------------------
   // Construction
   //---------------------------------------------------------------
   CPHXServices();
   ~CPHXServices();  
   //---------------------------------------------------------------
   // Life cycle
   //---------------------------------------------------------------
   bool Initialize();
   bool Start();
   void ConfigureRisk(
   double lot,
   double stopLossPoints,
   bool trailingEnabled,
   double trailingPoints,
   bool tradingTimeEnabled,
   int startHour,
   int startMinute,
   int endHour,
   int endMinute
);
   //--------------------------------------------------
   // Diagnostics
   //--------------------------------------------------
   void PrintConfiguration();
   void Tick();
   void Timer();
   void TradeTransaction(
      const MqlTradeTransaction &trans,
      const MqlTradeRequest &request,
      const MqlTradeResult &result);
   void Stop();
   void Shutdown();   
   bool IsInitialized() const;   
   //--------------------------------------------------
   // Accessors
   //--------------------------------------------------
public:
   CPHXMarketServices* GetMarket();
   CPHXIndicatorServices* GetIndicators();   
   CPHXMarketIndicatorProvider* GetMarketIndicatorProvider();
       
//--------------------------------------------------
// Indicator Access
//--------------------------------------------------
   CPHXATR* CurrentATR();   
   CPHXATR* BaseATR();
   CPHXATREnergy* ATREnergy();
   CPHXMovingAverage* MA();
   CPHXRSI* RSI();
   CPHXADX* ADX();
   CPHXVolumeAnalyzer* Volume();   
   CPHXMarketEngine* GetMarketEngine();
   CPHXSymbolInfo* GetSymbolInfo();
   CPHXTickBuffer* GetTickBuffer();
   CPHXSpreadMonitor* GetSpreadMonitor();
   CPHXSessionManager* GetSessionManager();
   CPHXMarketSnapshot* GetSnapshot();   
   CPHXTradeServices* GetTradeServices();
   //---------------------------------------------------------------
   // Infrastructure access
   //---------------------------------------------------------------
   CPHXLogger* Logger();
   CPHXConfigManager* Config();
   CPHXStateManager* State();
   CPHXPerformanceMonitor* Performance();
   CPHXClock* Clock();
   CPHXEventBus* EventBus();
   CPHXDiagnostics* Diagnostics();
   CPHXBuildInfo* BuildInfo();
   //---------------------------------------------------------------
   // Market access
   //---------------------------------------------------------------
   CPHXMarketEngine* MarketEngine();
   CPHXSymbolInfo* SymbolInfo();
   CPHXTickBuffer* TickBuffer();
   CPHXSpreadMonitor* SpreadMonitor();
   CPHXSessionManager* SessionManager();
   CPHXMarketSnapshot* MarketSnapshot();      
   CPHXTradeServices* TradeServices();      
   CPHXTradeExecutor* TradeExecutor();      
   //---------------------------------------------------------------
   // Signal access
   //---------------------------------------------------------------
   CPHXSignalValidation* SignalValidation();      
   CPHXSignalServices* Signals();       
   CPHXTrendServices* Trend();
   CPHXSignalQualityTracker* SignalQualityTracker();      
   CPHXRiskManager* Risk();      
   CPHXRiskSnapshotBuilder* RiskSnapshotBuilder();      
   //--------------------------------------------------
   // Position access
   //--------------------------------------------------
   CPHXPositionManager* PositionManager();
   CPHXPositionStatistics* PositionStatistics();   
   //---------------------------------------------------------------
   // Const access
   //---------------------------------------------------------------
   const CPHXLogger* Logger() const;
   const CPHXConfigManager* Config() const;
   const CPHXStateManager* State() const;
   const CPHXPerformanceMonitor* Performance() const;
   const CPHXClock* Clock() const;
   const CPHXEventBus* EventBus() const;
   const CPHXDiagnostics* Diagnostics() const;
   const CPHXBuildInfo* BuildInfo() const;
   const CPHXMarketEngine* Market() const;
   const CPHXSymbolInfo* SymbolInfo() const;
   const CPHXTickBuffer* TickBuffer() const;
   const CPHXSpreadMonitor* SpreadMonitor() const;
   const CPHXSessionManager* SessionManager() const;
   const CPHXMarketSnapshot* MarketSnapshot() const;
};
//+------------------------------------------------------------------+
//| Constructor                                                     |
//+------------------------------------------------------------------+
   CPHXServices::CPHXServices()
{
   m_marketServices = NULL;
   m_indicatorService = NULL;
   m_signalServices = NULL;
   m_signalState = NULL;
   m_atrEnergy = NULL;
   m_signalQualityTracker = NULL;
   m_emaProvider = NULL;
   m_marketStateProvider = NULL;
   m_marketIndicatorProvider = NULL;      
   m_signalValidation = NULL;   
   m_positionManager = NULL;
   m_positionStatistics = NULL;
   m_tradeServices = NULL;
   m_tradeExecutor = NULL;
   m_riskManager = NULL;
   m_riskSnapshotBuilder = NULL;
   m_initialized = false;
   m_started = false;
   m_initializing = false;
}
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
   CPHXServices::~CPHXServices()
{
   Shutdown();
}
//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
   bool CPHXServices::Initialize()
{
   m_initializing = true;
   Print("PHXServices: Initialize started");
   if(m_initialized)
      return true;
   //--------------------------------------------------
   // Logger
   //--------------------------------------------------
   SPHXLoggerConfig loggerConfig;
   if(!m_logger.Initialize(loggerConfig))
{
   Shutdown();
   return false;
}
   //--------------------------------------------------
   // Infrastructure
   //--------------------------------------------------
   if(!m_config.Initialize())
{
      Shutdown();
      return false;
}
   if(!m_state.Initialize())
{
      Shutdown();
      return false;
}
   if(!m_performance.Initialize())
{
      Shutdown();
      return false;
}
   if(!m_clock.Initialize())
{
      Shutdown();
      return false;
}
   if(!m_eventBus.Initialize())
{
      Shutdown();
      return false;
}
   if(!m_diagnostics.Initialize())
{
      Shutdown();
      return false;
}
   if(!m_buildInfo.Initialize())
{
      Shutdown();
      return false;
}
   //--------------------------------------------------
   // Market Services Container
   //--------------------------------------------------
   m_marketServices = new CPHXMarketServices();
   if(m_marketServices == NULL)      
      return false;
   if(!(*m_marketServices).Initialize())
   {
      delete m_marketServices;
      m_marketServices = NULL;    
      return false;
   }
   //--------------------------------------------------
   // Indicator Services Container
   //--------------------------------------------------
   m_indicatorService = new CPHXIndicatorServices();   
   if(m_indicatorService == NULL)
      return false;
   if(!(*m_indicatorService).Initialize())
   {
      delete m_indicatorService;
      m_indicatorService = NULL;
      return false;
   } 
   //--------------------------------------------------
   // Configure MTF Alignment
   //--------------------------------------------------

   SPHXMTFAlignmentConfig mtfConfig =
   m_config.GetMTFAlignmentConfig();


   m_indicatorService.ConfigureMTFAlignment(
   mtfConfig
);
   //--------------------------------------------------
   // Risk Snapshot Builder
   //--------------------------------------------------
   m_riskSnapshotBuilder =
   new CPHXRiskSnapshotBuilder();
   if(m_riskSnapshotBuilder == NULL)
   {
   Shutdown();
   return false;
   }
   (*m_riskSnapshotBuilder).SetIndicatorProvider(
   m_indicatorService
);
   //--------------------------------------------------
   // EMA Provider
   //--------------------------------------------------
   m_emaProvider = new CPHXEMAProvider();
   if(m_emaProvider == NULL)
   return false;
   if(!(*m_emaProvider).Initialize(
      _Symbol,
      PERIOD_CURRENT
   ))
   {
   delete m_emaProvider;
   m_emaProvider = NULL;
   return false;
   }
   //--------------------------------------------------
   // Market Indicator Provider
   //--------------------------------------------------
   m_marketIndicatorProvider =
   new CPHXMarketIndicatorProvider();
   if(m_marketIndicatorProvider == NULL)
   {
   Shutdown();
   return false;
   }
   if(!(*m_marketIndicatorProvider).Initialize(
      _Symbol,
      PERIOD_CURRENT
   ))
   {
   delete m_marketIndicatorProvider;
   m_marketIndicatorProvider = NULL;
   Shutdown();
   return false;
   }
   //--------------------------------------------------
   // Link Indicator Services
   //--------------------------------------------------
   (*m_marketIndicatorProvider).SetIndicatorService(
   m_indicatorService
   );
   //--------------------------------------------------
   // Market State Provider
   //--------------------------------------------------
   m_marketStateProvider = new CPHXMarketStateProvider();
   if(m_marketStateProvider == NULL)
   return false;
   if(!(*m_marketStateProvider).Initialize(
      _Symbol
   ))
   {
   delete m_marketStateProvider;
   m_marketStateProvider = NULL;
   return false;
   }
   m_previousTrend =
   PHX_TREND_FLAT;

   m_barsSinceTrendChange =
   0;
   m_lastTrendTransitionBarTime =
   0; 
   m_exhaustionUpBars =
   0;   
   //--------------------------------------------------
   // Risk Manager
   //--------------------------------------------------
   m_riskManager = new CPHXRiskManager();
   if(m_riskManager == NULL)
   {
   Shutdown();
   return false;
   }
   //--------------------------------------------------
   // Position Manager
   //--------------------------------------------------
   m_positionManager =
   new CPHXPositionManager();
   if(m_positionManager == NULL)
   {
   Shutdown();
   return false;
   }
   m_positionManager.SetMagic(
   260826
   );
   m_positionManager.SetSymbol(
   _Symbol
   );
   //--------------------------------------------------
   // Trend
   //--------------------------------------------------
   if(!m_trend.Initialize())
   {
   Print("PHXServices: Trend initialization failed.");
   Shutdown();
   return false;
   }
   //--------------------------------------------------
   // Trend Snapshot Builder
   //--------------------------------------------------
   m_trendSnapshotBuilder.SetTrendScoreProvider(
   &m_trend
   );
   m_trendSnapshotBuilder.SetMarketProvider(
   GetMarket()
   );
   m_trendSnapshotBuilder.SetMarketSnapshotProvider(
   m_marketServices
   );
   m_trendSnapshotBuilder.SetIndicatorProvider(
   m_indicatorService
   );
   m_trendSnapshotBuilder.SetEMAProvider(
   m_emaProvider
   );
   m_trendSnapshotBuilder.SetMarketStateProvider(
   m_marketStateProvider
   );
   //--------------------------------------------------
   // Signal Services
   //--------------------------------------------------
   m_signalServices = new CPHXSignalServices();
   if(m_signalServices == NULL)
   {
   Shutdown();
   return false;
   }
   //--------------------------------------------------
   // Signal Quality Tracker shutdown
   //--------------------------------------------------
   if(m_signalQualityTracker != NULL)
   {
   Print(
      "PHXServices: deleting Signal Quality Tracker"
   );

   delete m_signalQualityTracker;
   m_signalQualityTracker = NULL;

   Print(
      "PHXServices: Signal Quality Tracker released"
   );
   }
   //--------------------------------------------------
   // Signal Validation
   //--------------------------------------------------
   m_signalValidation = new CPHXSignalValidation();
   if(m_signalValidation == NULL)
   {
   
   return false;
   }
   if(!(*m_signalValidation).Initialize())
   {
   delete m_signalValidation;
   m_signalValidation = NULL;
   return false;
   }
   //--------------------------------------------------
   // Signal ATR State
   //--------------------------------------------------

   //--------------------------------------------------
   // Signal State
   //--------------------------------------------------
   m_signalState = new CPHXSignalState();

   if(m_signalState == NULL)
   {
   Shutdown();
   return false;
   }
   //--------------------------------------------------
   // Signal Quality Tracker
   //--------------------------------------------------
   m_signalQualityTracker =
   new CPHXSignalQualityTracker();

   if(m_signalQualityTracker == NULL)
   {
   Shutdown();
   return false;
   }

   Print(
   "PHXServices: Signal Quality Tracker created"
   );

   //--------------------------------------------------
   // Configure MTF Alignment Dependency
   //--------------------------------------------------

   m_signalQualityTracker.SetMTFAlignment(
   m_indicatorService.GetMTFAlignment()
);
   //--------------------------------------------------
   // ATR Energy
   //--------------------------------------------------
   m_atrEnergy =
   new CPHXATREnergy();
   if(m_atrEnergy == NULL)
   {
   Print(
      "PHXServices ERROR: ATR Energy creation failed"
   );
   Shutdown();
   return false;
   }
   Print(
   "PHXServices: ATR Energy created"
   );
   //--------------------------------------------------
   // Configure Signal Dependencies
   //--------------------------------------------------
   (*m_signalServices).SetATREnergy(
   m_atrEnergy
   );
   (*m_signalServices).SetIndicators(
   m_indicatorService
   );
   (*m_signalServices).SetMarketServices(
   m_marketServices
   );
   (*m_signalServices).SetQualityTracker(
   m_signalQualityTracker
   );
   //--------------------------------------------------
   // Configure Divergence
   //--------------------------------------------------
   SPHXDivergenceConfig divergenceConfig =
      m_config.GetDivergenceConfig();
   (*m_signalServices).SetDivergenceConfig(
      divergenceConfig
   );
   //--------------------------------------------------
   // Configure Trading Engine Market Price Provider
   //--------------------------------------------------

   //--------------------------------------------------
   // Initialize Signal Services
   //--------------------------------------------------
   if(!(*m_signalServices).Initialize())
   {
   delete m_signalServices;
   m_signalServices = NULL; 
   return false;
   }
   Print(
   "PHXServices: Signal Services initialized"
   ); 
   //--------------------------------------------------
   // Position Services
   //--------------------------------------------------
   m_positionStatistics = new CPHXPositionStatistics();
   if(m_positionStatistics == NULL)
   {
   delete m_positionManager;
   m_positionManager = NULL;
   return false;
   }
   Print("PHXServices: Position Services initialized");
   //--------------------------------------------------
   // Configure Risk Dependencies
   //--------------------------------------------------
   (*m_riskManager).SetIndicatorProvider(
   m_indicatorService
   );
   //--------------------------------------------------
   // Configure Risk Settings
   //--------------------------------------------------
   m_riskConfig.Reset();
   m_riskConfig.StopLossPoints = 500.0;
   m_riskConfig.EmergencyEquityPercent = 0.5;
   m_riskConfig.MaxDrawdownPercent = 10.0;
   m_riskConfig.MaxSpread = 50;
   m_riskConfig.MaxPositions = 3;
   //--------------------------------------------------
   // Trading Schedule
   //--------------------------------------------------
   (*m_riskManager).SetConfig(
   m_riskConfig
   );
   //--------------------------------------------------
   // Trade Services
   //--------------------------------------------------
   m_tradeServices = new CPHXTradeServices();
   if(m_tradeServices == NULL)
   {
   return false;
   }
   if(!m_tradeServices.Initialize())
   {
   delete m_tradeServices;
   m_tradeServices = NULL;
   return false;
   }
   Print("PHXServices: Trade Services initialized");
   //--------------------------------------------------
   // Trade Executor
   //--------------------------------------------------
   m_tradeExecutor = new CPHXTradeExecutor();
   if(m_tradeExecutor == NULL)
   {
   Print(
      "PHXServices: Trade Executor allocation failed"
   );
   return false;
   }
   if(!(*m_tradeExecutor).Initialize())
   {
   delete m_tradeExecutor;

   m_tradeExecutor = NULL;
   return false;
   }
   //--------------------------------------------------
   // Information Panel
   //--------------------------------------------------
   if(!m_infoPanel.Initialize())
   {
   Print(
      "PHXServices: Info Panel initialization failed"
   );

   Shutdown();
   return false;
   }

   Print(
   "PHXServices: Info Panel initialized"
   );


   //--------------------------------------------------
   // System Ready
   //--------------------------------------------------
   m_diagnostics.SetSystemReady(true);

   m_initialized = true;
   m_initializing = false;

   return true;
   }
   //+------------------------------------------------------------------+
   //| Start                                                            |
   //+------------------------------------------------------------------+
   bool CPHXServices::Start()
   {

   if(!m_initialized)
      return false;
   if(m_started)
      return true;
   //--------------------------------------------------
   // Start Market Services
   //--------------------------------------------------
   if(m_marketServices == NULL)
      return false;
   if(!(*m_marketServices).IsInitialized())
      return false;
   //--------------------------------------------------
   // Start Indicator Services
   //--------------------------------------------------
   if(m_indicatorService == NULL)
      return false;
   if(!(*m_indicatorService).IsInitialized())
      return false;
   //--------------------------------------------------
   // System State
   //--------------------------------------------------
   m_state.SetStarted(true);
   m_state.SetTradingEnabled(true);
   //--------------------------------------------------
   // Diagnostics
   //--------------------------------------------------
   m_diagnostics.SetSystemReady(true);
   //--------------------------------------------------
   // Container State
   //--------------------------------------------------
   m_started = true;
   return true;
}

//+------------------------------------------------------------------+
//| Shutdown                                                         |
//+------------------------------------------------------------------+
   void CPHXServices::Shutdown()
{
   if(!m_initialized && !m_initializing)
      return;
   Print("PHXServices: Shutdown started");
   
   //--------------------------------------------------
   // Information Panel shutdown
   //--------------------------------------------------
   if(m_infoPanel.IsInitialized())
{
   Print(
      "PHXServices: shutting down Info Panel"
   );

   m_infoPanel.Shutdown();

   Print(
      "PHXServices: Info Panel released"
   );
}
   //--------------------------------------------------
   // Indicator Services shutdown
   //--------------------------------------------------
   if(m_indicatorService != NULL)
{
   Print("PHXServices: deleting Indicators");
   delete m_indicatorService;
   m_indicatorService = NULL;
   Print("PHXServices: Indicators released");
} 
   //--------------------------------------------------
   // Signal shutdown
   //--------------------------------------------------
   if(m_signalServices != NULL)
{
   Print("PHXServices: deleting Signals");
   (*m_signalServices).Shutdown();
   delete m_signalServices;
   m_signalServices = NULL;
   Print("PHXServices: Signals released");
}
   //--------------------------------------------------
   // Signal Quality Tracker shutdown
   //--------------------------------------------------
   if(m_signalQualityTracker != NULL)
{
   Print(
      "PHXServices: deleting Signal Quality Tracker"
   );

   delete m_signalQualityTracker;

   m_signalQualityTracker = NULL;

   Print(
      "PHXServices: Signal Quality Tracker released"
   );
}

   //--------------------------------------------------
   // Shutdown Trade Services
   //--------------------------------------------------
   if(m_tradeServices != NULL)
{
   m_tradeServices.Shutdown();
   delete m_tradeServices;
   m_tradeServices = NULL;  
   Print("PHXServices: TradeServices released");
}
   //--------------------------------------------------
   // Risk Manager Shutdown
   //--------------------------------------------------
   if(m_riskManager != NULL)
{
   delete m_riskManager;
   m_riskManager = NULL;
}
//--------------------------------------------------
// Risk Snapshot Builder Shutdown
//--------------------------------------------------
   if(m_riskSnapshotBuilder != NULL)
{
   delete m_riskSnapshotBuilder;
   m_riskSnapshotBuilder = NULL;
}
   //--------------------------------------------------
   // Position Services
   //--------------------------------------------------
   //--------------------------------------------------
   // Position Statistics Shutdown
   //--------------------------------------------------
   if(m_positionStatistics != NULL)
{
   Print(
      "PHXServices: deleting Position Statistics"
   );
   delete m_positionStatistics;
   m_positionStatistics = NULL;
   Print(
      "PHXServices: Position Statistics released"
   );
}
   //--------------------------------------------------
   // Position Manager Shutdown
   //--------------------------------------------------
   if(m_positionManager != NULL)
{
   Print(
      "PHXServices: deleting Position Manager"
   );
   delete m_positionManager;
   m_positionManager = NULL;
   Print(
      "PHXServices: Position Manager released"
   );
}
   //--------------------------------------------------
   // Market State Provider
   //--------------------------------------------------
   if(m_marketStateProvider != NULL)
{
   delete m_marketStateProvider;
   m_marketStateProvider = NULL;
}
   //--------------------------------------------------
   // EMA Provider
   //--------------------------------------------------
   if(m_emaProvider != NULL)
{
   delete m_emaProvider;
   m_emaProvider = NULL;
}
   //--------------------------------------------------
   // Market Indicator Provider
   //--------------------------------------------------
   if(m_marketIndicatorProvider != NULL)
{
   delete m_marketIndicatorProvider;
   m_marketIndicatorProvider = NULL;
}
   //--------------------------------------------------
   // Shutdown Trade Executor
   //--------------------------------------------------
   if(m_tradeExecutor != NULL)
{
   delete m_tradeExecutor;
   m_tradeExecutor = NULL;
}
   //--------------------------------------------------
   // Delete Signal State
   //--------------------------------------------------
   if(m_signalState != NULL)
{
   delete m_signalState;
   m_signalState = NULL;
   Print("PHXServices: Signals State");
}
   //--------------------------------------------------
   // Market Services shutdown
   //--------------------------------------------------
   if(m_marketServices != NULL)
   {
      (*m_marketServices).Shutdown();
      delete m_marketServices;
      m_marketServices = NULL;
      Print("PHXServices: Market Services released");
   }
  if(m_signalValidation != NULL)
  {
   delete m_signalValidation;
   m_signalValidation = NULL;
  }
  //--------------------------------------------------
  // ATR Energy shutdown
  //--------------------------------------------------
   if(m_atrEnergy != NULL)
{
   Print("PHXServices: deleting ATR Energy");
   delete m_atrEnergy;
   m_atrEnergy = NULL;
   Print("PHXServices: ATR Energy released");
}
   //--------------------------------------------------
   // Infrastructure shutdown
   //--------------------------------------------------
   m_buildInfo.Shutdown();
   m_diagnostics.Shutdown();
   m_eventBus.Shutdown();
   m_clock.Shutdown();
   m_performance.Shutdown();
   m_state.Shutdown();
   m_config.Shutdown();
   m_logger.Shutdown();
   m_trend.Shutdown();
   m_started = false;
   m_initialized = false;
   m_initializing = false;
   Print("PHXServices: Shutdown complete");
}
//+------------------------------------------------------------------+
//| Infrastructure Accessors                                        |
//+------------------------------------------------------------------+
   CPHXLogger* CPHXServices::Logger()
{
   return &m_logger;
}
   CPHXConfigManager* CPHXServices::Config()
{
   return &m_config;
}
   CPHXStateManager* CPHXServices::State()
{
   return &m_state;
}
   CPHXPerformanceMonitor* CPHXServices::Performance()
{
   return &m_performance;
}
   CPHXClock* CPHXServices::Clock()
{
   return &m_clock;
}
   CPHXEventBus* CPHXServices::EventBus()
{
   return &m_eventBus;
}
   CPHXDiagnostics* CPHXServices::Diagnostics()
{
   return &m_diagnostics;
}
   CPHXBuildInfo* CPHXServices::BuildInfo()
{
   return &m_buildInfo;
}
//+------------------------------------------------------------------+
//| Trend Service Access                                             |
//+------------------------------------------------------------------+
   CPHXTrendServices* CPHXServices::Trend()
{
   return &m_trend;
}
//+------------------------------------------------------------------+
//| Risk Access                                                     |
//+------------------------------------------------------------------+
   CPHXRiskManager* CPHXServices::Risk()
{
   return m_riskManager;
}
//+------------------------------------------------------------------+
//| Position Manager Access                                                     |
//+------------------------------------------------------------------+
   CPHXPositionManager*CPHXServices::PositionManager()
{
   return m_positionManager;
} 
//+------------------------------------------------------------------+
//| ATR Energy Accessor                                              |
//+------------------------------------------------------------------+
   CPHXATREnergy* CPHXServices::ATREnergy()
{
   return m_atrEnergy;
}
//+------------------------------------------------------------------+
//| Market Accessors                                                 |
//+------------------------------------------------------------------+
   CPHXMarketEngine* CPHXServices::MarketEngine()
{
   if(m_marketServices == NULL)
      return NULL;

   return (*m_marketServices).GetMarketEngine();
}
   CPHXSymbolInfo* CPHXServices::SymbolInfo()
{
   if(m_marketServices == NULL)
      return NULL;
   return (*m_marketServices).GetSymbolInfo();
}
   CPHXTickBuffer* CPHXServices::TickBuffer()
{
   if(m_marketServices == NULL)
      return NULL;
   return (*m_marketServices).GetTickBuffer();
}
   CPHXSpreadMonitor* CPHXServices::SpreadMonitor()
{
   if(m_marketServices == NULL)
      return NULL;
   return (*m_marketServices).GetSpreadMonitor();
}
   CPHXSessionManager* CPHXServices::SessionManager()
{
   if(m_marketServices == NULL)
      return NULL;
   return (*m_marketServices).GetSessionManager();
}
   CPHXMarketSnapshot* CPHXServices::MarketSnapshot()
{
   if(m_marketServices == NULL)
      return NULL;
   return (*m_marketServices).GetSnapshot();
}
//+------------------------------------------------------------------+
//| Const Infrastructure Accessors                                  |
//+------------------------------------------------------------------+
   const CPHXLogger* CPHXServices::Logger() const
{
   return &m_logger;
}
   const CPHXConfigManager* CPHXServices::Config() const
{
   return &m_config;
}
   const CPHXStateManager* CPHXServices::State() const
{
   return &m_state;
}
   const CPHXPerformanceMonitor* CPHXServices::Performance() const
{
   return &m_performance;
}
   const CPHXClock* CPHXServices::Clock() const
{
   return &m_clock;
}
   const CPHXEventBus* CPHXServices::EventBus() const
{
   return &m_eventBus;
}
   const CPHXDiagnostics* CPHXServices::Diagnostics() const
{
   return &m_diagnostics;
}
   const CPHXBuildInfo* CPHXServices::BuildInfo() const
{
   return &m_buildInfo;
}
//+------------------------------------------------------------------+
//| Const Market Accessors                                           |
//+------------------------------------------------------------------+
   const CPHXMarketEngine* CPHXServices::Market() const
{
   if(m_marketServices == NULL)
      return NULL;
   return (*m_marketServices).GetMarketEngine();
}
  CPHXSymbolInfo* CPHXServices::GetSymbolInfo()
{
   if(m_marketServices == NULL)
      return NULL;
   return (*m_marketServices).GetSymbolInfo();
}
  CPHXTickBuffer* CPHXServices::GetTickBuffer()
{
   if(m_marketServices == NULL)
      return NULL;
   return (*m_marketServices).GetTickBuffer();
}
  CPHXSpreadMonitor* CPHXServices::GetSpreadMonitor()
{
   if(m_marketServices == NULL)
      return NULL;
   return (*m_marketServices).GetSpreadMonitor();
}
  CPHXSessionManager* CPHXServices::GetSessionManager()
{
   if(m_marketServices == NULL)
      return NULL;
   return (*m_marketServices).GetSessionManager();
}
   CPHXMarketSnapshot* CPHXServices::GetSnapshot()
{
   if(m_marketServices == NULL)
      return NULL;
   return (*m_marketServices).GetSnapshot();
}
   CPHXTradeServices* CPHXServices::GetTradeServices()
{
   return m_tradeServices;
}
//+------------------------------------------------------------------+
//| Tick                                                             |
//+------------------------------------------------------------------+
  void CPHXServices::Tick()
{
//===============================================================
// INFO PANEL DATA
//===============================================================

double panelDailyATR =
   0.0;

double panelEnergyLeft =
   0.0;
   //--------------------------------------------------
   // Market update
   //--------------------------------------------------
   if(m_marketServices == NULL)
      return;
   if(!(*m_marketServices).IsInitialized())
      return;
   (*m_marketServices).Update();
   
   //--------------------------------------------------
   // Spread ATR Filter
   //--------------------------------------------------
   if(m_marketServices != NULL &&
   m_indicatorService != NULL)
{
   CPHXATR* currentATRService =
      (*m_indicatorService).GetCurrentATR();
   if(currentATRService == NULL)
   {
      Print(
         "PHX Spread ATR Filter: Current ATR unavailable"
      );
      return;
   }
   CPHXSpreadMonitor* spreadMonitor =
      (*m_marketServices).GetSpreadMonitor();
}
   //--------------------------------------------------
   // Indicators update
   //--------------------------------------------------
    if(m_indicatorService != NULL)
   {
      if(!(*m_indicatorService).Update())
      {
         Print("PHXServices: Indicators update FAILED");
      }
   }
   if(m_emaProvider != NULL)
{
   if(!(*m_emaProvider).Refresh())
   {
      Print(
         "PHXServices: EMA refresh FAILED"
      );
   }
}
   if(m_marketStateProvider != NULL)
{
   m_marketStateProvider.Refresh();
}
//--------------------------------------------------
// Trend Snapshot Build
//--------------------------------------------------
SPHXTrendSnapshot trendSnapshot;
trendSnapshot.Reset();
if(!m_trendSnapshotBuilder.Build(trendSnapshot))
{
   Print("PHXServices: Trend Snapshot build FAILED");
   return;
}
//--------------------------------------------------
// Calculate Trend Score
//--------------------------------------------------
if(!m_trend.Calculate(trendSnapshot))
{
   Print("PHXServices: Trend calculation FAILED");
   return;
}
SPHXTrendScore currentTrendScore;
currentTrendScore =
   m_trend.GetScore();
//--------------------------------------------------
// Momentum Engine
//--------------------------------------------------

int momentumScore = 0;

int momentumDirection = 0;


//--------------------------------------------------
// Early bullish momentum
//--------------------------------------------------

if(
   trendSnapshot.M1BullSequence >= 1
)
{
   momentumDirection = 1;
}


//--------------------------------------------------
// Early bearish momentum
//--------------------------------------------------

else
if(
   trendSnapshot.M1BearSequence >= 1
)
{
   momentumDirection = -1;
}

trendSnapshot.MomentumDirection =
   momentumDirection;
//--------------------------------------------------
// Apply Trend Direction
//--------------------------------------------------
   if(currentTrendScore.Total > 0)
{
   trendSnapshot.Trend =
      PHX_TREND_UP;
}
   else
   if(currentTrendScore.Total < 0)
{
   trendSnapshot.Trend =
      PHX_TREND_DOWN;
}
   else
{
   trendSnapshot.Trend =
      PHX_TREND_FLAT;
}

//--------------------------------------------------
// Trend transition diagnostics
// Update only once per working timeframe bar
//--------------------------------------------------

datetime currentTrendBarTime =
   iTime(
      _Symbol,
      _Period,
      0
   );


if(
   currentTrendBarTime > 0 &&
   currentTrendBarTime !=
      m_lastTrendTransitionBarTime
)
{
   if(
      m_lastTrendTransitionBarTime == 0
   )
   {
      //--------------------------------------------------
      // First observed bar
      //--------------------------------------------------

      m_previousTrend =
         trendSnapshot.Trend;

      m_barsSinceTrendChange =
         0;
   }
   else
   if(
      trendSnapshot.Trend !=
      m_previousTrend
   )
   {
      //--------------------------------------------------
      // Trend direction changed
      //--------------------------------------------------

      m_barsSinceTrendChange =
         0;
   }
   else
   {
      //--------------------------------------------------
      // Same trend on the next bar
      //--------------------------------------------------

      m_barsSinceTrendChange++;
   }


   m_lastTrendTransitionBarTime =
      currentTrendBarTime;
}


trendSnapshot.PreviousTrend =
   m_previousTrend;


trendSnapshot.BarsSinceTrendChange =
   m_barsSinceTrendChange;


m_previousTrend =
   trendSnapshot.Trend;
//--------------------------------------------------
// Trend transition diagnostics log
//--------------------------------------------------

Print(
   "PHX TREND STATE: ",
   "Current=",
   EnumToString(trendSnapshot.Trend),
   " Previous=",
   EnumToString(trendSnapshot.PreviousTrend),
   " BarsSinceChange=",
   trendSnapshot.BarsSinceTrendChange
);

//--------------------------------------------------
// Store Score in Snapshot
//--------------------------------------------------
   trendSnapshot.Score =
   currentTrendScore;
//--------------------------------------------------
// Market Phase
//--------------------------------------------------

trendSnapshot.MarketPhase =
   PHX_PHASE_UNKNOWN;


//--------------------------------------------------
// Momentum Engine
//--------------------------------------------------

int bullishMomentumScore = 0;
int bearishMomentumScore = 0;


//--------------------------------------------------
// Bull Pressure
//--------------------------------------------------

if(
   trendSnapshot.M1BullSequence >= 2
)
{
   bullishMomentumScore++;
}


if(
   trendSnapshot.RSIChange > 0.0
)
{
   bullishMomentumScore++;
}


if(
   trendSnapshot.EMASlopeChange > 0.0
)
{
   bullishMomentumScore++;
}


//--------------------------------------------------
// Bear Pressure
//--------------------------------------------------

//--------------------------------------------------
// Bear Pressure
//--------------------------------------------------

if(
   trendSnapshot.Trend != PHX_TREND_UP
   &&
   trendSnapshot.M1BearSequence >= 2
)
{
   bearishMomentumScore++;
}


if(
   trendSnapshot.Trend != PHX_TREND_UP
   &&
   trendSnapshot.RSIChange < 0.0
)
{
   bearishMomentumScore++;
}


if(
   trendSnapshot.Trend != PHX_TREND_UP
   &&
   trendSnapshot.EMASlopeChange < 0.0
)
{
   bearishMomentumScore++;
}

//--------------------------------------------------
// Momentum Direction
//--------------------------------------------------

if(
   bullishMomentumScore >= 3
)
{
   trendSnapshot.MomentumDirection = 1;
}
else
if(
   bearishMomentumScore >= 3
)
{
   trendSnapshot.MomentumDirection = -1;
}
else
{
   trendSnapshot.MomentumDirection = 0;
}
Print(
   "PHX MOMENTUM STATE: ",
   "BullScore=",
   IntegerToString(bullishMomentumScore),
   " BearScore=",
   IntegerToString(bearishMomentumScore),
   " Direction=",
   IntegerToString(
      trendSnapshot.MomentumDirection
   )
);

//--------------------------------------------------
// Early Bearish Transition
//--------------------------------------------------

if(
   trendSnapshot.Trend ==
      PHX_TREND_UP
   &&
   trendSnapshot.M1BearSequence >= 2
   &&
   trendSnapshot.RSIChange < 0.0
   &&
   trendSnapshot.EMASlopeChange < 0.0
)
{
   trendSnapshot.MarketPhase =
      PHX_PHASE_EARLY_BEAR_REVERSAL;
}


//--------------------------------------------------
// Early Bullish Transition
//--------------------------------------------------

else
if(
   trendSnapshot.Trend ==
      PHX_TREND_DOWN
   &&
   trendSnapshot.M1BullSequence >= 2
   &&
   trendSnapshot.RSIChange > 0.0
   &&
   trendSnapshot.EMASlope > 0.0
   &&
   trendSnapshot.EMASlopeChange > 0.0
)
{
   trendSnapshot.MarketPhase =
      PHX_PHASE_EARLY_BULL_REVERSAL;
}


//--------------------------------------------------
// Up Trend Exhaustion with reset
//--------------------------------------------------

else
if(
   trendSnapshot.Trend ==
      PHX_TREND_UP
)
{
   bool exhaustionSignal =
   (
      trendSnapshot.EMASlopeChange < 0.0
      &&
      (
         trendSnapshot.RSIChange < 0.0
         ||
         trendSnapshot.M1BearSequence >= 1
      )
   );


   bool trendRecovery =
   (
      trendSnapshot.RSIChange > 0.0
      &&
      trendSnapshot.EMASlopeChange > 0.0
      &&
      trendSnapshot.M1BearSequence == 0
   );


   if(exhaustionSignal)
   {
      m_exhaustionUpBars++;
   }
   else
   if(trendRecovery)
   {
      m_exhaustionUpBars = 0;
   }
}


//--------------------------------------------------
// Overextended Up Trend
//--------------------------------------------------

bool overextendedUp =
(
   trendSnapshot.Trend ==
      PHX_TREND_UP

   &&

   trendSnapshot.EMASlope > 0.0

   &&

   (
      trendSnapshot.RSIChange <= 0.0
      ||
      trendSnapshot.EMASlopeChange < 0.0
   )

   &&

   trendSnapshot.M1BearSequence == 0
);


//--------------------------------------------------
// Market Phase assignment
//--------------------------------------------------

if(m_exhaustionUpBars >= 2)
{
   trendSnapshot.MarketPhase =
      PHX_PHASE_EXHAUSTION_UP;
}
else
if(overextendedUp)
{
   trendSnapshot.MarketPhase =
      PHX_PHASE_OVEREXTENDED_UP;
}
else
if(
   trendSnapshot.Trend ==
      PHX_TREND_UP
)
{
   trendSnapshot.MarketPhase =
      PHX_PHASE_TREND_UP;
}
else
if(
   trendSnapshot.Trend ==
      PHX_TREND_DOWN
)
{
   trendSnapshot.MarketPhase =
      PHX_PHASE_TREND_DOWN;
}
Print(
   "PHX TREND DYNAMICS: ",
   "RSIChange=",
   DoubleToString(trendSnapshot.RSIChange, 4),
   " EMASlope=",
   DoubleToString(trendSnapshot.EMASlope, 6),
   " EMASlopeChange=",
   DoubleToString(trendSnapshot.EMASlopeChange, 6),
   " M1BullSequence=",
   trendSnapshot.M1BullSequence,
   " M1BearSequence=",
   trendSnapshot.M1BearSequence,
   " ExhaustionBars=",
   IntegerToString(m_exhaustionUpBars),
   " MarketPhase=",
   EnumToString(trendSnapshot.MarketPhase),
   " BarsSinceChange=",
   trendSnapshot.BarsSinceTrendChange
);   
//--------------------------------------------------
// Signal Validation
//--------------------------------------------------

if(m_signalValidation != NULL)
{
   (*m_signalValidation).SetSnapshot(
      trendSnapshot
   );


   SPHXSignal validationSignal;
   validationSignal.Reset();


   if(!(*m_signalValidation).Calculate(
      validationSignal
   ))
   {
      Print(
         "PHXServices: Signal Validation FAILED"
      );

      return;
   }


   //--------------------------------------------------
   // Attach validation result
   //--------------------------------------------------

   trendSnapshot.BuyResult =
      (*m_signalValidation).BuyResult();


   trendSnapshot.SellResult =
      (*m_signalValidation).SellResult();
}
//-Временная вставка--
//--------------------------------------------------
// FINAL SNAPSHOT DEBUG BEFORE SIGNAL SERVICES
//--------------------------------------------------

Print(
   "PHX FINAL SNAPSHOT BEFORE SIGNAL: ",
   "Trend=",
   EnumToString(trendSnapshot.Trend),

   " Momentum=",
   IntegerToString(
      trendSnapshot.MomentumDirection
   ),

   " Phase=",
   EnumToString(
      trendSnapshot.MarketPhase
   ),

   " BuyResult=",
   IntegerToString(
      trendSnapshot.BuyResult
   ),

   " SellResult=",
   IntegerToString(
      trendSnapshot.SellResult
   ),

   " RSIChange=",
   DoubleToString(
      trendSnapshot.RSIChange,
      4
   ),

   " M1Bull=",
   IntegerToString(
      trendSnapshot.M1BullSequence
   ),

   " M1Bear=",
   IntegerToString(
      trendSnapshot.M1BearSequence
   )
);

//--------------------------------------------------
// Store FINAL Trend Snapshot
//--------------------------------------------------
// ВАЖНО:
// НЕ вызываем m_trend.Calculate() повторно!
// Snapshot уже рассчитан.
//--------------------------------------------------

SPHXTrendSnapshot storedTrendSnapshot;

storedTrendSnapshot =
   trendSnapshot;


//--------------------------------------------------
// Pass FINAL Snapshot To Signal Services
//--------------------------------------------------

if(m_signalServices != NULL)
{
   (*m_signalServices).SetTrendSnapshot(
      storedTrendSnapshot
   );
}
//--------------------------------------------------
// Signals update
//--------------------------------------------------
if(m_signalServices != NULL)
{
   if(!(*m_signalServices).Update())
   {
      Print("PHXServices: Signals update FAILED");
   }
}
//--------------------------------------------------
// Signal Quality Tracker update
//--------------------------------------------------
if(m_signalQualityTracker != NULL)
{
   (*m_signalQualityTracker).Update();
}
else
{
   Print(
      "PHX QUALITY UPDATE CALL: TRACKER NULL"
   );
}
//--------------------------------------------------
// Signal State Check
//--------------------------------------------------
SPHXSignal signal =
   (*m_signalServices).GetSignal();


//--------------------------------------------------
// Local ATR Diagnostics
// M30 / H1 DO NOT affect trading decision
//--------------------------------------------------
if(signal.signal != PHX_SIGNAL_NONE)
{
   if(m_indicatorService != NULL)
   {
      CPHXATR* currentATRService =
         (*m_indicatorService).GetCurrentATR();

      CPHXATR* baseATRService =
         (*m_indicatorService).GetBaseATR();

      if(
         currentATRService != NULL &&
         baseATRService != NULL
      )
      {
         double currentATR =
            (*currentATRService).GetValue();

         double baseATR =
            (*baseATRService).GetValue();

         if(m_atrEnergy != NULL)
         {
            (*m_atrEnergy).PrintLocalATRDiagnostics(
               currentATR,
               baseATR
            );
         }
      }
      else
      {
         Print(
            "PHX ATR LOCAL DIAGNOSTICS: ",
            "ATR services unavailable ",
            "DecisionImpact=NONE"
         );
      }
   }
}
//--------------------------------------------------
// D1 ATR Energy Calculation
// D1 ONLY - independent from working timeframe
//--------------------------------------------------
bool d1EnergyOK = false;

if(m_indicatorService == NULL)
{
   Print(
      "PHX D1 ENERGY ERROR: IndicatorService=NULL"
   );
}
else
if(m_atrEnergy == NULL)
{
   Print(
      "PHX D1 ENERGY ERROR: ATREnergy=NULL"
   );
}
else
{
   double technicalDailyATR =
      (*m_indicatorService).DailyATR();
   d1EnergyOK =
      (*m_atrEnergy).IsEnergyEnough(
         technicalDailyATR
      );
   //--------------------------------------------------
   // Info Panel D1 Data
   //--------------------------------------------------
   panelDailyATR =
      technicalDailyATR;
   panelEnergyLeft =
      (*m_atrEnergy).GetRemainingRatio() * 100.0;
}
//===============================================================
// INFO PANEL RSI
//===============================================================

double panelRSI =
   0.0;

if(m_indicatorService != NULL)
{
   CPHXRSI* panelRSIService =
      (*m_indicatorService).GetRSI();

   if(panelRSIService != NULL)
   {
      panelRSI =
         (*panelRSIService).GetValue();
   }
}
//===============================================================
// INFO PANEL ADX
//===============================================================

double panelADX =
   0.0;

if(m_indicatorService != NULL)
{
   CPHXADX* panelADXService =
      (*m_indicatorService).GetADX();

   if(panelADXService != NULL)
   {
      if((*panelADXService).IsInitialized())
      {
         panelADX =
            (*panelADXService).GetADX();
      }
   }
}
//===============================================================
// INFO PANEL TREND
//===============================================================

string panelTrend =
   "--";

switch(storedTrendSnapshot.Trend)
{
   case PHX_TREND_FLAT:
      panelTrend = "FLAT";
      break;

   case PHX_TREND_UP:
      panelTrend = "UP";
      break;

   case PHX_TREND_DOWN:
      panelTrend = "DOWN";
      break;

   case PHX_TREND_STRONG_UP:
      panelTrend = "STRONG UP";
      break;

   case PHX_TREND_STRONG_DOWN:
      panelTrend = "STRONG DOWN";
      break;

   case PHX_TREND_UNKNOWN:
   default:
      panelTrend = "--";
      break;
}

//===============================================================
// INFO PANEL SCORE
//===============================================================

int panelScore =
   storedTrendSnapshot.Score.Total;
//===============================================================
// INFO PANEL SIGNAL
//===============================================================

string panelSignal =
   "NONE";

if(signal.signal == PHX_SIGNAL_BUY)
{
   panelSignal = "BUY";
}
else if(signal.signal == PHX_SIGNAL_SELL)
{
   panelSignal = "SELL";
}   
//===============================================================
// INFO PANEL UPDATE
//===============================================================

m_infoPanel.Update(
   panelDailyATR,       // D1 ATR
   panelEnergyLeft,     // Energy Left %
   panelRSI,            // RSI
   panelADX,            // ADX
   panelTrend,          // Trend
   panelScore,          // Score
   panelSignal          // Signal
);
//--------------------------------------------------
// D1 ATR Energy Trading Protection
// Blocks ONLY a NEW signal/trade
//--------------------------------------------------
if(
   signal.signal != PHX_SIGNAL_NONE &&
   !d1EnergyOK
)
{
   Print(
      "PHX TRADE BLOCKED: ",
      "D1 Remaining Energy below minimum"
   );

   return;
}
//--------------------------------------------------
// Spread protection
//--------------------------------------------------
   if(signal.signal != PHX_SIGNAL_NONE)
{
   CPHXSpreadMonitor* spreadMonitor =
      (*m_marketServices).GetSpreadMonitor();
   if(spreadMonitor != NULL)
   {
      bool spreadOK =
         (*spreadMonitor).IsSpreadAllowed(
             50
         );
      if(!spreadOK)
      {
         Print(
            "PHX TRADE BLOCKED: Spread too high. ",
            "Spread=",
            (*spreadMonitor).GetSpreadPoints()
         );
         return;
      }
   }
}
//--------------------------------------------------
// New signal check
//--------------------------------------------------
   if(m_signalState != NULL)
{
   if((*m_signalState).IsNewSignal(signal))
   {
      if(signal.signal == PHX_SIGNAL_BUY)
      {
         Print(
            "PHX NEW SIGNAL BUY | ",
            "Confidence=",
            signal.confidence,
            " RSI=",
            signal.rsi,
            " MA=",
            signal.ma,
            " Price=",
            signal.price
         );
      }
      if(signal.signal == PHX_SIGNAL_SELL)
      {
         Print(
            "PHX NEW SIGNAL SELL | ",
            "Confidence=",
            signal.confidence,
            " RSI=",
            signal.rsi,
            " MA=",
            signal.ma,
            " Price=",
            signal.price
         );
      }
      (*m_signalState).Update(signal);
   }
}
//--------------------------------------------------
// Signal output
//--------------------------------------------------

// используем уже существующую переменную signal

   //--------------------------------------------------
   // Indicator values test
   //--------------------------------------------------
   if(CurrentATR() != NULL &&
   BaseATR() != NULL &&
   RSI() != NULL)
{
   Print(
   "PHXIndicators: ",
   "CurrentATR=",
   DoubleToString((*CurrentATR()).GetValue(),3),
   " BaseATR=",
   DoubleToString((*BaseATR()).GetValue(),3),
   " RSI=",
   DoubleToString((*RSI()).GetValue(),2)
);
}
}
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
   void CPHXServices::Timer()
{
   if(!m_state.IsStarted())
      return;
   // Update server/local time
   if(!m_clock.UpdateClock())
{
   m_diagnostics.AddError();
   return;
}
   // Trading state check
   if(!m_state.IsTradingEnabled())
      return;
}
//+------------------------------------------------------------------+
//| Trade Transaction                                                |
//+------------------------------------------------------------------+
   void CPHXServices::TradeTransaction(
      const MqlTradeTransaction &trans,
      const MqlTradeRequest &request,
      const MqlTradeResult &result)
{
   if(!m_initialized)
      return;
   // Пока только заглушка.
   // Здесь позже подключим:
   // - Trade Manager
   // - Position Manager
   // - Statistics
   // - Risk Engine
}
//+------------------------------------------------------------------+
//| Configure Risk                                                   |
//+------------------------------------------------------------------+
void CPHXServices::ConfigureRisk(
   double lot,
   double stopLossPoints,
   bool trailingEnabled,
   double trailingPoints,
   bool tradingTimeEnabled,
   int startHour,
   int startMinute,
   int endHour,
   int endMinute
)
{
   m_riskConfig.TradeLot =
      lot;
   m_riskConfig.StopLossPoints =
      stopLossPoints;
   m_riskConfig.TrailingEnabled =
      trailingEnabled;
   m_riskConfig.TrailingStopPoints =
      trailingPoints;
   m_riskConfig.TradingTimeEnabled =
      tradingTimeEnabled;
   m_riskConfig.TradingStartHour =
      startHour;
   m_riskConfig.TradingStartMinute =
      startMinute;
   m_riskConfig.TradingEndHour =
      endHour;
   m_riskConfig.TradingEndMinute =
      endMinute;

   //--------------------------------------------------
   // Update Risk Manager Configuration
   //--------------------------------------------------
   if(m_riskManager != NULL)
   {
      (*m_riskManager).SetConfig(
         m_riskConfig
      );
      Print(
         "PHXServices: Risk Manager configuration updated"
      );
   }
   //--------------------------------------------------
   // Diagnostics
   //--------------------------------------------------
   Print(
      "PHX ConfigureRisk: ",
      "TradeLot=",
      DoubleToString(
         m_riskConfig.TradeLot,
         2
      ),
      " StopLossPoints=",
      DoubleToString(
         m_riskConfig.StopLossPoints,
         0
      ),
      " TrailingPoints=",
      DoubleToString(
         m_riskConfig.TrailingStopPoints,
         0
      )
   );
}
//+------------------------------------------------------------------+
//| IzInitialized                                                         |
//+------------------------------------------------------------------+
   bool CPHXServices::IsInitialized() const
{
   return m_initialized;
}
//+------------------------------------------------------------------+
//| Get Market Services                                              |
//+------------------------------------------------------------------+
   CPHXMarketServices* CPHXServices::GetMarket()
{
   return m_marketServices;
}
//+------------------------------------------------------------------+
//| Market Engine Access                                             |
//+------------------------------------------------------------------+
CPHXMarketEngine* CPHXServices::GetMarketEngine()
{
   if(m_marketServices == NULL)
      return NULL;
   return (*m_marketServices).GetMarketEngine();
}
//+------------------------------------------------------------------+
//| Get Indicator Services                                           |
//+------------------------------------------------------------------+
   CPHXIndicatorServices* CPHXServices::GetIndicators()
{
   return m_indicatorService;
}
//+------------------------------------------------------------------+
//| Indicator Access                                                 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Get Market Indicator Provider                                    |
//+------------------------------------------------------------------+
CPHXMarketIndicatorProvider* CPHXServices::GetMarketIndicatorProvider()
{
   return m_marketIndicatorProvider;
}
   //+------------------------------------------------------------------+
   //| Current ATR Access                                               |
   //+------------------------------------------------------------------+
   CPHXATR* CPHXServices::CurrentATR()
{
   if(m_indicatorService == NULL)
      return NULL;
   return (*m_indicatorService).GetCurrentATR();
}
   //+------------------------------------------------------------------+
   //| Base ATR Access                                                  |
   //+------------------------------------------------------------------+
   CPHXATR* CPHXServices::BaseATR()
{
   if(m_indicatorService == NULL)
      return NULL;
   return (*m_indicatorService).GetBaseATR();
}
//+------------------------------------------------------------------+
   CPHXMovingAverage* CPHXServices::MA()
{
   if(m_indicatorService == NULL)
      return NULL;
   return (*m_indicatorService).GetMA();
}
//+------------------------------------------------------------------+
   CPHXRSI* CPHXServices::RSI()
{
   if(m_indicatorService == NULL)
      return NULL;
   return (*m_indicatorService).GetRSI();
}
//+------------------------------------------------------------------+
   CPHXADX* CPHXServices::ADX()
{
   if(m_indicatorService == NULL)
      return NULL;
   return (*m_indicatorService).GetADX();
}
//+------------------------------------------------------------------+
   CPHXVolumeAnalyzer* CPHXServices::Volume()
{
   if(m_indicatorService == NULL)
      return NULL;
   return (*m_indicatorService).GetVolume();
}
//+------------------------------------------------------------------+
   CPHXSignalServices* CPHXServices::Signals()
{
   return m_signalServices;
}
//+------------------------------------------------------------------+
//| Position Statistics Access                                       |
//+------------------------------------------------------------------+
   CPHXPositionStatistics* CPHXServices::PositionStatistics()
{
   return m_positionStatistics;
}
//+------------------------------------------------------------------+
//| Signal Validation                                               |
//+------------------------------------------------------------------+
   CPHXSignalValidation* CPHXServices::SignalValidation()
{
   return m_signalValidation;
}
//+------------------------------------------------------------------+
//| Trade Executor                                               |
//+------------------------------------------------------------------+
   CPHXTradeExecutor* CPHXServices::TradeExecutor()
{
   return m_tradeExecutor;
}
//+------------------------------------------------------------------+
//| Signal Quality Tracker                                           |
//+------------------------------------------------------------------+

CPHXSignalQualityTracker* CPHXServices::SignalQualityTracker()
{
   return m_signalQualityTracker;
}
//+------------------------------------------------------------------+
//| Risk Snapshot Builder                                            |
//+------------------------------------------------------------------+
   CPHXRiskSnapshotBuilder* CPHXServices::RiskSnapshotBuilder()
{
   return m_riskSnapshotBuilder;
}
//+------------------------------------------------------------------+
//| Print Configuration                                              |
//+------------------------------------------------------------------+
void CPHXServices::PrintConfiguration()
{
   Print(
      "=================================================="
   );
   Print(
      "        PHOENIX PRO CONFIGURATION"
   );
   Print(
      "=================================================="
   );
   Print(
      "Trade Lot = ",
      DoubleToString(
         m_riskConfig.TradeLot,
         2
      )
   );
   //--------------------------------------------------
   // Trading Schedule
   //--------------------------------------------------
   Print(
      "Trading Time Enabled = ",
      m_riskConfig.TradingTimeEnabled
   );

   Print(
      "Trading Window = ",
      IntegerToString(
         m_riskConfig.TradingStartHour
      ),
      ":",
      IntegerToString(
         m_riskConfig.TradingStartMinute
      ),
      " - ",
      IntegerToString(
         m_riskConfig.TradingEndHour
      ),
      ":",
      IntegerToString(
         m_riskConfig.TradingEndMinute
      )
   );
   //--------------------------------------------------
   // Trailing
   //--------------------------------------------------
   Print(
      "Trailing Enabled = ",
      m_riskConfig.TrailingEnabled
   );
   Print(
      "Trailing Points = ",
      DoubleToString(
         m_riskConfig.TrailingStopPoints,
         1
      )
   );
   Print(
      "=================================================="
   );
}


#endif // __PHX_SERVICES_MQH__
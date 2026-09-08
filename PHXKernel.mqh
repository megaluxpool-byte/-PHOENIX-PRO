//+------------------------------------------------------------------+
//|                                                PHXKernel.mqh     |
//|                  PHOENIX PRO Trading Framework                   |
//|                                                                  |
//| Description:                                                     |
//|   Core system kernel                                             |
//+------------------------------------------------------------------+
#ifndef __PHX_KERNEL_MQH__
#define __PHX_KERNEL_MQH__

#include "PHXFactory.mqh"
#include "PHXServiceLocator.mqh"
#include "PHXServices.mqh"
#include "PHXTradingEngine.mqh"

//+------------------------------------------------------------------+
//| PHOENIX PRO Kernel                                               |
//+------------------------------------------------------------------+
class CPHXKernel
{

private:

   bool m_initialized;


   //--------------------------------------------------
   // Root Service Container
   //--------------------------------------------------

   CPHXServices* m_services;
   
   CPHXTradingEngine* m_tradingEngine;


public:

   CPHXKernel();

   ~CPHXKernel();


public:

   bool Initialize();
   
   //--------------------------------------------------
   // Trading Engine Binding
   //--------------------------------------------------

   bool BindTradingEngine();

   void Update();

   void Shutdown();

   void Reset();

   bool IsInitialized() const;
   
   //--------------------------------------------------
   // Service Container Access
   //--------------------------------------------------

   CPHXServices* Services();


public:

   void ProcessTick();

   void ProcessTimer();


   void ProcessTradeTransaction(
      const MqlTradeTransaction &trans,
      const MqlTradeRequest &request,
      const MqlTradeResult &result);


   double OnTester();


   void Shutdown(const int reason);

};


//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPHXKernel::CPHXKernel()
{
   m_services = NULL;
   
   m_tradingEngine = NULL;

   m_initialized = false;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPHXKernel::~CPHXKernel()
{
   Shutdown(0);
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CPHXKernel::Initialize()
{

   if(m_initialized)
      return true;


   //--------------------------------------------------
   // Create Root Services Container
   //--------------------------------------------------

   m_services = new CPHXServices();


   if(m_services == NULL)
      return false;



   //--------------------------------------------------
   // Initialize Services
   //--------------------------------------------------

   if(!(*m_services).Initialize())
   {
      delete m_services;

      m_services = NULL;

      return false;
   }



   //--------------------------------------------------
   // Start Services
   //--------------------------------------------------

   if(!(*m_services).Start())
{
   (*m_services).Shutdown();

   delete m_services;

   m_services = NULL;

   return false;
}

   //--------------------------------------------------
   // Create Trading Engine
   //--------------------------------------------------

   m_tradingEngine = new CPHXTradingEngine();


   if(m_tradingEngine == NULL)
{
   (*m_services).Shutdown();

   delete m_services;

   m_services = NULL;

   return false;
}


   if(!m_tradingEngine.Initialize())
{
   delete m_tradingEngine;

   m_tradingEngine = NULL;

   (*m_services).Shutdown();

   delete m_services;

   m_services = NULL;

   return false;
}

   //--------------------------------------------------
   // Bind Trading Engine Dependencies
   //--------------------------------------------------

   if(!BindTradingEngine())
{
   delete m_tradingEngine;

   m_tradingEngine = NULL;

   (*m_services).Shutdown();

   delete m_services;

   m_services = NULL;

   return false;
   
}
   
   m_initialized = true;


   Print("PHXKernel: initialized");


   return true;

}

//+------------------------------------------------------------------+
//| Bind Trading Engine                                              |
//+------------------------------------------------------------------+

bool CPHXKernel::BindTradingEngine()
{

//--------------------------------------------------
// Validation
//--------------------------------------------------

if(m_services == NULL)
   return false;

if(m_tradingEngine == NULL)
   return false;


//--------------------------------------------------
// Market Provider
//--------------------------------------------------

(*m_tradingEngine).SetMarketProvider(
   (*m_services).GetMarket()
);

//--------------------------------------------------
// Market Indicator Provider
//--------------------------------------------------
(*m_tradingEngine).SetIndicatorProvider(
   (*m_services).GetMarketIndicatorProvider()
);
//--------------------------------------------------
// Market Price Provider
//--------------------------------------------------
(*m_tradingEngine).SetMarketPriceProvider(
   (*m_services).GetMarketEngine()
);
//--------------------------------------------------
// Risk
//--------------------------------------------------
(*m_tradingEngine).SetRiskProvider(
   (*m_services).Risk()
);
//--------------------------------------------------
// Trade Services
//--------------------------------------------------
CPHXTradeServices *tradeServices;
tradeServices = (*m_services).GetTradeServices();
if(tradeServices == NULL)
   return false;
//--------------------------------------------------
// Trade Decision
//--------------------------------------------------
(*m_tradingEngine).SetTradeDecisionProvider(
   (*tradeServices).Decision()
);
//--------------------------------------------------
// Trade Executor
//--------------------------------------------------
(*m_tradingEngine).SetTradeExecutor(
   (*tradeServices).GetExecutor()
);
//--------------------------------------------------
// Position
//--------------------------------------------------
(*m_tradingEngine).SetPositionProvider(
   (*m_services).PositionManager()
);
//--------------------------------------------------
// Signal Validation
//--------------------------------------------------
(*m_tradingEngine).SetSignalProvider(
   (*m_services).SignalValidation()
);
//--------------------------------------------------
// Risk Provider
//--------------------------------------------------
(*m_tradingEngine).SetRiskProvider(
   (*m_services).Risk()
);
//--------------------------------------------------
// Risk Snapshot Builder
//--------------------------------------------------
(*m_tradingEngine).SetRiskSnapshotBuilder(
   (*m_services).RiskSnapshotBuilder()
);
//--------------------------------------------------
// Trade Executor
//--------------------------------------------------
(*m_tradingEngine).SetTradeExecutor(
   (*m_services).TradeExecutor()
);
//--------------------------------------------------
// Signal Services
//--------------------------------------------------
(*m_tradingEngine).SetSignalServices(
   (*m_services).Signals()
);

//--------------------------------------------------
// Signal Quality Tracker
//--------------------------------------------------
(*m_tradingEngine).SetQualityTracker(
   (*m_services).SignalQualityTracker()
);
//--------------------------------------------------
// D1 ATR Energy
//--------------------------------------------------
(*m_tradingEngine).SetATREnergy(
   (*m_services).ATREnergy()
);
//--------------------------------------------------
// Indicator Services
//--------------------------------------------------
(*m_tradingEngine).SetIndicatorServices(
   (*m_services).GetIndicators()
);
//--------------------------------------------------
// Trend Provider
//--------------------------------------------------
(*m_tradingEngine).SetTrendProvider(
   (*m_services).Trend()
);
return true;
}
//+------------------------------------------------------------------+
//| Update                                                           |
//+------------------------------------------------------------------+
void CPHXKernel::Update()
{
   if(!m_initialized)
      return;
   if(m_services == NULL)
      return;
   (*m_services).Tick();
}
   //+------------------------------------------------------------------+
   //| Process Tick                                                     |
   //+------------------------------------------------------------------+
   void CPHXKernel::ProcessTick()
{
   //--------------------------------------------------
   // Kernel State
   //--------------------------------------------------

   if(!m_initialized)
   return;


   //--------------------------------------------------
   // Update Services
   //--------------------------------------------------

   if(m_services != NULL)
{

   (*m_services).Tick();

}


   //--------------------------------------------------
   // Trading Engine
   //--------------------------------------------------

   if(m_tradingEngine != NULL)
{

   if(!(*m_tradingEngine).Process())
   {

      Print(
         "PHXKernel: TradingEngine Process failed"
      );

   }

}

}

//+------------------------------------------------------------------+
//| Process Timer                                                   |
//+------------------------------------------------------------------+

void CPHXKernel::ProcessTimer()
{

if(!m_initialized)
   return;

if(m_services == NULL)
   return;


//--------------------------------------------------
// Timer Services
//--------------------------------------------------

(*m_services).Timer();

}

//+------------------------------------------------------------------+
//| Trade Transaction                                                |
//+------------------------------------------------------------------+
void CPHXKernel::ProcessTradeTransaction(
      const MqlTradeTransaction &trans,
      const MqlTradeRequest &request,
      const MqlTradeResult &result)
{

   if(!m_initialized)
      return;


   if(m_services == NULL)
      return;


   (*m_services).TradeTransaction(
      trans,
      request,
      result);

}

//+------------------------------------------------------------------+
//| Tester                                                           |
//+------------------------------------------------------------------+
double CPHXKernel::OnTester()
{
   return 0.0;
}


//+------------------------------------------------------------------+
//| Shutdown                                                         |
//+------------------------------------------------------------------+
void CPHXKernel::Shutdown(const int reason)
{

   if(!m_initialized)
      return;
      
   //--------------------------------------------------
   // Shutdown Trading Engine
   //--------------------------------------------------

   if(m_tradingEngine != NULL)
   {
   delete m_tradingEngine;
   m_tradingEngine = NULL;
   }

   if(m_services != NULL)
   {
      (*m_services).Shutdown();
      delete m_services;
      m_services = NULL;
   }
   
    m_initialized = false;


   Print("PHXKernel: shutdown reason=",reason);

}
//+------------------------------------------------------------------+
//| Reset                                                            |
//+------------------------------------------------------------------+
void CPHXKernel::Reset()
{
   Shutdown(0);

   Initialize();
}

//+------------------------------------------------------------------+
//| IsInitialized                                                    |
//+------------------------------------------------------------------+
bool CPHXKernel::IsInitialized() const
{
   return m_initialized;
}

//+------------------------------------------------------------------+
//| Services Access                                                  |
//+------------------------------------------------------------------+

CPHXServices* CPHXKernel::Services()
{
   return m_services;
}

#endif // __PHX_KERNEL_MQH__
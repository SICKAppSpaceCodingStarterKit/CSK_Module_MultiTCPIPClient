---@diagnostic disable: redundant-parameter, undefined-global

--***************************************************************
-- Inside of this script, you will find the relevant parameters
-- for this module and its default values
--***************************************************************

local functions = {}

local function getParameters()

  local multiTCPIPClientParameters = {}
  multiTCPIPClientParameters.flowConfigPriority = CSK_FlowConfig ~= nil or false -- Status if FlowConfig should have priority for FlowConfig relevant configurations
  multiTCPIPClientParameters.processingFile = 'CSK_MultiTCPIPClient_Processing' -- which file to use for processing (will be started in own thread)

  multiTCPIPClientParameters.interface = '' -- Interface to use (must be set individually)
  multiTCPIPClientParameters.connectionStatus = false -- Configure module to try to connect to server

  -- List of incoming trigger commands to forward as events
  -- e.g. "commandList['TRG'] = 'OnNewTrigger' will trigger the event "CSK_TCPIPClient.OnNewTrigger" if receiving 'TRG' via TCP/IP connection
  multiTCPIPClientParameters.commandList = {}

  -- List of events to register to and forward content to TCP/IP server
  multiTCPIPClientParameters.forwardEvents = {}

  multiTCPIPClientParameters.serverIP = '192.168.0.202' -- IP of TCP/IP server
  multiTCPIPClientParameters.port = 1234 -- Port of TCP/IP connection
  multiTCPIPClientParameters.rxFrame = 'STX-ETX' -- OR 'empty' -- RX Frame
  multiTCPIPClientParameters.txFrame = 'STX-ETX' -- OR 'empty' -- TX Frame

  return multiTCPIPClientParameters
end
functions.getParameters = getParameters

return functions
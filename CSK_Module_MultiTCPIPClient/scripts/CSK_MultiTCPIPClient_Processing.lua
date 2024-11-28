---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

-- If App property "LuaLoadAllEngineAPI" is FALSE, use this to load and check for required APIs
-- This can improve performance of garbage collection
local availableAPIs = require('Communication/MultiTCPIPClient/helper/checkAPIs') -- check for available APIs
-----------------------------------------------------------
local nameOfModule = 'CSK_MultiTCPIPClient'
--Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')

local scriptParams = Script.getStartArgument() -- Get parameters from model

local multiTCPIPClientInstanceNumber = scriptParams:get('multiTCPIPClientInstanceNumber') -- number of this instance
local multiTCPIPClientInstanceNumberString = tostring(multiTCPIPClientInstanceNumber) -- number of this instance as string

-- Event to notify result of processing
Script.serveEvent("CSK_MultiTCPIPClient.OnNewData" .. multiTCPIPClientInstanceNumberString, "MultiTCPIPClient_OnNewData" .. multiTCPIPClientInstanceNumberString, 'string') -- Edit this accordingly
-- Event to forward content from this thread to Controller to show e.g. on UI
Script.serveEvent("CSK_MultiTCPIPClient.OnNewValueToForward".. multiTCPIPClientInstanceNumberString, "MultiTCPIPClient_OnNewValueToForward" .. multiTCPIPClientInstanceNumberString, 'string, auto')
-- Event to forward update of e.g. parameter update to keep data in sync between threads
Script.serveEvent("CSK_MultiTCPIPClient.OnNewValueUpdate" .. multiTCPIPClientInstanceNumberString, "MultiTCPIPClient_OnNewValueUpdate" .. multiTCPIPClientInstanceNumberString, 'int, string, auto, int:?')

local tcpipHandle = TCPIPClient.create() -- Handle of TCPIP client

local log = {} -- Log of TCP/IP communication

local processingParams = {}
processingParams.activeInUI = false

processingParams.connectionStatus = scriptParams:get('connectionStatus')
processingParams.interface = scriptParams:get('interface')
processingParams.serverIP = scriptParams:get('serverIP')
processingParams.port = scriptParams:get('port')
processingParams.rxFrame = scriptParams:get('rxFrame')
processingParams.txFrame = scriptParams:get('txFrame')

processingParams.currentConnectionStatus = scriptParams:get('currentConnectionStatus')
processingParams.command = scriptParams:get('command')

processingParams.commandList = {}
processingParams.forwardEvents = {}

--- Function to notify latest log messages, e.g. to show on UI
local function sendLog()
  if #log == 100 then
    table.remove(log, 100)
  end
  local tempLog = ''
  for i=1, #log do
    tempLog = tempLog .. tostring(log[i]) .. '\n'
  end
  if processingParams.activeInUI then
    Script.notifyEvent("MultiTCPIPClient_OnNewValueToForward" .. multiTCPIPClientInstanceNumberString, 'MultiTCPIPClient_OnNewLog', tostring(tempLog))
  end
end

--- Function to react on disconnection from TCP/IP server
local function handleOnDisconnected()
  _G.logger:info(nameOfModule .. ": Instance No. " .. multiTCPIPClientInstanceNumberString .. " is now disconnected.")
  processingParams.currentConnectionStatus = false
  Script.notifyEvent("MultiTCPIPClient_OnNewValueUpdate" .. multiTCPIPClientInstanceNumberString, multiTCPIPClientInstanceNumber, 'currentConnectionStatus', false)
  if processingParams.activeInUI then
    Script.notifyEvent("MultiTCPIPClient_OnNewValueToForward" .. multiTCPIPClientInstanceNumberString, 'MultiTCPIPClient_OnNewCurrentConnectionStatus', false)
  end
end

--- Function to react on connection from device to TCP/IP server
local function handleOnConnected()
  _G.logger:info(nameOfModule .. ": Instance No. " .. multiTCPIPClientInstanceNumberString .. " is now connected.")
  processingParams.currentConnectionStatus = true
  Script.notifyEvent("MultiTCPIPClient_OnNewValueUpdate" .. multiTCPIPClientInstanceNumberString, multiTCPIPClientInstanceNumber, 'currentConnectionStatus', true)
  if processingParams.activeInUI then
    Script.notifyEvent("MultiTCPIPClient_OnNewValueToForward" .. multiTCPIPClientInstanceNumberString, 'MultiTCPIPClient_OnNewCurrentConnectionStatus', true)
  end
end

local function handleTransmitData(data)
  _G.logger:fine(nameOfModule .. ": Try to send data on instance No. " .. multiTCPIPClientInstanceNumberString)
  local numberOfBytesTransmitted

  if processingParams.currentConnectionStatus ~= nil then
    numberOfBytesTransmitted = tcpipHandle:transmit(tostring(data))

    table.insert(log, 1, DateTime.getTime() .. ' - SENT = ' .. tostring(data))

    sendLog()

    if numberOfBytesTransmitted == 0 then
      _G.logger:warning(nameOfModule .. ": TCP Data Out failed")
    else
      _G.logger:fine(nameOfModule .. ": Send: " .. tostring(data))
    end
  else
    _G.logger:warning(nameOfModule .. ": No TCP connection.")
  end

  return numberOfBytesTransmitted
end
Script.serveFunction("CSK_MultiTCPIPClient.transmitData"..multiTCPIPClientInstanceNumberString, handleTransmitData, 'string:1', 'int:1')

--- Function only used to forward the content from events to the served function.
--- This is only needed, as deregistering from the event would internally release the served function and would make it uncallable from external.
---@param data string Data to transmit
local function tempHandleTransmitData(data)
  handleTransmitData(data)
end

--- Function to receive incoming TCP/IP data
---@param data binary The received data
local function handleOnReceive(data)

  _G.logger:fine(nameOfModule .. ": Received data on instance No. " .. multiTCPIPClientInstanceNumberString .. " = " .. data)

  -- Forward data to other modules
  Script.notifyEvent("MultiTCPIPClient_OnNewData" .. multiTCPIPClientInstanceNumberString, data)

  table.insert(log, 1, DateTime.getTime() .. ' - RECV = ' .. tostring(data))

  sendLog()

  -- Check if cmd includes parameters seperated by a ','
  local _, pos = string.find(data, ',')

  if pos then
    -- Check for command with parameter attached
    local cmd = string.sub(data, 1, pos-1)
    if processingParams.commandList[cmd] then
      Script.notifyEvent("MultiTCPIPClient_" .. processingParams.commandList[cmd], string.sub(data, pos + 1))
    end
  else
    -- Check for command without parameter
    if processingParams.commandList[data] then
      Script.notifyEvent("MultiTCPIPClient_" .. processingParams.commandList[data])
    end
  end
end

--- Function to update the TCP/IP connection with new setup
local function updateSetup()

  tcpipHandle:setIPAddress(processingParams.serverIP)
  tcpipHandle:setPort(processingParams.port)
  if processingParams.rxFrame == 'STX-ETX' then
    if processingParams.txFrame == 'STX-ETX' then
      tcpipHandle:setFraming('\02','\03','\02','\03')
    else
      tcpipHandle:setFraming('\02','\03','','')
    end
  elseif processingParams.txFrame == 'STX-ETX' then
      tcpipHandle:setFraming('','','\02','\03')
  else
      tcpipHandle:setFraming('','','','')
  end

  tcpipHandle:setInterface(processingParams.interface)

  sendLog()

end

--- Function to create a new TCP/IP connection
local function connect()
  updateSetup()
  tcpipHandle:connect()
end

--- Function to close the TCP/IP connection
local function disconnect()
  if processingParams.currentConnectionStatus then
    handleTransmitData('Closing connection.')
  end
  tcpipHandle:disconnect()
end

--- Function to handle updates of processing parameters from Controller
---@param multiTCPIPClientNo int Number of instance to update
---@param parameter string Parameter to update
---@param value auto Value of parameter to update
---@param value2 auto 2nd value of parameter to update
local function handleOnNewProcessingParameter(multiTCPIPClientNo, parameter, value, value2)

  if multiTCPIPClientNo == multiTCPIPClientInstanceNumber then -- set parameter only in selected script
    if value then
      _G.logger:fine(nameOfModule .. ": Update parameter '" .. parameter .. "' of multiTCPIPClientInstanceNo." .. tostring(multiTCPIPClientNo) .. " to value = " .. tostring(value))
    else
      _G.logger:fine(nameOfModule .. ": Update parameter '" .. parameter .. "' of multiTCPIPClientInstanceNo." .. tostring(multiTCPIPClientNo))
    end

    if parameter == 'connect' then
      connect()

    elseif parameter == 'disconnect' then
      disconnect()

    elseif parameter == 'transmit' then
      handleTransmitData(value)

    elseif parameter == 'addEvent' then
      if processingParams.forwardEvents[value] then
        Script.deregister(processingParams.forwardEvents[value], tempHandleTransmitData)
      end
      processingParams.forwardEvents[value] = value

      local suc = Script.register(value, tempHandleTransmitData)
      _G.logger:fine(nameOfModule .. ": Added event to forward content = " .. value .. " on instance No. " .. multiTCPIPClientInstanceNumberString)
      _G.logger:fine(nameOfModule .. ": Success to register to event = " .. tostring(suc) .. " on instance No. " .. multiTCPIPClientInstanceNumberString)

    elseif parameter == 'removeEvent' then
      processingParams.forwardEvents[value] = nil
      local suc = Script.deregister(value, tempHandleTransmitData)
      _G.logger:fine(nameOfModule .. ": Deleted event = " .. tostring(value) .. " on instance No. " .. multiTCPIPClientInstanceNumberString)
      _G.logger:fine(nameOfModule .. ": Success to deregister of event = " .. tostring(suc) .. " on instance No. " .. multiTCPIPClientInstanceNumberString)

    elseif parameter == 'addTrigger' then
      _G.logger:fine(nameOfModule .. ": Added Trigger/Event pair = " .. value .. '/' .. value2)
      processingParams.commandList[value] = value2

      local check = Script.isServedAsEvent("CSK_MultiTCPIPClient." .. value2)
      if not check then
        Script.serveEvent("CSK_MultiTCPIPClient." .. value2, "MultiTCPIPClient_" .. value2, 'string:?')
      end

    elseif parameter == 'removeTrigger' then
      _G.logger:fine(nameOfModule .. ": Deleted trigger = " .. tostring(value) .. " on instance No. " .. multiTCPIPClientInstanceNumberString)
      processingParams.commandList[value] = nil

    elseif parameter == 'clearAll' then
      for forwardEvent in pairs(processingParams.forwardEvents) do
        processingParams.forwardEvents[forwardEvent] = nil
        Script.deregister(forwardEvent, tempHandleTransmitData)
      end

      for trigger, event in pairs(processingParams.commandList) do
        processingParams.commandList[trigger] = nil
      end

    else
      processingParams[parameter] = value
      updateSetup()
    end
  elseif parameter == 'activeInUI' then
    processingParams[parameter] = false
  end
end
Script.register("CSK_MultiTCPIPClient.OnNewProcessingParameter", handleOnNewProcessingParameter)

tcpipHandle:register('OnReceive', handleOnReceive)
tcpipHandle:register("OnDisconnected", handleOnDisconnected)
tcpipHandle:register("OnConnected", handleOnConnected)

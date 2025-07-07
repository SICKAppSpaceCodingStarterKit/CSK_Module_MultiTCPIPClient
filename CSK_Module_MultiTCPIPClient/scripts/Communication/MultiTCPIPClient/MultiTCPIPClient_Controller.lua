---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the MultiTCPIPClient_Model and _Instances
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_MultiTCPIPClient'

local funcs = {}

-- Timer to update UI via events after page was loaded
local tmrMultiTCPIPClient = Timer.create()
tmrMultiTCPIPClient:setExpirationTime(300)
tmrMultiTCPIPClient:setPeriodic(false)

local triggerValue, eventValue = '', '' -- Selected trigger command + eventName for trigger/event pair via UI
local selectedTrigger = '' -- Selected trigger/event pair

local eventToForward = '' -- Preset event name to add via UI (see 'addEventToForwardViaUI')
local selectedEventToForward = '' -- Selected event to forward content to TCP/IP server within UI table

local multiTCPIPClient_Model -- Reference to model handle
local multiTCPIPClient_Instances -- Reference to instances handle
local selectedInstance = 1 -- Which instance is currently selected
local helperFuncs = require('Communication/MultiTCPIPClient/helper/funcs')

-- ************************ UI Events Start ********************************
-- Only to prevent WARNING messages, but these are only examples/placeholders for dynamically created events/functions
----------------------------------------------------------------
local function emptyFunction()
end
Script.serveFunction("CSK_MultiTCPIPClient.transmitDataNUM", emptyFunction)

Script.serveEvent("CSK_MultiTCPIPClient.OnNewDataNUM", "MultiTCPIPClient_OnNewDataNUM")
Script.serveEvent("CSK_MultiTCPIPClient.OnNewValueToForwardNUM", "MultiTCPIPClient_OnNewValueToForwardNUM")
Script.serveEvent("CSK_MultiTCPIPClient.OnNewValueUpdateNUM", "MultiTCPIPClient_OnNewValueUpdateNUM")

-- Real events
--------------------------------------------------

Script.serveEvent('CSK_MultiTCPIPClient.OnNewStatusModuleVersion', 'MultiTCPIPClient_OnNewStatusModuleVersion')
Script.serveEvent('CSK_MultiTCPIPClient.OnNewStatusCSKStyle', 'MultiTCPIPClient_OnNewStatusCSKStyle')
Script.serveEvent('CSK_MultiTCPIPClient.OnNewStatusModuleIsActive', 'MultiTCPIPClient_OnNewStatusModuleIsActive')

Script.serveEvent("CSK_MultiTCPIPClient.OnNewConnectionStatus", "MultiTCPIPClient_OnNewConnectionStatus")
Script.serveEvent("CSK_MultiTCPIPClient.OnNewInterfaceList", "MultiTCPIPClient_OnNewInterfaceList")
Script.serveEvent("CSK_MultiTCPIPClient.OnNewInterface", "MultiTCPIPClient_OnNewInterface")
Script.serveEvent("CSK_MultiTCPIPClient.OnNewServerIP", "MultiTCPIPClient_OnNewServerIP")
Script.serveEvent("CSK_MultiTCPIPClient.OnNewPort", "MultiTCPIPClient_OnNewPort")
Script.serveEvent("CSK_MultiTCPIPClient.OnNewRxFrame", "MultiTCPIPClient_OnNewRxFrame")
Script.serveEvent("CSK_MultiTCPIPClient.OnNewTxFrame", "MultiTCPIPClient_OnNewTxFrame")
Script.serveEvent("CSK_MultiTCPIPClient.OnNewCurrentConnectionStatus", "MultiTCPIPClient_OnNewCurrentConnectionStatus")
Script.serveEvent("CSK_MultiTCPIPClient.OnNewCommand", "MultiTCPIPClient_OnNewCommand")
Script.serveEvent("CSK_MultiTCPIPClient.OnNewLog", "MultiTCPIPClient_OnNewLog")
Script.serveEvent("CSK_MultiTCPIPClient.OnNewTriggerEventPairList", "MultiTCPIPClient_OnNewTriggerEventPairList")
Script.serveEvent("CSK_MultiTCPIPClient.OnNewTriggerEventPairTrigger", "MultiTCPIPClient_OnNewTriggerEventPairTrigger")
Script.serveEvent("CSK_MultiTCPIPClient.OnNewTriggerEventPairEvent", "MultiTCPIPClient_OnNewTriggerEventPairEvent")
Script.serveEvent("CSK_MultiTCPIPClient.OnNewEventToForwardList", "MultiTCPIPClient_OnNewEventToForwardList")
Script.serveEvent("CSK_MultiTCPIPClient.OnNewEventToForward", "MultiTCPIPClient_OnNewEventToForward")

Script.serveEvent("CSK_MultiTCPIPClient.OnNewStatusLoadParameterOnReboot", "MultiTCPIPClient_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_MultiTCPIPClient.OnPersistentDataModuleAvailable", "MultiTCPIPClient_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_MultiTCPIPClient.OnNewParameterName", "MultiTCPIPClient_OnNewParameterName")
Script.serveEvent('CSK_MultiTCPIPClient.OnNewStatusFlowConfigPriority', 'MultiTCPIPClient_OnNewStatusFlowConfigPriority')

Script.serveEvent("CSK_MultiTCPIPClient.OnNewInstanceList", "MultiTCPIPClient_OnNewInstanceList")
Script.serveEvent("CSK_MultiTCPIPClient.OnNewProcessingParameter", "MultiTCPIPClient_OnNewProcessingParameter")
Script.serveEvent("CSK_MultiTCPIPClient.OnNewSelectedInstance", "MultiTCPIPClient_OnNewSelectedInstance")
Script.serveEvent("CSK_MultiTCPIPClient.OnDataLoadedOnReboot", "MultiTCPIPClient_OnDataLoadedOnReboot")

Script.serveEvent("CSK_MultiTCPIPClient.OnUserLevelOperatorActive", "MultiTCPIPClient_OnUserLevelOperatorActive")
Script.serveEvent("CSK_MultiTCPIPClient.OnUserLevelMaintenanceActive", "MultiTCPIPClient_OnUserLevelMaintenanceActive")
Script.serveEvent("CSK_MultiTCPIPClient.OnUserLevelServiceActive", "MultiTCPIPClient_OnUserLevelServiceActive")
Script.serveEvent("CSK_MultiTCPIPClient.OnUserLevelAdminActive", "MultiTCPIPClient_OnUserLevelAdminActive")

-- ************************ UI Events End **********************************
--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Functions to forward logged in user roles via CSK_UserManagement module (if available)
-- ***********************************************
--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("MultiTCPIPClient_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("MultiTCPIPClient_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("MultiTCPIPClient_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("MultiTCPIPClient_OnUserLevelAdminActive", status)
end
-- ***********************************************

--- Function to forward data updates from instance threads to Controller part of module
---@param eventname string Eventname to use to forward value
---@param value auto Value to forward
local function handleOnNewValueToForward(eventname, value)
  Script.notifyEvent(eventname, value)
end

--- Function to sync paramters between instance threads and Controller part of module
---@param instance int Instance new value is coming from
---@param parameter string Name of the paramter to update/sync
---@param value auto Value to update
local function handleOnNewValueUpdate(instance, parameter, value)
  if parameter == 'currentConnectionStatus' then
    multiTCPIPClient_Instances[instance][parameter] = value
  else
    multiTCPIPClient_Instances[instance].parameters[parameter] = value
  end
end

--- Function to get access to the multiTCPIPClient_Model object
---@param handle handle Handle of multiTCPIPClient_Model object
local function setMultiTCPIPClient_Model_Handle(handle)
  multiTCPIPClient_Model = handle
  Script.releaseObject(handle)
end
funcs.setMultiTCPIPClient_Model_Handle = setMultiTCPIPClient_Model_Handle

--- Function to get access to the multiTCPIPClient_Instances object
---@param handle handle Handle of multiTCPIPClient_Instances object
local function setMultiTCPIPClient_Instances_Handle(handle)
  multiTCPIPClient_Instances = handle
  if multiTCPIPClient_Instances[selectedInstance].userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)

  for i = 1, #multiTCPIPClient_Instances do
    Script.register("CSK_MultiTCPIPClient.OnNewValueToForward" .. tostring(i) , handleOnNewValueToForward)
  end

  for i = 1, #multiTCPIPClient_Instances do
    Script.register("CSK_MultiTCPIPClient.OnNewValueUpdate" .. tostring(i) , handleOnNewValueUpdate)
  end

end
funcs.setMultiTCPIPClient_Instances_Handle = setMultiTCPIPClient_Instances_Handle

--- Function to update user levels
local function updateUserLevel()
  if multiTCPIPClient_Instances[selectedInstance].userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("MultiTCPIPClient_OnUserLevelAdminActive", true)
    Script.notifyEvent("MultiTCPIPClient_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("MultiTCPIPClient_OnUserLevelServiceActive", true)
    Script.notifyEvent("MultiTCPIPClient_OnUserLevelOperatorActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrMultiTCPIPClient()

  Script.notifyEvent("MultiTCPIPClient_OnNewStatusModuleVersion", 'v' .. multiTCPIPClient_Model.version)
  Script.notifyEvent("MultiTCPIPClient_OnNewStatusCSKStyle", multiTCPIPClient_Model.styleForUI)
  Script.notifyEvent("MultiTCPIPClient_OnNewStatusModuleIsActive", _G.availableAPIs.default and _G.availableAPIs.specific)

  if _G.availableAPIs.default and _G.availableAPIs.specific then

    updateUserLevel()

    Script.notifyEvent('MultiTCPIPClient_OnNewSelectedInstance', selectedInstance)
    Script.notifyEvent("MultiTCPIPClient_OnNewInstanceList", helperFuncs.createStringListBySize(#multiTCPIPClient_Instances))

    Script.notifyEvent("MultiTCPIPClient_OnNewConnectionStatus", multiTCPIPClient_Instances[selectedInstance].parameters.connectionStatus)
    Script.notifyEvent("MultiTCPIPClient_OnNewInterfaceList", multiTCPIPClient_Instances[selectedInstance].interfaceList)
    Script.notifyEvent("MultiTCPIPClient_OnNewInterface", multiTCPIPClient_Instances[selectedInstance].parameters.interface)
    Script.notifyEvent("MultiTCPIPClient_OnNewServerIP", multiTCPIPClient_Instances[selectedInstance].parameters.serverIP)
    Script.notifyEvent("MultiTCPIPClient_OnNewPort", multiTCPIPClient_Instances[selectedInstance].parameters.port)
    Script.notifyEvent("MultiTCPIPClient_OnNewRxFrame", multiTCPIPClient_Instances[selectedInstance].parameters.rxFrame)
    Script.notifyEvent("MultiTCPIPClient_OnNewTxFrame", multiTCPIPClient_Instances[selectedInstance].parameters.txFrame)
    Script.notifyEvent("MultiTCPIPClient_OnNewCurrentConnectionStatus", multiTCPIPClient_Instances[selectedInstance].currentConnectionStatus)
    Script.notifyEvent("MultiTCPIPClient_OnNewCommand", multiTCPIPClient_Instances[selectedInstance].command)
    Script.notifyEvent("MultiTCPIPClient_OnNewStatusLoadParameterOnReboot", multiTCPIPClient_Instances[selectedInstance].parameterLoadOnReboot)
    Script.notifyEvent("MultiTCPIPClient_OnPersistentDataModuleAvailable", multiTCPIPClient_Instances[selectedInstance].persistentModuleAvailable)
    Script.notifyEvent("MultiTCPIPClient_OnNewParameterName", multiTCPIPClient_Instances[selectedInstance].parametersName)

    Script.notifyEvent("MultiTCPIPClient_OnNewTriggerEventPairList", multiTCPIPClient_Instances[selectedInstance].helperFuncs.createSpecificJsonList('commandList', multiTCPIPClient_Instances[selectedInstance].parameters.commandList))
    Script.notifyEvent("MultiTCPIPClient_OnNewTriggerEventPairTrigger", '')
    triggerValue = ''
    Script.notifyEvent("MultiTCPIPClient_OnNewTriggerEventPairEvent", '')
    eventValue = ''
    Script.notifyEvent("MultiTCPIPClient_OnNewEventToForwardList", multiTCPIPClient_Instances[selectedInstance].helperFuncs.createSpecificJsonList('eventToForward', multiTCPIPClient_Instances[selectedInstance].parameters.forwardEvents))
    Script.notifyEvent("MultiTCPIPClient_OnNewEventToForward", '')
    eventToForward = ''
    Script.notifyEvent("MultiTCPIPClient_OnNewStatusFlowConfigPriority", multiTCPIPClient_Instances[selectedInstance].parameters.flowConfigPriority)
    Script.notifyEvent("MultiTCPIPClient_OnNewStatusLoadParameterOnReboot", multiTCPIPClient_Instances[selectedInstance].parameterLoadOnReboot)
    Script.notifyEvent("MultiTCPIPClient_OnPersistentDataModuleAvailable", multiTCPIPClient_Instances[selectedInstance].persistentModuleAvailable)
    Script.notifyEvent("MultiTCPIPClient_OnNewParameterName", multiTCPIPClient_Instances[selectedInstance].parametersName)
  end
end
Timer.register(tmrMultiTCPIPClient, "OnExpired", handleOnExpiredTmrMultiTCPIPClient)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    updateUserLevel() -- try to hide user specific content asap
  end
  tmrMultiTCPIPClient:start()
  return ''
end
Script.serveFunction("CSK_MultiTCPIPClient.pageCalled", pageCalled)

local function setSelectedInstance(instance)
  if #multiTCPIPClient_Instances >= instance then
    selectedInstance = instance
    _G.logger:fine(nameOfModule .. ": New selected instance = " .. tostring(selectedInstance))
    multiTCPIPClient_Instances[selectedInstance].activeInUI = true
    Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'activeInUI', true)
    tmrMultiTCPIPClient:start()
  else
    _G.logger:warning(nameOfModule .. ": Selected instance does not exist.")
  end
end
Script.serveFunction("CSK_MultiTCPIPClient.setSelectedInstance", setSelectedInstance)

local function getInstancesAmount ()
  if multiTCPIPClient_Instances then
    return #multiTCPIPClient_Instances
  else
    return 0
  end
end
Script.serveFunction("CSK_MultiTCPIPClient.getInstancesAmount", getInstancesAmount)

local function addInstance()
  _G.logger:fine(nameOfModule .. ": Add instance")
  table.insert(multiTCPIPClient_Instances, multiTCPIPClient_Model.create(#multiTCPIPClient_Instances+1))
  Script.deregister("CSK_MultiTCPIPClient.OnNewValueToForward" .. tostring(#multiTCPIPClient_Instances) , handleOnNewValueToForward)
  Script.register("CSK_MultiTCPIPClient.OnNewValueToForward" .. tostring(#multiTCPIPClient_Instances) , handleOnNewValueToForward)
  Script.deregister("CSK_MultiTCPIPClient.OnNewValueUpdate" .. tostring(#multiTCPIPClient_Instances) , handleOnNewValueUpdate)
  Script.register("CSK_MultiTCPIPClient.OnNewValueUpdate" .. tostring(#multiTCPIPClient_Instances) , handleOnNewValueUpdate)

  handleOnExpiredTmrMultiTCPIPClient()
end
Script.serveFunction('CSK_MultiTCPIPClient.addInstance', addInstance)

local function resetInstances()
  _G.logger:fine(nameOfModule .. ": Reset instances.")
  setSelectedInstance(1)
  local totalAmount = #multiTCPIPClient_Instances
  while totalAmount > 1 do
    Script.releaseObject(multiTCPIPClient_Instances[totalAmount])
    multiTCPIPClient_Instances[totalAmount] =  nil
    totalAmount = totalAmount - 1
  end
  handleOnExpiredTmrMultiTCPIPClient()
end
Script.serveFunction('CSK_MultiTCPIPClient.resetInstances', resetInstances)

local function selectEventToForwardViaUI(selection)

  if selection == "" then
    selectedEventToForward = ''
    _G.logger:warning(nameOfModule .. ": Did not find EventToForward. Is empty")
  else
    local _, pos = string.find(selection, '"EventToForward":"')
    if pos == nil then
      _G.logger:warning(nameOfModule .. ": Did not find EventToForward. Is nil")
      selectedEventToForward = ''
    else
      pos = tonumber(pos)
      local endPos = string.find(selection, '"', pos+1)
      selectedEventToForward = string.sub(selection, pos+1, endPos-1)
      if ( selectedEventToForward == nil or selectedEventToForward == "" ) then
        _G.logger:warning(nameOfModule .. ": Did not find EventToForward. Is empty or nil")
        selectedEventToForward = ''
      else
        _G.logger:fine(nameOfModule .. ": Selected EventToForward: " .. tostring(selectedEventToForward))
        if ( selectedEventToForward ~= "-" ) then
          eventToForward = selectedEventToForward
          Script.notifyEvent("MultiTCPIPClient_OnNewEventToForward", eventToForward)
        end
      end
    end
  end
end
Script.serveFunction("CSK_MultiTCPIPClient.selectEventToForwardViaUI", selectEventToForwardViaUI)

local function addEventToForward(event)
  if ( event == '' ) then
    _G.logger:info(nameOfModule .. ": EventToForward cannot be added. Is empty")
  else
    multiTCPIPClient_Instances[selectedInstance].parameters.forwardEvents[event] = event
    Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'addEvent', event)
    Script.notifyEvent("MultiTCPIPClient_OnNewEventToForwardList", multiTCPIPClient_Instances[selectedInstance].helperFuncs.createSpecificJsonList('eventToForward', multiTCPIPClient_Instances[selectedInstance].parameters.forwardEvents))
  end
end
Script.serveFunction("CSK_MultiTCPIPClient.addEventToForward", addEventToForward)

local function addEventToForwardViaUI()
  addEventToForward(eventToForward)
end
Script.serveFunction("CSK_MultiTCPIPClient.addEventToForwardViaUI", addEventToForwardViaUI)

local function deleteEventToForward(event)
  multiTCPIPClient_Instances[selectedInstance].parameters.forwardEvents[event] = nil
  Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'removeEvent', event)
  Script.notifyEvent("MultiTCPIPClient_OnNewEventToForwardList", multiTCPIPClient_Instances[selectedInstance].helperFuncs.createSpecificJsonList('eventToForward', multiTCPIPClient_Instances[selectedInstance].parameters.forwardEvents))
end
Script.serveFunction("CSK_MultiTCPIPClient.deleteEventToForward", deleteEventToForward)

local function deleteEventToForwardViaUI()
  if selectedEventToForward ~= '' then
    deleteEventToForward(selectedEventToForward)
  end
end
Script.serveFunction("CSK_MultiTCPIPClient.deleteEventToForwardViaUI", deleteEventToForwardViaUI)

local function setEventToForward(value)
  eventToForward = value
  _G.logger:fine(nameOfModule .. ": Set eventToForward = " .. tostring(value))
end
Script.serveFunction("CSK_MultiTCPIPClient.setEventToForward", setEventToForward)

local function selectTriggerEventPairViaUI(selection)

  if selection == "" then
    selectedTrigger = ''
    _G.logger:info(nameOfModule .. ": Did not find TriggerCommand. Is empty")
  else
    local _, pos = string.find(selection, '"TriggerCommand":"')
    if pos == nil then
      _G.logger:info(nameOfModule .. ": Did not find TriggerCommand. Is nil")
      selectedTrigger = ''
    else
      pos = tonumber(pos)
      local endPos = string.find(selection, '"', pos+1)
      selectedTrigger = string.sub(selection, pos+1, endPos-1)
      if ( selectedTrigger == nil or selectedTrigger == "" ) then
        _G.logger:info(nameOfModule .. ": Did not find TriggerCommand. Is empty or nil")
        selectedTrigger = ''
      else
        _G.logger:fine(nameOfModule .. ": Selected TriggerCommand: " .. tostring(selectedTrigger))
        if ( selectedTrigger ~= "-" ) then
          triggerValue = selectedTrigger
          eventValue = multiTCPIPClient_Instances[selectedInstance].parameters.commandList[selectedTrigger]
          Script.notifyEvent("MultiTCPIPClient_OnNewTriggerEventPairTrigger", triggerValue)
          Script.notifyEvent("MultiTCPIPClient_OnNewTriggerEventPairEvent", eventValue)
        end
      end
    end
  end
end
Script.serveFunction("CSK_MultiTCPIPClient.selectTriggerEventPairViaUI", selectTriggerEventPairViaUI)

local function addTriggerEventPair(trigger, event)
  if ( trigger == '' ) then
    _G.logger:info(nameOfModule .. ": TriggerCommand cannot be added. Trigger is empty")
  elseif ( event == '' ) then
    _G.logger:info(nameOfModule .. ": TriggerCommand cannot be added. Event is empty")
  else
    multiTCPIPClient_Instances[selectedInstance].parameters.commandList[trigger] = event
    Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'addTrigger', trigger, event)
    Script.notifyEvent("MultiTCPIPClient_OnNewTriggerEventPairList", multiTCPIPClient_Instances[selectedInstance].helperFuncs.createSpecificJsonList('commandList', multiTCPIPClient_Instances[selectedInstance].parameters.commandList))
  end
end
Script.serveFunction("CSK_MultiTCPIPClient.addTriggerEventPair", addTriggerEventPair)

local function deleteTriggerEventPair(trigger)
  Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'removeTrigger', trigger)
  multiTCPIPClient_Instances[selectedInstance].parameters.commandList[trigger] = nil
  Script.notifyEvent("MultiTCPIPClient_OnNewTriggerEventPairList", multiTCPIPClient_Instances[selectedInstance].helperFuncs.createSpecificJsonList('commandList', multiTCPIPClient_Instances[selectedInstance].parameters.commandList))
end
Script.serveFunction("CSK_MultiTCPIPClient.deleteTriggerEventPair", deleteTriggerEventPair)

local function deleteTriggerEventPairViaUI()
  if selectedTrigger ~= '' then
    deleteTriggerEventPair(selectedTrigger)
  end
end
Script.serveFunction("CSK_MultiTCPIPClient.deleteTriggerEventPairViaUI", deleteTriggerEventPairViaUI)

local function setTrigger(value)
  triggerValue = value
  _G.logger:fine(nameOfModule .. ": Set trigger = " .. tostring(value))
end
Script.serveFunction("CSK_MultiTCPIPClient.setTrigger", setTrigger)

local function setEventValue(value)
  eventValue = value
  _G.logger:fine(nameOfModule .. ": Set event value = " .. tostring(value))
end
Script.serveFunction("CSK_MultiTCPIPClient.setEventValue", setEventValue)

local function addTriggerEventPairViaUI()
  addTriggerEventPair(triggerValue, eventValue)
end
Script.serveFunction("CSK_MultiTCPIPClient.addTriggerEventPairViaUI", addTriggerEventPairViaUI)

local function setConnectionStatus(status)
  multiTCPIPClient_Instances[selectedInstance].parameters.connectionStatus = status
  _G.logger:fine(nameOfModule .. ": Set connection status = " .. tostring(status))
  if status then
    Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'connect')
  else
    Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'disconnect')
  end
end
Script.serveFunction("CSK_MultiTCPIPClient.setConnectionStatus", setConnectionStatus)

local function setServerAddress(address)
  multiTCPIPClient_Instances[selectedInstance].parameters.serverIP = address
  _G.logger:fine(nameOfModule .. ": Set Server IP = " .. tostring(address))
  Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'serverIP', address)
end
Script.serveFunction("CSK_MultiTCPIPClient.setServerAddress", setServerAddress)

local function setPort(port)
  multiTCPIPClient_Instances[selectedInstance].parameters.port = port
  _G.logger:fine(nameOfModule .. ": Set Port = " .. tostring(port))
  Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'port', port)
end
Script.serveFunction("CSK_MultiTCPIPClient.setPort", setPort)

local function setInterface(interface)
  multiTCPIPClient_Instances[selectedInstance].parameters.interface = interface
  _G.logger:fine(nameOfModule .. ": Set interface = " .. tostring(interface))
  Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'interface', tostring(interface))
end
Script.serveFunction("CSK_MultiTCPIPClient.setInterface", setInterface)

local function setRxFraming(frame)
  _G.logger:fine(nameOfModule .. ": Set RX framing = " .. tostring(frame))
  if frame == 'STX-ETX' or frame == 'empty' then
    multiTCPIPClient_Instances[selectedInstance].parameters.rxFrame = frame
    Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'rxFrame', frame)
  end
end
Script.serveFunction("CSK_MultiTCPIPClient.setRxFraming", setRxFraming)

local function setTxFraming(frame)
  _G.logger:fine(nameOfModule .. ": Set TX framing = " .. tostring(frame))
  if frame == 'STX-ETX' or frame == 'empty' then
    multiTCPIPClient_Instances[selectedInstance].parameters.txFrame = frame
    Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'txFrame', frame)
  end
end
Script.serveFunction("CSK_MultiTCPIPClient.setTxFraming", setTxFraming)

local function replaceHex(value)
  local subString = string.sub(value, 3, 4)
  if multiTCPIPClient_Instances[selectedInstance].hexValues[subString] then
    return multiTCPIPClient_Instances[selectedInstance].hexValues[subString]
  else
    return value
  end
end

local function setCommand(cmd)
  _G.logger:fine(nameOfModule .. ": Preset command to send = " .. tostring(cmd))
  local res = string.gsub(cmd, "\\x+%w%w", replaceHex)
  multiTCPIPClient_Instances[selectedInstance].command = res
end
Script.serveFunction("CSK_MultiTCPIPClient.setCommand", setCommand)

local function transmitCommando()
  _G.logger:fine(nameOfModule .. ": Send command = " .. tostring(multiTCPIPClient_Instances[selectedInstance].command))
  Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'transmit', tostring(multiTCPIPClient_Instances[selectedInstance].command))
end
Script.serveFunction("CSK_MultiTCPIPClient.transmitCommando", transmitCommando)

--- Function to share process relevant configuration with processing threads
local function updateProcessingParameters()

  Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'disconnect')
  Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'clearAll')

  Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'activeInUI', true)
  Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'serverIP', multiTCPIPClient_Instances[selectedInstance].parameters.serverIP)
  Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'port', multiTCPIPClient_Instances[selectedInstance].parameters.port)
  Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'rxFrame', multiTCPIPClient_Instances[selectedInstance].parameters.rxFrame)
  Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'txFrame', multiTCPIPClient_Instances[selectedInstance].parameters.txFrame)
  Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'interface', multiTCPIPClient_Instances[selectedInstance].parameters.interface)

  for forwardEvent in pairs(multiTCPIPClient_Instances[selectedInstance].parameters.forwardEvents) do
    Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'addEvent', forwardEvent)
  end

  for trigger, event in pairs(multiTCPIPClient_Instances[selectedInstance].parameters.commandList) do
    Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'addTrigger', trigger, event)
  end
end

local function getStatusModuleActive()
  return _G.availableAPIs.default and _G.availableAPIs.specific
end
Script.serveFunction('CSK_MultiTCPIPClient.getStatusModuleActive', getStatusModuleActive)

local function clearFlowConfigRelevantConfiguration()
  for i = 1, #multiTCPIPClient_Instances do
    if multiTCPIPClient_Instances[i].parameters.flowConfigPriority then
      for key, value in pairs(multiTCPIPClient_Instances[i].parameters.forwardEvents) do
        deleteEventToForward(value)
      end
    end
  end
end
Script.serveFunction('CSK_MultiTCPIPClient.clearFlowConfigRelevantConfiguration', clearFlowConfigRelevantConfiguration)

local function getParameters(instanceNo)
  if instanceNo <= #multiTCPIPClient_Instances then
    return helperFuncs.json.encode(multiTCPIPClient_Instances[instanceNo].parameters)
  else
    return ''
  end
end
Script.serveFunction('CSK_MultiTCPIPClient.getParameters', getParameters)

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:fine(nameOfModule .. ": Set parameter name = " .. tostring(name))
  multiTCPIPClient_Instances[selectedInstance].parametersName = name
end
Script.serveFunction("CSK_MultiTCPIPClient.setParameterName", setParameterName)

local function sendParameters(noDataSave)
  if multiTCPIPClient_Instances[selectedInstance].persistentModuleAvailable then
    CSK_PersistentData.addParameter(helperFuncs.convertTable2Container(multiTCPIPClient_Instances[selectedInstance].parameters), multiTCPIPClient_Instances[selectedInstance].parametersName)

    -- Check if CSK_PersistentData version is >= 3.0.0
    if tonumber(string.sub(CSK_PersistentData.getVersion(), 1, 1)) >= 3 then
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiTCPIPClient_Instances[selectedInstance].parametersName, multiTCPIPClient_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance), #multiTCPIPClient_Instances)
    else
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiTCPIPClient_Instances[selectedInstance].parametersName, multiTCPIPClient_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance))
    end
    _G.logger:fine(nameOfModule .. ": Send MultiTCPIPClient parameters with name '" .. multiTCPIPClient_Instances[selectedInstance].parametersName .. "' to CSK_PersistentData module.")
    if not noDataSave then
      CSK_PersistentData.saveData()
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_MultiTCPIPClient.sendParameters", sendParameters)

local function loadParameters()

  if multiTCPIPClient_Instances[selectedInstance].persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(multiTCPIPClient_Instances[selectedInstance].parametersName)
    if data then
      _G.logger:info(nameOfModule .. ": Loaded parameters for multiTCPIPClientObject " .. tostring(selectedInstance) .. " from CSK_PersistentData module.")
      multiTCPIPClient_Instances[selectedInstance].parameters = helperFuncs.convertContainer2Table(data)

      multiTCPIPClient_Instances[selectedInstance].parameters = helperFuncs.checkParameters(multiTCPIPClient_Instances[selectedInstance].parameters, helperFuncs.defaultParameters.getParameters())

      -- If something needs to be configured/activated with new loaded data
      updateProcessingParameters()

      if multiTCPIPClient_Instances[selectedInstance].parameters.connectionStatus then
        Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'connect')
      end

      tmrMultiTCPIPClient:start()
      return true
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
      tmrMultiTCPIPClient:start()
      return false
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
    tmrMultiTCPIPClient:start()
    return false
  end
end
Script.serveFunction("CSK_MultiTCPIPClient.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  multiTCPIPClient_Instances[selectedInstance].parameterLoadOnReboot = status
  _G.logger:fine(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
  Script.notifyEvent("MultiTCPIPClient_OnNewStatusLoadParameterOnReboot", status)
end
Script.serveFunction("CSK_MultiTCPIPClient.setLoadOnReboot", setLoadOnReboot)

local function setFlowConfigPriority(status)
  multiTCPIPClient_Instances[selectedInstance].parameters.flowConfigPriority = status
  _G.logger:fine(nameOfModule .. ": Set new status of FlowConfig priority: " .. tostring(status))
  Script.notifyEvent("MultiTCPIPClient_OnNewStatusFlowConfigPriority", multiTCPIPClient_Instances[selectedInstance].parameters.flowConfigPriority)
end
Script.serveFunction('CSK_MultiTCPIPClient.setFlowConfigPriority', setFlowConfigPriority)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  if _G.availableAPIs.default and _G.availableAPIs.specific then
    _G.logger:fine(nameOfModule .. ': Try to initially load parameter from CSK_PersistentData module.')
    if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

      _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')

      for j = 1, #multiTCPIPClient_Instances do
        multiTCPIPClient_Instances[j].persistentModuleAvailable = false
      end
    else
      -- Check if CSK_PersistentData version is >= 3.0.0
      if tonumber(string.sub(CSK_PersistentData.getVersion(), 1, 1)) >= 3 then
        local parameterName, loadOnReboot, totalInstances = CSK_PersistentData.getModuleParameterName(nameOfModule, '1')
        -- Check for amount if instances to create
        if totalInstances then
          local c = 2
          while c <= totalInstances do
            addInstance()
            c = c+1
          end
        end
      end

      if not multiTCPIPClient_Instances then
          return
        end

      for i = 1, #multiTCPIPClient_Instances do
        local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule, tostring(i))

        if parameterName then
          multiTCPIPClient_Instances[i].parametersName = parameterName
          multiTCPIPClient_Instances[i].parameterLoadOnReboot = loadOnReboot
        end

        if multiTCPIPClient_Instances[i].parameterLoadOnReboot then
          setSelectedInstance(i)
          loadParameters()
        end
      end
      Script.notifyEvent('MultiTCPIPClient_OnDataLoadedOnReboot')
    end
  end
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

local function resetModule()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    for i = 1, #multiTCPIPClient_Instances do
      for key, value in pairs(multiTCPIPClient_Instances[i].parameters.forwardEvents) do
        deleteEventToForward(value)
      end
      setConnectionStatus(false)
    end
    pageCalled()
  end
end
Script.serveFunction('CSK_MultiTCPIPClient.resetModule', resetModule)
Script.register("CSK_PersistentData.OnResetAllModules", resetModule)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return funcs

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************


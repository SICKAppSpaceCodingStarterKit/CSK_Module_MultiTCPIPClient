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

local multiTCPIPClient_Model -- Reference to model handle
local multiTCPIPClient_Instances -- Reference to instances handle
local selectedInstance = 1 -- Which instance is currently selected
local helperFuncs = require('Communication/MultiTCPIPClient/helper/funcs')

-- ************************ UI Events Start ********************************
-- Only to prevent WARNING messages, but these are only examples/placeholders for dynamically created events/functions
----------------------------------------------------------------
local function emptyFunction()
end
Script.serveFunction("CSK_MultiTCPIPClient.processInstanceNUM", emptyFunction)

Script.serveEvent("CSK_MultiTCPIPClient.OnNewResultNUM", "MultiTCPIPClient_OnNewResultNUM")
Script.serveEvent("CSK_MultiTCPIPClient.OnNewValueToForwardNUM", "MultiTCPIPClient_OnNewValueToForwardNUM")
Script.serveEvent("CSK_MultiTCPIPClient.OnNewValueUpdateNUM", "MultiTCPIPClient_OnNewValueUpdateNUM")
----------------------------------------------------------------

-- Real events
--------------------------------------------------
-- Script.serveEvent("CSK_MultiTCPIPClient.OnNewEvent", "MultiTCPIPClient_OnNewEvent")
Script.serveEvent('CSK_MultiTCPIPClient.OnNewResult', 'MultiTCPIPClient_OnNewResult')

Script.serveEvent('CSK_MultiTCPIPClient.OnNewStatusRegisteredEvent', 'MultiTCPIPClient_OnNewStatusRegisteredEvent')

Script.serveEvent("CSK_MultiTCPIPClient.OnNewStatusLoadParameterOnReboot", "MultiTCPIPClient_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_MultiTCPIPClient.OnPersistentDataModuleAvailable", "MultiTCPIPClient_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_MultiTCPIPClient.OnNewParameterName", "MultiTCPIPClient_OnNewParameterName")

Script.serveEvent("CSK_MultiTCPIPClient.OnNewInstanceList", "MultiTCPIPClient_OnNewInstanceList")
Script.serveEvent("CSK_MultiTCPIPClient.OnNewProcessingParameter", "MultiTCPIPClient_OnNewProcessingParameter")
Script.serveEvent("CSK_MultiTCPIPClient.OnNewSelectedInstance", "MultiTCPIPClient_OnNewSelectedInstance")
Script.serveEvent("CSK_MultiTCPIPClient.OnDataLoadedOnReboot", "MultiTCPIPClient_OnDataLoadedOnReboot")

Script.serveEvent("CSK_MultiTCPIPClient.OnUserLevelOperatorActive", "MultiTCPIPClient_OnUserLevelOperatorActive")
Script.serveEvent("CSK_MultiTCPIPClient.OnUserLevelMaintenanceActive", "MultiTCPIPClient_OnUserLevelMaintenanceActive")
Script.serveEvent("CSK_MultiTCPIPClient.OnUserLevelServiceActive", "MultiTCPIPClient_OnUserLevelServiceActive")
Script.serveEvent("CSK_MultiTCPIPClient.OnUserLevelAdminActive", "MultiTCPIPClient_OnUserLevelAdminActive")

-- ...

-- ************************ UI Events End **********************************

--[[
--- Some internal code docu for local used function
local function functionName()
  -- Do something

end
]]

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

--- Optionally: Only use if needed for extra internal objects -  see also Model
--- Function to sync paramters between instance threads and Controller part of module
---@param instance int Instance new value is coming from
---@param parameter string Name of the paramter to update/sync
---@param value auto Value to update
---@param selectedObject int? Optionally if internal parameter should be used for internal objects
local function handleOnNewValueUpdate(instance, parameter, value, selectedObject)
    multiTCPIPClient_Instances[instance].parameters.internalObject[selectedObject][parameter] = value
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
  -- Script.notifyEvent("MultiTCPIPClient_OnNewEvent", false)

  updateUserLevel()

  Script.notifyEvent('MultiTCPIPClient_OnNewSelectedInstance', selectedInstance)
  Script.notifyEvent("MultiTCPIPClient_OnNewInstanceList", helperFuncs.createStringListBySize(#multiTCPIPClient_Instances))

  Script.notifyEvent("MultiTCPIPClient_OnNewStatusRegisteredEvent", multiTCPIPClient_Instances[selectedInstance].parameters.registeredEvent)

  Script.notifyEvent("MultiTCPIPClient_OnNewStatusLoadParameterOnReboot", multiTCPIPClient_Instances[selectedInstance].parameterLoadOnReboot)
  Script.notifyEvent("MultiTCPIPClient_OnPersistentDataModuleAvailable", multiTCPIPClient_Instances[selectedInstance].persistentModuleAvailable)
  Script.notifyEvent("MultiTCPIPClient_OnNewParameterName", multiTCPIPClient_Instances[selectedInstance].parametersName)

  -- ...
end
Timer.register(tmrMultiTCPIPClient, "OnExpired", handleOnExpiredTmrMultiTCPIPClient)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrMultiTCPIPClient:start()
  return ''
end
Script.serveFunction("CSK_MultiTCPIPClient.pageCalled", pageCalled)

local function setSelectedInstance(instance)
  selectedInstance = instance
  _G.logger:info(nameOfModule .. ": New selected instance = " .. tostring(selectedInstance))
  multiTCPIPClient_Instances[selectedInstance].activeInUI = true
  Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'activeInUI', true)
  tmrMultiTCPIPClient:start()
end
Script.serveFunction("CSK_MultiTCPIPClient.setSelectedInstance", setSelectedInstance)

local function getInstancesAmount ()
  return #multiTCPIPClient_Instances
end
Script.serveFunction("CSK_MultiTCPIPClient.getInstancesAmount", getInstancesAmount)

local function addInstance()
  _G.logger:info(nameOfModule .. ": Add instance")
  table.insert(multiTCPIPClient_Instances, multiTCPIPClient_Model.create(#multiTCPIPClient_Instances+1))
  Script.deregister("CSK_MultiTCPIPClient.OnNewValueToForward" .. tostring(#multiTCPIPClient_Instances) , handleOnNewValueToForward)
  Script.register("CSK_MultiTCPIPClient.OnNewValueToForward" .. tostring(#multiTCPIPClient_Instances) , handleOnNewValueToForward)
  handleOnExpiredTmrMultiTCPIPClient()
end
Script.serveFunction('CSK_MultiTCPIPClient.addInstance', addInstance)

local function resetInstances()
  _G.logger:info(nameOfModule .. ": Reset instances.")
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

local function setRegisterEvent(event)
  multiTCPIPClient_Instances[selectedInstance].parameters.registeredEvent = event
  Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'registeredEvent', event)
end
Script.serveFunction("CSK_MultiTCPIPClient.setRegisterEvent", setRegisterEvent)

--- Function to share process relevant configuration with processing threads
local function updateProcessingParameters()
  Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'activeInUI', true)

  Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'registeredEvent', multiTCPIPClient_Instances[selectedInstance].parameters.registeredEvent)

  --Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'value', multiTCPIPClient_Instances[selectedInstance].parameters.value)

  -- optionally for internal objects...
  --[[
  -- Send config to instances
  local params = helperFuncs.convertTable2Container(multiTCPIPClient_Instances[selectedInstance].parameters.internalObject)
  Container.add(data, 'internalObject', params, 'OBJECT')
  Script.notifyEvent('MultiTCPIPClient_OnNewProcessingParameter', selectedInstance, 'FullSetup', data)
  ]]

end

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:info(nameOfModule .. ": Set parameter name = " .. tostring(name))
  multiTCPIPClient_Instances[selectedInstance].parametersName = name
end
Script.serveFunction("CSK_MultiTCPIPClient.setParameterName", setParameterName)

local function sendParameters()
  if multiTCPIPClient_Instances[selectedInstance].persistentModuleAvailable then
    CSK_PersistentData.addParameter(helperFuncs.convertTable2Container(multiTCPIPClient_Instances[selectedInstance].parameters), multiTCPIPClient_Instances[selectedInstance].parametersName)

    -- Check if CSK_PersistentData version is >= 3.0.0
    if tonumber(string.sub(CSK_PersistentData.getVersion(), 1, 1)) >= 3 then
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiTCPIPClient_Instances[selectedInstance].parametersName, multiTCPIPClient_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance), #multiTCPIPClient_Instances)
    else
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiTCPIPClient_Instances[selectedInstance].parametersName, multiTCPIPClient_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance))
    end
    _G.logger:info(nameOfModule .. ": Send MultiTCPIPClient parameters with name '" .. multiTCPIPClient_Instances[selectedInstance].parametersName .. "' to CSK_PersistentData module.")
    CSK_PersistentData.saveData()
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

      -- If something needs to be configured/activated with new loaded data
      updateProcessingParameters()
      CSK_MultiTCPIPClient.pageCalled()
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
  tmrMultiTCPIPClient:start()
end
Script.serveFunction("CSK_MultiTCPIPClient.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  multiTCPIPClient_Instances[selectedInstance].parameterLoadOnReboot = status
  _G.logger:info(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
end
Script.serveFunction("CSK_MultiTCPIPClient.setLoadOnReboot", setLoadOnReboot)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  _G.logger:info(nameOfModule .. ': Try to initially load parameter from CSK_PersistentData module.')
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
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

return funcs

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************


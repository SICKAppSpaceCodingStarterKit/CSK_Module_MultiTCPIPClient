---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_MultiTCPIPClient'

-- Create kind of "class"
local multiTCPIPClient = {}
multiTCPIPClient.__index = multiTCPIPClient

multiTCPIPClient.styleForUI = 'None' -- Optional parameter to set UI style
multiTCPIPClient.version = Engine.getCurrentAppVersion() -- Version of module

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on UI style change
local function handleOnStyleChanged(theme)
  multiTCPIPClient.styleForUI = theme
  Script.notifyEvent("MultiTCPIPClient_OnNewStatusCSKStyle", multiTCPIPClient.styleForUI)
end
Script.register('CSK_PersistentData.OnNewStatusCSKStyle', handleOnStyleChanged)

--- Function to create new instance
---@param multiTCPIPClientInstanceNo int Number of instance
---@return table[] self Instance of multiTCPIPClient
function multiTCPIPClient.create(multiTCPIPClientInstanceNo)

  local self = {}
  setmetatable(self, multiTCPIPClient)

  self.multiTCPIPClientInstanceNo = multiTCPIPClientInstanceNo -- Number of this instance
  self.multiTCPIPClientInstanceNoString = tostring(self.multiTCPIPClientInstanceNo) -- Number of this instance as string
  self.helperFuncs = require('Communication/MultiTCPIPClient/helper/funcs') -- Load helper functions
  self.hexValues = require('Communication/MultiTCPIPClient/helper/hexValues') -- Hex values

  -- Create parameters etc. for this module instance
  self.activeInUI = false -- Check if this instance is currently active in UI

  -- Check if CSK_PersistentData module can be used if wanted
  self.persistentModuleAvailable = CSK_PersistentData ~= nil or false

  -- Check if CSK_UserManagement module can be used if wanted
  self.userManagementModuleAvailable = CSK_UserManagement ~= nil or false

  -- Default values for persistent data
  -- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
  self.parametersName = 'CSK_MultiTCPIPClient_Parameter' .. self.multiTCPIPClientInstanceNoString -- name of parameter dataset to be used for this module
  self.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

  self.currentConnectionStatus = false -- Status of TCP/IP connection to TCP/IP server
  self.command = '' -- Temp command to preset to transmit
  self.log = {} -- Log of TCP/IP communication
  self.availableInterfaces = Engine.getEnumValues("EthernetInterfaces") -- Available ethernet interfaces on device
  self.interfaceList = self.helperFuncs.createStringListBySimpleTable(self.availableInterfaces) -- List of ethernet interfaces

  -- Parameters to be saved permanently if wanted
  self.parameters = {}
  self.parameters = self.helperFuncs.defaultParameters.getParameters() -- Load default parameters

  -- Instance specific parameters
  if self.availableInterfaces then
    self.parameters.interface = self.availableInterfaces[1] -- e.g. 'ETH1' -- Select first available ethernet interface per default
  else
    self.parameters.interface = nil
  end

  -- Parameters to give to the processing script
  self.multiTCPIPClientProcessingParams = Container.create()
  self.multiTCPIPClientProcessingParams:add('multiTCPIPClientInstanceNumber', multiTCPIPClientInstanceNo, "INT")

  self.multiTCPIPClientProcessingParams:add('currentConnectionStatus', self.currentConnectionStatus, "BOOL")
  self.multiTCPIPClientProcessingParams:add('command', self.command, "STRING")

  self.multiTCPIPClientProcessingParams:add('connectionStatus', self.parameters.connectionStatus, "BOOL")
  self.multiTCPIPClientProcessingParams:add('interface', self.parameters.interface, "STRING")
  self.multiTCPIPClientProcessingParams:add('serverIP', self.parameters.serverIP, "STRING")
  self.multiTCPIPClientProcessingParams:add('port', self.parameters.port, "INT")
  self.multiTCPIPClientProcessingParams:add('rxFrame', self.parameters.rxFrame, "STRING")
  self.multiTCPIPClientProcessingParams:add('txFrame', self.parameters.txFrame, "STRING")

  -- Handle processing
  Script.startScript(self.parameters.processingFile, self.multiTCPIPClientProcessingParams)

  return self
end

return multiTCPIPClient

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************
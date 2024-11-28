-- Block namespace
local BLOCK_NAMESPACE = "MultiTCPIPClient_FC.OnReceive"
local nameOfModule = 'CSK_MultiTCPIPClient'

--*************************************************************
--*************************************************************

-- Required to keep track of already allocated resource
local instanceTable = {}

local function register(handle, _ , callback)

  Container.remove(handle, "CB_Function")
  Container.add(handle, "CB_Function", callback)

  local instance = Container.get(handle, 'Instance')
  local command = Container.get(handle,"Command")
  --print("Command = " .. tostring(command))

  -- Check if amount of instances is valid
  -- if not: add multiple additional instances
  while true do
    local amount = CSK_MultiTCPIPClient.getInstancesAmount()
    if amount < instance then
      CSK_MultiTCPIPClient.addInstance()
    else
      break
    end
  end

  if command ~= '' then
    CSK_MultiTCPIPClient.setSelectedInstance(instance)
    CSK_MultiTCPIPClient.addTriggerEventPair(command, 'OnNewTrigger' .. tostring(instance) .. '_' .. tostring(command))
  end

  local function localCallback()
    local cbFunction = Container.get(handle,"CB_Function")

    if cbFunction ~= nil then
      if command ~= '' then
        Script.callFunction(cbFunction, 'CSK_MultiTCPIPClient.OnNewTrigger' .. tostring(instance) .. '_' .. tostring(command))
      else
        Script.callFunction(cbFunction, 'CSK_MultiTCPIPClient.OnNewData' .. tostring(instance))
      end
    else
      _G.logger:warning(nameOfModule .. ": " .. BLOCK_NAMESPACE .. ".CB_Function missing!")
    end
  end
  Script.register('CSK_FlowConfig.OnNewFlowConfig', localCallback)

  return true
end
Script.serveFunction(BLOCK_NAMESPACE ..".register", register)

--*************************************************************
--*************************************************************

local function create(instance, command)

  local fullInstanceName = tostring(instance)
  if command then
    fullInstanceName = fullInstanceName .. tostring(command)
  end

  -- Check if same instance is already configured
  if instance < 1 or instanceTable[fullInstanceName] ~= nil then
    _G.logger:warning(nameOfModule .. "Instance invalid or already in use, please choose another one")
    return nil
  else
    -- Otherwise create handle and store the restriced resource
    local handle = Container.create()
    instanceTable[fullInstanceName] = fullInstanceName
    Container.add(handle, 'Instance', instance)
    if command then
      Container.add(handle, 'Command', command)
    else
      Container.add(handle, 'Command', '')
    end
    Container.add(handle, "CB_Function", "")
    return handle
  end
end
Script.serveFunction(BLOCK_NAMESPACE .. ".create", create)

--- Function to reset instances if FlowConfig was cleared
local function handleOnClearOldFlow()
  Script.releaseObject(instanceTable)
  instanceTable = {}
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)
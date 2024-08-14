--*****************************************************************
-- Here you will find all the required content to provide specific
-- features of this module via the 'CSK FlowConfig'.
--*****************************************************************

require('Communication.MultiTCPIPClient.FlowConfig.MultiTCPIPClient_OnReceive')
require('Communication.MultiTCPIPClient.FlowConfig.MultiTCPIPClient_Transmit')

-- Reference to the multiTCPIPClient_Instances handle
local multiTCPIPClient_Instances

--- Function to react if FlowConfig was updated
local function handleOnClearOldFlow()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    for i = 1, # multiTCPIPClient_Instances do
      if multiTCPIPClient_Instances[i].parameters.flowConfigPriority then
        CSK_MultiTCPIPClient.clearFlowConfigRelevantConfiguration()
        break
      end
    end
  end
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)

--- Function to get access to the multiTCPIPClient_Instances
---@param handle handle Handle of multiTCPIPClient_Instances object
local function setMultiTCPIPClient_Instances_Handle(handle)
  multiTCPIPClient_Instances = handle
end

return setMultiTCPIPClient_Instances_Handle
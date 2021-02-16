vRPCarthief = {}
vRPCarthief.CurrentRequestId          = 0
vRPCarthief.ServerCallbacks           = {}

vRPCarthief.TriggerServerCallback = function(name, cb, ...)
	vRPCarthief.ServerCallbacks[vRPCarthief.CurrentRequestId] = cb

	TriggerServerEvent('vRPCarthief:triggerServerCallback', name, vRPCarthief.CurrentRequestId, ...)

	if vRPCarthief.CurrentRequestId < 65535 then
		vRPCarthief.CurrentRequestId = vRPCarthief.CurrentRequestId + 1
	else
		vRPCarthief.CurrentRequestId = 0
	end
end

RegisterNetEvent('vRPCarthief:serverCallback')
AddEventHandler('vRPCarthief:serverCallback', function(requestId, ...)
	vRPCarthief.ServerCallbacks[requestId](...)
	vRPCarthief.ServerCallbacks[requestId] = nil
end)
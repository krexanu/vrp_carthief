vRPCarthief={}
vRPCarthief.ServerCallbacks={}


RegisterServerEvent('vRPCarthief:triggerServerCallback')
AddEventHandler('vRPCarthief:triggerServerCallback',function(a,b,...)
    local c=source

    vRPCarthief.TriggerServerCallback(a,requestID,c,function(...)
        TriggerClientEvent('vRPCarthief:serverCallback',c,b,...)end,...)
    end)
        
        
    
vRPCarthief.RegisterServerCallback = function(a,t)
    vRPCarthief.ServerCallbacks[a]=t 
end
                    
vRPCarthief.TriggerServerCallback = function(a,b,source,t,...)
    if vRPCarthief.ServerCallbacks[a]~=nil then 
        vRPCarthief.ServerCallbacks[a](source,t,...)
    else 
        print('TriggerServerCallback => ['..a..'] does not exist')
    end 
end
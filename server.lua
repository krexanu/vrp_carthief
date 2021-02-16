local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")


vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vRP_carthief")
vRPCcarthief = Tunnel.getInterface("vRP_carthief","vRP_carthief")

vRPcarthief = {}
Tunnel.bindInterface("vRP_carthief",vRPcarthief)
Proxy.addInterface("vRP_carthief",vRPcarthief)

-------------------- INSERT INTO DATABASE --------------------   exports.ghmattimysql:execute

AddEventHandler( "playerConnecting", function(name)
	local identifier = GetPlayerIdentifiers(source)[1]
	exports.ghmattimysql:execute("SELECT * FROM carthief WHERE identifier = @identifier", {['@identifier'] = identifier},function(rows)
		if rows then
			exports.ghmattimysql:execute("INSERT INTO carthief (`identifier`, `timeleft`) VALUES (@identifier, @timeleft)",{['@identifier'] = identifier, ['timeleft'] = 0})
			print('/////////////////////////////// loffe_carthief ///////////////////////////////')
			print('Spelaren med steamnamet ' .. name .. ' lades in i databasen "carthief", ' .. name .. 's hexkod är: ' .. identifier)
			print('/////////////////////////////////////////////////////////////////////////')
		end
	end)
end)

-------------------- DATABASE --------------------

RegisterServerEvent('loffe_carthief:updateTime')
AddEventHandler('loffe_carthief:updateTime', function()
	local identifier = GetPlayerIdentifiers(source)[1]
	exports.ghmattimysql:execute('SELECT timeleft FROM carthief WHERE identifier=@identifier',
    {
        ['@identifier'] = identifier
    }, function(timeleft)
		if timeleft ~= 0 then
			local newtime = timeleft - 1
			exports.ghmattimysql:execute("UPDATE carthief SET timeleft=@timeleft WHERE identifier=@identifier", {['@identifier'] = identifier, ['@timeleft'] = newtime})
		end
	end)
end)

RegisterServerEvent('loffe_carthief:questFinished')
AddEventHandler('loffe_carthief:questFinished', function()
	local identifier = GetPlayerIdentifiers(source)[1]
	local xPlayer = vRP.getUserId({source})
	local payment = math.random(Config.MinPayment, Config.MaxPayment) -- vad man får för att göra uppdraget, 50-75 tusen.
	vRP.giveMoney({xPlayer,payment})
	vRPclient.notify(source,{'Ai terminat si ai primit ' .. payment .. ' $','success'})
	exports.ghmattimysql:execute("UPDATE carthief SET timeleft=@timeleft WHERE identifier=@identifier", {['@identifier'] = identifier, ['@timeleft'] = Config.HoursSucess*120}) 
	local weaponRandom = math.random(1, 100)
	if weaponRandom <= Config.ChanceWeapon then
		vRPclient.giveWeapons(player,{{
			['WEAPON_COMBATPISTOL'] = {math.random(50, 150)}
		}})
	end
end)

RegisterServerEvent('loffe_carthief:wait')
AddEventHandler('loffe_carthief:wait', function()
	local identifier = GetPlayerIdentifiers(source)[1]

	exports.ghmattimysql:execute("UPDATE carthief SET timeleft=@timeleft WHERE identifier=@identifier", {['@identifier'] = identifier, ['@timeleft'] = Config.HoursFailure*120}) 
end)

vRPCarthief.RegisterServerCallback('vezijob', function(source, cb)
	local user_id = vRP.getUserId({source})
	local faction = vRP.getUserFaction({user_id})
	if faction == 'Politie' then
		cb(true)
	else
		cb(false)
	end
end)

vRPCarthief.RegisterServerCallback('loffe_carthief:getTimeLeft', function(source, cb)
	local identifier = GetPlayerIdentifiers(source)[1]
	exports.ghmattimysql:execute('SELECT timeleft FROM carthief WHERE identifier=@identifier',
    {
        ['@identifier'] = identifier
    }, function(timeleft)
		cb(timeleft)
	end)
end)

-------------------- POLICE BLIPS --------------------

RegisterServerEvent('loffe_carthief:removeblip')
AddEventHandler('loffe_carthief:removeblip', function()
	local xPlayers = vRP.GetUsers({})
	for i=1, #xPlayers, 1 do
		local xPlayer = vRP.getUserId({xPlayers[i]})
		local faction = vRP.getUserFaction({xPlayer})
		if faction == 'Politie' then
			TriggerClientEvent('loffe_carthief:killblip', xPlayers[i])
		else
			TriggerClientEvent('loffe_carthief:killblip', xPlayers[i]) 
		end
	end
end)

RegisterServerEvent('loffe_carthief:moveblip')
AddEventHandler('loffe_carthief:moveblip', function(position)
	local xPlayers = vRP.GetUsers({})

	-- Remove old one and place a new one
	for i=1, #xPlayers, 1 do
		local xPlayer = vRP.getUserId({xPlayers[i]})
		local faction = vRP.getUserFaction({xPlayer})
		if faction == 'Politie' then
			TriggerClientEvent('loffe_carthief:killblip', xPlayers[i])
		else
			TriggerClientEvent('loffe_carthief:killblip', xPlayers[i]) 
		end
	end

	

	for i=1, #xPlayers, 1 do
		local xPlayer = vRP.getUserId({xPlayers[i]})
		local faction = vRP.getUserFaction({xPlayer})
		if faction == 'Politie' then
			TriggerClientEvent('loffe_carthief:setblip', xPlayers[i], position)
		end
	end
end)

-------------------- START MISSION --------------------

RegisterServerEvent('loffe_carthief:startMission')
AddEventHandler('loffe_carthief:startMission', function(mission)
    local _source    = source
    local identifier = GetPlayerIdentifiers(_source)[1]
	exports.ghmattimysql:execute('SELECT timeleft FROM carthief WHERE identifier=@identifier',
    {
        ['@identifier'] = identifier
    }, function(timeleft)
		if timeleft == 0 then
			if mission == 0 then
				local policeConnected = 0
				local xPlayers = vRP.GetUsers({})
				for i=1, #xPlayers, 1 do
					local xPlayer = vRP.getUserId({xPlayers[i]})
					local faction = vRP.getUserFaction({xPlayer})
					if faction == 'Politie' then
						policeConnected = policeConnected + 1
					end
				end
				if policeConnected >= Config.CopsRequired then
					TriggerClientEvent('loffe_carthief:mission0', _source)
				else
					vRPclient.notify(_source,{'Nu sunt politisti online','error'})
				end
			end
		else
			vRPclient.notify(_source,{'Mai ai de asteptat '..math.ceil(timeleft/120).. ' minute','error'})
		--	sendNotification(_source, _U('play_server') .. math.ceil(timeleft/120) .. _U('until_steal'), 'error', 5500)
			
		end
	end)
end)
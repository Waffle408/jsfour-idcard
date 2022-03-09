local ESX = nil
-- ESX
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Open ID card
RegisterServerEvent('jsfour-idcard:open')
AddEventHandler('jsfour-idcard:open', function(ID, targetID, type)
	local identifier = ESX.GetPlayerFromId(ID).identifier
	local _source 	 = ESX.GetPlayerFromId(targetID).source
	local show       = false

	MySQL.Async.fetchAll('SELECT firstname, lastname, dateofbirth, sex, height FROM users WHERE identifier = @identifier', {['@identifier'] = identifier},
	function (user)
		if (user[1] ~= nil) then
			MySQL.Async.fetchAll('SELECT type FROM user_licenses WHERE owner = @identifier', {['@identifier'] = identifier},
			function (licenses)
				if type ~= nil then
					for i=1, #licenses, 1 do
						if type == 'driver' then
							if licenses[i].type == 'drive' or licenses[i].type == 'drive_bike' or licenses[i].type == 'drive_truck' then
								show = true
							end
						elseif type =='weapon' then
							if licenses[i].type == 'weapon' then
								show = true
							end
						end
					end
				else
					show = true
				end

				if show then

					MySQL.Async.fetchAll('SELECT id FROM users WHERE identifier = @identifier', {['@identifier'] = identifier},
					function (mdtchar)
						print(mdtchar[1].id)
						MySQL.Async.fetchAll('SELECT mugshot_url FROM user_mdt WHERE char_id = @identifier', {['@identifier'] = mdtchar[1].id},
						function (mugurl)
							---table.insert(user, mugurl)
							--user.mug = mugurl
							--print(json.encode(mugurl))
							local array = {
								user = user,
								licenses = licenses,
								mugurl = mugurl
								 
							}
							print(json.encode(array.mugurl))
							TriggerClientEvent('jsfour-idcard:open', _source, array, type)

						end)

					end)
					TriggerClientEvent('jsfour-idcard:open', _source, array, type, mugurl)
				else
					TriggerClientEvent('esx:showNotification', _source, "You don't have that type of license..")
				end
			end)
		end
	end)
end)



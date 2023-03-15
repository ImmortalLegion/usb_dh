-- Информация о скрипте
script_name('«USB Doklad Helper»')																					-- Указываем имя скрипта																							-- Указываем версию скрипта / FINAL
script_author('Marshall Milford | H.Rogge, A.Fawkess')																-- Указываем имя автора

-- Библиотеки
require 'lib.moonloader'
require 'lib.sampfuncs'
local dlstatus = require('moonloader').download_status
local inicfg = require 'inicfg'
local sampev = require "lib.samp.events"

local _, myid
local mynickname

update_state = false

local script_vers = 2
local script_vers_text = "1.02"

local update_url = "https://raw.githubusercontent.com/ImmortalLegion/usb_dh/main/update.ini"
local update_path = getWorkingDirectory() .. "/update.ini"

local script_url = "https://raw.githubusercontent.com/ImmortalLegion/usb_dh/main/usb_dokhelper.lua"
local script_path = thisScript().path
local updateIni = inicfg.load(nil, update_path)

local nicks = {
	 -- Commanders
	 ['Renya_Stoun'] = 'R-S-7',
	 ['Franko_Matizovich'] = 'F-M-95',
	 ['Marshall_Requiem'] = 'M-R-71',
	 -- Senior Operative
	 ['Teddy_Ruiz'] = 'T-R-43',
	 ['Marshall_Milford'] = 'M-M-23',
	 ['Ray_Hoggarth'] = 'R-H-51',
	 -- Operative
	 ['Frederick_Wertheim'] = 'F-W-69',
	 -- Trainee
	 ['Czar_Stolbentsov'] = 'C-S-21',
	 ['Yukio_Matsui'] = 'Y-M-88',
	 ['Looneyz_Kotov'] = 'L-K-34'
}

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end												-- Проверяем загружен ли sampfuncs и SAMP если не загружены - возвращаемся к началу
	while not isSampAvailable() do wait(100) end																	-- Проверяем загружен ли SA-MP

	sampAddChatMessage('{333366} «USB Doklad Helper» {808080}успешно загружен. Версия: ' .. script_vers_text, 0xFFFFFF)				    -- Сообщаем об загрузке скрипта

	sampRegisterChatCommand('dk', cmd_dk)																			-- Регистрация команды
	sampRegisterChatCommand('dn', cmd_dn)                                                         
	sampRegisterChatCommand('kc', cmd_kc)     
	
	sampRegisterChatCommand('spost', cmd_spost)                                                          
	sampRegisterChatCommand('ppost', cmd_ppost)                                                          
	sampRegisterChatCommand('npost', cmd_npost)                                                          
	sampRegisterChatCommand('epost', cmd_epost)      
	
	sampRegisterChatCommand('sdd', cmd_sdd)  
	sampRegisterChatCommand('cdd', cmd_cdd)  
	sampRegisterChatCommand('edd', cmd_edd)  

	sampRegisterChatCommand('dh_info', cmd_dh_info)  

	while not sampIsLocalPlayerSpawned() do wait(0) end																-- Проверяем зашёл ли игрок на сервер

	_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	mynickname = sampGetPlayerNickname(myid)

	downloadUrlToFile(update_url, update_path, function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
			if tonumber(updateIni.info.vers) > script_vers then
				sampAddChatMessage('{333366} USB DH info | {808080}Есть обновление. Новая версия: ' .. updateIni.info.vers_text, 0xFFFFFF)	
				update_state = true
			else
				sampAddChatMessage('{333366} USB DH info | {808080}Обновлений нет. Загружена последняя версия: ' .. script_vers_text, 0xFFFFFF)	
			end
			os.remove(update_path)
		end
	end)

	while true do																									-- Цикл для постоянной работы скрипта
		wait(0)

		if update_state then
		sampAddChatMessage('{333366} USB DH info | {808080Началось скачивание обновления. Скрипт перезагрузится через пару секунд', 0xFFFFFF)
			downloadUrlToFile(script_url, script_path, function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
					sampAddChatMessage('{333366} USB DH info | {808080}Обновление успешно скачано и установлено', 0xFFFFFF)
					thisScript():reload()
				end
			end)
			break
		end
	end
end

function cmd_dk(args)
	local info = {}
	if isCharInAnyCar(PLAYER_PED) then
		if #args ~= 0 then
			local mycar = storeCarCharIsInNoSave(PLAYER_PED)
			for i = 0, 999 do
				if sampIsPlayerConnected(i) then
					local ichar = select(2, sampGetCharHandleBySampPlayerId(i))
					if doesCharExist(ichar) then
						if isCharInAnyCar(ichar) then
							local icar = storeCarCharIsInNoSave(ichar)
							if mycar == icar then
								local nicktoid = sampGetPlayerNickname(i)
								if nicks[nicktoid] ~= nil then
									local call = nicks[nicktoid]
									table.insert(info, call)
								else
									local nick = string.gsub(sampGetPlayerNickname(i), "(%u+)%l+_(%w+)", "%1.%2")
									table.insert(info, nick)
								end
							end
						end
					end
				end
			end
			local mycod = nicks[mynickname]
			if mycod ~= nil then
				if #info > 0 then
					sampProcessChatInput(string.format('/kk %s, 10-%s, %s', mycod, args, table.concat(info,', ')))
				else
					sampProcessChatInput(string.format('/kk %s, 10-%s, solo', mycod, args))
				end
			else 
				sampAddChatMessage('{333366} USB DH info | {808080}Ваш код в таблице сотрудников не обнаружен', 0xFFFFFF)		
				return
			end
		else
			sampAddChatMessage('{333366} USB DH info | {808080}Введите тен-код', 0xFFFFFF)
			return
		end
	else 
		sampAddChatMessage('{333366} USB DH info | {808080}Вы не сидите в автомобиле', 0xFFFFFF)
		return
	end
end

function cmd_dn(args)
	local tmp_nick = sampGetPlayerNickname(args)
	local tmp_codnick = nicks[tmp_nick]
	if #args ~= 0 then
		if tmp_codnick ~= nil then
			sampProcessChatInput(string.format('%s', tmp_codnick))
		else
			sampAddChatMessage('{333366} USB DH info | {808080}Человек в таблице сотрудников не обнаружен', 0xFFFFFF)
			return
		end
	else
		sampAddChatMessage('{333366} USB DH info | {808080}Введите ID', 0xFFFFFF)
		return
	end
end

function cmd_kc(args)
	local mycod = nicks[mynickname]
	if #args ~= 0 then
		if mycod ~= nil then
			sampProcessChatInput(string.format('/kk %s, %s', mycod, args))
		else
			sampAddChatMessage('{333366} USB DH info | {808080}Ваш код в таблице сотрудников не обнаружен', 0xFFFFFF)
			return
		end
	else
		sampAddChatMessage('{333366} USB DH info | {808080}Введите сообщение', 0xFFFFFF)
		return
	end
end

function cmd_spost(args)
	local mycod = nicks[mynickname]
	if #args ~= 0 then
		if mycod ~= nil then
			local h = os.date()
			sampProcessChatInput(string.format('/kk %s, заступил в пост-наряд. Сектор: %s. Время: '..os.date('%H:%M'), mycod, args))
		else
			sampAddChatMessage('{333366} USB DH info | {808080}Ваш код в таблице сотрудников не обнаружен', 0xFFFFFF)
			return
		end
	else
		sampAddChatMessage('{333366} USB DH info | {808080}Введите квадрат', 0xFFFFFF)
		return
	end
end

function cmd_ppost(args)
	local mycod = nicks[mynickname]
	if #args ~= 0 then
		if mycod ~= nil then
			local h = os.date()
			sampProcessChatInput(string.format('/kk %s, пост-наряд. Перемещаюсь в сектор: %s. Время: '..os.date('%H:%M'), mycod, args))
		else
			sampAddChatMessage('{333366} USB DH info | {808080}Ваш код в таблице сотрудников не обнаружен', 0xFFFFFF)
			return
		end
	else
		sampAddChatMessage('{333366} USB DH info | {808080}Введите квадрат', 0xFFFFFF)
		return
	end
end

function cmd_npost(args)
	local mycod = nicks[mynickname]
	if #args ~= 0 then
		if mycod ~= nil then
			local h = os.date()
			sampProcessChatInput(string.format('/kk %s, пост-наряд. Сектор: %s. Время: '..os.date('%H:%M'), mycod, args))
		else
			sampAddChatMessage('{333366} USB DH info | {808080}Ваш код в таблице сотрудников не обнаружен', 0xFFFFFF)
			return
		end
	else
		sampAddChatMessage('{333366} USB DH info | {808080}Введите квадрат', 0xFFFFFF)
		return
	end
end

function cmd_epost(args)
	local mycod = nicks[mynickname]
	if #args ~= 0 then
		if mycod ~= nil then
			local h = os.date()
			sampProcessChatInput(string.format('/kk %s, заканчиваю пост-наряд. Сектор: %s. Время: '..os.date('%H:%M'), mycod, args))
		else
			sampAddChatMessage('{333366} USB DH info | {808080}Ваш код в таблице сотрудников не обнаружен', 0xFFFFFF)
			return
		end
	else
		sampAddChatMessage('{333366} USB DH info | {808080}Введите квадрат', 0xFFFFFF)
		return
	end
end

function cmd_sdd()
	local info = {}
	if isCharInAnyCar(PLAYER_PED) then
		local mycar = storeCarCharIsInNoSave(PLAYER_PED)
		for i = 0, 999 do
			if sampIsPlayerConnected(i) then
				local ichar = select(2, sampGetCharHandleBySampPlayerId(i))
				if doesCharExist(ichar) then
					if isCharInAnyCar(ichar) then
						local icar = storeCarCharIsInNoSave(ichar)
						if mycar == icar then
							local nicktoid = sampGetPlayerNickname(i)
							if nicks[nicktoid] ~= nil then
								local call = nicks[nicktoid]
								table.insert(info, call)
							else
								local nick = string.gsub(sampGetPlayerNickname(i), "(%u+)%l+_(%w+)", "%1.%2")
								table.insert(info, nick)
							end
						end
					end
				end
			end
		end
		local mycod = nicks[mynickname]
		if mycod ~= nil then
			if #info > 0 then
				sampProcessChatInput(string.format('/kk %s, start checking dangerous districts. Working with %s', mycod, table.concat(info,', ')))
			else
				sampProcessChatInput(string.format('/kk %s, start checking dangerous districts. Working solo', mycod, args))
			end
		else 
			sampAddChatMessage('{333366} USB DH info | {808080}Ваш код в таблице сотрудников не обнаружен', 0xFFFFFF)		
			return
		end
	else 
		sampAddChatMessage('{333366} USB DH info | {808080}Вы не сидите в автомобиле', 0xFFFFFF)
		return
	end
end

function cmd_cdd(args)
	local info = {}
	if isCharInAnyCar(PLAYER_PED) then
		if #args ~= 0 then
			local mycar = storeCarCharIsInNoSave(PLAYER_PED)
			for i = 0, 999 do
				if sampIsPlayerConnected(i) then
					local ichar = select(2, sampGetCharHandleBySampPlayerId(i))
					if doesCharExist(ichar) then
						if isCharInAnyCar(ichar) then
							local icar = storeCarCharIsInNoSave(ichar)
							if mycar == icar then
								local nicktoid = sampGetPlayerNickname(i)
								if nicks[nicktoid] ~= nil then
									local call = nicks[nicktoid]
									table.insert(info, call)
								else
									local nick = string.gsub(sampGetPlayerNickname(i), "(%u+)%l+_(%w+)", "%1.%2")
									table.insert(info, nick)
								end
							end
						end
					end
				end
			end
			local mycod = nicks[mynickname]
			if mycod ~= nil then
				if #info > 0 then
					sampProcessChatInput(string.format('/kk %s, checking dangerous districts, %s. Working with %s', mycod, args, table.concat(info,', ')))
				else
					sampProcessChatInput(string.format('/kk %s, checking dangerous districts, %s. Working solo', mycod, args))
				end
			else 
				sampAddChatMessage('{333366} USB DH info | {808080}Ваш код в таблице сотрудников не обнаружен', 0xFFFFFF)		
				return
			end
		else
			sampAddChatMessage('{333366} USB DH info | {808080}Введите информацию по проверке', 0xFFFFFF)
			return
		end
	else 
		sampAddChatMessage('{333366} USB DH info | {808080}Вы не сидите в автомобиле', 0xFFFFFF)
		return
	end
end

function cmd_edd()
	local info = {}
	if isCharInAnyCar(PLAYER_PED) then
		local mycar = storeCarCharIsInNoSave(PLAYER_PED)
		for i = 0, 999 do
			if sampIsPlayerConnected(i) then
				local ichar = select(2, sampGetCharHandleBySampPlayerId(i))
				if doesCharExist(ichar) then
					if isCharInAnyCar(ichar) then
						local icar = storeCarCharIsInNoSave(ichar)
						if mycar == icar then
							local nicktoid = sampGetPlayerNickname(i)
							if nicks[nicktoid] ~= nil then
								local call = nicks[nicktoid]
								table.insert(info, call)
							else
								local nick = string.gsub(sampGetPlayerNickname(i), "(%u+)%l+_(%w+)", "%1.%2")
								table.insert(info, nick)
							end
						end
					end
				end
			end
		end
		local mycod = nicks[mynickname]
		if mycod ~= nil then
			if #info > 0 then
				sampProcessChatInput(string.format('/kk %s, end checking dangerous districts. Working with %s', mycod, table.concat(info,', ')))
			else
				sampProcessChatInput(string.format('/kk %s, end checking dangerous districts. Working solo', mycod, args))
			end
		else 
			sampAddChatMessage('{333366} USB DH info | {808080}Ваш код в таблице сотрудников не обнаружен', 0xFFFFFF)		
			return
		end
	else 
		sampAddChatMessage('{333366} USB DH info | {808080}Вы не сидите в автомобиле', 0xFFFFFF)
		return
	end
end

function cmd_dh_info()
	sampAddChatMessage('{333366} USB DH info | {808080}Список команд USB Doklad Helper', 0xFFFFFF)	
	sampAddChatMessage('{333366} USB DH info | {9999CC}/dk - {808080}стандартный доклад с тен-кодом', 0xFFFFFF)	
	sampAddChatMessage('{333366} USB DH info | {9999CC}/dn - {808080}вывод кода сотрудника в чат', 0xFFFFFF)	
	sampAddChatMessage('{333366} USB DH info | {9999CC}/kc - {808080}сообщение в /kk с личным кодом', 0xFFFFFF)	
	sampAddChatMessage('{333366} USB DH info | {9999CC}/spost - {808080}начало пост-наряда', 0xFFFFFF)	
	sampAddChatMessage('{333366} USB DH info | {9999CC}/ppost - {808080}перемещение в пост-наряде в другой сектор', 0xFFFFFF)	
	sampAddChatMessage('{333366} USB DH info | {9999CC}/npost - {808080}доклад в пост-наряде', 0xFFFFFF)	
	sampAddChatMessage('{333366} USB DH info | {9999CC}/epost - {808080}конец пост-наряда', 0xFFFFFF)	
	sampAddChatMessage('{333366} USB DH info | {9999CC}/sdd - {808080}начало проверки опасных районов', 0xFFFFFF)	
	sampAddChatMessage('{333366} USB DH info | {9999CC}/cdd - {808080}доклад о проверке опасных районов', 0xFFFFFF)	
	sampAddChatMessage('{333366} USB DH info | {9999CC}/edd - {808080}конец проверки опасных районов', 0xFFFFFF)	
end

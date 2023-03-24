-- ���������� � �������
script_name('�USB Doklad Helper�')																					-- ��������� ��� �������																							-- ��������� ������ ������� / FINAL
script_author('Marshall Milford | H.Rogge, A.Fawkess')																-- ��������� ��� ������

-- ����������
require 'lib.moonloader'
require 'lib.sampfuncs'
local dlstatus = require('moonloader').download_status
local inicfg = require 'inicfg'
local sampev = require "lib.samp.events"

local script_vers = 15
local script_vers_text = "4.15"

local _, myid
local mynickname


local kktag = true
local nicks = {}

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end												-- ��������� �������� �� sampfuncs � SAMP ���� �� ��������� - ������������ � ������
	while not isSampAvailable() do wait(100) end																	-- ��������� �������� �� SA-MP

	local txt = getWorkingDirectory() .. '/usb_dokhelper_members.txt'

	access = false
	update_txt = true
	del_txt = false
	update_state = false

	local update_url = "https://raw.githubusercontent.com/ImmortalLegion/usb_dh/main/update.ini"
	local update_path = getWorkingDirectory() .. "/usb_dokhelper_update.ini"

	local script_url = "https://raw.githubusercontent.com/ImmortalLegion/usb_dh/main/usb_dokhelper.lua"
	local script_path = thisScript().path

	while not sampIsLocalPlayerSpawned() do wait(0) end																-- ��������� ����� �� ����� �� ������

	_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	mynickname = sampGetPlayerNickname(myid)

	downloadUrlToFile(update_url, update_path, function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
			updateIni = inicfg.load(nil, update_path)
			if tonumber(updateIni.info.vers) > script_vers then
				update_state = true
			end
		end
	end)

	while true do																									-- ���� ��� ���������� ������ �������
		wait(0)
		if update_txt then
			wait(10000)
			os.remove(txt)
			downloadUrlToFile('https://docs.google.com/spreadsheets/d/e/2PACX-1vSM_ClmsCK3HS3nqRhoVbtxGKU6ddGRk-134z4DDuEccmNDRHXODMxZvkb4O7pRqO8ZEq7tTUKX6Td2/pub?output=tsv', txt, function (id, status, p1, p2)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					update_txt = false
					local file = io.open(txt, 'r')
					local i = 0

					if update_txt == false then
						if file ~= nil then
							for line in io.lines(txt) do
								i = i + 1	
								local name, sur, f, s, num = string.match(line, '(%a+)_(%a+)	(%a)-(%a)-(%d+)')
								x = name .. '_' .. sur
								y = f .. '-' .. s .. '-' .. num
								nicks[x] = y
							end
							file:close()
							local mycod = nicks[mynickname]
							if mycod ~= nil then
								sampAddChatMessage('{333366} USB DH info | {808080}� ��� ��������� ���������� ������ �����������', 0xFFFFFF)	 
								access = true
							else
								sampAddChatMessage('{333366} �USB Doklad Helper� {808080}�� ��������', 0xFFFFFF)		
								sampAddChatMessage('{333366} USB DH info | {808080}�� �� ���������� � ���� ����������� ���. ���������� � ����������', 0xFFFFFF)	
								del_txt = true
							end
						else 
							sampAddChatMessage('{333366} USB DH info | {808080}�������� � ����������� �����. ���������� � ������������', 0xFFFFFF)
							del_txt = true
						end
						if del_txt then
							os.remove(txt)
						end
						if access then
							sampAddChatMessage('{333366} �USB Doklad Helper� {808080}������� ��������. ������: ' .. script_vers_text, 0xFFFFFF)				  

							sampRegisterChatCommand('dk', cmd_dk)																			-- ����������� �������
							sampRegisterChatCommand('dn', cmd_dn)                                                         
							sampRegisterChatCommand('kn', cmd_kn)                                                         
							sampRegisterChatCommand('kc', cmd_kc)     
	   
							sampRegisterChatCommand('post', cmd_post)      
	
							sampRegisterChatCommand('cdd', cmd_cdd)  

							sampRegisterChatCommand('dhinfo', cmd_dhinfo)  
						end
					end
					
				end
			end)
			wait(2000)
			if update_state and access then
				sampAddChatMessage('{333366} USB DH info | {808080}���� ����������. ����� ������: ' .. updateIni.info.vers_text, 0xFFFFFF)	
				sampAddChatMessage('{333366} USB DH info | {808080}�������� ���������� ����������. ������ �������������� ����� ���� ������', 0xFFFFFF)
				downloadUrlToFile(script_url, script_path, function(id, status)
					if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
						sampAddChatMessage('{333366} USB DH info | {808080}���������� ������� ������� � �����������', 0xFFFFFF)
						thisScript():reload()
					end
				end)
			else
				sampAddChatMessage('{333366} USB DH info | {808080}���������� ���. ��������� ��������� ������: ' .. script_vers_text, 0xFFFFFF)	
			end
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
				if tonumber(args) then
					if #info > 0 then
						sampProcessChatInput(string.format('/kk %s, 10-%s, %s', mycod, args, table.concat(info,', ')))
					else
						sampProcessChatInput(string.format('/kk %s, 10-%s, solo', mycod, args))
					end
				else
					if #info > 0 then
						sampProcessChatInput(string.format('/kk %s, %s, %s', mycod, args, table.concat(info,', ')))
					else
						sampProcessChatInput(string.format('/kk %s, %s, solo', mycod, args))
					end
				end
			else 
				sampAddChatMessage('{333366} USB DH info | {808080}��� ��� � ������� ����������� �� ���������', 0xFFFFFF)		
				return
			end
		else
			sampAddChatMessage('{333366} USB DH info | {808080}������� ���-��� ��� ������', 0xFFFFFF)
			return
		end
	else 
		sampAddChatMessage('{333366} USB DH info | {808080}�� �� ������ � ����������', 0xFFFFFF)
		return
	end
end

function cmd_kn(args)
	local tmp_nick = sampGetPlayerNickname(args)
	local tmp_codnick = nicks[tmp_nick]
	if #args ~= 0 then
		if tmp_codnick ~= nil then
			sampAddChatMessage('{333366} USB DH info | {808080}' ..tmp_nick.. ' ����� ��� - ' ..tmp_codnick, 0xFFFFFF)
		else
			sampAddChatMessage('{333366} USB DH info | {808080}������� � ������� ����������� �� ���������', 0xFFFFFF)
			return
		end
	else
		sampAddChatMessage('{333366} USB DH info | {808080}������� ID', 0xFFFFFF)
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
			sampAddChatMessage('{333366} USB DH info | {808080}������� � ������� ����������� �� ���������', 0xFFFFFF)
			return
		end
	else
		sampAddChatMessage('{333366} USB DH info | {808080}������� ID', 0xFFFFFF)
		return
	end
end

function cmd_kc(args)
	local mycod = nicks[mynickname]
	if #args ~= 0 then
		if mycod ~= nil then
			sampProcessChatInput(string.format('/kk %s, %s', mycod, args))
		else
			sampAddChatMessage('{333366} USB DH info | {808080}��� ��� � ������� ����������� �� ���������', 0xFFFFFF)
			return
		end
	else
		sampAddChatMessage('{333366} USB DH info | {808080}������� ���������', 0xFFFFFF)
		return
	end
end

function cmd_post(args)
	arg1, arg2 = string.match(args, "(.+) (.+)")
	local mycod = nicks[mynickname]
	if arg1 == nil or arg1 == '' then
		sampAddChatMessage('{333366} USB DH info | {808080}�� ����������� ����� ���������, �������� /dh_info', 0xFFFFFF)
	else
		if mycod ~= nil then
			local h = os.date()
			if arg1 == 's' then
				sampProcessChatInput(string.format('/kk %s, �������� � ����-�����. ������: %s. �����: '..os.date('%H:%M'), mycod, arg2))
			elseif arg1 == 'p' then
				sampProcessChatInput(string.format('/kk %s, ����-�����. ����������� � ������: %s. �����: '..os.date('%H:%M'), mycod, arg2))
			elseif arg1 == 'd' then
				sampProcessChatInput(string.format('/kk %s, ����-�����. ������: %s. �����: '..os.date('%H:%M'), mycod, arg2))
			elseif arg1 == 'e' then
				sampProcessChatInput(string.format('/kk %s, ���������� ����-�����. ������: %s. �����: '..os.date('%H:%M'), mycod, arg2))
			else 
				sampAddChatMessage('{333366} USB DH info | {808080}�� ����� ������������ �����������', 0xFFFFFF)
				return
			end
		else
			sampAddChatMessage('{333366} USB DH info | {808080}��� ��� � ������� ����������� �� ���������', 0xFFFFFF)
			return
		end
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
				if args == 's' then
					if #info > 0 then
						sampProcessChatInput(string.format('/kk %s, start checking dangerous districts. Working with %s', mycod, table.concat(info,', ')))
					else
						sampProcessChatInput(string.format('/kk %s, start checking dangerous districts. Working solo', mycod, args))
					end
				elseif args == 'e' then
					if #info > 0 then
						sampProcessChatInput(string.format('/kk %s, end checking dangerous districts. Working with %s', mycod, table.concat(info,', ')))
					else
						sampProcessChatInput(string.format('/kk %s, end checking dangerous districts. Working solo', mycod, args))
					end
				else
					if #info > 0 then
						sampProcessChatInput(string.format('/kk %s, checking dangerous districts, %s. Working with %s', mycod, args, table.concat(info,', ')))
					else
						sampProcessChatInput(string.format('/kk %s, checking dangerous districts, %s. Working solo', mycod, args))
					end
				end
			else 
				sampAddChatMessage('{333366} USB DH info | {808080}��� ��� � ������� ����������� �� ���������', 0xFFFFFF)		
				return
			end
		else
			sampAddChatMessage('{333366} USB DH info | {808080}������� ����������� ��� ���������� � ��������', 0xFFFFFF)
			return
		end
	else 
		sampAddChatMessage('{333366} USB DH info | {808080}�� �� ������ � ����������', 0xFFFFFF)
		return
	end
end

function cmd_dhinfo()
	sampAddChatMessage('{333366} USB DH info | {808080}������ ������ USB Doklad Helper. ������: ' ..script_vers_text, 0xFFFFFF)	
	sampAddChatMessage('{333366} USB DH info | {9999CC}/dk - {808080}����������� ������ � ���-����� ��� ���', 0xFFFFFF)	
	sampAddChatMessage('{333366} USB DH info | {9999CC}/dn - {808080}����� ���� ���������� � ���', 0xFFFFFF)	
	sampAddChatMessage('{333366} USB DH info | {9999CC}/kn - {808080}����� ���� ���������� � ���, ������� ������ ������ ��', 0xFFFFFF)	
	sampAddChatMessage('{333366} USB DH info | {9999CC}/kc - {808080}��������� � /kk � ������ �����', 0xFFFFFF)	
	sampAddChatMessage('{333366} USB DH info | {9999CC}/post [s, p, d, e] [kv] - {808080}s - �����, p - �����������, d - ������, e - �����, kv - �������', 0xFFFFFF)	
	sampAddChatMessage('{333366} USB DH info | {9999CC}/cdd [s, e, mes] - {808080}s - ����� ��������, e - �����, mes - ��������� � ��������', 0xFFFFFF)	
end
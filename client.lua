--[[RegisterCommand("gotoWP", function(source, args)
  Citizen.CreateThread(function()
    local entity = PlayerPedId()
    if IsPedInAnyVehicle(entity, false) then
      entity = GetVehiclePedIsUsing(entity)
    end
    local success = false
    local blipFound = false
    local blipIterator = GetBlipInfoIdIterator()
    local blip = GetFirstBlipInfoId(8)

    while DoesBlipExist(blip) do
      if GetBlipInfoIdType(blip) == 4 then
        cx, cy, cz = table.unpack(Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ReturnResultAnyway(), Citizen.ResultAsVector())) --GetBlipInfoIdCoord(blip)
        blipFound = true
        break
      end
      blip = GetNextBlipInfoId(blipIterator)
    end

    if blipFound then
      DoScreenFadeOut(250)
      while IsScreenFadedOut() do
        Citizen.Wait(250)
        
      end
      local groundFound = false
      local yaw = GetEntityHeading(entity)
      
      for i = 0, 1000, 1 do
        SetEntityCoordsNoOffset(entity, cx, cy, ToFloat(i), false, false, false)
        SetEntityRotation(entity, 0, 0, 0, 0 ,0)
        SetEntityHeading(entity, yaw)
        SetGameplayCamRelativeHeading(0)
        Citizen.Wait(0)
        --groundFound = true
        if GetGroundZFor_3dCoord(cx, cy, ToFloat(i), cz, false) then --GetGroundZFor3dCoord(cx, cy, i, 0, 0) GetGroundZFor_3dCoord(cx, cy, i)
          cz = ToFloat(i)
          groundFound = true
          break
        end
      end
      if not groundFound then
        cz = -300.0
      end
      success = true
    end

    if success then
      SetEntityCoordsNoOffset(entity, cx, cy, cz, false, false, true)
      SetGameplayCamRelativeHeading(0)
      if IsPedSittingInAnyVehicle(PlayerPedId()) then
        if GetPedInVehicleSeat(GetVehiclePedIsUsing(PlayerPedId()), -1) == PlayerPedId() then
          SetVehicleOnGroundProperly(GetVehiclePedIsUsing(PlayerPedId()))
        end
      end
      DoScreenFadeIn(250)
    end
  end)
end)]]


local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
}

ESX              = nil
local isMissionRunning = false
local componentCollected = 0
local readytoGetReward = false

local myblip

local npcBlip = {}

AddEventHandler('esx_duty:hasEnteredMarker', function (zone)
    if zone ~= nil then
      CurrentAction     = 'onoff'
      CurrentActionMsg  = "Press E to start the mission"
    end
    print("weaponCrafting :-> entered marker")
  end)
  
AddEventHandler('esx_duty:hasExitedMarker', function (zone)
    CurrentAction = nil
    print("weaponCrafting :-> exit marker")
end)
  


Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(100)
	end
end)

Citizen.CreateThread(function()
    RequestModel(GetHashKey("a_m_y_business_03"))
    while not HasModelLoaded(GetHashKey("a_m_y_business_03")) do
        Wait(1)
    end
    
    for _, item in pairs(Config.NPC) do
        local npc = CreatePed(4, 0xA1435105, item.Pos.x, item.Pos.y, item.Pos.z, item.Pos.heading, false, true)
        
        SetEntityHeading(npc, item.Pos.heading)
        FreezeEntityPosition(npc, true)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        TaskStartScenarioInPlace(npc, "WORLD_HUMAN_SMOKING", 0, false)
        npcBlip[_] = AddBlipForCoord(item.Pos.x, item.Pos.y, item.Pos.z)
        SetBlipSprite(npcBlip[_], 150)
        SetBlipDisplay(npcBlip[_], 4)
        SetBlipScale(npcBlip[_], 1.0)
        SetBlipColour(npcBlip[_], 5)
        SetBlipAsShortRange(npcBlip[_], true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Weapon Crafter")
        EndTextCommandSetBlipName(npcBlip[_])
    end
end)

Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(1)

        local playerPed = GetPlayerPed(-1)

        if CurrentAction ~= nil and not isMissionRunning then
          if readytoGetReward then
            SetTextComponentFormat('STRING')
            AddTextComponentString("Press E to get your reward")
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)
            if IsControlJustPressed(0, Keys['E']) then
                getReward()
            end
          else
            SetTextComponentFormat('STRING')
            AddTextComponentString(CurrentActionMsg)
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)
            if IsControlJustPressed(0, Keys['E']) then
                startMission()
            end
          end
        elseif CurrentAction ~= nil then
          SetTextComponentFormat('STRING')
          AddTextComponentString("Please collect all of components !")
          DisplayHelpTextFromStringLabel(0, 0, 1, -1)
        end

    end       
end)

Citizen.CreateThread(function ()
    while true do
      Wait(0)
  
      local coords = GetEntityCoords(GetPlayerPed(-1))

      for k,v in pairs(Config.NPC) do
        if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
          DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
         
        end
      end
    end
  end)
  

  Citizen.CreateThread(function ()
    while true do
      Wait(0)
      
      local coords      = GetEntityCoords(GetPlayerPed(-1))
      local isInMarker  = false
      local currentZone = nil
      for k,v in pairs(Config.NPC) do
        if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
          isInMarker  = true
          currentZone = k
        end
      end
  
      if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
        HasAlreadyEnteredMarker = true
        LastZone                = currentZone
        TriggerEvent('esx_duty:hasEnteredMarker', currentZone)
      end
  
      if not isInMarker and HasAlreadyEnteredMarker then
        HasAlreadyEnteredMarker = false
        TriggerEvent('esx_duty:hasExitedMarker', LastZone)
      end
    end
  end)

function playAnim()
  local pid = PlayerPedId()
  RequestAnimDict("amb@prop_human_bum_bin@idle_b")
  while (not HasAnimDictLoaded("amb@prop_human_bum_bin@idle_b")) do Citizen.Wait(0) end
    TaskPlayAnim(pid,"amb@prop_human_bum_bin@idle_b","idle_d",100.0, 200.0, 0.3, 120, 0.2, 0, 0, 0)
    Wait(750)
    StopAnimTask(pid, "amb@prop_human_bum_bin@idle_b","idle_d", 1.0)
end


function startMission()
  print("weaponCrafting :-> mission start!")
  isMissionRunning = true
  local blips = {}
  for k,v in pairs(Config.Pos) do
      --print(k,v)
      local tempTable = {}
      for ki,va in pairs(v) do
          --print(ki,va.x)
          tempTable = {x = va.x, y = va.y , z = va.z}
          table.insert(blips,tempTable)
      end
  end
  Citizen.CreateThread(function()
      local tempBlips = blips
      local useBlips = {}
      local myRandom
      local nBlip = #tempBlips
      for i = 1 , Config.Quantity , 1 do
        nBlip = #tempBlips
        math.randomseed(GetGameTimer())
        myRandom = math.random(1,nBlip)
        --print("random : "..myRandom)
        table.insert(useBlips,tempBlips[myRandom])
        table.remove(tempBlips,myRandom)
        --print(#tempBlips)
      end
      local nowOP = 1
      local callbackSuccess = false
      ESX.TriggerServerCallback('weaponCrafting:getItem',function(myCompo)
        if myCompo > 0 then
          print("callback completed -> "..myCompo)
          nowOP = myCompo+1
          if myCompo >= Config.Quantity then
            print("Ready to get reward")
            isMissionRunning = false
            readytoGetReward = true
          end
        end
        callbackSuccess = true
      end)
      while not callbackSuccess do
        print("Wait for callback")
        Citizen.Wait(10)
      end
      if isMissionRunning then 
        print("First blip created!")
        createBlip(useBlips[nowOP])  
      end 
      local mytext = "Component collected "..tostring(nowOP-1).."/"..tostring(#useBlips)
      --[[TriggerEvent("pNotify:SendNotification",{
        text = mytext, 
        type = "success", 
        timeout = 5000,
        layout = "centerLeft",
        queue = "left"
      })]]
      while isMissionRunning do
          --createText(mytext)
          
          if isInArea(useBlips[nowOP]) and nowOP <= #useBlips then
            SetTextComponentFormat('STRING')
            AddTextComponentString("Press E to collect component")
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)
            if IsControlJustPressed(0, Keys['E']) then
              print("Component collected -> # "..nowOP)
              playAnim()
              mytext = "Component collected "..tostring(nowOP).."/"..tostring(#useBlips)
              --creatText(mytext)
              TriggerEvent("pNotify:SendNotification",{
                text = mytext, 
                type = "success", 
                timeout = 5000,
                layout = "centerLeft",
                queue = "left"
              })
              nowOP = nowOP + 1
              TriggerServerEvent("weaponCrafting:giveCompo")
              RemoveBlip(myblip)
              if useBlips[nowOP] then
                createBlip(useBlips[nowOP])
              end
            end
          end
          
          if nowOP > #useBlips  then
            isMissionRunning = false
          end
          Wait(1)
      end
      if nowOP > #useBlips  then
          print("Finished")
          readytoGetReward = true
      end
  end)

end

function isInArea(Pos)
  local coords      = GetEntityCoords(GetPlayerPed(-1))
  if GetDistanceBetweenCoords(coords, Pos.x, Pos.y, Pos.z, true) < 5 then
    return true
  end
  return false
end

function createBlip(info)
  myblip = AddBlipForCoord(info.x, info.y, info.z)
  SetBlipSprite(myblip, 150)
  SetBlipDisplay(myblip, 4)
  SetBlipScale(myblip, 1.0)
  SetBlipColour(myblip, 5)
  SetBlipAsShortRange(myblip, true)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString("Weapon Component Collect Area")
  EndTextCommandSetBlipName(myblip)
end

function createText(text)
  SetTextFont(0)
  SetTextProportional(1)
  SetTextScale(0.30, 0.30)
  SetTextColour(255, 255, 255, 255)
  SetTextDropshadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextRightJustify(true)
  SetTextEntry("STRING")
  SetTextWrap(0.0,0.97)
  AddTextComponentString(text)
  DrawText(0.05, 0.75)
end

function getReward()
  math.randomseed(GetGameTimer())
  TriggerServerEvent("weaponCrafting:getReward",math.random(1,100000))
  readytoGetReward = false
  print("weaponCrafting :-> Successfully Crafted!")
end
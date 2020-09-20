# ECU Autopilot
Author: [Deadrank](https://dualuniverselualibrary.page.link/deadrank)
Type: ECU Autoconfig replacement

## Description


## Requirements
Element Code: Emergency Controller (ECU)
Link Slot Naming:
* No link slots needed


## Instructions
1. Right Click ECU and Select "Run default autoconfigure > (Pilot) Flying Construct
2. Add the following **to the top** of UNIT > START()
```lua
--Unit>Start()--
cruiseAltitude = 300 --export
rAngle = 0 --export
maxPitch = 25 --export

--Custom Widgets--
local panel = system.createWidgetPanel("Cruise Selections")
--Cruise Altitude
local cruiseAltWidget
cruiseAltWidget = system.createWidget(panel, "text")
cruiseAltJson = json.encode ({ text = "Cruise Altitude: "})
cruiseAltData = system.createData(cruiseAltJson)
system.addDataToWidget(cruiseAltData, cruiseAltWidget)
--Cruise Heading
local cruiseHeadWidget
cruiseHeadWidget = system.createWidget(panel, "text")
cruiseHeadJson = json.encode ({ text = "Cruise Heading: "})
cruiseHeadData = system.createData(cruiseHeadJson)
system.addDataToWidget(cruiseHeadData, cruiseHeadWidget)
--Cruise Speed
local cruiseHeadWidget
cruiseSpeedWidget = system.createWidget(panel, "text")
cruiseSpeedJson = json.encode ({ text = "Cruise Speed: "})
cruiseSpeedData = system.createData(cruiseSpeedJson)
system.addDataToWidget(cruiseSpeedData, cruiseSpeedWidget)
--END CUSTOM WIDGETS--

worldSpeed = vec3(core.getWorldVelocity())
constSpeed = vec3(core.getVelocity())

--Get initial yaw--
local yaw
local worldVertical = vec3(core.getWorldVertical())
local shipForward = vec3(vec3(core.getConstructWorldOrientationForward()):project_on_plane(worldVertical)):normalize()
local shipRight = vec3(vec3(core.getConstructWorldOrientationRight()):project_on_plane(worldVertical)):normalize()
local shipUp = vec3(core.getConstructWorldOrientationUp())
local north = vec3(vec3(0,0,1):project_on_plane(worldVertical)):normalize()
local angleUp = shipUp:dot(worldVertical)
if angleUp > 0 then shipRight = -shipRight end
local angleForward = math.acos(shipForward:dot(north))*constants.rad2deg
local angleRight = math.acos(shipRight:dot(north))*constants.rad2deg
if angleRight < 90 then -- facing west
	yaw = 180 - angleForward
else
	yaw = angleForward - 180
end
targetHeading = yaw + 180
if vec3(core.getWorldVelocity()):len()*3.6 > 50 then
	targetSpeed = vec3(core.getWorldVelocity()):len()*3.6
else
    targetSpeed = 0
end
```

3. In UNIT > START() **locate** line:
```lua
-- Proxy array to access auto-plugged slots programmatically
```

4. Add the following code **directly above** the line from step 5:
```lua
_autoconf.updateCategoryPanel = function(elements, size, title, type, widgetPerData)
	for i = 1, size do
		local data = elements[i].getData()
		system.updateData(elements[i].getDataId(), dJson)
	end
end
```

5. In UNIT > START() **comment out** the following line (add two -- to the beginning of the line):
```lua
Nav.axisCommandManager:setupCustomTargetSpeedRanges(axisCommandId.longitudinal, {1000, 5000, 10000, 20000, 30000})
```

6. Move to the SYSTEM slot and remove all filters **__except__** the following:
* UPDATE()
* START()
* FLUSH()

7. **Replace the entire contents** of SYSTEM > START() with the following:
```lua
function getYaw()
  local worldVertical = vec3(core.getWorldVertical())
  local shipForward = vec3(vec3(core.getConstructWorldOrientationForward()):project_on_plane(worldVertical)):normalize()
  local shipRight = vec3(vec3(core.getConstructWorldOrientationRight()):project_on_plane(worldVertical)):normalize()
  local shipUp = vec3(core.getConstructWorldOrientationUp())
  local north = vec3(vec3(0,0,1):project_on_plane(worldVertical)):normalize()
  local angleUp = shipUp:dot(worldVertical)
  if angleUp > 0 then shipRight = -shipRight end
  local angleForward = math.acos(shipForward:dot(north))*constants.rad2deg
  local angleRight = math.acos(shipRight:dot(north))*constants.rad2deg
  if angleRight < 90 then -- facing west
    return 180 - angleForward
  else
    return angleForward - 180
  end
end


function cruiseAdjust(tAltitude,mPitch)
	local wForward = vec3(core.getConstructWorldOrientationForward())
	local wVertical = vec3(core.getWorldVertical())
	local tolerance = 50
	local cPitch
    if core.getAltitude() >= tAltitude + tolerance/5 then
		cPitch = -math.asin(wForward:dot(wVertical)) * constants.rad2deg + (mPitch * .01)
	end
    if core.getAltitude() <= tAltitude - tolerance/5 then
		cPitch = -math.asin(wForward:dot(wVertical)) * constants.rad2deg - (mPitch * .01)
	end
	
    if core.getAltitude() >= tAltitude + tolerance/2 then
		cPitch = -math.asin(wForward:dot(wVertical)) * constants.rad2deg + (mPitch * .5)
	end
    if core.getAltitude() <= tAltitude - tolerance/2 then
		cPitch = -math.asin(wForward:dot(wVertical)) * constants.rad2deg - (mPitch * .5)
	end
	
	if core.getAltitude() >= tAltitude + tolerance then
		cPitch = -math.asin(wForward:dot(wVertical)) * constants.rad2deg + (mPitch)
	end
    if core.getAltitude() <= tAltitude - tolerance then
		cPitch = -math.asin(wForward:dot(wVertical)) * constants.rad2deg - (mPitch)
	end
	
    if core.getAltitude() < tAltitude + tolerance/5 and core.getAltitude() > tAltitude - tolerance/5 then
		cPitch = -math.asin(wForward:dot(wVertical)) * constants.rad2deg
	end
	return cPitch
end
```

8. **Replace the entire contents** of SYSTEM > UPDATE() with the following:
```lua
--CUSTOM WIDGETS--
cruiseAltJson = json.encode ({ text = "Cruise Altitude: " .. tostring(cruiseAltitude)})
system.updateData(cruiseAltData, cruiseAltJson)

cruiseHeadJson = json.encode ({ text = "Cruise Heading: " .. tostring(targetHeading)})
system.updateData(cruiseHeadData, cruiseHeadJson)

cruiseSpeedJson = json.encode ({ text = "Cruise Speed: " .. tostring(targetSpeed)})
system.updateData(cruiseSpeedData, cruiseSpeedJson)

--Widget Updates
_autoconf.updateCategoryPanel(weapon, weapon_size, "Weapons", "weapon", true)
_autoconf.updateCategoryPanel(radar, radar_size, "Periscope", "periscope")
placeRadar = true
if atmofueltank_size > 0 then
    _autoconf.updateCategoryPanel(atmofueltank, atmofueltank_size, "Atmo Fuel", "fuel_container")
    if placeRadar then
        _autoconf.updateCategoryPanel(radar, radar_size, "Radar", "radar")
        placeRadar = false
    end
end
if spacefueltank_size > 0 then
    _autoconf.updateCategoryPanel(spacefueltank, spacefueltank_size, "Space Fuel", "fuel_container")
    if placeRadar then
        _autoconf.updateCategoryPanel(radar, radar_size, "Radar", "radar")
        placeRadar = false
    end
end
_autoconf.updateCategoryPanel(rocketfueltank, rocketfueltank_size, "Rocket Fuel", "fuel_container")
if placeRadar then -- We either have only rockets or no fuel tanks at all, uncommon for usual vessels
    _autoconf.updateCategoryPanel(radar, radar_size, "Radar", "radar")
    placeRadar = false
end
```

9. **Replace the entire contents** of SYSTEM > FLUSH() with the following:
```lua
local power = 5
local worldUp = vec3(core.getConstructWorldOrientationUp())
local worldForward = vec3(core.getConstructWorldOrientationForward())
local worldRight = vec3(core.getConstructWorldOrientationRight())
local worldVertical = vec3(core.getWorldVertical())
worldSpeed = vec3(core.getWorldVelocity())
constSpeed = vec3(core.getVelocity())

if (pitchPID == nil) then
	pitchPID = pid.new(0.2, 0, 10)
	rollPID = pid.new(0.2, 0, 10)
	yawPID = pid.new(0.01, 0, 5)
	speedPID = pid.new(2, 0, 10)
end

------------------Adjustments--------------------
--pitchAdjust
currentPitch = cruiseAdjust(cruiseAltitude,maxPitch)
pitchPID:inject(-currentPitch)
pitchAdjust = pitchPID:get() * worldRight

--rollAdjust
currentRoll = getRoll(worldVertical, worldForward, worldRight)
rollPID:inject(rAngle-currentRoll)
rollAdjust = rollPID:get() * worldForward

--yawAdjust
--(coordTarget - constructPos):angle_between(constructWorldForward) 
currentHeading = getYaw()

if math.abs(currentHeading - targetHeading) < 180 then
	yawPID:inject(-(currentHeading - targetHeading))
else
	yawPID:inject(-(targetHeading - currentHeading))
end

yawAdjust = yawPID:get() * worldUp
--------------------------------------------------------------

angularAcceleration = rollAdjust + pitchAdjust + yawAdjust

Nav:setEngineCommand('torque', vec3(), angularAcceleration)

-----Thrust/Speed------
speedDif = targetSpeed - (worldSpeed:len() * 3.6)
speedPID:inject(-speedDif)
velocityAdjust = speedPID:get() * worldVertical - vec3(core.getWorldAirFrictionAcceleration())
if targetSpeed > 10 then
	Nav:setEngineCommand('longitudinal', velocityAdjust, vec3(),false)
end
```

10. Create the following ActionStart() filters, and place the code below as shown in each:
- yawright
  - `targetHeading = targetHeading + 5`
- yawleft
  - `targetHeading = targetHeading - 5`
- groundaltitudeup
  - `cruiseAltitude = cruiseAltitude + 20`
- groundaltitudedown
  - `cruiseAltitude = cruiseAltitude - 20`
- speedup
  - `targetSpeed = targetSpeed + 5`
- speeddown
  - `targetSpeed = targetSpeed - 5`

11. Hit APPLY to save your code. Enjoy!
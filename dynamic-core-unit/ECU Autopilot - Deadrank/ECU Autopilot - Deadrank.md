# ECU Autopilot
Author: [Deadrank](https://dualuniverselualibrary.page.link/deadrank)
Type: ECU Autoconfig replacement

## Description


## Requirements
Element Code: Emergency Controller (ECU)
Link Slot Naming:
* No link slots needed


## Instructions
1. Right Click ECU
2. Select "Run default autoconfigure > (Pilot) Flying Construct
3. Add the following to the top of UNIT > START()
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




 [**__See Code__**](https://dualuniverselualibrary.page.link/code-ecu-autopilot-deadrank)
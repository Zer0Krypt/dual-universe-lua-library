--[[
Title: ECU Autopilot
Author: Deadrank
Description: This script enables the following auto pilot features: Auto-level

Usage: Replace entire contents of ECU > UNIT > START(), SYSTEM > START(), SYSTEM > UPDATE(), and SYSTEM > FLUSH()

LUA REQUIREMENTS
>Linked Slots & Slot Names<
- None
--]]


-- ***** ECU > UNIT > START() ***** --
Nav = Navigator.new(system, core, unit)
--Global Vars--
cruiseAltitude = 400 --export
targetHeading = 270 --export
rAngle = 0 --export
pAngle = 10 --export
targetSpeed = vec3(core.getWorldVelocity())

--Widgets--
gyro.show()
local panel = system.createWidgetPanel("ECU Test")
--Pitch Adjust
local tPitchWidget
tPitchWidget = system.createWidget(panel, "text")
tPitchJson = json.encode ({ text = "Pitch Adjust: "})
tPitchData = system.createData(tPitchJson)
system.addDataToWidget(tPitchData, tPitchWidget)
--Roll Adjust
local tRollWidget
tRollWidget = system.createWidget(panel, "text")
tRollJson = json.encode ({ text = "Roll Adjust: "})
tRollData = system.createData(tRollJson)
system.addDataToWidget(tRollData, tRollWidget)
--Yaw Adjust
local tYawWidget
tYawWidget = system.createWidget(panel, "text")
tYawJson = json.encode ({ text = "Yaw Adjust: "})
tYawData = system.createData(tYawJson)
system.addDataToWidget(tYawData, tYawWidget)
--Current Heading
local cHeadingWidget
cHeadingWidget = system.createWidget(panel, "text")
cHeadingJson = json.encode ({ text = "Heading: "})
cHeadingData = system.createData(cHeadingJson)
system.addDataToWidget(cHeadingData, cHeadingWidget)


-- ***** ECU > SYSTEM > START() ***** --
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


-- ***** ECU > SYSTEM > UPDATE() ***** --
tPitchJson = json.encode ({ text = "Pitch Adjust: " .. tostring(vec3(pitchAdjust))})
system.updateData(tPitchData, tPitchJson)

tRollJson = json.encode ({ text = "Roll Adjust: " .. tostring(vec3(rollAdjust))})
system.updateData(tRollData, tRollJson)

tYawJson = json.encode ({ text = "Yaw Adjust: " .. tostring(vec3(yawAdjust))})
system.updateData(tYawData, tYawJson)

cHeadingJson = json.encode ({ text = "Heading: " .. tostring(currentHeading)})
system.updateData(cHeadingData, cHeadingJson)


-- ***** ECU > SYSTEM > FLUSH() ***** --
--ECU Testing
local power = 3
local worldUp = vec3(core.getConstructWorldOrientationUp())
local worldForward = vec3(core.getConstructWorldOrientationForward())
local worldRight = vec3(core.getConstructWorldOrientationRight())
local worldVertical = vec3(core.getWorldVertical())
local speed = vec3(core.getVelocity()):len() * 3.6

if (pitchPID == nil) then
	pitchPID = pid.new(0.2, 0, 10)
	rollPID = pid.new(0.2, 0, 10)
	yawPID = pid.new(0.001, 0, 1)
end

------------------Adjustments--------------------
--pitchAdjust
currentPitch = -math.asin(worldForward:dot(worldVertical)) * constants.rad2deg
pitchPID:inject(pAngle - currentPitch)
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
--stabilization =  power * targetVelocity
--Nav:setEngineCommand('thrust', stabilization - vec3(core.getWorldVelocity()), vec3(), false)
--STARBOARD SIDE RECEIVER--
local abs = math.abs
local max = math.max
local min = math.min

rednet.open("front")

BOW = null
STERN = null

modem_peripherals = peripheral.wrap("top").getNamesRemote()
if(peripheral.getType(modem_peripherals[1]) == "redstoneIntegrator") then
	BOW = peripheral.wrap(modem_peripherals[1])
end

modem_peripherals = peripheral.wrap("bottom").getNamesRemote()
if(peripheral.getType(modem_peripherals[1]) == "redstoneIntegrator") then
	STERN = peripheral.wrap(modem_peripherals[1])
end

function applyRedStonePower(lin_mv,rot_mv)
	--Redstone signal for linear movement p==positive, n==negative--
	lin_x_p = max(0,lin_mv.x)
	lin_x_n = abs(min(0,lin_mv.x))
	lin_y_p = max(0,lin_mv.y)
	lin_y_n = abs(min(0,lin_mv.y))
	lin_z_p = max(0,lin_mv.z)
	lin_z_n = abs(min(0,lin_mv.z))

	--Redstone signal for angular movement p==positive, n==negative--
	rot_x_p = max(0,rot_mv.x)
	rot_x_n = abs(min(0,rot_mv.x))
	rot_y_p = max(0,rot_mv.y)
	rot_y_n = abs(min(0,rot_mv.y))
	rot_z_p = max(0,rot_mv.z)
	rot_z_n = abs(min(0,rot_mv.z))
	
	--Thruster Components--
	--[[
	BOW == front of ship
	STERN == Back of ship
	PORT == Left of ship
	STARBOARD == Right of ship
	
	I would have kept it simple and just use front,back,left and right but that made it more confusing for me at the time of writing the first few iterations
	]]--
	
	--these are why I had to write a separate script for the port and starboard component controllers--
	
	BF = lin_z_p --BOW FORWARD thruster
	BU = lin_x_n+lin_y_p+rot_x_n+rot_y_n+rot_z_n --BOW UP thruster
	BD = lin_x_n+lin_y_n+rot_x_p+rot_y_n+rot_z_p --BOW DOWN thruster
	SB = lin_z_n --STERN BACKWARD thruster
	SU = lin_x_n+lin_y_p+rot_x_p+rot_y_p+rot_z_n --STERN UP thruster
	SD = lin_x_n+lin_y_n+rot_x_n+rot_y_p+rot_z_p --STERN DOWN thruster
	
	print("BF: "..BF)
	print("BD: "..BD)
	print("BU: "..BU)
	print("SB: "..SB)
	print("SD: "..SD)
	print("SU: "..SU)

	BOW.setAnalogOutput("front", BF)
	STERN.setAnalogOutput("back", SB)

	BOW.setAnalogOutput("bottom", BD)
	STERN.setAnalogOutput("bottom", SD)
	
	BOW.setAnalogOutput("right", BU)
	STERN.setAnalogOutput("right", SU)
	
	--[[
	--for PORT receiver:
	BF = lin_z_p
	BU = lin_x_p+lin_y_p+rot_x_n+rot_y_p+rot_z_p
	BD = lin_x_p+lin_y_n+rot_x_p+rot_y_p+rot_z_n
	SB = lin_z_n
	SU = lin_x_p+lin_y_p+rot_x_p+rot_y_n+rot_z_p
	SD = lin_x_p+lin_y_n+rot_x_n+rot_y_n+rot_z_n
	
	
	print("BF: "..BF)
	print("BD: "..BD)
	print("BU: "..BU)
	print("SB: "..SB)
	print("SD: "..SD)
	print("SU: "..SU)
	
	BOW.setAnalogOutput("front", BF)
	STERN.setAnalogOutput("back", SB)

	BOW.setAnalogOutput("bottom", BD)
	STERN.setAnalogOutput("bottom", SD)
	
	BOW.setAnalogOutput("left", BU)
	STERN.setAnalogOutput("left", SU)
	]]--
end

function resetAllRSI()
	applyRedStonePower(vector.new(0,0,0),vector.new(0,0,0))
end

resetAllRSI()

main_controller_id = 7
debug_remote_id = 0

while true do
    id, message = rednet.receive("component_controls")
	if (id == main_controller_id or id == debug_remote_id) then
		term.clear()
		term.setCursorPos(1,1)
		
		distributed_torque_RS = vector.new(message.rot.x,message.rot.y,message.rot.z)
		distributed_thrust_RS = vector.new(message.pos.x,message.pos.y,message.pos.z)
		print("distributed_torque_RS: "..distributed_torque_RS:tostring())
		print("distributed_thrust_RS: "..distributed_thrust_RS:tostring())
		applyRedStonePower(distributed_thrust_RS,distributed_torque_RS)
		
	end
end


os.loadAPI("lib/quaternions.lua")
os.loadAPI("lib/pidcontrollers.lua")
os.loadAPI("lib/pid_utility.lua")

shipreader = peripheral.find("ship_reader")
rednet.open("bottom")

term.clear()
term.setCursorPos(1,1)

--------------------------------------------------------------------------------
--the ship is actually built vertical with the front of the ship facing up so I have to rotate the ships default orientation to get it to face up--
function getOffsetDefaultShipOrientation(default_ship_orientation)
	offset_orientation = quaternions.Quaternion.fromRotation(default_ship_orientation:localPositiveX(), -90)*default_ship_orientation
	offset_orientation = quaternions.Quaternion.fromRotation(offset_orientation:localPositiveZ(), 135)*offset_orientation
	return offset_orientation
end

ship_rotation = shipreader.getRotation(true)
ship_rotation = quaternions.Quaternion.new(ship_rotation.w,ship_rotation.x,ship_rotation.y,ship_rotation.z)
ship_rotation = getOffsetDefaultShipOrientation(ship_rotation)

ship_global_position = shipreader.getWorldspacePosition()
ship_global_position = vector.new(ship_global_position.x,ship_global_position.y,ship_global_position.z)

world_up_vector = vector.new(0,1,0)

target_global_position = ship_global_position
target_position_displacement = vector.new(0,0,0)
target_rotation = ship_rotation


target_rotation_delta = 20
target_position_displacement_delta = 2

debug_remote_id = 0 --for the pocket computer
remote_control_id = 4 --for the Create Link Controller
port_side_component_controller_id = 5 --left side onboard component controller
starboard_side_component_controller_id = 8 --right side onboard component controller

--Create Link Controller Key binds--
--[[
Thanks to: codenio
https://stackoverflow.com/questions/37447704/what-is-the-alternative-for-switch-statement-in-lua-language
]]--
switch = function (choice)
  choice = choice and tonumber(choice) or choice
	
  case =
   {
	["w"] = function ( )
				target_position_displacement = vector.new(0,0,1)*target_position_displacement_delta
			end,                                            
	["s"] = function ( )
				target_position_displacement = vector.new(0,0,-1)*target_position_displacement_delta
			end,
	["a"] = function ( )
				target_position_displacement = vector.new(1,0,0)*target_position_displacement_delta
			end,
	["d"] = function ( )
				target_position_displacement = vector.new(-1,0,0)*target_position_displacement_delta
			end,
	["space"] = function ( )
				target_position_displacement = vector.new(0,1,0)*target_position_displacement_delta
			end,
	["shift"] = function ( )
				target_position_displacement = vector.new(0,-1,0)*target_position_displacement_delta
			end,
	["shift+a"] = function ( )
				local_rotation_axis = target_rotation:localPositiveZ()
				target_rotation = quaternions.Quaternion.fromRotation(local_rotation_axis, -target_rotation_delta)*target_rotation
			end,
	["shift+d"] = function ( )
				local_rotation_axis = target_rotation:localPositiveZ()
				target_rotation = quaternions.Quaternion.fromRotation(local_rotation_axis, target_rotation_delta)*target_rotation
			end,
	["space+w"] = function ( )
				local_rotation_axis = target_rotation:localPositiveX()
				target_rotation = quaternions.Quaternion.fromRotation(local_rotation_axis, target_rotation_delta)*target_rotation
			end,
	["space+s"] = function ( )
				local_rotation_axis = target_rotation:localPositiveX()
				target_rotation = quaternions.Quaternion.fromRotation(local_rotation_axis, -target_rotation_delta)*target_rotation
			end,
	["space+a"] = function ( )
				local_rotation_axis = world_up_vector--target_rotation:localPositiveY()
				target_rotation = quaternions.Quaternion.fromRotation(local_rotation_axis, target_rotation_delta)*target_rotation
			end,
	["space+d"] = function ( )
				local_rotation_axis = world_up_vector--target_rotation:localPositiveY()
				target_rotation = quaternions.Quaternion.fromRotation(local_rotation_axis, -target_rotation_delta)*target_rotation
			end,
	["stop"] = function ( )
				target_position_displacement = vector.new(0,0,0)
			end,
	["realign"] = function ( )
				target_position_displacement = vector.new(0,0,0)
				target_rotation = quaternions.Quaternion.fromRotation(vector.new(0,1,0), 0)
			end,
	["hush"] = function ( ) --kill command
				component_control_msg = {pos=vector.new(0,0,0),rot=vector.new(0,0,0)}
				rednet.send(starboard_side_component_controller_id,component_control_msg,"component_controls") --right side
				rednet.send(port_side_component_controller_id,component_control_msg,"component_controls") --left side
				os.reboot()
			end,
     default = function ( )
				print("default case executed")   
			end,
   }
  if case[choice] then
     case[choice]()
  else
     case["default"]()
  end
end



function receiveCommand()
	while true do
		id,message = rednet.receive("remote_controls")
		
		if id==remote_control_id or id==debug_remote_id then
			target_position_displacement = vector.new(0,0,0)
			switch(message)
		end
		
		--the ship is designed to move forward parallel with the floor regardless of holding a pitch angle... except when it's pointing straight up
		rotated_z_axis = ship_rotation:localPositiveZ()
		if (rotated_z_axis~=vector.new(0,1,0) and rotated_z_axis~=vector.new(0,-1,0)) then
			world_up_local_x_axis = world_up_vector:cross(rotated_z_axis)
			world_up_local_x_axis = world_up_local_x_axis:normalize()

			world_up_local_z_axis = world_up_local_x_axis:cross(world_up_vector)
			world_up_local_z_axis = world_up_local_z_axis:normalize()
			
			target_global_position = target_global_position:add(world_up_local_x_axis*target_position_displacement.x)
			target_global_position = target_global_position:add(world_up_local_z_axis*target_position_displacement.z)
			target_global_position = target_global_position:add(world_up_vector*target_position_displacement.y)
		end
	end
end

function getLocalPositionError(trg_g_pos,current_g_pos,current_rot)
	trg_l_pos = trg_g_pos - current_g_pos
	trg_l_pos = current_rot:inv():rotateVector3(trg_l_pos) --target position in the ship's perspective
	return trg_l_pos
end

--want to learn more about quaternions? here's a simple tutorial video by sociamix that should get you started: https://youtu.be/1yoFjjJRnLY
local rotation_difference = quaternions.Quaternion.fromRotation(vector.new(0,1,0), 0)

function getQuaternionRotationError(target_rot,current_rot)
	rotation_difference = target_rot * current_rot:inv()
	error_magnitude = rotation_difference:rotationAngle()
	rotation_axis = rotation_difference:rotationAxis()
	local_rotation = current_rot:inv():rotateVector3(rotation_axis) --have to reorient target rotation axis to the ship's perspective
	return local_rotation:mul(error_magnitude)
end

function calculateMovement()
	min_time_step = 0.05 --how fast the computer should continuously loop (the max is 0.05 for ComputerCraft)
	ship_mass = shipreader.getMass()
	gravity_acceleration_vector = vector.new(0,-9.8,0)
	
	max_redstone = 15
	
	mod_configured_thruster_speed = 55000 --make sure to check the VS2-Tournament mod config 
	thruster_tier=5--make sure ALL the tournament thrusters are upgraded to level 5
	
	
	inv_active_thrusters_per_linear_movement = vector.new(1/4,1/4,1/2) --the number of thruster responsible for each axis of linear movement... but they're inverted
	inv_active_thrusters_per_angular_movement = vector.new(1/4,1/4,1/4) --the number of thruster responsible for each axis of angular movement... but they're inverted
	
	base_thruster_force = mod_configured_thruster_speed*thruster_tier --thruster force when powered with 1 redstone(from VS2-Tournament code)
	
	inv_base_thruster_force = 1/base_thruster_force --the base thruster force... but it's inverted
	--it's easier for the computer to use the multiplicatio operator them instead of dividing them over and over again (I'm not really sure if this applies to Lua, I just know that this is what (should) generally go on in your CPU hardware)
	
	max_thruster_force = max_redstone*base_thruster_force
	max_linear_acceleration = max_thruster_force/ship_mass --for PID Integral clamping
	
	--I used Create Schematics to build local inertia tensor.. I built my own java project to get this--
	--these values are specific for 0sand_scorcher_v7_symetric.nbt--
	local_inertia_tensor = {
		x=vector.new(2721858.967822532, -2.4945912002749537E-10, -2.6830093702301383E-11),
		y=vector.new(-2.4945912002749537E-10, 5125310.2694579, 575888.6038319),
		z=vector.new(-2.6830093702301383E-11, 575888.6038319, 3246758.698364628)
	}
	local_inertia_tensor_inv = {
		x=vector.new(3.6739596423689536E-7, 1.7897459761854365E-23, -1.384996576108819E-25),
		y=vector.new(1.7897459761854383E-23, 1.990777542156359E-7, -3.53110965674719E-8),
		z=vector.new(-1.3849965761088417E-25, -3.53110965674719E-8, 3.142627318180287E-7)
	}

	--also specific for 0sand_scorcher_v7_symetric.nbt--
	--F_B_thruster_position = vector.new(3,4,3) --Forward and Backward thrusters are not really used for rotation... but Imma put'm here anyway
	U_R_D_L_thruster_position = vector.new(3,3,2) -- Thruster position relative to the center of mass. Since these thrusters are somewhat symetrical arround the center of mass, I can use this one vector to describe the other thrusters' distance from the center of mass instead of defining them individually

	
	--the ship is actually built vertical with the front of the ship facing up so I have to get the thruster position relative to the new ship orientation--
	new_local_orientation = quaternions.Quaternion.fromRotation(vector.new(1,0,0), -90)
	new_local_orientation = quaternions.Quaternion.fromRotation(new_local_orientation:localPositiveZ(), 135)*new_local_orientation
	
	new_local_x_axis = new_local_orientation:rotateVector3(vector.new(1,0,0))
	new_local_y_axis = new_local_orientation:rotateVector3(vector.new(0,1,0))
	new_local_z_axis = new_local_orientation:rotateVector3(vector.new(0,0,1))
	
	new_local_U_R_D_L_thruster_position = vector.new(0,0,0)
	new_local_U_R_D_L_thruster_position.x = new_local_x_axis:dot(U_R_D_L_thruster_position)
	new_local_U_R_D_L_thruster_position.y = new_local_y_axis:dot(U_R_D_L_thruster_position)
	new_local_U_R_D_L_thruster_position.z = new_local_z_axis:dot(U_R_D_L_thruster_position)
	
	thruster_distances_from_axes = vector.new(0,0,0)
	thruster_distances_from_axes.x = vector.new(0,new_local_U_R_D_L_thruster_position.y,new_local_U_R_D_L_thruster_position.z):length()
	thruster_distances_from_axes.y = vector.new(new_local_U_R_D_L_thruster_position.x,0,new_local_U_R_D_L_thruster_position.z):length()
	thruster_distances_from_axes.z = vector.new(new_local_U_R_D_L_thruster_position.x,new_local_U_R_D_L_thruster_position.y,0):length()
	
	
	perpendicular_force = base_thruster_force*math.sin(math.pi/4)--the rotation thrusters are all at an angle of 45 degrees
	
	--multiply this with the PID calculated torque to get the needed redstone power for the thruster--
	torque_redstone_coefficient_for_x_axis = 1/(thruster_distances_from_axes.x*perpendicular_force)
	torque_redstone_coefficient_for_y_axis = 1/(thruster_distances_from_axes.y*perpendicular_force)
	torque_redstone_coefficient_for_z_axis = 1/(thruster_distances_from_axes.z*perpendicular_force)
	
	--for PID output (and Integral) clamping--
	max_perpendicular_force = max_thruster_force*math.sin(math.pi/4)
	
	torque_saturation = vector.new(0,0,0)
	torque_saturation.x = thruster_distances_from_axes.x * (max_perpendicular_force)
	torque_saturation.y = thruster_distances_from_axes.y * (max_perpendicular_force)--should actually be using cosine instead of sine but... meh
	torque_saturation.z = thruster_distances_from_axes.z * (max_perpendicular_force)
	
	max_angular_acceleration = vector.new(0,0,0)
	max_angular_acceleration.x = torque_saturation:dot(local_inertia_tensor_inv.x)
	max_angular_acceleration.y = torque_saturation:dot(local_inertia_tensor_inv.y)
	max_angular_acceleration.z = torque_saturation:dot(local_inertia_tensor_inv.z)
	
	--PID Controllers--
	--[[
	Technically they're PD controllers...
	Usually people would use a PI controller but since I don't have to worry about "sensor noise" I can safely set a Derivative(D) gain
	I could set an Integral(I) gain for each controller... but I don't think I'll need it after all... (even though I spent hours getting Integral Clamping to work right)
	I don't want to deal with the over shoot...
	Sure it drifts a bit from it's target position but you barely notice it while flying
	Atleast the output value is clamped anyways...
	I would use LQR but that would be over kill dont you think?
	]]--
	pos_PID = pidcontrollers.PID_PWM(0.5,0,2,-max_linear_acceleration,max_linear_acceleration)
	
	rot_x_PID = pidcontrollers.PID_PWM_scalar(0.15,0,0.1,-max_angular_acceleration.x,max_angular_acceleration.x)
	rot_y_PID = pidcontrollers.PID_PWM_scalar(0.15,0,0.3,-max_angular_acceleration.y,max_angular_acceleration.y)
	rot_z_PID = pidcontrollers.PID_PWM_scalar(0.15,0,0.3,-max_angular_acceleration.z,max_angular_acceleration.z)
	
	--Error Based Distributed PWM Algorithm by NikZapp for finer control over the redstone thrusters--
	linear_pwm = pid_utility.pwm()
	angular_pwm = pid_utility.pwm()
	
	while true do
		term.clear()
		term.setCursorPos(1,1)

		print("ship_mass: "..ship_mass)
			
		ship_rotation = shipreader.getRotation(true)
		ship_rotation = quaternions.Quaternion.new(ship_rotation.w,ship_rotation.x,ship_rotation.y,ship_rotation.z)
		ship_rotation = getOffsetDefaultShipOrientation(ship_rotation)
		
		ship_global_position = shipreader.getWorldspacePosition()
		ship_global_position = vector.new(ship_global_position.x,ship_global_position.y,ship_global_position.z)
		
		--FOR ANGULAR MOVEMENT--
		rotation_error = getQuaternionRotationError(target_rotation,ship_rotation) --The difference between the ship's current rotation and the ship's target rotation
		
		print("\nrotation_error: \nX:"..rotation_error.x.."\nY:"..rotation_error.y.."\nZ:"..rotation_error.z)

		pid_output_angular_acceleration = vector.new(0,0,0)
		pid_output_angular_acceleration.x = rot_x_PID:run(rotation_error.x)
		pid_output_angular_acceleration.y = rot_y_PID:run(rotation_error.y)
		pid_output_angular_acceleration.z = rot_z_PID:run(rotation_error.z)
		
		distributed_net_torque = vector.new(0,0,0)
		distributed_net_torque.x = pid_output_angular_acceleration:dot(local_inertia_tensor.x)
		distributed_net_torque.y = pid_output_angular_acceleration:dot(local_inertia_tensor.y)
		distributed_net_torque.z = pid_output_angular_acceleration:dot(local_inertia_tensor.z)
		
		--I divide the calculated torque to the apointed thrusters--
		distributed_net_torque.x = distributed_net_torque.x*inv_active_thrusters_per_angular_movement.x
		distributed_net_torque.y = distributed_net_torque.y*inv_active_thrusters_per_angular_movement.y
		distributed_net_torque.z = distributed_net_torque.z*inv_active_thrusters_per_angular_movement.z

		calculated_angular_RS_PID = distributed_net_torque
		
		--convert calculated torque to redstone signal--
		calculated_angular_RS_PID.x = calculated_angular_RS_PID.x*torque_redstone_coefficient_for_x_axis
		calculated_angular_RS_PID.y = calculated_angular_RS_PID.y*torque_redstone_coefficient_for_y_axis
		calculated_angular_RS_PID.z = calculated_angular_RS_PID.z*torque_redstone_coefficient_for_z_axis
		
		calculated_angular_RS_PID = angular_pwm:run(calculated_angular_RS_PID)
		
		print("\ncalculated_angular_RS_PID: "..calculated_angular_RS_PID:tostring())
		
		
		
		--FOR LINEAR MOVEMENT--
		position_error = getLocalPositionError(target_global_position,ship_global_position,ship_rotation)--The difference between the ship's current position and the ship's target position
		
		print("\nposition_error: \nX:"..position_error.x.."\nY:"..position_error.y.."\nZ:"..position_error.z)
		
		
		local_gravity_acceleration = ship_rotation:inv():rotateVector3(gravity_acceleration_vector)--the gravity vector in the ship's perspective
		
		pid_output_linear_acceleration = pos_PID:run(position_error)
		net_linear_acceleration = pid_output_linear_acceleration:sub(local_gravity_acceleration)
		distributed_linear_net_force = net_linear_acceleration:mul(ship_mass)

		--the thrusters responsible for vertical and side-to-side movement are at an angle of 45 degrees (pi/4)
		distributed_linear_net_force.x = distributed_linear_net_force.x/math.sin(math.pi/4)
		distributed_linear_net_force.y = distributed_linear_net_force.y/math.sin(math.pi/4)
		
		distributed_linear_net_force.x = distributed_linear_net_force.x*inv_active_thrusters_per_linear_movement.x
		distributed_linear_net_force.y = distributed_linear_net_force.y*inv_active_thrusters_per_linear_movement.y
		distributed_linear_net_force.z = distributed_linear_net_force.z*inv_active_thrusters_per_linear_movement.z
		
		
		calculated_linear_RS_PID = distributed_linear_net_force:mul(inv_base_thruster_force)--convert calculated thrust to redstone signal

		
		calculated_linear_RS_PID = linear_pwm:run(calculated_linear_RS_PID)
		print("\ncalculated_linear_RS_PID: "..calculated_linear_RS_PID:tostring())
		
		
		--[[
		--purely for DEBUGGING--
		rotated_z_axis_debug = ship_rotation:localPositiveZ()
		rotated_y_axis_debug = ship_rotation:localPositiveY()
		print("\nrotated_z_axis_debug: "..rotated_z_axis_debug:tostring())
		print("rotated_y_axis_debug: "..rotated_y_axis_debug:tostring())
		--purely for DEBUGGING--
		]]--
		
		--send calculated redstone to component(thruster) controllers--
		component_control_msg = {pos=calculated_linear_RS_PID,rot=calculated_angular_RS_PID}
		
		rednet.send(starboard_side_component_controller_id,component_control_msg,"component_controls") --right side
		rednet.send(port_side_component_controller_id,component_control_msg,"component_controls") --left side
		
		sleep(min_time_step)
	end
end


--DEBUG:MANUALLY SIMULATE SHIP TRANSFORM:--
--[[
switchSim = function (choice)
  choice = choice and tonumber(choice) or choice string. 
  case =
   {
	["close_rot"] = function ( )
			ship_rotation = target_rotation
			end,
	["close_dist"] = function ( )
            ship_global_position = target_global_position
			end, 			
     default = function ( )
             print("default case executed")   
			end,
   }
  if case[choice] then
     case[choice]()
  else
     case["default"]()
  end
end

function simulate()
	while true do
		id,message = rednet.receive("simulate")
		if id==debug_remote_id then
			switchSim(message)
		end
	end
end
parallel.waitForAny(receiveCommand, calculateMovement,simulate)
]]--
--DEBUG:MANUALLY SIMULATE SHIP TRANSFORM:--


parallel.waitForAny(receiveCommand, calculateMovement)

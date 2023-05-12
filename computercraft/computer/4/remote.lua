--FOR CREATE LINK CONTROLLER--
rednet.open("left")

local min = math.min

main_controller_id = 7

cannon_trigger=false
flamethrower_trigger = false

rsi_movement = null
rsi_armaments = null

modem_peripherals = peripheral.wrap("top").getNamesRemote()
if(peripheral.getType(modem_peripherals[1]) == "redstoneIntegrator") then
	rsi_movement = peripheral.wrap(modem_peripherals[1])
end

modem_peripherals = peripheral.wrap("right").getNamesRemote()
if(peripheral.getType(modem_peripherals[1]) == "redstoneIntegrator") then
	rsi_armaments = peripheral.wrap(modem_peripherals[1])
end


previous_key_stroke = ""

key_bind_actions = function (choice)
  case =
   {
	--["space_bar,shift_key,w,a,s,d"]--
	
	["100000"] = function ( )
				print("space")
				rednet.send(main_controller_id,"space","remote_controls")
			end,
	["010000"] = function ( )
				rednet.send(main_controller_id,"shift","remote_controls")
			end,


	["001000"] = function ( )
				rednet.send(main_controller_id,"w","remote_controls")
			end,
	["000010"] = function ( )
				rednet.send(main_controller_id,"s","remote_controls")
			end,

			
	["000100"] = function ( )
				rednet.send(main_controller_id,"a","remote_controls")
			end,
	["000001"] = function ( )
				rednet.send(main_controller_id,"d","remote_controls")
			end,

			
	["101000"] = function ( )
				rednet.send(main_controller_id,"space+w","remote_controls")
			end,
	["100010"] = function ( )
				rednet.send(main_controller_id,"space+s","remote_controls")
			end,

			
	["100100"] = function ( )
				rednet.send(main_controller_id,"space+a","remote_controls")
			end,
	["100001"] = function ( )
				rednet.send(main_controller_id,"space+d","remote_controls")
			end,
			
	["101100"] = function ( )
				rednet.send(main_controller_id,"w","remote_controls")
				rednet.send(main_controller_id,"space+a","remote_controls")
			end,
	["101001"] = function ( )
				rednet.send(main_controller_id,"w","remote_controls")
				rednet.send(main_controller_id,"space+d","remote_controls")
			end,
	["100110"] = function ( )
				rednet.send(main_controller_id,"s","remote_controls")
				rednet.send(main_controller_id,"space+a","remote_controls")
			end,
	["100011"] = function ( )
				rednet.send(main_controller_id,"s","remote_controls")
				rednet.send(main_controller_id,"space+d","remote_controls")
			end,


	["010100"] = function ( )
				rednet.send(main_controller_id,"shift+a","remote_controls")
			end,
	["010001"] = function ( )
				rednet.send(main_controller_id,"shift+d","remote_controls")
			end,
			
			
			
	["111000"] = function ( ) --full auto toggle cannons
				if (previous_key_stroke ~= "111000") then --anti-switch-bounce
					cannon_trigger = not cannon_trigger
				end
			end,
	["110010"] = function ( ) --full auto toggle flamethrower
				if (previous_key_stroke ~= "110010") then --anti-switch-bounce
					flamethrower_trigger = not flamethrower_trigger
					rsi_armaments.setOutput("front",flamethrower_trigger)
				end
				
			end,
	
	--["space_bar,shift_key,w,a,s,d"]--
	
     default = function ( )
				--print("default action, choice: "..choice)  
			end,
   }
  if case[choice] then
     case[choice]()
  else
     case["default"]()
  end
end

rsi_armaments.setOutput("front",true)--the flame thrower is active-off

function receiveCommand()
	while true do

		w = min(1,rsi_movement.getAnalogInput("back"))
		a = min(1,rsi_movement.getAnalogInput("left"))
		s = min(1,rsi_movement.getAnalogInput("front"))
		d = min(1,rsi_movement.getAnalogInput("right"))
		space_bar = min(1,rsi_movement.getAnalogInput("top"))
		shift_key = min(1,redstone.getAnalogInput("back"))
		

		key_stroke = space_bar..shift_key..w..a..s..d
		
		print(key_stroke)
		
		key_bind_actions(key_stroke)
		
		previous_key_stroke = key_stroke
		
		sleep(0.05)
	end
end

function fireLoop()
	fire = false
	while true do
		if cannon_trigger then
			fire = not fire
			rsi_armaments.setOutput("back",fire)
		end
		
		sleep(0.05)
	end
end

parallel.waitForAny(receiveCommand,fireLoop)
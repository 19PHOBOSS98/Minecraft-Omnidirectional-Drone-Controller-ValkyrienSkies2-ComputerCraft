--KILL SWITCH--
rednet.open("back")

port_side_component_controller_id = 5 --left
starboard_side_component_controller_id = 8 --right
main_controller_id = 7

component_control_msg = {pos=vector.new(0,0,0),rot=vector.new(0,0,0)}

rednet.send(starboard_side_component_controller_id,component_control_msg,"component_controls")
rednet.send(port_side_component_controller_id,component_control_msg,"component_controls")
rednet.send(main_controller_id,"hush","remote_controls")
	

# Minecraft-Omnidirectional-Drone-Controller | Built With ValkyrienSkies2, Create & ComputerCraft Mods

## Example Uses
  ### Mr. Smiles the SAND SCORCHER
  
  ![Snapshot](https://github.com/19PHOBOSS98/Minecraft-Omnidirectional-Drone-Controller-ValkyrienSkies2-ComputerCraft/assets/37253663/d2666dca-22d5-44d9-8cd5-263a397e4755)

  ### Phase 1: Prototype
  [YouTube Video](https://youtu.be/yQ7BXQkKIRI)
  ![image](https://github.com/19PHOBOSS98/Minecraft-Omnidirectional-Drone-Controller-ValkyrienSkies2-ComputerCraft/assets/37253663/e7c710f2-2ac9-422d-902a-3aeb1eb5b204)

Minecraft has a giant modding community. With the Valkyrien Skies 2 mod (currently a modding API for building sub-mods), players are able to build physics based creations. The ComputerCraft mod adds in-game computers and peripherals with Lua based programming.
I abused both along with my college degree to create this.

## The Handicaps That I Had To Overcome
Imma be honest, it wasn't easy for me to pull this off. 

### Redstone
The thrusters (the red and white rockets) are powered by Redstone. [More about Redstone here...](https://minecraft.fandom.com/wiki/Redstone_Dust)
For those of you unfamiliar with Redstone, it only comes in POSITIVE INTEGERS. 

That made it difficult to control the thrusters by default. I had to resort to using Pulse Width Modulation to get finer control over the thrusters.

At first I assumed it would be enough to use a fixed redstone value and just pulse it in certain intervals to control the thrusters. However, thanks to **NikZapp**'s help, I was able to get the full range of redstone strength while retaining fine control!

Thanks to **NikZapp** For the Distributed-PWM-Redstone Algorithm. Never would have done this without it!

### Inertia Tensor
Currently, the mods I used didn't provide the ship's Inertia Tensor right out of the box. I had to build my own inertia tensor for my ship.

With Create's Schematics.nbt file and a dictionary of block masses, I wrote my own separate java program to extract the data and construct an inertia tensor.

A big thanks to Querz for building the Java Library I used to extract NBT data from the schematic files:
https://github.com/Querz/NBT

But tbh, I think the VS2-Computers addon will eventually implement a function in the future to expose the ships inertia tensor so people wouldn't have to go thru what I went thru...

## Prerequisits
You might need to read up on these topics before diving in the code. Here are some videos that should help you get started:

  +Quaternions: https://youtu.be/1yoFjjJRnLY
  
  +Inertia Tensors: https://youtu.be/SbTSATs-DBA
  
  +PWM Signals: https://youtu.be/B_Ysdv1xRbA
  
  +PID Controller for Lua: https://youtu.be/K4sHec1qGKg


## A Few Things To Note Before Using The Schematics and World Save

### **!!!!USE AT YOUR OWN RISK, MAKE BACK UPS!!!!**

Prepare the game to use atleast **8GB** of RAM by setting the JVM Arguments in the Minecraft Launcher

### COMPUTERCRAFT FOLDERS

Folder 0: For the Wireless Pocket Computer.

Folder 4: For the Create Link Controller setup (0scorcher_remote_armed.nbt)

Folder 5: For the Left Side onboard component controller

Folder 7: For the main onboard computer

Folder 8: For the Right Side onboard component controller

### PRE-"SHIP ASSEMBLY" CHECKS
1. Make sure to set the Thruster Speed to 55000 in the VS2-Tournament Mod Config Settings (this is specifically for Sand Scorcher).
2. Disable the block-black-list over at the VS2-Eureka mod config settings (or whichever VS2 addon that has an assembler block that you use to assemble ships with). 
3. Build Create schematic as is. Do NOT rotate or mirror the schematics.
4. Connect the floating parts of the ship together with temporary blocks (I usually just use wool).
5. make sure the flamethrower Create-Link is turned ON from the Create-Link Controller setup (0scorcher_remote_armed.nbt). It should turn on by default when you first run "remote.lua" on the computer. The FlameThrower is "ACTIVE-LOW". That means it turns on with a redstone signal of 0.
6. Replenish cannon ammo and flamethrower charges.
7. I usually just go for a VS2-Eureka Ship Helm to assemble a ship but the other addons' assembler blocks should work just as fine.

### POST-"SHIP ASSEMBLY" CHECKS
1. Make sure the VS2-Tournament thrusters are all upgraded to level 5 thrusters.
2. Remove the placed temporary blocks placed earlier.
3. Turn on the cable-modems on the redstone integrators.
4. Build and prepare the Create:Autocannons at the back end.
5. If you're assembling the Scorcher variant with the "flame" contraption, be prepared to glue the flames yourself.
6. Spin the hand cranks to make them look like handle bars.

### PREFLIGHT CHECKS
1. Run `remote.lua` on the Create-Link Controller setup (0scorcher_remote_armed.nbt) and grab the Link Cotroller
2. Prepare to run `reset.lua` on the Wireless Pocket Computer. This should reset the craft thrusters and reboot the main onboard computer if anything goes wrong
3. Prepare a VS2-Eureka Ship Helm on hand. Placing it on a ship forces it to stop freaking out if anything goes wrong 
4. Run `recv_L_scorcher.lua` on the left side onboard computer
5. Run `recv_R_scorcher.lua` on the right side onboard computer. These control the thrusters
6. Run `flight_control_firmware_scorcher.lua` on the main onboard computer
7. Fly

### POSTFLIGHT CHECKS
**THIS IS IMPORTANT TO DO BEFORE LOGGING OFF**
1. After flying, run `reset.lua` on your Wireless Pocket Computer to shutoff the thrusters and stop the main script. 

    CC:Computers turnoff when the player exits the world. Upon logging back in, the onboard computers would be turned off but the Redstone Integrator peripherals would retain their last redstone settings and inturn would still be powering the thrusters.
    
    If this ever happens, the Scorcher would start flying off by itself when you log in.
    
    At the very least quickly prepare a VS2-Eureka Ship Helm to calm down the ship and 
    
    **RUN the `recv_L_scorcher.lua` and `recv_R_scorcher.lua` scripts** 
    
    on the left and right side onboard computers to reset the Redstone Integrators back to 0.

### RELEVANT MODS:

**Valkyrien Skies:**
```
valkyrienskies-118-forge-2.1.0-beta.12c3076eba24 (Valkyrien Skies 2 Core)

vc-1.5.2+2090972a50 (Valkyrien Skies 2-Computers)

eureka-1.1.0-beta.8 (Valkyrien Skies 2-Eureka)

takeoff-forge-1.0.0-beta1+308678c5c5 (Valkyrien Skies 2-Takeoff)

tournament-forge-1.0.0-beta3-0.6+f5dce4613f (Valkyrien Skies 2-Tournament)

Clockwork_Pre-Alpha_Patch_1.3c_FORGE (Valkyrien Skies 2-Clockwork)
```

**Create:**
```
create-1.18.2-0.5.0.i (Create Core)

createbigcannons-forge-1.18.2-0.5.1.a-nightly-1c78f14 (Create Big Cannons)
```

**Macaw's Windows (Sand Scorcher "Armor"):**
```
mcw-windows-2.1.1-mc1.18.2forge
```

**ComputerCraft:**
```
cc-tweaked-1.18.2-1.101.2 (ComputerCraft Tweaked)

AdvancedPeripherals-0.7.27r (ComputerCraft Advanced Peripherals)
```


# Minecraft-Omnidirectional-Drone-Controller | Built With ValkyrienSkies2, Create & ComputerCraft Mods

## Example Uses
  ### Mr. Smiles the SAND SCORCHER
  
  ![Snapshot](https://github.com/19PHOBOSS98/Minecraft-Omnidirectional-Drone-Controller-ValkyrienSkies2-ComputerCraft/assets/37253663/d2666dca-22d5-44d9-8cd5-263a397e4755)

  ### Phase 1: Prototype
  [YouTube Video](https://youtu.be/yQ7BXQkKIRI)
  ![image](https://github.com/19PHOBOSS98/Minecraft-Omnidirectional-Drone-Controller-ValkyrienSkies2-ComputerCraft/assets/37253663/e7c710f2-2ac9-422d-902a-3aeb1eb5b204)

Minecraft has a giant modding community. With the Valkyrien Skies 2 mod (currently a modding API for building sub-mods), players are able to build physics based creations. The ComputerCraft mod adds in-game computers and peripherals with Lua based programming.


## The Handicaps That I Had To Overcome
Imma be honest, it wasn't easy for me to pull this off. 

### Redstone
The thrusters (the red and white rockets) are powered by Redstone. For those of you unfamiliar with Redstone, it only comes in POSITIVE INTEGERS. [More about Redstone here...](https://minecraft.fandom.com/wiki/Redstone_Dust)

That made it difficult to control the thrusters by default. I had to resort to using Pulse Width Modulation to get finer control over the thrusters.

At first I assumed it would be enough to use a fixed redstone value and just pulse it in certain intervals to control the thrusters. However, thanks to **NikZapp**'s help, I was able to get the full range of redstone strength while retaining fine control!

Thanks to **NikZapp** For the Distributed-PWM-Redstone Algorithm. Never would have fine control over RedStone Thrusters without it!

### Inertia Tensor
Currently, the mods I used didn't provide the ship's Inertia Tensor right out of the box. I had to build my own inertia tensor for my ships.

With Create's Schematics.nbt file and a dictionary of block masses, I wrote my own separate java program to extract the data and construct an inertia tensor

A big thanks to Querz for building the Java Library I used to extract NBT data from the schematic files:
https://github.com/Querz/NBT

But tbh, I think the VS2-Computers addon will eventually implement a function in the future to expose the ships inertia tensor so people wouldn't have to go thru what I went thru...


You might need to read up on these topics before diving in the code. Here are some videos that should help you get started:

  +Quaternions: https://youtu.be/1yoFjjJRnLY
  
  +Inertia Tensors: https://youtu.be/SbTSATs-DBA
  
  +PWM Signals: https://youtu.be/B_Ysdv1xRbA
  
  +PID Controller for Lua: https://youtu.be/K4sHec1qGKg




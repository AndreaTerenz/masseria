# MASseria

Project work for the MultiAgent Systems exam (91267 & 91289) of the Master's Degree in Artificial Intelligence at UniBO, done by Andrea Terenziani and Alberto Luise

The goal of this project is to develop a MultiAgent System to manage a pizza restaurant along the lines of a classic Flash game, [Papa's Pizzeria](https://papaspizzeria.io), that used to be very popular a few years ago. The original game consisted in managing a small restaurant, trying to satisfy customers by completing as many orders as well as possible. The fundamental idea is to turn this game into a Multi-Agent System by replacing the player, usually the only employee of the pizzeria, with the collaborative effort of multiple Agents with specific roles and abilities. No single agent will be able to complete orders by itself, forcing the agents to achieve a smoothly running restaurant by cooperating and exchanging tasks, with the system and agents' behavior specifically coded to this end. 

## Running the project

Except on MacOS, make sure that the dynamic library `liblimboai` is in the same directory as the executable (this will be a `.so` file on Linux and a `.dll` on Windows)

### Linux

Double click on `MASseria.x86_64`. If it doesn't launch, open a terminal in the directory and run `chmod +x MASseria.x86_64` to make it executable.

### Windows

Double click on `MASseria.exe`.

### MacOS

The project will be a `.zip` archive. When unzipped, it will produce an application file `MASseria.app`. Before running it the first time, you need to run `xattr -rc MASSeria.app` to make sure the executable isn't blocked by Gatekeeper.

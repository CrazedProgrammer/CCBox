# CCBox
System virtualisation program for ComputerCraft.  
My entry for CCJam 2017.  
This program was made with and tested for the [ComputerCraft 1.80 Nightly](https://cc.crzd.me/) builds.

# Download
[pastebin get PheuiSP1 ccbox.lua](https://pastebin.com/PheuiSP1)  

# How to use
Get a boot file ([bios.lua](https://github.com/dan200/ComputerCraft/blob/master/src/main/resources/assets/computercraft/lua/bios.lua)):  
`wget https://raw.githubusercontent.com/dan200/ComputerCraft/master/src/main/resources/assets/computercraft/lua/bios.lua bios.lua`  
And then simply run `ccjam`.  
You can exit a VM by running `shutdown`.  
There are many different options available:  
  
![](https://img.crzd.me/ccbox.png)  
Note that the tempfs mount type is currently not implemented due to time constraints.

# Building
Compiling is done with the [Urn](https://gitlab.com/urn/urn) compiler:  
`urn main.lisp`

# CCBox
ComputerCraft emulator written in Urn.  
Designed to be able to run on multiple Lua platforms (ComputerCraft, POSIX + Lua 5.1/5.2/5.3/JIT).

# How to use
Get a boot file ([bios.lua](https://github.com/dan200/ComputerCraft/blob/master/src/main/resources/assets/computercraft/lua/bios.lua)):  
`wget https://raw.githubusercontent.com/dan200/ComputerCraft/master/src/main/resources/assets/computercraft/lua/bios.lua bios.lua`  
And then simply run `ccbox`.  
You can exit a VM by running `shutdown`.  
There are many different options available:  
```
usage: buildenv/ccbox.lua [--help] [--bios BIOS-PATH] [--log LOG-PATH] [--command STARTUP-COMMAND] [--features FEATURES] [--json JSON-PATH] [VFS-MOUNTS...]

 VFS-MOUNTS     The virtual file system mounts.
  `<attrs>:<mount>:[dir]`
  attr: attributes. w (write), t (tmpfs), c (ccfs)
  Temp doesn't require a dir argument.
  mount: mount point (has to start with /)
  dir: host file system directory
  Can be relative to the current directory.
  Default on CC platform: cw:/:. c:/rom:/rom
  Default on PUC platform: tw:/:@embed
 --help, -h     Show this help message
 --bios, -b     The bios.lua file path.
 --log, -l      The log file path.
 --command, -c  The startup command.
 --features     Enabled features, space separated.
  Possible values: "advanced network redstone peripheral disk mount"
  Default values: "advanced network"
 --json         Path to a JSON library (needs to have .encode and .decode functions). Only needed when loading/saving tmpfs filesystems.
```

# Building
Compiling is done with the [Urn](https://gitlab.com/urn/urn) compiler:  
`cd src; urn main.lisp -o ccbox`

# Download
It is recommended you build this program yourself (see Building), as this download can be outdated.  
[`wget https://i.crzd.me/ccbox.lua`](https://i.crzd.me/ccbox.lua)

# CCJam-2017
This was originally my entry for CCJam 2017, but has since been updated.  
You can find the original code for the CCJam 2017 in the `ccjam-2017` tag.  
This program was made with and tested for the [ComputerCraft 1.80 Nightly](https://cc.crzd.me/) builds, but could run on older versions too.

# CCBox
System virtualisation program for ComputerCraft.  
This was originally my entry for CCJam 2017, but has since been updated.  
You can find the original code for the CCJam 2017 in the `ccjam-2017` tag.  
This program was made with and tested for the [ComputerCraft 1.80 Nightly](https://cc.crzd.me/) builds, but could run on older versions too.

# Download
It is recommended you build this program yourself (see Building), as this download can be outdated.  
[pastebin get PheuiSP1 ccbox.lua](https://pastebin.com/PheuiSP1)

# How to use
Get a boot file ([bios.lua](https://github.com/dan200/ComputerCraft/blob/master/src/main/resources/assets/computercraft/lua/bios.lua)):  
`wget https://raw.githubusercontent.com/dan200/ComputerCraft/master/src/main/resources/assets/computercraft/lua/bios.lua bios.lua`  
And then simply run `ccbox`.  
You can exit a VM by running `shutdown`.  
There are many different options available:  
```
usage: ccbox [--help] [--boot BOOT-FILE] [--log LOG-FILE] [--command STARTUP-COMMAND] [--disable-net] [--enable-rs] [--enable-per] [--enable-disk] [--non-advanced] [VFS-MOUNTS...]

 VFS-MOUNTS         The virtual file system mounts.
  `<attrs>:<mount>:[dir]`
  attr: attributes. w (write), t (tempfs), c (ccfs)
  Temp doesn't require a dir argument.
  mount: mount point (has to start with /)
  dir: host file system directory
  Can be relative to the current directory.
  Default: cw:/:. c:/rom:/rom
 --help, -h         Show this help message
 --boot, -b         The boot file. Default: ./bios.lua
 --log, -l          The log file.
 --command, -c      The startup command.
 --disable-net, -n  Disables networking (http, socket).
 --enable-rs, -R    Enables redstone passthrough.
 --enable-per, -P   Enables peripheral passthrough.
 --enable-disk, -D  Enables disk drive passthrough.
 --non-advanced     Run as a standard (non-advanced) computer.
```

# Building
Compiling is done with the [Urn](https://gitlab.com/urn/urn) compiler:  
`urn main.lisp`

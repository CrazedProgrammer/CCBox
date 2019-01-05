(import io/argparse ())

(define args
        (with (spec (create))
          (add-help! spec)
          (add-argument! spec '("vfs-mounts")
            :help "The virtual file system mounts.
                     `<attrs>:<mount>:[dir]`
                     attr: attributes. w (write), t (tempfs), r (realfs)
                     Temp doesn't require a dir argument.
                     mount: mount point (has to start with /)
                     dir: host file system directory
                     Can be relative to the current directory.
                     Default: rw:/:. r:/rom:/rom"
            :default '("cw:/:." "c:/rom:/rom"))

          (add-argument! spec '("--boot" "-b")
            :name "boot-file"
            :help "The boot file. Default: ./bios.lua"
            :default "bios.lua"
            :narg 1)

          (add-argument! spec '("--log" "-l")
            :name "log-file"
            :help "The log file."
            :narg 1)

          (add-argument! spec '("--command" "-c")
            :name "startup-command"
            :help "The startup command."
            :default ""
            :narg 1)

          (add-argument! spec '("--disable-net" "-n")
            :name "disable-networking"
            :help "Disables networking (http, socket).")

          (add-argument! spec '("--enable-rs" "-R")
            :name "enable-redstone"
            :help "Enables redstone passthrough.")

          (add-argument! spec '("--enable-per" "-P")
            :name "enable-peripheral"
            :help "Enables peripheral passthrough.")

          (add-argument! spec '("--enable-disk" "-D")
            :name "enable-disk"
            :help "Enables disk drive passthrough.")

          (add-argument! spec '("--non-advanced")
            :name "non-advanced"
            :help "Run as a standard (non-advanced) computer.")

          (parse! spec)))

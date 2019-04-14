(import io/argparse ())

(define cli-args
        (with (spec (create))
          (add-help! spec)
          (add-argument! spec '("vfs-mounts")
            :help "The virtual file system mounts.
                     `<attrs>:<mount>:[dir]`
                     attr: attributes. w (write), t (tmpfs), c (ccfs)
                     Temp doesn't require a dir argument.
                     mount: mount point (has to start with /)
                     dir: host file system directory
                     Can be relative to the current directory.
                     Default on CC platform: cw:/:. c:/rom:/rom
                     Default on PUC platform: tw:/:@embed")

          (add-argument! spec '("--bios" "-b")
            :name "bios-path"
            :help "The bios.lua file path."
            :narg 1)

          (add-argument! spec '("--log" "-l")
            :name "log-path"
            :help "The log file path."
            :narg 1)

          (add-argument! spec '("--command" "-c")
            :name "startup-command"
            :help "The startup command."
            :narg 1)

          (add-argument! spec '("--features")
            :name "features"
            :help "Enabled features, space separated.
                     Possible values: \"advanced network redstone peripheral disk mount\"
                     Default values: \"advanced network\""
            :narg 1)

          (add-argument! spec '("--json")
            :name "json-path"
            :help "Path to a JSON library (needs to have .encode and .decode functions). Only needed when loading/saving tmpfs filesystems."
            :narg 1)

          (parse! spec)))

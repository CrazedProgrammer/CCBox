(import computer)
(import vfs)
(import bindings/os os)
(import bindings/shell shell)
(import extra/argparse ())

(define args
        (with (spec (create))
          (add-help! spec)
          (add-argument! spec '("vfs-mounts")
            :help "  The virtual file system mounts.
                     `<attrs>:<mount>:[dir]`
                     attr: attributes. w (write), t (tempfs), r (realfs)
                     Temp doesn't require a dir argument.
                     mount: mount point (has to start with /)
                     dir: host file system directory
                     Can be relative to the current directory."
            :default '("rw:/:." "r:/rom:/rom"))

          (add-argument! spec '("--boot" "-b")
            :name "boot-file"
            :help "The boot file."
            :default "bios.lua"
            :narg 1)

          (add-argument! spec '("--disable-net")
            :name "disable-networking"
            :help "Disables networking (http, socket).")

          (add-argument! spec '("--enable-rs")
            :name "enable-redstone"
            :help "Enables redstone passthrough.")

          (add-argument! spec '("--enable-per")
            :name "enable-peripheral"
            :help "Enables peripheral passthrough.")

          (add-argument! spec '("--enable-disk")
            :name "enable-disk"
            :help "Enables disk drive passthrough.")

          (parse! spec)))

(defun run ()
  (with (comp (computer/create args))
    (while (.> comp :running)
      (computer/next comp (list (os/pullEventRaw))))))

(run)

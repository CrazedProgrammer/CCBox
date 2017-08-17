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

          (parse! spec)))

(defun run ()
  (with (comp (computer/create (shell/resolve (.> args :boot-file)) (.> args :vfs-mounts)))
    (while true
      (computer/next comp (list (os/pullEventRaw))))))

;(print! (pretty ((.> (vfs/create-vfs (.> args :vfs-mounts)) :list) "////rom/apis")))
(run)

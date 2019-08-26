(import util (get-platform))
(import util/io (read-file-force! resolve-path))
(import util/embed (embedded-bios embedded-ccfs))

(defun create-spec (args)
  (with (platform (or (.> args :platform) (get-platform)))
    { :platform platform
      :bios (if (.> args :bios-path)
               (read-file-force! (resolve-path (.> args :bios-path)))
               (or (.> args :bios)
                   (or embedded-bios
                       (exit! "--bios argument is required" 1))))
      :startup-command (or (.> args :startup-command) "")
      :features (string/split (or (.> args :features) "advanced network") " ")
      :vfs-mounts (if (and (.> args :vfs-mounts) (> (n (.> args :vfs-mounts)) 0))
                    (.> args :vfs-mounts)
                    (if embedded-ccfs
                      '("tw:/:@embed")
                      (case platform
                        [cc '("cw:/:." "c:/rom:/rom")]
                        [puc (exit! "VFS mounts argument is required" 1)]))) }))

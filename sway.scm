;; This is an operating system configuration generated
;; by the graphical installer.

(define-module (sway)
  #:use-module (gnu)
  #:use-module (config services)
  #:use-module (config sway)
  #:use-module (guix gexp)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match)
  #:export (%sway-os))

(use-package-modules fonts libusb linux security-token wm)
(use-service-modules avahi base databases dbus desktop mcron
                     networking sound ssh xorg)

(define %sway-os
  (operating-system
    (host-name "wind")
    (timezone "Europe/Oslo")
    (locale "en_US.utf8")
    (keyboard-layout (keyboard-layout "us" "altgr-intl"))
    (kernel-arguments (append '("modprobe.blacklist=pcspkr,snd_pcsp")
                              %default-kernel-arguments))
    (groups (append (list (user-group
                           (name "hacker"))
                          (user-group
                           (name "gamer"))
                          (user-group
                           ;; Some udev rules refer to this.
                           (name "plugdev")
                           (system? #t)))
                    %base-groups))
    (users (cons* (user-account
                   (name "hacker")
                   ;; Use the 'passwd' command to change this initial password.
                   (password (crypt "hacker" "$5$abc123"))
                   (comment "Leet Hacker")
                   (group "hacker")
                   (home-directory "/home/hacker")
                   (shell %sway-login-shell)
                   (supplementary-groups
                    '("wheel" "netdev" "plugdev" "audio" "video" "lp" "kvm")))
                  (user-account
                   (name "gamer")
                   (password (crypt "gamer" "$5$abc123"))
                   (comment "Lame Gamer")
                   (group "gamer")
                   (home-directory "/home/gamer")
                   (shell %sway-login-shell)
                   (supplementary-groups
                    '("plugdev" "audio" "video" "lp")))
                  %base-user-accounts))

    (packages
     (append (map specification->package
                  '("nss-certs" "htop" "file" "tmux" "screen"
                    "git" "stow" "curl" "wget" "jq"
                    "sway" "i3status"
                    "wpa-supplicant-gui"

                    "adwaita-icon-theme" ;to make GTK applications look OK
                    "qtbase" "qtwayland" ;to make Qt work on Wayland
                    "ncurses"            ;for the search path (XXX)

                    ;; Fonts.
                    "font-dejavu"
                    "font-liberation"
                    "font-google-noto"
                    "font-adobe-source-han-sans"
                    "font-adobe-source-code-pro"

                    ;; Emacs & friends.
                    "emacs-next-pgtk"   ;experimental GTK+ backend
                    "emacs-guix"
                    "emacs-evil"
                    "emacs-magit"

                    "foot"              ;terminal emulator
                    "wofi"              ;command launcher
                    "imv"))             ;image viewer
             %base-packages))
    (services
     (append (list (dbus-service)
                   (service polkit-service-type)
                   (service elogind-service-type)
                   (service pulseaudio-service-type)
                   (service mcron-service-type)

                   ;; Network services.
                   (service dhcp-client-service-type)
                   (service wpa-supplicant-service-type
                            (wpa-supplicant-configuration
                             (config-file "/etc/wpa_supplicant.conf")
                             (interface "wlp0s20f3")))
                   (service bluetooth-service-type)
                   (service tor-service-type)
                   (service openssh-service-type
                            (openssh-configuration
                             (password-authentication? #f)))
                   (service avahi-service-type)
                   (service ntp-service-type
                            (ntp-configuration
                             (servers (map (lambda (server)
                                             (ntp-server (address server)))
                                           '("0.no.pool.ntp.org"
                                             "1.no.pool.ntp.org"
                                             "2.no.pool.ntp.org"
                                             "3.no.pool.ntp.org")))))

                   ;; Install udev rules from these packages.
                   (simple-service 'udev-rules udev-service-type
                                   (list libmtp libu2f-host brightnessctl))

                   ;; Finally our custom services.
                   %powertop-service
                   %sway-environment-service
                   (extra-special-file "/etc/sway/config" %sway-config)
                   (screen-locker-service swaylock "swaylock"))
             (modify-services %base-services
               ;; Use a custom console font.
               (console-font-service-type
                config =>
                (map (lambda (tty)
                       (cons tty
                             ;; Note: use e.g. terminus ter-132n for Hi-DPI.
                             (file-append kbd "/share/consolefonts/eurlatgr")))
                     '("tty1" "tty2" "tty3" "tty4" "tty5" "tty6")))
               ;; Automatically login the users on TTY2 and TTY3.
               (mingetty-service-type
                config =>
                (mingetty-configuration
                 (inherit config)
                 (auto-login
                  (match (mingetty-configuration-tty config)
                    ("tty2" "hacker")
                    ("tty3" "gamer")
                    (_ #f)))))
               ;; Customize the Guix service.
               (guix-service-type
                config =>
                (guix-configuration
                 (inherit config)
                 (discover? #t)       ;discover substitutes on the LAN
                 (extra-options
                  '("--max-jobs=3" "--cores=3"
                    "--gc-keep-outputs" "--cache-failures")))))))
    (bootloader
     (bootloader-configuration
      (bootloader grub-efi-bootloader)
      (theme (grub-theme
              (inherit (grub-theme))
              (gfxmode '("1024x768x32"))))
      (target "/boot/efi")
      (keyboard-layout keyboard-layout)))
    (file-systems
     (cons* (file-system
              (mount-point "/")
              (device "/dev/sda1")
              (type "ext4"))
            (file-system
              (mount-point "/boot/efi")
              (device "/dev/sda2")
              (type "vfat"))
            %base-file-systems))))

%sway-os

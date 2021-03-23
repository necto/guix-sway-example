(define-module (config foot)
  #:use-module (guix gexp)
  #:export (foot-config))

(define foot-config
  (plain-file
   "foot.ini"
   "workers = 2

[scrollback]
lines = 2000

[cursor]
blink = yes

[mouse]
hide-when-typing = yes

[colors]
# \"Selenized\", taken from
# https://mjanja.ch/2021/01/selenized-dark-color-scheme-for-foot/
alpha=1.0
foreground=adbcbc
background=103c48
regular0=184956  # black
regular1=fa5750  # red
regular2=75b938  # green
regular3=dbb32d  # yellow
regular4=4695f7  # blue
regular5=f275be  # magenta
regular6=41c7b9  # cyan
regular7=72898f  # white
bright0=2d5b69   # bright black
bright1=ff665c   # bright red
bright2=84c747   # bright green
bright3=ebc13d   # bright yellow
bright4=58a3ff   # bright blue
bright5=ff84cd   # bright magenta
bright6=53d6c7   # bright cyan
bright7=cad8d9   # bright white
selection-foreground=cad8d9
selection-background=184956
"))

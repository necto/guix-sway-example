# Guix Sway example

This is an example Guix configuration that starts Sway directly
on TTY2 and TTY3 for two different user accounts.

It also embeds some "dotfiles" as G-expressions for inspiration.

The repository is separated into modules, you will need to add the
directory on Guile's load path to use it as-is:

```
guix system reconfigure -L . sway.scm
```

Have fun!
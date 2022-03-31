# nix-config

My NixOS configurations. It's contains:
+ TimeZone = America/Sao_Paulo
+ Keyboard = br-abnt2
+ defaultLocale = pt_BR
+ videoDrivers= amdgpu
+ desktopManager = StumpWM and XFCE
+ windowsManager.default = stumpWM
+ displayManager = lightDM
+ Disk = openZFS antive encryption and Segure Boot 


# How to use

To use this, you only need to clone this repository in `/etc/nixos`:

```
git clone git@github.com:carlosalbertofilho/nix-config.git /etc/nixos
chown -R 1000:100 /etc/nixos # to avoid need root to edit the files
```

And then you can follow the installation of the system.


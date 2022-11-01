# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix ./zfs.nix
    ];


  networking.hostName = "helena"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
   networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.enableB43Firmware = true;

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
   i18n.defaultLocale = "pt_BR.UTF-8";
   console = {
     font = "Lat2-Terminus16";
     keyMap = "br-abnt2";
     # useXkbConfig = true; # use xkbOptions in tty.
   };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "br";
  services.xserver.libinput.enable = true;

  # Enable the Plasma 5 Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;


  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;


  # Enable unfree packages
  nixpkgs.config.allowUnfree = true; 


  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users.carlosfilho = {
     isNormalUser = true;
     extraGroups = [ 
	"wheel" # Enable ‘sudo’ for the user.
	"docker"
        "networkmanager"
        "messagebus"
        "systemd-journal"
        "disk"
        "audio"
        "video"
	"lp"
     ]; 
     initialHashedPassword="$6$PbUsXPlzoG6oTxog$Upo8xLhjHjg3MKn1xPe6Byvk9o1H9afF5nt8booMCvVFy2KI5OPYjV6YvmSJDUE2LQgUiTJ6HEWY7GKzmrFJj.";
     packages = with pkgs; [
       firefox
       thunderbird
       keepassxc
       neofetch
       zoom-us
       discord
     ];
   };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
   environment.systemPackages = with pkgs; [
     vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     wget
     google-chrome
     tdesktop
     kate
     latte-dock 
     spotify
     libreoffice-qt
     libsForQt5.kdenlive
     libsForQt5.ksshaskpass
     libsForQt5.sddm-kcm
     ffmpeg
     gimp
     wget
     zip unzip
     ripgrep-all
     archivemount
     glxinfo
     pciutils
     hplip
     gitFull
     neovim
    ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
   programs.dconf.enable = true;
   programs.mtr.enable = true;
   programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
   };

  # List services that you want to enable:

  # Syslog-ng enable
  services.syslog-ng.enable = true;

  # Locate Server
  services.locate.enable = true;

  # fan controller daemon for Apple Macs and MacBooks.
  services.mbpfan.enable = true;

  # Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;

  # Automatic Upgrades
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;


  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
   networking.firewall.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}


# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
    ./hardware-configuration.nix ./fonts.nix
    ./flakeModule.nix ./homeManager.nix
    ];


    networking.hostName = "aa102-006l"; # Define your hostname.
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
    services.printing.drivers = [ pkgs.hplip ];

    #Scanner
    hardware.sane.enable = true;
    hardware.sane.extraBackends = [ pkgs.hplipWithPlugin ];

    #GVFS
    services.gvfs.enable = true;

    # Enable sound.
    sound.enable = true;
    hardware.pulseaudio.enable = true;


    # Enable unfree packages
    nixpkgs.config.allowUnfree = true;

    users.users.carlosfilho = {
      isNormalUser = true;
      extraGroups = [
      "wheel" "docker" "networkmanager" "messagebus"
      "systemd-journal" "disk" "audio" "video" "lp"  ];
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      anydesk
      archivemount
      aspell aspellDicts.pt_BR ispell
      brave
      emacs
      exa
      ffmpeg
      fzf fzf-zsh
      gimp
      gitFull
      glxinfo
      gnupg
      google-chrome
      kate
      kgpg
      kwalletcli
      lbry
      libreoffice-qt
      libsForQt5.akonadi
      libsForQt5.akonadi-calendar
      libsForQt5.akonadi-contacts
      libsForQt5.akonadi-import-wizard
      libsForQt5.akonadi-mime
      libsForQt5.akonadi-notes
      libsForQt5.akonadi-search
      libsForQt5.akonadiconsole
      libsForQt5.dolphin-plugins
      libsForQt5.kconfig
      libsForQt5.kconfigwidgets
      libsForQt5.kdenlive
      libsForQt5.kdeplasma-addons
      libsForQt5.korganizer
      libsForQt5.ksshaskpass
      libsForQt5.print-manager
      libsForQt5.sddm-kcm
      neovim
      opera
      pass
      pass-git-helper
      pciutils
      pinentry-qt
      plymouth
      qtpass
      remmina
      ripgrep
      ripgrep-all
      spotify
      tdesktop
      vim
      vivaldi
      vivaldi-ffmpeg-codecs
      wget
      zip unzip ark
    ];

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    programs.dconf.enable = true;

    programs.mtr.enable = true;

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "qt";
    };

    programs.ssh.askPassword = "/run/current-system/sw/bin/ksshaskpass";

    # LAN discovery.
    services.avahi = {
      enable = true;
      nssmdns = true;
    };

    # List services that you want to enable:

    # Syslog-ng enable
    services.syslog-ng.enable = true;

    # Enable Emacs Service
    # programs.emacs.enable = true;

    # Enable zsh for all user
    programs.zsh.enable = true;
    users.defaultUserShell = pkgs.zsh;
    environment.shells = with pkgs; [ zsh ];

    # Bluetooth.
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;

    # Locate Server
    services.locate.enable = true;

    # fan controller daemon for Apple Macs and MacBooks.
    services.mbpfan.enable = true;

    # Docker
    virtualisation.docker.enable = true;
    virtualisation.docker.enableOnBoot = true;

    # Config kwallet
    security.pam.services.kwallet = {
      name = "kwallet";
      enableKwallet = true;
    };

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
    system.stateVersion = "22.11"; # Did you read the comment?

}



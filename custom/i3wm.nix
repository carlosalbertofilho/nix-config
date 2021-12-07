{ config, pkgs, callPackage, ... }:
{
  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw
  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false;
    };

    displayManager = {
        defaultSession = "none+i3";
    };

    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;

      extraPackages = with pkgs; [
        dmenu
        dunst
        i3status
        i3-balance-workspace
        file # Needed to make py3status work
        (python3Packages.py3status.overrideAttrs (oldAttrs: {
          propagatedBuildInputs = with python3Packages; [
            pytz
            tzlocal
          ] ++ oldAttrs.propagatedBuildInputs;
        }))
     ];
    };
  };
}

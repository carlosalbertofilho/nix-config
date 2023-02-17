{ config, pkgs, ... }:
{
  fonts = {
    enableDefaultFonts = true; # Those fonts you expect every distro to have.
    fonts = with pkgs; [
      bakoma_ttf
      cantarell-fonts
      corefonts
      dejavu_fonts
      fira
      fira-code
      fira-code-symbols
      font-awesome_4
      font-awesome_5
      gentium
      google-fonts
      ibm-plex
      inconsolata
      liberation_ttf
      nerdfonts
      noto-fonts
      noto-fonts-cjk
      open-fonts
      powerline-fonts
      roboto
      terminus_font
      ubuntu_font_family
      borg-sans-mono

    ];
    fontconfig = {
      cache32Bit = true;
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Roboto" ];
        monospace = [ "Fira Code" ];
      };
    };
  };
}


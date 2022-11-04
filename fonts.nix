{ config, pkgs, ... }:
{
  fonts = {
    enableDefaultFonts = true; # Those fonts you expect every distro to have.
    fonts = with pkgs; [
      borg-sans-mono
      cantarell-fonts
      fira
      fira-code
      fira-code-symbols
      font-awesome_4
      font-awesome_5
      noto-fonts
      noto-fonts-cjk
      open-fonts
      roboto
      ubuntu_font_family
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

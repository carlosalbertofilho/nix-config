
{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];
  home-manager.users.carlosfilho = {
    home.username = "carlosfilho";
    home.homeDirectory = "/home/carlosfilho";
    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
    
    /* Here goes your home-manager config, eg  */
    home.stateVersion = "22.11";
    home.packages = with pkgs; [
       firefox  thunderbird  keepassxc  neofetch
       zoom-us  discord 
    ];

    
    programs.git = {
       enable = true;
       userName  = "carlosalbertofilho";
       userEmail = "carlosalberto_filho@outlook.com";
    };
    
    programs.emacs.enable = true;

    home.file.".gnupg/gpg.conf".source = ./dotfile/gnupg/gpg.conf;
  };
}
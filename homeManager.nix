
{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  nix-file-config = "/home/carlosfilho/Projetos/nix-config/configuration.nix";
  home-directory = "/home/carlosfilho";
  doom-emacs = pkgs.callPackage (builtins.fetchTarball {
    url = https://github.com/nix-community/nix-doom-emacs/archive/master.tar.gz;
  }) {
    doomPrivateDir = ./dotfile/doom.d;  # Directory containing your config.el init.el
    # and packages.el files
  };
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
      zoom-us  discord doom-emacs emacsPackages.all-the-icons
      aspellDicts.en aspellDicts.pt_BR aspellDicts.en-science
      aspellDicts.en-computers
    ];

    programs.git = {
      enable = true;
      userName  = "carlosalbertofilho";
      userEmail = "carlosalberto_filho@outlook.com";
    };

    programs.zsh = {
      enable = true;
      enableSyntaxHighlighting = true;
      shellAliases = {
        ls = "exa --group-directories-first --icons --color-scale";
	      lt = "exa --tree --level=2 --icons";
	      l = "exa";
        ll = "ls -lbG --git";
	      la = "exa -lah";
	      emacs = "emacs -nw";
    	  update = "sudo nixos-rebuild switch -I nixos-config=${nix-file-config}";
      };
      history = {
      	size = 10000;
    	  path = "${home-directory}/zsh/history";
      };
      zplug = {
        enable = true;
    	  plugins = [
	        { name = "zsh-users/zsh-autosuggestions"; } # Simple plugin installation
	      ];
      };
      oh-my-zsh = {
        enable = true;
    	  plugins = [ "git" "rsync" ];
    	  theme = "darkblood";
      };
    };

    home.file.".emacs.d/init.el".text = ''
      (load "default.el")
    '';

    home.file.".gnupg/gpg.conf".source = ./dotfile/gnupg/gpg.conf;
  };
}

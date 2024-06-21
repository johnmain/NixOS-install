{
  pkgs,
  username,
  host,
  ...
}:
let
  inherit (import ./variables.nix) gitUsername gitEmail;
in
{
  # Home Manager Settings
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.05";

  # Import Program Configurations
  imports = [
    
  ];
  programs.git = {
    enable = true;
    userName = "${gitUsername}";
    userEmail = "${gitEmail}";
  };
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
  # Define Settings For Xresources
  xresources.properties = {
    "Xcursor.size" = 24;
  };

  # Configure Cursor Theme
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };
  
  dconf.settings = {
	"org/virt-manager/virt-manager/connections" = {
	  autoconnect = [ "qemu:///system" ];
	  uris = [ "qemu:///system" ];
	};
  };
  gtk = {
    theme = {
      name = "Sweet-Dark-v40";
    };
    iconTheme = {
      name = "BeautyLine";
      
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
  qt = {
    enable = true;
    style.name = "adwaita-dark";
    platformTheme.name = "gtk3";
  };
programs = {
	fish = {
	  enable = true;
	  shellAliases = {
		cat = "bat";
		ls = "exa -la --icons --grid --group-directories-first";
	  };
	  shellInitLast = ''
		fastfetch
	  '';

	  interactiveShellInit = "
		set fish_greeting
	  ";
	  plugins = [
		{
		  name = "bobthefish";
		  src = pkgs.fishPlugins.bobthefish;
		}
	  ];
	};
};

}

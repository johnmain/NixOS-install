{
  config,
  pkgs,
  host,
  username,
  options,
  ...
}:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nvidia-drivers.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "tcp_bbr" ];
  boot.kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr";
  boot.kernel.sysctl."net.core.default_qdisc" = "fq";
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
  };


  networking.hostName = "frankenix"; # Define your hostname.
  networking.firewall.enable = false;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set GPU
  drivers.nvidia.enable = true;
  environment.extraInit = ''
    xset s off -dpms
    xset s off
  '';

  # Set your time zone.
  time.timeZone = "America/Winnipeg";
#  local.hardware-clock.enable = false;

  # Select internationalisation properties.
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Extra Portal Configuration
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal
    ];
    configPackages = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal
    ];
  };
  environment.sessionVariables = rec {
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";
    GTK_THEME = "Sweet-Dark-v40";

    # Not officially in the specification
    XDG_BIN_HOME    = "$HOME/.local/bin";
    PATH = [ 
      "${XDG_BIN_HOME}"
    ];
  };


  # Configure keymap in X11
  services = { 
    xserver = {
      enable=true;
      xkb = {
        layout = "us";      
        variant = "";
      };
      displayManager = {
        lightdm = {
          enable = true;
          greeters = {
            gtk = {
              enable = true;
            };
          };
        };
        setupCommands = ''
          ${pkgs.xorg.xrandr}/bin/xrandr --output DP-0 --off --output DP-1 --primary --mode 1920x1080 --pos 1920x1080 --rotate normal --output DP-2 --off --output DP-3 --mode 1920x1080 --pos 0x1080 --rotate normal --output HDMI-0 --mode 1920x1080 --pos 1920x0 --rotate normal --output DP-4 --off --output DP-5 --mode 1920x1080 --pos 0x0 --rotate normal
        '';
      };
      windowManager.i3 = {
        package = pkgs.i3-gaps;
        enable = true;
      };
      windowManager.bspwm.enable = true;
    }; 
    
    libinput.enable = true;
    fstrim.enable = true;
    gvfs.enable = true;
    openssh.enable = true;
    flatpak.enable = true;
    printing = {
      enable = true;
      drivers = [
        # pkgs.hplipWithPlugin 
      ];
    };
 
    gnome.gnome-keyring.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        userServices = true;
      };
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    rpcbind.enable = false;
    nfs.server.enable = false;
    picom = {
      enable = true;
      fade = true;
      vSync = true;
      shadow = false;
      fadeDelta = 4 ;
      inactiveOpacity = 1;
      activeOpacity = 1;
      backend = "glx";
      settings = {
        blur = {
          strength = 5;
        };
      };
    };
  };
  hardware.printers = {
    ensurePrinters = [
    {
      name = "Xerox-B205";
      location = "Home";
      deviceUri = "socket://192.168.88.11";
      model = "drv:///sample.drv/generic.ppd";
      ppdOptions = {
        PageSize = "US Letter";
      };
    }
    ];
    ensureDefaultPrinter = "Xerox-B205";
  };
  systemd.services.flatpak-repo = {
    path = [ pkgs.flatpak ];
    script = ''
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
    netConf = ''
      192.168.88.11
    '';
    openFirewall = true;  
    # disabledDefaultBackends = [ "escl" ];
    
  };
  security.rtkit.enable = true;
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (
        subject.isInGroup("users")
          && (
            action.id == "org.freedesktop.login1.reboot" ||
            action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
            action.id == "org.freedesktop.login1.power-off" ||
            action.id == "org.freedesktop.login1.power-off-multiple-sessions"
          )
        )
      {
        return polkit.Result.YES;
      }
    })
  '';
  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jmain = {
    isNormalUser = true;
    description = "John Main";
    extraGroups = [ "networkmanager" "wheel" "scanner" "lp" "libvirtd" "gamemode"];
    shell = pkgs.fish;
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    arandr
    autotiling
    bat
    bc
    btop
    discord
    duf
    eza
    fastfetch
    ffmpeg
    file-roller
    floorp
    font-manager
    galculator
    geany
    git
    greetd.tuigreet
    hugo
    i3status-rust
    imv
    jellyfin-media-player
    jq
    killall
    kitty
    libnotify
    libvirt
    lm_sensors
    lshw
    lxappearance
    lxqt.lxqt-policykit
    mpv
    ncdu
    networkmanagerapplet
    nh
    nitrogen
    nixfmt-rfc-style
    pavucontrol
    pciutils
    qemu_kvm
    rofi
    shutter
    simple-scan
    socat
    speedtest-rs
    tree
    unrar
    unzip
    virt-viewer
    vscode
    gfxreconstruct
    glslang
    polybarFull
    spirv-cross
    spirv-headers
    spirv-tools
    sxhkd
    vulkan-extension-layer
    vulkan-headers
    vulkan-loader
    vulkan-tools
    vulkan-tools-lunarg
    vulkan-utility-libraries
    vulkan-validation-layers
    vkdisplayinfo
    vkd3d
    vkd3d-proton
    vk-bootstrap
    wget
    xfce.ristretto
    xfce.xfce4-screenshooter
    xfce.tumbler
    xorg.xrandr
    yad
    ydotool
  ];
  fonts.fontconfig.allowBitmaps = true;
  fonts.fontconfig.useEmbeddedBitmaps = true;
  fonts.fontDir.enable = true;
  fonts = {
    packages = with pkgs; [
      noto-fonts-emoji
      noto-fonts-cjk
      font-awesome
      siji
      jetbrains-mono
      symbola
      material-icons
      fira-code
      nerdfonts
    ];
  };
 
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs = {
    fish.enable = true;
    dconf.enable = true;
    seahorse.enable = true;
    fuse.userAllowOther = true;
    mtr.enable = true;
    virt-manager.enable = true;
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
    gamemode.enable = true;

    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };
  
  # Optimization settings and garbage collection automation
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Virtualization / Containers
  virtualisation.libvirtd.enable = true;

  system.stateVersion = "24.05"; # Did you read the comment?
}

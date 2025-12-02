{ config
, pkgs
, inputs
, ... 
}:
#fetchFromGitHub
#buildGoModule
#lib

let
  # Import user-specific configuration
  userConfig = import ./user-config.nix;

in
{
  # General System Configurations
  system.stateVersion = "25.05"; # System version specification
  nixpkgs.config.allowUnfree = true; # Enable non-free packages
  time.timeZone = "Europe/London"; # Set timezone

  # Automated GC
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Hardware and Boot Configurations
  imports = [ ./hardware-configuration.nix ]; # Include hardware-specific configurations
  boot = {
    loader = { 
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest; # Specify the Linux kernel package version
    kernelModules = [ "uinput" ];
  };
  
  # Disable all power management related services
  systemd.targets = {
    suspend = {};
    hibernate = {};
    hybrid-sleep = {};
    sleep = {};
  };
  
  # Override the NetworkManager-wait-online.service
  systemd.services.NetworkManager-wait-online = {
    enable = false;
  };

  # User Configurations
  users.users.${userConfig.username} = {
    isNormalUser = true;
    home = userConfig.homeDirectory;
    shell = pkgs.zsh; # Setting Zsh as the default shell
    extraGroups = [ "wheel" "networkmanager" "input" ];
  };

  # Create udev rule for uinput access
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="777", GROUP="input", OPTIONS+="static_node=uinput"
  '';

  # Better scheduling for CPU cycles - thanks System76!
  services.system76-scheduler.settings.cfsProfiles.enable = true;
  # Enable TLP (better than gnomes internal power manager)
  services.tlp = {
    enable = true;
    settings = {
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    };
  };
  # Disable GNOMEs power management
  services.power-profiles-daemon.enable = false;
  # Enable powertop
  powerManagement.powertop.enable = true;
  # Enable thermald (only necessary if on Intel CPUs)
  #services.thermald.enable = true;

  # disable acpi on boot
  #boot.kernelParams = [ "acpi=off" ];

  # Software and Package Configurations
  environment.systemPackages = with pkgs; [ # List of packages to be globally installed
    alacritty google-chrome wget docker wob libfido2 gh swappy swaylock-effects
    python3 python3Packages.pip shellcheck wdisplays git blueman brightnessctl hyprpaper
    home-manager pavucontrol alsa-utils grim bluez vscode shfmt mako slurp 
    unzip statix nixpkgs-fmt neofetch rofi libnotify waybar htop postgresql
    vscode networkmanagerapplet lsd helix gopls
    go noto-fonts noto-fonts-color-emoji direnv # terraform # firefox
    wayland wl-clipboard lsof tre-command fzf ripgrep bat zip obs-studio jq
    kitty zsh-autosuggestions gnumake
    #hydra-check  #strace 
  ];

  virtualisation.docker.enable = true; # Enable Docker
  programs.dconf.enable = true; # Enable DConf for configuration management
  programs.zsh.enable = true; # Enable ZSH for the system

  programs.hyprland = {
    enable = true;
    # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  # Sound and Media Configurations
  # sound.enable = true; # Enable sound support
  security.rtkit.enable = true; # Enable RTKit for low-latency audio
  
  services = {
    pipewire = { # Enable PipeWire for audio support
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true; # If you want to enable 32 bit application support
      };
      jack = {
        enable = true; 
      };
      pulse.enable = true; # This enables the PulseAudio compatibility modules
    };
    blueman.enable = true; # Blueman service for managing Bluetooth
    fwupd.enable = true; # Enable firmware update
    #tailscale.enable = true; # Enable Tailscale
  };

  # Network and Bluetooth Configurations
  networking = {
    networkmanager.enable = true; # Enable NetworkManager for network management
    #networkmanager-wait-online.service = false;
    hosts = { # Hosts file configurations
      "127.0.0.1" = [
      "neowin.net"
      ];
    };
    firewall.enable = false; # Disable the firewall
  };

  hardware = {
    bluetooth = {
      enable = true;
      package = pkgs.bluez; # Use the full Bluez package for Bluetooth support
      powerOnBoot = true; # Power on Bluetooth devices at boot
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };
    enableAllFirmware = true;
    graphics = {
      enable = true;
    };
  };

  security.pam.services.swaylock = { allowNullPassword = true; }; # Enable PAM for Swaylock
}

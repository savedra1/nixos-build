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
  system.stateVersion = "23.05"; # System version specification
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
    extraGroups = [ "wheel" "networkmanager" ]; # Adding the user to groups
  };

  # Better scheduling for CPU cycles - thanks System76!!!
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


  # Software and Package Configurations
  environment.systemPackages = with pkgs; [ # List of packages to be globally installed
    alacritty google-chrome wget docker wob libfido2 gh swappy swaylock-effects
    nodejs python3 python3Packages.pip shellcheck wdisplays git blueman brightnessctl hyprpaper
    home-manager pavucontrol alsa-utils grim bluez vscode gnome.gnome-boxes shfmt mako slurp 
    unzip statix nixpkgs-fmt neofetch rofi-wayland libnotify waybar htop postgresql
    insomnia docker-compose vscode slack networkmanagerapplet openfortivpn lsd helix gopls
    go python311Packages.ruff-lsp noto-fonts noto-fonts-emoji direnv terraform awscli2 wayland 
    jira-cli-go hydra-check wl-clipboard firefox dig fwupd #unstable.clipse
  ];

  virtualisation.docker.enable = true; # Enable Docker
  programs.dconf.enable = true; # Enable DConf for configuration management
  programs.zsh.enable = true; # Enable ZSH for the system

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  # Sound and Media Configurations
  sound.enable = true; # Enable sound support
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
    opengl = {
      enable = true; # Enable OpenGL support
      driSupport = true; # Enable Direct Rendering Infrastructure support
    };
  };

  security.pam.services.swaylock = { allowNullPassword = true; }; # Enable PAM for Swaylock

}

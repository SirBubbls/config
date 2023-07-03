{ config, pkgs, ... }:
{
  home.username = "sirbubbls";
  home.homeDirectory = "/home/sirbubbls";
  home.file.".config/alacritty/alacritty.yml".source = ./config/alacritty.yml;
  home.file.".config/kitty/kitty.conf".source = ./config/kitty.conf;

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    ripgrep
    zk
    exa
    nodejs
    fzf
    cowsay
    fd
    file
    thefuck
    zsh-syntax-highlighting
    unzip
    progress
    (nerdfonts.override { fonts = [ "Iosevka" ]; })
    # Kubernetes Tools
    kubectx
    kubectl
    kubelogin
    kubernetes-helm
    # Build utilities
    gnumake
  ];
  home.stateVersion = "23.05";
  programs.home-manager.enable = true;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv = {
    enable = true;
  };

  # Terminal Emulators
  # HACK currently disable because of OpenGL issues on non NixOS systems
  programs.kitty = {
    enable = false;
    font = { name = "Iosevka Term"; size = 17; };
    theme = "One Dark";
    settings = {
      enable_audio_bell = false;
      confirm_os_window_close = -1;
    };
    keybindings = {
      "ctrl+equal" = "change_font_size all +2.0";
      "ctrl+minus" = "change_font_size all -2.0";
    };
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      cl = "clear";
      ls = "exa";
      vim = "nivm";
    };
    localVariables = {
      EDITOR = "nvim";
    };
    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; }
        { name = "zsh-users/zsh-syntax-highlighting"; }
        { name = "b4b4r07/enhancd"; }
        { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; }
      ];
    };
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.5.0";
          sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
        };
      }
    ];
    initExtra = ''
      ${builtins.readFile ./p10k.zsh}
      ${builtins.readFile ./config.zsh}
      ${builtins.readFile ./zsh/wsl.zsh}
    '';
    enableCompletion = true;
    enableAutosuggestions = true;
  };
  programs.git = {
    enable = true;
    userName = "Lucas Sas Brunschier";
    userEmail = "lucassas@live.de";
    extraConfig = {
      rebase = {
        autostash = true;
      };
      color = {
        ui = true;
      };
      pull = {
        rebase = true;
      };
    };
    ignores = [
      ".DS_Store"
      "*.pyc"
    ];
  };
  programs.tmux = {
    enable = true;
    secureSocket = false;
    plugins = with pkgs.tmuxPlugins; [
      yank
      sensible
      {
        plugin = dracula;
        extraConfig = ''
          				set -g @dracula-show-battery false
          				set -g @dracula-show-powerline true
                  set -g @dracula-show-left-icon session
          				set -g @dracula-refresh-rate 10
          			'';
      }
    ];
    extraConfig = ''
      set-option -ga terminal-overrides ",xterm-256color:Tc"
      setw -g pane-base-index 1
      set -g mouse on
      set -g base-index 1
      bind e select-pane -U
      bind n select-pane -D
      bind h select-pane -L
      bind i select-pane -R
      bind v split-window -h
      bind s split-window -v
      bind k kill-pane
      bind r source-file ~/.config/tmux/tmux.conf
    '';
  };
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = [
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
    ];
    extraConfig = ''
      ${builtins.readFile ./nvim/init.vim}
    '';
    extraLuaConfig = ''
      ${builtins.readFile ./nvim/init.lua}
    '';
  };
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };
}

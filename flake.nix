{
  description = "Welteki's nixOS modules";

  inputs.nixpkgs.follows = "nix/nixpkgs";

  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nix, nixpkgs, home-manager }:
    {
      nixosModules.home-user =
        { pkgs, ... }:
        {
          imports = [ home-manager.nixosModules.home-manager ];

          users.users.welteki = {
            isNormalUser = true;
            home = "/home/welteki";
            shell = pkgs.zsh;
            description = "Han Verstraete";
            extraGroups = [ "wheel" "networkmanager" ];
            openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDh4g/DLrLpZOh7/pjXYnRI/aaX3STRzPNbpuIAVYTY7ROB1xPN9o0pUzvFZdJAVf74twBUmXv4FElzKS6eG+JXEKqQjGYMA82fKXHoRfgrRGEYc+wE7xodqO7VQxgnNhdVFe6BtVOyL8M8amjZU7z7DTfhFP0oQ4TBjqO7BnUMGLkARTZGCYvnIHXSYUQc7fk/Ejj5HeFWK+j9F6l1xhvE+n/1FDitvxTMTuQ52vSk5SynP7WMPcNtrfnLTcgcxOw0deDU57d18Ts64lYG+IHiZsTUaNqUmTum1SuIsAPY4trFDXs5B0X6ma364I34OyH1o3+lsnWsZC9EjlwKdjs33YGKec05OXq7qfHWO6Myj7SQrFDkFQCst6buMVJpf+ZfSym2vGs/6uOtTmK4zy1f3dW96esaY5ZaFPp4h+4GZ46Ok96iWfkbFfArabQUa5YkfV37gjmP7J1bz0AgVxuMM69hz4qtMpgvOEyXbAe5+Ex7WCIw3CeEWJjs20km6DhHzLmOmrBA4e+4llFH9357LwF+z3a6Cxyjw2h8vyt64+OSSjncd0cgFmi+32Pfl93iXqAgzlNYKlZtJZotKxhIJoWgYV7wziv/RjVw5IyJ/SLsBKRk36JWxYlGaKWbaxQoAZZSTGbTi8hfxx5VmNscL52turiEOSP7G8lXVrofBQ== welteki" ];
          };
          home-manager.useGlobalPkgs = true;
          home-manager.users.welteki = import ./home.nix;
        };

      nixosModules.vscode-server =
        { lib, pkgs, ... }:

        let
          name = "auto-fix-vscode-server";
          nodePath = "${pkgs.nodejs-14_x}/bin/node";
        in
        {
          # configuration from: https://github.com/msteen/nixos-vscode-server
          # Copyright 2020 Matthijs Steen
          # Distributed under the MIT software license
          # license: https://github.com/msteen/nixos-vscode-server/blob/master/LICENSE

          systemd.user.services.${name} = {
            description = "Automatically fix the VS Code server used by the remote SSH extension";
            wantedBy = [ "default.target" ];
            serviceConfig = {
              # When a monitored directory is deleted, it will stop being monitored.
              # Even if it is later recreated it will not restart monitoring it.
              # Unfortunately the monitor does not kill itself when it stops monitoring,
              # so rather than creating our own restart mechanism, we leverage systemd to do this for us.
              Restart = "always";
              RestartSec = 0;
              ExecStart = pkgs.writeShellScript "${name}.sh" ''
                set -euo pipefail
                PATH=${lib.makeBinPath (with pkgs; [ coreutils inotify-tools ])}
                bin_dir=~/.vscode-server/bin
                [[ -e $bin_dir ]] &&
                find "$bin_dir" -mindepth 2 -maxdepth 2 -name node -type f -exec ln -sfT ${nodePath} {} \; ||
                mkdir -p "$bin_dir"

                while IFS=: read -r bin_dir event; do
                  # A new version of the VS Code Server is being created.
                  if [[ $event == 'CREATE,ISDIR' ]]; then
                    # Create a trigger to know when their node is being created and replace it for our symlink.
                    touch "$bin_dir/node"
                    inotifywait -qq -e DELETE_SELF "$bin_dir/node"
                    ln -sfT ${nodePath} "$bin_dir/node"
                  # The monitored directory is deleted, e.g. when "Uninstall VS Code Server from Host" has been run.
                  elif [[ $event == DELETE_SELF ]]; then
                    # See the comments above Restart in the service config.
                    exit 0
                  fi
                done < <(inotifywait -q -m -e CREATE,ISDIR -e DELETE_SELF --format '%w%f:%e' "$bin_dir")
              '';
            };
          };
      };
    };
}

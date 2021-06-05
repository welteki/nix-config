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
    };
}

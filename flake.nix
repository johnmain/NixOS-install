{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs = { self, nixpkgs,home-manager, ... }@inputs:
     let
       system = "x86_64-linux";
       host = "frankenix";
       username = "jmain";
     in
     {
       nixosConfigurations = {
         "${host}" = nixpkgs.lib.nixosSystem {
           specialArgs = {
            inherit system;
            inherit inputs;
            inherit username;
            inherit host;
          };
          modules = [
            # Import the previous configuration.nix we used,
            # so the old configuration file still takes effect
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = {
                inherit username;
                inherit inputs;
                inherit host;
              };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${username} = import ./home.nix;
            }

          ];
        };
      };   
    };
  
}

{ nixified-ai, nixpkgs, system }: { pkgs, ... }: 
let 
  ai-pkgs = import nixpkgs { 
    inherit system;
    overlays = [
      nixified-ai.overlays.comfyui
      nixified-ai.overlays.models
      nixified-ai.overlays.fetchers
    ];
    config = {
      allowUnfree = true;
      cudaSupport = true;
    };
  }; 
in { 

  imports = [ nixified-ai.nixosModules.comfyui ]; 

  services.comfyui = {
    enable = true;
    package = nixified-ai.packages.${system}.comfyui-nvidia;
    host = "0.0.0.0";
    models = [ ai-pkgs.nixified-ai.models.stable-diffusion-v1-5 ]; 
  }; 
}

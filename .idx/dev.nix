# To learn more about how to use Nix to configure your environment
# see: https://developers.google.com/idx/guides/customize-idx-env
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-24.05"; # or "unstable"
  # Use https://search.nixos.org/packages to find packages
  packages = [ pkgs.python3 pkgs.go pkgs.go-task pkgs.patch ];
  services.docker.enable = true;
  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [ "ms-python.python" "ms-python.debugpy" "ms-python.black-formatter" ];
    workspace = {
      # Runs when a workspace is first created with this `dev.nix` file
      onCreate = { };
    };
    # Enable previews and customize configuration
    previews = {
      enable = false;
    };
  };
}

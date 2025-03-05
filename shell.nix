{
  npins ? import ./npins,
  nixpkgs ? npins.nixpkgs,
  pkgs ? import nixpkgs { },
}:

pkgs.mkShellNoCC {
  name = "otasecrets";
  buildInputs = [
    pkgs.npins
    pkgs.sops
    pkgs.ssh-to-age
  ];
}

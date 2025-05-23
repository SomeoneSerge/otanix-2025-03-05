{
  npins ? import ./npins,
  nixpkgs ? npins.nixpkgs,
  pkgs ? import nixpkgs { },
  lib ? pkgs.lib,
  system ? builtins.currentSystem,
  hex ? import ./hex.nix,
}:

let
  nixosModules.microvm = (npins."microvm.nix" + "/nixos-modules/microvm");
  nixosModules.sops-nix = (npins.sops-nix + "/modules/sops/");
  nixosSystem =
    args:
    import (npins.nixpkgs + "/nixos/lib/eval-config.nix") (
      {
        specialArgs = { } // args.specialArgs or { };
        modules = args.modules or [ ] ++ [ ];
      }
      // builtins.removeAttrs args [
        "modules"
        "specialArgs"
      ]
    );
  enumerate =
    xs:
    let
      out =
        builtins.foldl'
          (
            { numbered, n }:
            x: {
              numbered = numbered ++ [
                {
                  value = x;
                  inherit n;
                }
              ];
              n = n + 1;
            }
          )
          {
            numbered = [ ];
            n = 1;
          }
          xs;
    in
    out.numbered;
  vmsDir = builtins.readDir ./vms;
  vmsConfigs = lib.concatMap (
    name:
    if builtins.pathExists (./vms + "/${name}/configuration.nix") then
      [
        {
          inherit name;
          configuration = ./vms + "/${name}/configuration.nix";
        }
      ]
    else
      [ ]
  ) (builtins.attrNames vmsDir);
  vms = lib.listToAttrs (
    map (
      { value, n }:
      {
        inherit (value) name;
        value =
          let
            evaluated = nixosSystem {
              inherit system;
              modules = [
                value.configuration
                {
                  networking.hostName = value.name;
                  # microvm.hypervisor = "cloud-hypervisor";
                  microvm.interfaces = [
                    {
                      id = "uvm-${lib.substring 0 4 value.name}${hex.digit n}";
                      type = "user";
                      mac = "32:0f:da:96:a1:0${hex.digit n}"; # FIXME: support >16 hosts
                    }
                  ];
                  microvm.shares = [
                    {
                      source = "/nix/store";
                      mountPoint = "/nix/.ro-store";
                      tag = "ro-store";
                      proto = "9p";
                    }
                  ];
                  microvm.volumes = [
                    {
                      image = "etc-${value.name}.img";
                      mountPoint = "/etc";
                      size = 256;
                    }
                  ];
                }
                nixosModules.sops-nix
                nixosModules.microvm
              ];
            };
          in
          # Shorthand so we don't have to mention config.microvm.declaredRunner in the README
          evaluated.config.microvm.declaredRunner // { inherit (evaluated) config; };
      }

    ) (enumerate vmsConfigs)
  );
  tlFontsConf = pkgs.makeFontsConf {
    fontDirectories = [
      "${texlive}/share/texmf/"
    ];
  };
  texlive = pkgs.texliveSmall.withPackages (ps: [
    ps.beamer
    ps.biber
    ps.biblatex
    ps.cm-unicode
    ps.fontawesome5
    ps.latexmk
    ps.minted
  ]);
in
{
  inherit vms;
  ghkeys = pkgs.writeShellScriptBin "ghkeys" ''
    name=$1
    shift
    ${lib.getExe pkgs.curl} "https://github.com/$name.keys" 2>/dev/null | ${lib.getExe pkgs.ssh-to-age}
  '';
  slides = pkgs.stdenvNoCC.mkDerivation {
    pname = "otasecrets";
    version = "0.0.0";
    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./README.md
        ./qr.png
      ];
    };
    nativeBuildInputs = [
      pkgs.pandoc
      texlive
    ];
    FONTCONFIG_FILE = tlFontsConf;
    buildPhase = ''
      runHook preBuild
      pandoc -t beamer README.md -o otasecrets.pdf
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      mkdir "$out"
      cp otasecrets.pdf "$out"/
      runHook postInstall
    '';
  };
}

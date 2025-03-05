{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.openssh.enable = true;
  services.yggdrasil.enable = true;
  services.yggdrasil.persistentKeys = true;
  services.yggdrasil.openMulticastPort = true;
  services.yggdrasil.settings = {
    Peers = [
      "tcp://someonex.net:43212"
      "quic://home.flokli.io:6443"
      "wss://home.flokli.io:6443"
    ];
  };

  systemd.services."yggdrasilctl-getself" = {
    script = ''
      ${lib.getExe' pkgs.yggdrasil "yggdrasilctl"} getself
    '';
    after = [
      "multi-user.target"
      "yggdrasil-persistent-keys.service"
      "yggdrasil.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      StandardOutput = "journal+console";
      StandardError = "journal+console";
    };
  };

  # IPv6 address:           200:531b:e48d:d90c:1912:6176:1344:4e9c
  # Public key:             d6720db91379f376cf44f65dd8b18fe830a667a89f60504063f1a64f25b5c448
  sops.secrets."yggi/yggdrasil/PrivateKey".sopsFile = ./secrets.yaml;
  sops.templates."yggdrasil/keys.json".content = builtins.toJSON {
    PrivateKey = config.sops.placeholder."yggi/yggdrasil/PrivateKey";
  };

  systemd.services.yggdrasil-persistent-keys-pre = {
    serviceConfig.User = "root";
    serviceConfig.Type = "oneshot";
    before = [
      "yggdrasil-persistent-keys.service"
      "yggdrasil.service"
    ];
    requiredBy = [
      "yggdrasil-persistent-keys.service"
      "yggdrasil.service"
    ];
    script = ''
      mkdir -p /var/lib/yggdrasil
      cp ${config.sops.templates."yggdrasil/keys.json".path} /var/lib/yggdrasil/keys.json
      chmod a+rx /var/lib/yggdrasil/
      chmod a+r /var/lib/yggdrasil/keys.json
    '';
  };

  users.users.otanix = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "otanix";
  };
}

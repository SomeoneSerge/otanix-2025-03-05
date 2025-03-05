{
  lib,
  pkgs,
  ...
}:
{
  services.openssh.enable = true;
  services.yggdrasil.enable = true;
  services.yggdrasil.persistentKeys = true; # 200:531b:e48d:d90c:1912:6176:1344:4e9c
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


  users.users.otanix = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "otanix";
  };
}

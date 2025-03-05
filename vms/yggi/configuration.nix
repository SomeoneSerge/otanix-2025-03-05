{ config, lib, pkgs, ... }:
{
  services.openssh.enable = true;
  services.yggdrasil.enable = true;
  # services.yggdrasil.persistentKeys = true;
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
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
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

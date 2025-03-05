{ config, ... }:
{
  services.openssh.enable = true;
  services.yggdrasil.enable = true;
  services.yggdrasil.openMulticastPort = true;
  services.yggdrasil.settings = {
    Peers = [
      "tcp://someonex.net:43212"
      "quic://home.flokli.io:6443"
      "wss://home.flokli.io:6443"
    ];
  };

  users.users.otanix = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "otanix";
  };
}

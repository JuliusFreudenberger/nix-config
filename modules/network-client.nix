{
  pkgs,
  lib,
  ...
}: {
  networking = {
    networkmanager = {
      enable = true;
      wifi.powersave = true;
      # logLevel = "INFO";
    };
    wireguard.enable = true;
    firewall = {
      # if packets are still dropped, they will show up in dmesg
      logReversePathDrops = true;
      # wireguard trips rpfilter up
      extraCommands = ''
        iptables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 1194 -j RETURN
        ip6tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 1194 -j RETURN
        iptables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 1194 -j RETURN
        ip6tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 1194 -j RETURN
      '';
      extraStopCommands = ''
        iptables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 1194 -j RETURN || true
        ip6tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 1194 -j RETURN || true
        iptables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 1194 -j RETURN || true
        ip6tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 1194 -j RETURN || true
      '';
    };
  };
}

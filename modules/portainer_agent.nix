{
  ...
}: {
  virtualisation.oci-containers.containers = {
    portainer_agent = {
      image = "portainer/agent:2.33.2";
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "/var/lib/docker/volumes:/var/lib/docker/volumes"
        "/:/host"
      ];
      environment = {
        EDGE = "1";
        CAP_HOST_MANAGEMENT = "1";
      };
      extraOptions = [
        ''--mount=type=volume,source=portainer_agent,target=/data,volume-driver=local''
      ];
    };
  };
}

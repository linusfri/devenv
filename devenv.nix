{ pkgs, lib, config, inputs, ... }:
let
  testDomain = "local.test";
in
{
  config = {
    env = {
      NGINX_PORT = "8080";
      NGINX_SSL_PORT = "4430";
      NGINX_HOST = testDomain;
    };

    packages = with pkgs; [
      git
      mysql-client
      nginx
      gh
    ];

    certificates = [
     testDomain
    ];

    hosts."${testDomain}" = "127.0.0.1";

    services.nginx = {
      enable = lib.mkDefault true;
      httpConfig = lib.mkDefault ''
          server {
            listen ${toString config.env.NGINX_PORT};
            listen ${toString config.env.NGINX_SSL_PORT} ssl;
            ssl_certificate     ${config.env.DEVENV_STATE}/mkcert/${testDomain}.pem;
            ssl_certificate_key ${config.env.DEVENV_STATE}/mkcert/${testDomain}-key.pem;
            root ${config.env.DEVENV_ROOT}/src;
            index index.php index.html index.htm;
            server_name ${config.env.NGINX_HOST};

            error_page 497 https://$server_name:$server_port$request_uri;

            location / {
              try_files $uri $uri/ /index.php$is_args$args;
            }
          }
      '';
    };

    services.mysql = {

    };

    languages = {
      javascript = {
        enable = true;
        package = pkgs.nodejs_21;
      };
    };
  };
}
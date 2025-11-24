{ pkgs }:

let
  files = pkgs.stdenv.mkDerivation {
    name = "files";
    src = ./.;
    installPhase = ''
      mkdir -p $out/opt/www
      cp -r . $out/opt/www
    '';
  };

  services = {
    mysql = {
      enable = true;
      package = pkgs.mysql;
    };

    phpfpm = {
      phpPackage = pkgs.php;
      pools.www = {
        user = "pup";
        group = "pup";
        listen = "/run/php-fpm/www.sock";
      };
    };

    caddy = {
      enable = true;
      package = pkgs.caddy;
      extraConfig = ''
        :8090 {
          root * ${files}/opt/www
          php_fastcgi /run/php-fpm/www.sock
          file_server
          handle_errors {
            respond "404"
          }
        }
      '';
    };
  };
in
{
  inherit services;
}

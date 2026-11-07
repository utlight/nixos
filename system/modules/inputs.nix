{...}: {
  flake.modules.nixos.base = {...}: {
    services.xserver.xkb = {
      layout = "us";
    };

    services.keyd = {
      enable = true;
      keyboards.default = {
        ids = ["*"];
        settings = {
          main = {
            leftalt = "layer(leftalt)";
            capslock = "overload(capslock, esc)";
          };
          "leftalt:A" = {
            "y" = "@";
            "u" = "{";
            "i" = "+";
            "o" = "=";
            "p" = "}";
            "h" = "_";
            "j" = "^";
            "k" = "&";
            "l" = "*";
            ";" = "$";
            "n" = "-";
            "m" = "!";
            "," = "%";
            "." = "#";
            "/" = "|";
          };
          "capslock" = {
            "u" = "0";
            "i" = "3";
            "o" = "6";
            "j" = "1";
            "k" = "4";
            "l" = "7";
            ";" = "9";
            "m" = "2";
            "," = "5";
            "." = "8";
          };
        };
      };
    };
  };
}

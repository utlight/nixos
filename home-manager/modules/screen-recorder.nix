{...}: {
  flake.modules.homeManager.base = {pkgs, ...}: {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "toggle-recording";
        runtimeInputs = [pkgs.procps pkgs.libnotify];
        text = ''
          toggle() {
            noctalia msg plugin noctalia/screen_recorder:service all toggle
          }

          if pgrep -f gpu-screen-recorder >/dev/null; then
            toggle
            notify-send -i media-record "Recording stopped"
          else
            toggle
            sleep 1
            if pgrep -f gpu-screen-recorder >/dev/null; then
              notify-send -i media-record "Recording started"
            else
              notify-send -u critical "Recording failed to start" \
                "See ~/.local/state/noctalia/screen_recorder/gpu-screen-recorder.log"
            fi
          fi
        '';
      })
    ];
  };
}

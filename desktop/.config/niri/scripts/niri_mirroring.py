import subprocess
import time

# --- Configuration ---
# Your laptop monitor name as seen in 'niri msg outputs'
MONITOR_NAME: str = "eDP-2"


def run_command(cmd: str) -> str:
    """Helper to run a shell command and return the stripped output."""
    args = cmd.split(" ")
    result = subprocess.run(args, capture_output=True, text=True, check=True)
    return result.stdout.strip()


def get_all_outputs() -> list[str]:
    """Returns a list of all active output names."""
    cmd = "niri msg outputs | grep '^Output' | cut -d'(' -f 2 | cut -d')' -f 1"
    output = run_command(cmd)
    return output.split("\n") if output else []


def get_focused_output() -> str:
    """Returns the name of the currently focused output."""
    cmd = "niri msg focused-output | grep '^Output' | cut -d'(' -f 2 | cut -d')' -f 1"
    return run_command(cmd)


def toggle_mirroring() -> None:
    outputs: list[str] = get_all_outputs()

    # Only attempt mirroring if exactly two screens are connected (Laptop + Projector)
    if len(outputs) == 2:
        # Check if wl-mirror is already running.
        # pkill returns 0 if it successfully killed a process (meaning it was running).
        is_mirroring: bool = subprocess.run(["pkill", "wl-mirror"]).returncode == 0

        if not is_mirroring:
            # We want to start mirroring.
            # If focus is on the laptop, move it to the projector first
            # so the wl-mirror window opens on the external screen.
            if get_focused_output() == MONITOR_NAME:
                subprocess.run(["niri", "msg", "action", "focus-monitor-next"])

            # Start mirroring the laptop screen in Fullscreen (-F)
            subprocess.Popen(["wl-mirror", "-F", MONITOR_NAME])
            # Alternative fallback for mirroring
            # subprocess.Popen(["wl-mirror", "-b", "screencopy-dmabuf", "-F", MONITOR_NAME])

            # Wait for the window to initialize before moving focus back
            time.sleep(0.7)

        # Ensure focus returns to the laptop monitor so you can actually work
        if get_focused_output() != MONITOR_NAME:
            subprocess.run(["niri", "msg", "action", "focus-monitor-next"])


if __name__ == "__main__":
    toggle_mirroring()

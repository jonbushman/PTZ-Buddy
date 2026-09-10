"""Main control loop: gamepad input -> smoothed pan/tilt servo motion.

Run directly for bench testing, or install ptz-controller.service to
start automatically on boot.
"""
import time

import config
from gamepad_input import Gamepad
from servo_controller import PanTiltRig


def main():
    rig = PanTiltRig()
    pad = Gamepad()
    print(f"Gamepad connected: {pad.device.name}")

    period = 1.0 / config.LOOP_HZ
    last = time.monotonic()

    while True:
        now = time.monotonic()
        dt = now - last
        last = now

        pan_stick, tilt_stick = pad.poll()
        rig.step(pan_stick, tilt_stick, dt)

        sleep_left = period - (time.monotonic() - now)
        if sleep_left > 0:
            time.sleep(sleep_left)


if __name__ == "__main__":
    main()

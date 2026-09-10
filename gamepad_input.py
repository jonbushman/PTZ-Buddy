"""Reads a Bluetooth gamepad via evdev and exposes normalized left-stick
axes for pan/tilt control.
"""
import evdev
from evdev import ecodes

import config

# Most gamepads report the left stick on ABS_X / ABS_Y. Run `evtest`
# against your controller once to confirm - some report ABS_RX/ABS_RY for
# the stick you actually want to use instead.
AXIS_PAN = ecodes.ABS_X
AXIS_TILT = ecodes.ABS_Y


def find_gamepad():
    for path in evdev.list_devices():
        dev = evdev.InputDevice(path)
        caps = dev.capabilities().get(ecodes.EV_ABS, [])
        if any(code == AXIS_PAN for code, _ in caps):
            return dev
    raise RuntimeError(
        "No gamepad with an analog stick found. Pair it first with "
        "`bluetoothctl`, then confirm it shows up under /dev/input/."
    )


class Gamepad:
    def __init__(self):
        self.device = find_gamepad()
        self._ranges = {}
        for code in (AXIS_PAN, AXIS_TILT):
            info = self.device.absinfo(code)
            self._ranges[code] = (info.min, info.max)
        self.pan = 0.0
        self.tilt = 0.0

    def _normalize(self, code, raw_value):
        lo, hi = self._ranges[code]
        mid = (lo + hi) / 2
        span = (hi - lo) / 2
        value = (raw_value - mid) / span
        if abs(value) < config.STICK_DEADZONE:
            return 0.0
        return max(-1.0, min(1.0, value))

    def poll(self):
        """Drain pending events and return the current (pan, tilt) axes."""
        while True:
            event = self.device.read_one()
            if event is None:
                break
            if event.type != ecodes.EV_ABS:
                continue
            if event.code == AXIS_PAN:
                self.pan = self._normalize(AXIS_PAN, event.value)
            elif event.code == AXIS_TILT:
                self.tilt = self._normalize(AXIS_TILT, event.value)
        return self.pan, self.tilt

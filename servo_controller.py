"""Smooth-motion pan/tilt servo driver on a PCA9685 I2C board."""
import math

import board
import busio
from adafruit_motor import servo
from adafruit_pca9685 import PCA9685

import config


class Axis:
    """One servo axis with velocity-ramped, angle-limited motion.

    Motion is driven by target speed rather than target angle so the
    control loop can ramp acceleration smoothly frame to frame instead of
    snapping the servo straight to a commanded position.
    """

    def __init__(self, pca_channel, min_deg, max_deg, home_deg, max_speed, accel):
        self._servo = servo.Servo(
            pca_channel, min_pulse=config.SERVO_MIN_US, max_pulse=config.SERVO_MAX_US
        )
        self.min_deg = min_deg
        self.max_deg = max_deg
        self.max_speed = max_speed
        self.accel = accel
        self.angle = home_deg
        self.velocity = 0.0
        self._servo.angle = self.angle

    def update(self, target_speed, dt):
        """Ramp velocity toward target_speed (deg/s) and integrate angle."""
        target_speed = max(-self.max_speed, min(self.max_speed, target_speed))
        max_delta = self.accel * dt
        if target_speed > self.velocity:
            self.velocity = min(target_speed, self.velocity + max_delta)
        else:
            self.velocity = max(target_speed, self.velocity - max_delta)

        new_angle = self.angle + self.velocity * dt
        clamped = max(self.min_deg, min(self.max_deg, new_angle))
        if clamped != new_angle:
            self.velocity = 0.0  # hit a mechanical limit - stop dead, don't push
        self.angle = clamped
        self._servo.angle = self.angle

    def set_angle_immediate(self, angle_deg):
        self.angle = max(self.min_deg, min(self.max_deg, angle_deg))
        self.velocity = 0.0
        self._servo.angle = self.angle


class PanTiltRig:
    def __init__(self):
        i2c = busio.I2C(board.SCL, board.SDA)
        self.pca = PCA9685(i2c)
        self.pca.frequency = 50

        self.pan = Axis(
            self.pca.channels[config.PAN_CHANNEL],
            config.PAN_MIN_DEG,
            config.PAN_MAX_DEG,
            config.PAN_HOME_DEG,
            config.PAN_MAX_SPEED,
            config.PAN_ACCEL,
        )
        self.tilt = Axis(
            self.pca.channels[config.TILT_CHANNEL],
            config.TILT_MIN_DEG,
            config.TILT_MAX_DEG,
            config.TILT_HOME_DEG,
            config.TILT_MAX_SPEED,
            config.TILT_ACCEL,
        )

    def _tilt_compensation_factor(self):
        """Scale factor for pan speed based on how far off level the tilt is.

        See config.TILT_COMPENSATION for the reasoning - this is what
        prevents a diagonal stick move from curving across the frame.
        """
        offset = math.radians(self.tilt.angle - config.TILT_LEVEL_DEG)
        factor = math.cos(offset)
        return 1.0 - config.TILT_COMPENSATION * (1.0 - factor)

    def step(self, pan_stick, tilt_stick, dt):
        """pan_stick/tilt_stick are normalized gamepad axes in [-1, 1]."""
        pan_speed = pan_stick * self.pan.max_speed * self._tilt_compensation_factor()
        tilt_speed = tilt_stick * self.tilt.max_speed
        self.pan.update(pan_speed, dt)
        self.tilt.update(tilt_speed, dt)

    def home(self):
        self.pan.set_angle_immediate(config.PAN_HOME_DEG)
        self.tilt.set_angle_immediate(config.TILT_HOME_DEG)

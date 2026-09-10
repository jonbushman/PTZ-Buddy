"""PTZ rig configuration - tune these for your hardware and lens FOV."""

# PCA9685 channels
PAN_CHANNEL = 0
TILT_CHANNEL = 1

# Servo pulse range (microseconds). 500/2500 is a safe wide default for
# MG995-style digital servos; narrow it if your servos buzz at the
# extremes instead of stopping cleanly.
SERVO_MIN_US = 500
SERVO_MAX_US = 2500

# Mechanical travel limits, degrees. Keep inside the servo's rated 180 deg
# and leave margin so the camera can't crash into the bracket or its own
# cabling.
PAN_MIN_DEG = 10
PAN_MAX_DEG = 170
TILT_MIN_DEG = 45
TILT_MAX_DEG = 135
TILT_LEVEL_DEG = 90  # tilt angle that corresponds to a level horizon

# Starting position on boot / home command
PAN_HOME_DEG = 90
TILT_HOME_DEG = 90

# Max angular speed, degrees/second, at full stick deflection
PAN_MAX_SPEED = 60.0
TILT_MAX_SPEED = 40.0

# Accel/decel ramp, degrees/second^2 - this is what keeps whip-pans smooth
# on stream instead of snapping instantly to full speed
PAN_ACCEL = 120.0
TILT_ACCEL = 90.0

# Tilt-compensated pan speed: broadcast PTZ heads slow the pan rate as tilt
# moves away from level so a diagonal move traces a straight line on screen
# instead of a visible curve. 1.0 = full compensation, 0.0 = disabled.
# Depends on your lens FOV/zoom, so expect to tune this by eye on camera.
TILT_COMPENSATION = 1.0

# Joystick deadzone (0-1) to stop drift-induced creep
STICK_DEADZONE = 0.08

# Control loop rate, Hz
LOOP_HZ = 50

# PTZ Buddy

Raspberry Pi + PCA9685 + two 20kg servos, driven by a Bluetooth gamepad's
left stick, for a DIY pan/tilt camcorder mount. This covers pan/tilt only
- the Vixia HF R600/R800 have no LANC port, so zoom/record stay manual (or
a future IR-blaster hack) rather than motorized.

## Wiring

- **PCA9685** on the Pi's I2C bus (`SDA`/`SCL`, plus 3.3V logic power and
  ground). Enable I2C first: `sudo raspi-config` -> Interface Options -> I2C.
- **Servo power (V+ on the PCA9685 terminal block)** comes from a separate
  5-6V, 3A+ supply - NOT the Pi's 5V rail. Two 20kg servos can pull well
  over 1A each under load; sharing the Pi's supply causes brownouts and
  random reboots. Tie the servo supply's ground to the Pi's ground.
- Pan servo -> PCA9685 channel 0, tilt servo -> channel 1 (see `config.py`
  if you wire them differently).

## Bluetooth gamepad pairing

```
sudo bluetoothctl
power on
agent on
scan on          # find your controller's MAC, then:
scan off
pair   <MAC>
trust  <MAC>
connect <MAC>
```

Confirm it shows up with `ls /dev/input/` and run `evtest` against it once
to check which `ABS_*` codes the left stick reports - most report
`ABS_X`/`ABS_Y`, but some (Switch Pro-style controllers especially) use
`ABS_RX`/`ABS_RY` instead. Update `AXIS_PAN`/`AXIS_TILT` in
`gamepad_input.py` if needed.

## Setup

```
pip install -r requirements.txt
python3 ptz_service.py   # bench test with the gamepad connected
```

Tune `config.py` before your first live test:
- `PAN_MIN_DEG`/`PAN_MAX_DEG`/`TILT_MIN_DEG`/`TILT_MAX_DEG` - set these to
  match your bracket's actual safe range of motion, with margin so the
  camera can't hit its own mount or cabling.
- `PAN_MAX_SPEED`/`TILT_MAX_SPEED` and `*_ACCEL` - how fast/snappy the rig
  feels under stick input.
- `TILT_COMPENSATION` - see below.

To run on boot:

```
sudo cp ptz-controller.service /etc/systemd/system/
sudo systemctl enable --now ptz-controller
```

## The "curving pan" fix

Panning at a fixed angular rate while tilted off level causes a diagonal
stick move to trace a visible curve on screen instead of a straight line -
this is a known artifact on two-axis pan/tilt heads, and professional PTZ
cameras counter it with "tilt-compensated pan speed": the pan rate is
scaled down as tilt moves away from level. `servo_controller.py` implements
a first-pass version of this (`PanTiltRig._tilt_compensation_factor`,
tuned via `config.TILT_COMPENSATION`). The right amount of compensation
depends on your lens FOV and zoom level, so expect to tune it by eye on
camera rather than trusting the default.

## 3D-printed bracket

See `cad/README.md` for the parametric pan/tilt bracket (OpenSCAD source,
STLs, and assembly instructions) that carries the camcorder on these two
servos.

## Future ideas

The control loop is intentionally split into small pieces
(`Gamepad`, `Axis`, `PanTiltRig`) so later additions can hook in without a
rewrite - preset positions, a network/websocket control surface (e.g. tied
into OBS or Overlay-Buddy for automated camera cuts), or recording gamepad
moves for playback.

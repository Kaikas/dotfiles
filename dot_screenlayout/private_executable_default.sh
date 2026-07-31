#!/bin/sh
# Dual 3840x2160@60, left to right: HDMI-A-1 | DisplayPort-1
# Output names changed with the new docking station (was HDMI-A-0 | DisplayPort-1).
#
# The LG UltraGear panels do 144 Hz, but their EDID only advertises 4K@60 over
# the current links: HDMI 2.0 caps 3840x2160 at 60, and the DP input defaults to
# DisplayPort 1.2. To get 3840x2160@144, put both screens on DP and switch
# "DisplayPort Version" to 1.4 in the monitor OSD, then raise --rate here.
#
# Only touch outputs that are actually connected -- xrandr fails the *whole*
# call if a mode is set on a disconnected output, which silently kills the
# second monitor.

xrandr \
  --output HDMI-A-1      --mode 3840x2160 --rate 60 --pos 0x0    --rotate normal --primary \
  --output DisplayPort-1 --mode 3840x2160 --rate 60 --pos 3840x0 --rotate normal \
  --output HDMI-A-0      --off \
  --output DisplayPort-0 --off

#!/usr/bin/env bash
set -Eeo pipefail

source /opt/ros/jazzy/setup.bash
source /opt/husky_overlay/setup.bash
if [[ -f /workspaces/ros_ws/install/setup.bash ]]; then
  source /workspaces/ros_ws/install/setup.bash
fi
set -u

unset ROS_DISCOVERY_SERVER
export RMW_IMPLEMENTATION=rmw_zenoh_cpp
export ROS_SUPER_CLIENT=True
export DISPLAY=:1
export QT_X11_NO_MITSHM=1
export LIBGL_ALWAYS_SOFTWARE=1

if [[ "${1:-}" != sim ]]; then
  exec "$@"
fi

cp /opt/husky_config/robot.yaml /runtime/clearpath/robot.yaml

Xvfb :1 -screen 0 1920x1080x24 -nolisten tcp &
xvfb_pid=$!
sleep 2
openbox &
openbox_pid=$!
x11vnc -display :1 -forever -shared -nopw -localhost -rfbport 5900 &
vnc_pid=$!
websockify --web=/usr/share/novnc 0.0.0.0:6080 localhost:5900 &
web_pid=$!

ros2 run rmw_zenoh_cpp rmw_zenohd &
zenoh_pid=$!
sleep 3

ros2 launch clearpath_gz simulation.launch.py setup_path:=/runtime/clearpath &
gazebo_pid=$!
sleep 15

ros2 launch clearpath_viz view_navigation.launch.py \
  namespace:=/a200_1077 use_sim_time:=true &
rviz_pid=$!
ros2 launch clearpath_nav2_demos nav2.launch.py \
  scan_topic:=/a200_1077/sensors/lidar3d_0/scan \
  use_sim_time:=true setup_path:=/runtime/clearpath &
nav2_pid=$!
ros2 launch clearpath_nav2_demos slam.launch.py \
  scan_topic:=/a200_1077/sensors/lidar3d_0/scan \
  use_sim_time:=true setup_path:=/runtime/clearpath &
slam_pid=$!

cleanup() {
  kill "$slam_pid" "$nav2_pid" "$rviz_pid" "$gazebo_pid" \
       "$zenoh_pid" "$web_pid" "$vnc_pid" "$openbox_pid" "$xvfb_pid" \
       2>/dev/null || true
  wait 2>/dev/null || true
}
trap cleanup EXIT INT TERM
wait "$gazebo_pid"

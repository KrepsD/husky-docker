#!/usr/bin/env bash
set -Eeo pipefail

source /opt/ros/jazzy/setup.bash
source /opt/husky_overlay/setup.bash
set -u
cd /workspaces/ros_ws
colcon build --symlink-install "$@"
printf '\nBuild concluído. Em novos terminais, use: source /workspaces/ros_ws/install/setup.bash\n'

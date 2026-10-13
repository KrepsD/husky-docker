FROM ros:jazzy

ENV DEBIAN_FRONTEND=noninteractive \
    ROS_DISTRO=jazzy \
    DISPLAY=:1 \
    QT_X11_NO_MITSHM=1 \
    LIBGL_ALWAYS_SOFTWARE=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-jazzy-clearpath-simulator \
    ros-jazzy-clearpath-nav2-demos \
    ros-jazzy-clearpath-viz \
    ros-jazzy-rmw-zenoh-cpp \
    ros-jazzy-nav2-bringup \
    ros-jazzy-navigation2 \
    ros-jazzy-slam-toolbox \
    ros-jazzy-cv-bridge \
    python3-colcon-common-extensions \
    python3-pip \
    python3-rosdep \
    build-essential \
    xvfb x11vnc novnc websockify openbox dbus-x11 \
    libgl1-mesa-dri mesa-utils \
    && rm -rf /var/lib/apt/lists/*

# O nav2.yaml original do A200 usa esta camada adicional de costmap.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-jazzy-spatio-temporal-voxel-layer \
    && rm -rf /var/lib/apt/lists/*

# CPU-only para funcionar também sem GPU no host. O Python do ROS 2 usa
# /usr/bin/python3, então as bibliotecas ficam no mesmo interpretador.
# NumPy 1.x preserva a compatibilidade binária com o cv_bridge do Jazzy.
RUN python3 -m pip install --no-cache-dir --break-system-packages \
      --index-url https://download.pytorch.org/whl/cpu \
      torch==2.14.1+cpu torchvision==0.29.1+cpu \
    && python3 -m pip install --no-cache-dir --break-system-packages \
      --ignore-installed typing-extensions==4.16.0 \
    && python3 -m pip install --no-cache-dir --break-system-packages \
      'numpy<2' 'opencv-python-headless<4.12' \
      ultralytics-opencv-headless==8.4.177 \
    && mkdir -p /opt/husky/models \
    && cd /opt/husky/models \
    && python3 -c 'from ultralytics import YOLO; YOLO("yolo26n.pt")'

# Cópias das alterações locais da simulação; o projeto original não é editado.
COPY overrides/ /opt/ros/jazzy/share/
COPY bundled/fees02_description/ /opt/husky_src/src/fees02_description/
COPY config/robot.yaml /opt/husky_config/robot.yaml
COPY scripts/ /opt/husky/scripts/

RUN . /opt/ros/jazzy/setup.sh \
    && cd /opt/husky_src \
    && colcon build --merge-install --packages-select fees02_description \
         --install-base /opt/husky_overlay --cmake-args -DBUILD_TESTING=OFF \
    && chmod +x /opt/husky/scripts/*.sh \
    && mkdir -p /workspaces/ros_ws/src /workspaces/ros_ws/build \
         /workspaces/ros_ws/install /workspaces/ros_ws/log /runtime/clearpath \
    && chmod 1777 /workspaces/ros_ws/build /workspaces/ros_ws/install \
         /workspaces/ros_ws/log

WORKDIR /workspaces/ros_ws
EXPOSE 6080
ENTRYPOINT ["/opt/husky/scripts/entrypoint.sh"]
CMD ["sim"]

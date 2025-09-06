# --- Base image ---
FROM osrf/ros:jazzy-desktop

LABEL name="ros2-gazebo-vnc" \
      description="ROS 2 Jazzy + Gazebo Harmonic + TurboVNC desktop with persistent home"

# --- Environment variables ---
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    USERNAME=ubuntu \
    HOME=/home/ubuntu \
    DISPLAY=:1 \
    DISPLAY_WIDTH=1280 \
    DISPLAY_HEIGHT=720 \
    SVGA_VGPU10=0 \
    ROS_LOG_DIR=/tmp/.ros/log \
    VNC_PASSWORD=changeme \
    PATH=$PATH:/opt/TurboVNC/bin

WORKDIR $HOME

# --- Locale, essentials, GUI packages, TurboVNC, OpenGL ---
RUN apt update && apt install -y \
    sudo wget curl gnupg2 lsb-release software-properties-common \
    locales xfce4 xfce4-terminal x11-apps \
    mesa-utils libgl1-mesa-dri libglx-mesa0 libglu1-mesa libegl-mesa0 \
    ca-certificates && \
    locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    add-apt-repository universe && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    # --- TurboVNC & VirtualGL repos ---
    wget -q -O- "https://packagecloud.io/dcommander/turbovnc/gpgkey" | gpg --dearmor > /etc/apt/trusted.gpg.d/TurboVNC.gpg && \
    wget -q -O /etc/apt/sources.list.d/TurboVNC.list "https://raw.githubusercontent.com/TurboVNC/repo/main/TurboVNC.list" && \
    wget -q -O- https://packagecloud.io/dcommander/libjpeg-turbo/gpgkey | gpg --dearmor > /etc/apt/trusted.gpg.d/libjpeg-turbo.gpg && \
    wget -q -O /etc/apt/sources.list.d/libjpeg-turbo.list "https://raw.githubusercontent.com/libjpeg-turbo/repo/main/libjpeg-turbo.list" && \
    wget -q -O- https://packagecloud.io/dcommander/virtualgl/gpgkey | gpg --dearmor > /etc/apt/trusted.gpg.d/VirtualGL.gpg && \
    wget -q -O /etc/apt/sources.list.d/VirtualGL.list "https://raw.githubusercontent.com/VirtualGL/repo/main/VirtualGL.list" && \
    # --- Gazebo repo ---
    curl -fsSL https://packages.osrfoundation.org/gazebo.gpg -o /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] \
    https://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/gazebo-stable.list && \
    apt update && apt install -y \
    turbovnc virtualgl libjpeg-turbo-official \
    gz-harmonic && \
    rm -rf /var/lib/apt/lists/*

# --- Final APT check ---
RUN apt update && apt full-upgrade -y && rm -rf /var/lib/apt/lists/*

# --- Switch user & permissions ---
RUN mkdir -p $HOME && chown -R $USERNAME:$USERNAME $HOME
USER $USERNAME

# --- VNC setup ---
RUN mkdir -p $HOME/.vnc && \
    echo "$VNC_PASSWORD" | /opt/TurboVNC/bin/vncpasswd -f > $HOME/.vnc/passwd && \
    chmod 600 $HOME/.vnc/passwd

RUN echo -e "#!/bin/bash\nxrdb \$HOME/.Xresources\nstartxfce4 &" > $HOME/.vnc/xstartup && \
    chmod +x $HOME/.vnc/xstartup

# --- Expose VNC port ---
EXPOSE 5901

# --- ROS 2 entrypoint ---
RUN echo "source /opt/ros/jazzy/setup.bash" >> $HOME/.bashrc

# --- Default CMD to start VNC ---
CMD ["/bin/bash", "-c", "rm -f /tmp/.X1-lock /tmp/.X1.pid /tmp/.X11-unix/X1 && /opt/TurboVNC/bin/vncserver :1 -geometry ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT} -depth 24 -fg"]


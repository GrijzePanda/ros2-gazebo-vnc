# ros2-gazebo-vnc Docker Container

**ROS 2 Jazzy + Gazebo Harmonic + TurboVNC desktop environment with persistent workspace.**

This container provides ROS 2 Jazzy Jalisco & Gazebo Harmonic in Docker, based on the MathWorks Robotics ROS Toolbox Dockerfile, carefully modified to fit my needs, and refined with guidance from an LLM.

## Build the Docker image

Run this in the directory containing the `Dockerfile`:

```bash
docker build -t ros2-gazebo-vnc .
```

## Prepare a persistent home folder

Create a folder on your host to store all container files:

```bash
mkdir -p ~/ros2-gazebo-vnc_data
```

## Run the container

```bash
docker run -d \
    -p 5901:5901 \
    -v ~/ros2-gazebo-vnc_data:$HOME \
    --name ros2-gazebo-vnc-container \
    ros2-gazebo-vnc
```

## Connect via VNC

1. Open your VNC client.
2. Connect to: `localhost:5901`
3. Use the password you set with `VNC_PASSWORD`.

You should see the XFCE desktop environment with ROS 2 Jazzy and Gazebo Harmonic ready.

## Stop and restart container

Stop the container:

```bash
docker stop ros2-gazebo-vnc-container
```

Restart with all data preserved:

```bash
docker start -d ros2-gazebo-vnc-container
```

## Sources

* ROS instructions: [ROS Jazzy Installation](https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debs.html)
* Gazebo instructions: [Gazebo Harmonic Install](https://gazebosim.org/docs/harmonic/install_ubuntu/)
* VNC instructions: [TurboVNC setup gist](https://gist.github.com/Ryther/b2718e68e7bc05bf4191391bdd8cd8ef)
* MathWorks Dockerfile reference: [MathWorks ROS Toolbox Docker](https://www.mathworks.com/help/ros/ug/install-and-set-up-docker-for-ros-2-and-gazebo.html)

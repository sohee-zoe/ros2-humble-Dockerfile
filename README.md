# ros2-humble-Dockerfile
Ubuntu 22.04   

ROS 2 Humble   

Base Image: osrf/ros:humble-desktop-full   


## XServer
```bash
xhost +local:docker
echo 'xhost +local:docker' | sudo tee /etc/profile.d/xhost.sh
sudo chmod +x /etc/profile.d/xhost.sh
```

## NVIDIA Container Toolkit
```bash
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
```

```bash
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
```

```bash
sudo nvidia-ctk runtime configure --runtime=docker --set-as-default
```

```bash
sudo systemctl restart docker
```


## Docker Build
```bash
echo "root:<password>" > .passwd
chmod 600 .passwd
docker build --secret id=passwd,src=.passwd -t <image_name> .
```

```bash
echo "root:1234" > .passwd
chmod 600 .passwd
docker build --secret id=passwd,src=.passwd -t ros2-humble .
```


## Docker Run
```bash
docker run \
    --name <container_name> \
    --hostname <container_hostname> \
    -itd \
    --net host \
    --restart always \
    --privileged \
    --runtime nvidia \
    --gpus all \
    -e DISPLAY=unix$DISPLAY \
    -e QT_X11_NO_MITSHM=1 \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -v $HOME/.Xauthority:/root/.Xauthority:rw \
    -v $HOME/<host_workspace>:/root/<container_workspace> \
    -w /root/ws \
    <image_name> \
    tail -f /dev/null
```

```bash
docker run \
    --name ros2 \
    --hostname humble \
    -itd \
    --net host \
    --restart always \
    --privileged \
    --runtime nvidia \
    --gpus all \
    -e DISPLAY=unix$DISPLAY \
    -e QT_X11_NO_MITSHM=1 \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -v $HOME/.Xauthority:/root/.Xauthority:rw \
    -v $HOME/project/ros2/humble/ws:/root/ws \
    -w /root/ws \
    ros2-humble \
    tail -f /dev/null
```


## Docker exec
```bash
docker exec -it <container_name> /bin/zsh
```

```bash
docker exec -it ros2 /bin/zsh
```

## Python Setting
### (Option 1) mise + uv + python
```bash
mise use -g python@3.10
mise use -g uv@latest
echo 'eval "$(uv generate-shell-completion zsh)"' >> ~/.zshrc
echo 'eval "$(uvx --generate-shell-completion zsh)"' >> ~/.zshrc
exec zsh
```

### (Option 2) pyenv
```bash
curl -fsSL https://pyenv.run | bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init - zsh)"' >> ~/.zshrc
exec zsh

pyenv install 3.10
pyenv global 3.10
```


## Install dependencies packages
```bash
apt-get update
apt-get install -y \
    libbullet-dev \
    python3-colcon-common-extensions \
    python3-flake8 \
    python3-pip \
    python3-pytest-cov \
    python3-rosdep \
    python3-setuptools \
    python3-vcstool
```
- `build-essential`: 빌드 도구
- `libbullet-dev`: Bullet 물리 엔진 라이브러리
- `python3-colcon-common-extensions`, `python3-vcstool`, `python3-rosdep`, `python3-setuptools`: 빌드 도구 colcon, vcstool, rosdep 등을 위한 Python 패키지
- `python3-flake8`, `python3-pytest-cov`: Python 코드 스타일 체커와 테스트 도구


```bash
# 미들웨어 구현체 (Fast-RTPS, CycloneDDS)
apt-get install -y \
    ros-humble-rmw-fastrtps-cpp \
    ros-humble-rmw-cyclonedds-cpp

# Gazebo 패키지
apt-get install -y \
    ros-humble-gazebo-ros \
    ros-humble-gazebo-ros-pkgs \
    ros-humble-gazebo-ros2-control

# SLAM 패키지
apt-get install -y \
    ros-humble-slam-toolbox

# Cartographer 패키지
apt-get install -y \
    ros-humble-cartographer \
    ros-humble-cartographer-ros
    
# Navigation2 패키지
apt-get install -y \
    ros-humble-navigation2 \
    ros-humble-nav2-bringup 
    
# ROS2 motion planning 프레임워크
apt-get install -y \
    ros-humble-moveit
    
# 로봇 상태 및 TF 관련 패키지
apt-get install -y \
    ros-humble-joint-state-publisher \
    ros-humble-robot-state-publisher \
    ros-humble-rqt-tf-tree \
    ros-humble-xacro

# 로봇 위치 추정 및 제어 관련 패키지
apt-get install -y \
    ros-humble-robot-localization \
    ros-humble-twist-mux

# 데이터 로깅 및 시각화 패키지
apt-get install -y \
    ros-humble-plotjuggler-ros \
    ros-humble-ros2bag \
    ros-humble-rosbag2-storage-default-plugins

# 하드웨어 인터페이스 패키지
apt-get install -y \
    ros-humble-usb-cam

# turtlebot3 로봇 플랫폼 패키지
apt-get install -y \
    ros-humble-turtlebot3 \
    ros-humble-turtlebot3-msgs
```

## Virtual Enviroenment Using UV
```bash
uv init
uv venv --python=3.10
source .venv/bin/activate
uv add pip setuptools wheel
```

## Python Packages
```bash
uv add argcomplete \
  flake8-blind-except \
  flake8-builtins \
  flake8-class-newline \
  flake8-comprehensions \
  flake8-deprecated \
  flake8-docstrings \
  flake8-import-order \
  flake8-quotes \
  pytest-repeat \
  pytest-rerunfailures \
  pytest
```

## C++ Libraries
```bash
apt install --no-install-recommends -y \
  libasio-dev \
  libtinyxml2-dev \
  libcunit1-dev
```

## PyQT
```bash
apt-get install pyqt5-dev-tools
uv add catkin_pkg \
    cryptography \
    empy \
    ifcfg \
    lark-parser \
    lxml \
    netifaces \
    numpy \
    opencv-python \
    pyparsing \
    pyyaml \
    setuptools \
    rosdistro
uv add pydot PyQt5
```

## Envirionment Setup
`/root/.zshrc`에 추가

```bash
source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.zsh
source /usr/share/vcstool-completion/vcs.zsh
source /usr/share/colcon_cd/function/colcon_cd.sh
export _colcon_cd_root=~/ws

export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
# export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
# export RMW_IMPLEMENTATION=rmw_connext_cpp
# export RMW_IMPLEMENTATION=rmw_gurumdds_cpp

# export RCUTILS_CONSOLE_OUTPUT_FORMAT='[{severity} {time}] [{name}]: {message} ({function_name}() at {file_name}:{line_number})'
export RCUTILS_CONSOLE_OUTPUT_FORMAT='[{severity}]: {message}'
export RCUTILS_COLORIZED_OUTPUT=1
export RCUTILS_LOGGING_USE_STDOUT=0
export RCUTILS_LOGGING_BUFFERED_STREAM=1

autoload -U bashcompinit
bashcompinit
eval "$(register-python-argcomplete3 ros2)"
eval "$(register-python-argcomplete3 colcon)"

alias rosdi="rosdep install --from-paths src --ignore-src --rosdistro=${ROS_DISTRO} -y"
alias cbuild="colcon build --symlink-install"
alias ssetup="source ~/ws/install/local_setup.zsh"

alias cyclone="export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp"
alias fastdds="export RMW_IMPLEMENTATION=rmw_fastrtps_cpp"

alias killgazebo='killall -9 gazebo & killall -9 gzserver & killall -9 gzclient'

alias cb='cd ~/ws && colcon build --symlink-install'
alias cbs='colcon build --symlink-install'
alias cbp='colcon build --symlink-install --packages-select'
alias cbu='colcon build --symlink-install --packages-up-to'
alias ct='colcon test'
alias ctp='colcon test --packages-select'
alias ctr='colcon test-result'

alias rt='ros2 topic list'
alias re='ros2 topic echo'
alias rn='ros2 node list'

alias testpub='ros2 run demo_nodes_cpp talker'
alias testsub='ros2 run demo_nodes_cpp listener'
alias testpubimg='ros2 run image_tools cam2image'
alias testpubimgshow='ros2 run image_tools cam2image --ros-args -p show_camera:=true'
alias testsubimg='ros2 run image_tools showimage'
```

```bash
exec zsh
```

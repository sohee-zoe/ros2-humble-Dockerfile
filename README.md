# ros2-humble-Dockerfile
Ubuntu 22.04   

ROS 2 Humble   

Base Image: osrf/ros:humble-desktop-full   




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


## Docker exec
```bash
docker exec -it <container_name> /bin/zsh
```


## zsh Shell
```bash
sudo chsh -s $(which zsh)
```


## mise + uv + python
```bash
mise use -g python@3.10
mise use -g uv@latest
exec zsh
```

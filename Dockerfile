# 베이스 이미지 (ROS2 Humble Desktop Full)
FROM osrf/ros:humble-desktop-full

ARG ROOT_PASSWORD=${passwd}

# 패키지 설치
RUN sed -i 's/archive.ubuntu.com/mirror.kakao.com/' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    curl \
    git \
    nano \
    neovim \
    wget \
    zsh \
    locales \
    openssh-server \
    net-tools \
    gazebo \
    && rm -rf /var/lib/apt/lists/*

# 로케일 설정 (zsh 오류 방지)
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# SSH 설정
RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo "root:${ROOT_PASSWORD}" | chpasswd

# ZSH 설정
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.1/zsh-in-docker.sh)" -- \
    -t agnoster \
    -p git \
    -p virtualenv \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-syntax-highlighting

# ROS 환경 설정
RUN echo 'export LC_NUMERIC="en_US.UTF-8"' >> ~/.zshrc && \
    echo "export DISABLE_AUTO_TITLE=true" >> ~/.zshrc && \
    echo "source /opt/ros/humble/setup.zsh" >> ~/.zshrc && \
    echo "source /usr/share/gazebo/setup.sh" >> ~/.zshrc

# mise + uv
RUN curl https://mise.run | sh && \
    echo 'eval "$($HOME/.local/bin/mise activate zsh)"' >> ~/.zshrc &&

# 서비스 시작 스크립트
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 포트 노출
EXPOSE 22

# 기본 쉘 변경
SHELL ["/usr/bin/zsh", "-c"]

# 엔트리포인트 설정
ENTRYPOINT ["/entrypoint.sh"]

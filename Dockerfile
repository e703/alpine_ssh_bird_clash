# 指定创建的基础镜像
FROM alpine

# 作者描述信息
LABEL maintainer="alpine_sshd_bird (alan@1280.fun)"

# 替换阿里云的源
# RUN echo "http://mirrors.aliyun.com/alpine/latest-stable/main/" > /etc/apk/repositories
# RUN echo "http://mirrors.aliyun.com/alpine/latest-stable/community/" >> /etc/apk/repositories

# 修改sysctl.conf文件
RUN echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

# 更新源、安装openssh bird  并修改配置文件和生成key 并且同步时间
RUN apk update && \
    apk add --no-cache openssh-server bird curl tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
    ssh-keygen -t rsa -P "" -f /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -t ecdsa -P "" -f /etc/ssh/ssh_host_ecdsa_key && \
    ssh-keygen -t ed25519 -P "" -f /etc/ssh/ssh_host_ed25519_key && \
    echo "root:admin" | chpasswd
# 安装最新版本mihomo
RUN LATEST_VERSION=$(curl -s https://api.github.com/repos/MetaCubeX/mihomo/releases/latest | grep "tag_name" | cut -d '"' -f 4) && \
    DOWNLOAD_URL="https://github.com/MetaCubeX/mihomo/releases/download/${LATEST_VERSION}/mihomo-linux-amd64-compatible-${LATEST_VERSION}.gz" && \
    wget ${DOWNLOAD_URL} && \
    gunzip "mihomo-linux-amd64-compatible-${LATEST_VERSION}.gz" && \
    mv "mihomo-linux-amd64-compatible-${LATEST_VERSION}" clash && \
    chmod u+x clash && \
    mkdir -p /etc/clash && \
    mv ./clash /usr/local/bin

# 创建启动脚本
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
# 开放22端口
EXPOSE 22

# 执行ssh启动命令
#CMD ["/usr/sbin/sshd", "-D"]
#CMD ["/bin/sh", "-c", "/usr/local/bin/clash -d /etc/clash && /usr/sbin/sshd -D && /usr/sbin/bird -c /etc/bird/bird.conf"]
#CMD ["/bin/sh", "-c", "/usr/sbin/bird -c /etc/bird/bird.conf && /usr/sbin/sshd -D"]
CMD ["/usr/local/bin/start.sh"]

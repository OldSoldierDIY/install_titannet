#!/bin/bash

# 设置目录
# USER_HOME=$(eval echo ~${SUDO_USER})
USER_HOME="/root"
# 设置存储空间大小
STORAGE_SIZE="700GB"
URL="https://github.com/Titannet-dao/titan-node/releases/download/v0.1.19/titan-l2edge_v0.1.19_patch_linux_amd64.tar.gz"
DOWNLOAD_DIR="${USER_HOME}"
TAR_FILE="titan-edge_linux_amd64.tar.gz"
EXTRACT_DIR="${DOWNLOAD_DIR}/titan-edge"
LIB_FILE="libgoworkerd.so"
SYSTEMD_SERVICE_FILE="/etc/systemd/system/titan-edge.service"
SERVICE_NAME="titan-edge"
LOG_FILE="${EXTRACT_DIR}/edge.log"
HASH="294E4F18-A1AE-432F-8509-ADC6049EE5B5"
BIND_URL="https://api-test1.container1.titannet.io/api/v2/device/binding"

# 下载并解压文件
wget $URL -O ${DOWNLOAD_DIR}/${TAR_FILE}
mkdir -p $EXTRACT_DIR
tar -xzvf ${DOWNLOAD_DIR}/${TAR_FILE} -C $EXTRACT_DIR --strip-components=1

# 设置环境变量
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${EXTRACT_DIR}

# 创建 systemd 服务文件
cat <<EOL > $SYSTEMD_SERVICE_FILE
[Unit]
Description=Titan Edge Daemon Service
After=network.target

[Service]
ExecStart=${EXTRACT_DIR}/titan-edge daemon start --init --url https://cassini-locator.titannet.io:5000/rpc/v0
WorkingDirectory=${EXTRACT_DIR}
Environment="LD_LIBRARY_PATH=${EXTRACT_DIR}"
StandardOutput=file:${LOG_FILE}
StandardError=file:${LOG_FILE}
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOL

# 重新加载 systemd 并启动服务
systemctl daemon-reload
systemctl start $SERVICE_NAME

# 等待 7 秒
sleep 7

# 绑定设备
${EXTRACT_DIR}/titan-edge bind --hash=${HASH} ${BIND_URL}

# 设置存储大小
${EXTRACT_DIR}/titan-edge config set --storage-size ${STORAGE_SIZE}

# 重启服务
systemctl restart $SERVICE_NAME

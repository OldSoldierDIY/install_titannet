#!/bin/bash

# 定义要检查的容器名称
containers=(docker1 docker2 docker3 docker4 docker5)

# 遍历容器数组
for container in "${containers[@]}"; do
  # 检查容器是否在运行
  if ! docker ps --format '{{.Names}}' | grep -w "$container" > /dev/null; then
    echo "$container is down. Attempting to restart..."
    # 如果容器不在运行状态，尝试重启
    docker start "$container"
    echo "$container has been restarted."
  else
    echo "$container is running."
  fi
done

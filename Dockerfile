# 使用多阶段构建
FROM node:16.11.1 AS builder

# 设置构建参数
ENV PYTHON=/usr/bin/python3

# 安装构建依赖
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 设置yarn源
RUN yarn config set registry https://registry.npmmirror.com/ && \
    yarn config set disturl https://npmmirror.com/dist

# 复制package文件
COPY package*.json yarn.lock ./

# 安装所有依赖
RUN yarn install

# 复制应用代码
COPY . .

# 第二阶段：运行环境
FROM node:16.11.1-slim

# 安装运行时依赖
RUN apt-get update && apt-get install -y \
    python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 从builder阶段复制node_modules和应用代码
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app .

# 创建临时文件夹
RUN mkdir -p tempImgs && \
    chmod 777 tempImgs

# 暴露端口
EXPOSE 3006

# 启动命令
CMD ["yarn", "start"] 

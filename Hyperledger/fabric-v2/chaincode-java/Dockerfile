# 基础镜像
FROM openjdk:11-jdk-slim

# 维护者信息（可选）
LABEL maintainer="your-name <your-email@example.com>"

# 设置环境变量（可根据需要修改Gradle版本）
ENV GRADLE_VERSION=7.6.4
ENV GRADLE_HOME=/opt/gradle/gradle-${GRADLE_VERSION}
ENV PATH=${GRADLE_HOME}/bin:${PATH}
# 设置时区（避免构建时时间相关问题）
ENV TZ=Asia/Shanghai

# 安装必要依赖 + 配置国内源 + 下载安装Gradle
RUN set -eux; \
    # 更换debian源为阿里云
    sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list; \
    # 安装依赖（curl、unzip用于下载解压Gradle）
    apt-get update && apt-get install -y --no-install-recommends \
        curl \
        unzip \
        tzdata \
        && rm -rf /var/lib/apt/lists/*; \
    # 创建Gradle安装目录
    mkdir -p /opt/gradle; \
    # 从阿里云镜像下载Gradle（国内速度快）
    curl -fsSL https://mirrors.cloud.tencent.com/gradle/gradle-${GRADLE_VERSION}-bin.zip -o /tmp/gradle.zip; \
    # 解压并校验（确保下载完整）
    unzip -q /tmp/gradle.zip -d /opt/gradle; \
    # 删除临时文件
    rm -f /tmp/gradle.zip; \
    # 验证Gradle安装
    gradle --version; \
    # 设置时区
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 创建工作目录
WORKDIR /app

# 复制项目文件（先复制gradle配置，利用docker缓存）
COPY build.gradle settings.gradle ./
# 复制源码
COPY src ./src
# 复制入口脚本并赋予执行权限
COPY docker/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN gradle clean build -x test -x checkstyleMain -x checkstyleTest

# 设置入口脚本
CMD ["docker-entrypoint.sh"]
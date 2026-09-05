# Syncplay Server

基于官方 [Syncplay](https://github.com/Syncplay/syncplay) 源码构建的 Docker 镜像，用于运行 Syncplay Server。

## 使用

### Docker Compose

可以直接下载仓库中的 Compose 文件：

```bash
mkdir syncplay-server
cd syncplay-server

curl -LO https://raw.githubusercontent.com/Q16KBreak/syncplay-server/master/compose.yml
```

或者使用 `wget`：

```bash
wget https://raw.githubusercontent.com/Q16KBreak/syncplay-server/master/compose.yml
```

然后启动：

```bash
docker compose up -d
```

默认服务端口为 `8999`。

完整的 Compose 配置：

```yaml
services:
  syncplay:
    image: q16kbreak/syncplay-server:latest
    container_name: syncplay-server
    restart: unless-stopped

    ports:
      - 8999:8999

    volumes:
      - ./data:/var/lib/syncplay
      # - ./tls:/tls

    environment:
      SYNCPLAY_PORT: 8999
      SYNCPLAY_ISOLATE_ROOMS: true
      # SYNCPLAY_TLS: "/tls"
```

### 本地构建

克隆本仓库：

```bash
git clone https://github.com/Q16KBreak/syncplay-server.git
cd syncplay-server
```

执行构建脚本：

```bash
./build.sh
```

构建完成后会生成：

```text
syncplay-server:latest
syncplay-server:<Syncplay commit SHA>-<repository commit SHA>
```

如果构建脚本没有执行权限，可以使用：

```bash
chmod +x build.sh
./build.sh
```

本地构建使用仓库中的 `python-image.digest` 固定 Python 基础镜像，并使用仓库中的 `requirements.lock` 安装 Python 依赖。

构建过程中会获取 Syncplay `master` 的最新 commit，并使用该 commit 构建镜像。

### 数据持久化

容器使用：

```text
/var/lib/syncplay
```

保存运行时数据。

推荐将其挂载到宿主机：

```yaml
volumes:
  - ./data:/var/lib/syncplay
```

其中包括自动生成的 `salt` 文件。

首次启动时，如果没有指定 `SYNCPLAY_SALT`，容器会自动生成随机 salt 并保存到：

```text
./data/salt
```

因此只要保留 `./data`，重新创建容器不会改变 salt。

## 环境变量

环境变量会由 `entrypoint.sh` 转换为对应的 Syncplay Server 命令行参数。

| Environment                        | Syncplay 参数                 | 说明                  |
| ---------------------------------- | --------------------------- | ------------------- |
| `SYNCPLAY_SALT`                    | `--salt`                    | 认证 salt。不设置时自动生成并保存 |
| `SYNCPLAY_PORT`                    | `--port`                    | 监听端口                |
| `SYNCPLAY_ISOLATE_ROOMS`           | `--isolate-rooms`           | 是否隔离房间              |
| `SYNCPLAY_DISABLE_READY`           | `--disable-ready`           | 禁用 Ready 状态         |
| `SYNCPLAY_DISABLE_CHAT`            | `--disable-chat`            | 禁用聊天                |
| `SYNCPLAY_PASSWORD`                | `--password`                | 服务端密码               |
| `SYNCPLAY_MOTD_FILE`               | `--motd-file`               | MOTD 文件路径           |
| `SYNCPLAY_ROOMS_DB_FILE`           | `--rooms-db-file`           | 房间数据库文件路径           |
| `SYNCPLAY_PERMANENT_ROOMS_FILE`    | `--permanent-rooms-file`    | 永久房间配置文件路径          |
| `SYNCPLAY_MAX_CHAT_MESSAGE_LENGTH` | `--max-chat-message-length` | 最大聊天消息长度            |
| `SYNCPLAY_MAX_USERNAME_LENGTH`     | `--max-username-length`     | 最大用户名长度             |
| `SYNCPLAY_STATS_DB_FILE`           | `--stats-db-file`           | 统计数据库文件路径           |
| `SYNCPLAY_TLS`                     | `--tls`                     | TLS 配置/证书路径         |
| `SYNCPLAY_IPV4_ONLY`               | `--ipv4-only`               | 仅使用 IPv4            |
| `SYNCPLAY_IPV6_ONLY`               | `--ipv6-only`               | 仅使用 IPv6            |
| `SYNCPLAY_INTERFACE_IPV4`          | `--interface-ipv4`          | 指定 IPv4 网络接口        |
| `SYNCPLAY_INTERFACE_IPV6`          | `--interface-ipv6`          | 指定 IPv6 网络接口        |

对于布尔选项：

```text
true  → 添加对应参数
false → 不添加参数
```

例如：

```yaml
environment:
  SYNCPLAY_PORT: 8999
  SYNCPLAY_ISOLATE_ROOMS: true
  SYNCPLAY_DISABLE_CHAT: true
  SYNCPLAY_IPV4_ONLY: true
```

等价于：

```text
--port=8999
--isolate-rooms
--disable-chat
--ipv4-only
```

### 自定义参数

除环境变量外，也可以直接向容器传递 Syncplay Server 参数。

例如：

```bash
docker run --rm \
  -p 8999:8999 \
  q16kbreak/syncplay-server:latest \
  --help
```

`entrypoint.sh` 会保留传入的命令行参数，并在此基础上添加由环境变量生成的参数。


## 标签命名规则

镜像标签格式为：

```text
<Syncplay commit SHA>-<repository commit SHA>
```

其中：

* `<Syncplay commit SHA>`：构建时使用的 Syncplay 源码 commit SHA
* `<repository commit SHA>`：构建配置仓库对应 commit 的短 SHA

例如：

```text
a1b2c3d4e5f6...-7f3a21c
```

`latest` 始终指向当前最新成功构建的镜像。

镜像支持：

```text
linux/amd64
linux/arm64
```

## License

本项目是 Syncplay 的 Docker 构建与运行环境。

镜像中的 Syncplay 源代码来自官方 Syncplay 项目，并根据 **Apache License 2.0** 进行分发。Syncplay 源码中的原始 `LICENSE` 文件会随源码保留在镜像中。

本仓库中的 Dockerfile、Compose 文件、启动脚本、健康检查脚本及 CI 配置等 Docker packaging 内容与 Syncplay 源代码相互独立。

Syncplay：

https://github.com/Syncplay/syncplay

其源代码及相关版权归 Syncplay 项目及其贡献者所有，并受 Apache License 2.0 约束。

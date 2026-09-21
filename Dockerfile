# MinerU 4.0 api-server（GPU 集群侧）
# 构建：docker build -t mineru-api:4.0 .
# 注意：client 端通过 MinerUApiParser 或本仓库 mineru_client.py 的 HTTP 协议调用。

FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    MINERU_MODEL_SOURCE=modelscope \
    MINERU_HOME=/root/.mineru

# 系统依赖：OpenCV / libGL 中文字体 / curl（健康检查）
RUN apt-get update && apt-get install -y --no-install-recommends \
        libgl1 libglib2.0-0 libgomp1 curl fonts-noto-cjk \
    && rm -rf /var/lib/apt/lists/*

# full 安装（Linux GPU：Torch + vLLM）
RUN python3 -m pip install -U "mineru[full]>=4.0,<5"

# 预下载 standard 档位模型（ModelScope 源）；如网络受限可注释并在运行时下载
RUN mineru-kit models download --tier standard --source modelscope

EXPOSE 8000

# V1 API Server（与现有项目 mineru-api 端点一致：POST /file_parse）
CMD ["mineru-kit", "api-server", "--host", "0.0.0.0", "--port", "8000", "--tier", "standard"]
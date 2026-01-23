# 1. Base Image
FROM quay.io/vessl-ai/torch:2.2.2-cuda11.8-r5

ENV DEBIAN_FRONTEND=noninteractive

# 2. 필수 시스템 패키지 설치
RUN apt-get update && apt-get install -y \
    wget unzip ca-certificates git build-essential \
    libasound2 libatk1.0-0 libc6 libcairo2 libcap2 libcom-err2 libcups2 \
    libdbus-1-3 libfontconfig1 libgconf-2-4 libgcrypt20 libgdk-pixbuf2.0-0 \
    libgstreamer-plugins-base1.0-0 libgstreamer1.0-0 libgtk-3-0 \
    libnspr4 libnss3 libpam0g libpango-1.0-0 libpangocairo-1.0-0 \
    libpangoft2-1.0-0 libsm6 libsndfile1 libuuid1 libx11-6 libx11-xcb1 \
    libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 \
    libxft2 libxi6 libxinerama1 libxrandr2 libxrender1 libxss1 libxt6 \
    libxtst6 libxxf86vm1 x11-xkb-utils xauth xfonts-base \
    && rm -rf /var/lib/apt/lists/*

# 3. Meep 설치
RUN apt-get update && apt-get install -y meep h5utils python3-meep && \
    pip install antigravity

# 4-1. MPM 다운로드 및 [1차 설치]: Core & Radar/Comms (기반 툴박스)
# 에뮬레이션 부하를 줄이기 위해 먼저 설치합니다.
RUN wget -q https://www.mathworks.com/mpm/lnx/mpm && \
    chmod +x mpm && \
    ./mpm install \
    --release R2023b \
    --destination /usr/local/matlab/R2023b \
    --products \
    MATLAB Simulink \
    Signal_Processing_Toolbox \
    Phased_Array_System_Toolbox \
    Communications_Toolbox \
    Radar_Toolbox \
    Antenna_Toolbox \
    RF_Toolbox \
    Optimization_Toolbox \
    Global_Optimization_Toolbox \
    && rm -f mpm

# 4-2. MPM 재다운로드 및 [2차 설치]: AI & Parallel Computing (무거운 툴박스)
# 1차 설치된 경로에 덧붙여서 설치합니다.
RUN wget -q https://www.mathworks.com/mpm/lnx/mpm && \
    chmod +x mpm && \
    ./mpm install \
    --release R2023b \
    --destination /usr/local/matlab/R2023b \
    --products \
    Deep_Learning_Toolbox \
    Statistics_and_Machine_Learning_Toolbox \
    Reinforcement_Learning_Toolbox \
    Parallel_Computing_Toolbox \
    Computer_Vision_Toolbox \
    Lidar_Toolbox \
    Sensor_Fusion_and_Tracking_Toolbox \
    MATLAB_Coder \
    GPU_Coder \
    Text_Analytics_Toolbox \
    Predictive_Maintenance_Toolbox \
    && rm -f mpm

# 5. MATLAB Python Engine 설치
WORKDIR /usr/local/matlab/R2023b/extern/engines/python
RUN python setup.py install

# 6. 환경 설정
ENV PATH="/usr/local/matlab/R2023b/bin:${PATH}"
RUN mkdir -p /usr/local/matlab/R2023b/licenses

WORKDIR /root
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--allow-root", "--NotebookApp.token=''", "--port=8888"]

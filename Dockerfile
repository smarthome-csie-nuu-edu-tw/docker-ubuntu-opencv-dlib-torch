# 2080系列GPU安裝運作OpenFace環境

FROM nvidia/cuda:10.0-cudnn7-devel

MAINTAINER Zi-Yi Wang <m0724001@gm.nuu.edu.tw>

USER root

ENV DEBIAN_FRONTEND noninteractive
# Tensorflow Allowing GPU memory growth
ENV TF_FORCE_GPU_ALLOW_GROWTH true

RUN apt-get update && apt-get -yq dist-upgrade \
    && apt-get install -yq --no-install-recommends \
    apt-utils autoconf automake \
    bzip2 build-essential \
    ca-certificates cmake clang \
    default-jre \
    emacs \
    fonts-liberation ffmpeg \
    git graphviz \
    php7.2 php7.2-dev php-zmq \
    inkscape \
    jed \
    libsm6 libxext-dev libxrender1 lmodern locales \
    libreadline-dev libopencv-dev libzmq3-dev libtool \
    libssl-dev libglu1-mesa-dev \
    make mesa-common-dev \
    nano \
    openssh-client \
    pandoc python-dev python-pydot python-pydot-ng pkg-config pv protobuf-compiler python-pil python-lxml python-tk \
    rename \
    sudo \
    texlive-fonts-extra texlive-fonts-recommended texlive-generic-recommended texlive-latex-base texlive-latex-extra texlive-xetex \
    unrar unzip \
    vim \
    wget \
    zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -yq --no-install-recommends fonts-moe-standard-song fonts-moe-standard-kai fonts-cns11643-sung fonts-cns11643-kai fonts-arphic-ukai \
    fonts-arphic-uming fonts-arphic-bkai00mp fonts-arphic-bsmi00lp fonts-arphic-gbsn00lp fonts-arphic-gkai00mp fonts-cwtex-ming fonts-cwtex-kai fonts-cwtex-heib \
    fonts-cwtex-yen fonts-cwtex-fs fonts-cwtex-docs fonts-wqy-microhei fonts-wqy-zenhei xfonts-wqy fonts-hanazono && \
    apt-get install -yq --no-install-recommends language-pack-zh* && \
    apt-get install -yq --no-install-recommends chinese* && \
    apt-get install -yq --no-install-recommends fonts-arphic-ukai fonts-arphic-uming fonts-ipafont-mincho fonts-ipafont-gothic fonts-unfonts-core \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
    curl \
    git \
    graphicsmagick \
    libssl-dev \
    libffi-dev \
    python-dev \
    python-pip \
    python-numpy \
    python-nose \
    python-scipy \
    python-pandas \
    python-protobuf \
    python-openssl \
    python-setuptools \
    wget \
    zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

##########
#安裝Torch
##########

#參考來源:https://github.com/nagadomi/distro https://github.com/nagadomi/waifu2x/issues/253
ENV TORCH_NVCC_FLAGS -D__CUDA_NO_HALF_OPERATORS__
RUN git clone https://github.com/nagadomi/distro.git ~/torch --recursive && \
    cd ~/torch && \
    ./install-deps && \
    ./clean.sh && \
    ./install.sh && \
    ./clean.sh && \
    ./update.sh

RUN cd ~//torch/extra/cutorch && \
    ~/torch/install/bin/luarocks make rocks/cutorch-scm-1.rockspec

RUN cd ~/torch/install/bin/ && \
    for NAME in dpnn nn optim optnet csvigo cunn fblualib torchx tds; \
    do ./luarocks install $NAME; \
    done

#########
#安裝opencv
#########
RUN cd ~ && \
    mkdir -p ocv-tmp && \
    cd ocv-tmp && \
    git clone https://github.com/opencv/opencv.git opencv-2.4.11 && \
    #unzip ocv.zip && \
    cd opencv-2.4.11 && \
    mkdir release && \
    cd release && \
    cmake -DCMAKE_BUILD_TYPE=RELEASE \
          -DCMAKE_INSTALL_PREFIX=/usr/local \
          -DBUILD_PYTHON_SUPPORT=ON \
          -DCUDA_nppi_LIBRARY=true \
          -Wno-dev \
          .. && \
    make -j8 && \
    make install && \
    rm -rf ~/ocv-tmp

##########
#安裝dlib
##########

# 原生 Install dlib GPU 
RUN cd /tmp && \
    git clone https://github.com/davisking/dlib.git && \
    cd dlib && \
    python setup.py install
    #rm -rf dlib && \
    #fix-permissions $CONDA_DIR && \
    #fix-permissions /home/$NB_USER

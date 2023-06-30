FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04
# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV ROS_DISTRO noetic
ENV TZ=Asia/Taipei
# for tiny-cuda-nn
ENV TCNN_CUDA_ARCHITECTURES=86

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_DPDS=apt_packages.txt
ARG PY_DPDS=requirements.txt
ARG PY_DPDS2=requirements2.txt
ARG APT_SERVER=http:\/\/mirror01.idc.hinet.net

WORKDIR /tmp

USER root

# Change faster apt server
RUN sed -i 's/^\(\s*deb\s*\)\w*:\/\/[^\/]*/\1${APT_SERVER}/g' /etc/apt/sources.list

# install apt dependencies
RUN apt update
COPY ./docker/${APT_PKGS} ./
RUN xargs apt install \
    --yes \
    --no-install-recommends \
    < ${APT_DPDS}

# install python dependencies
RUN python3 -m pip install --upgrade --no-cache-dir pip
COPY ./docker/${PY_DPDS} ./
RUN python3 -m pip install --no-cache-dir \
    --find-links https://download.pytorch.org/whl/cu113/torch_stable.html \
    --requirement ${PY_DPDS}
COPY ./docker/${PY_DPDS2} ./
RUN python3 -m pip install --no-cache-dir \
    --requirement ${PY_DPDS2}

# Build extension (marching cubes from neuralRGBD)
COPY ./external/NumpyMarchingCubes ./
RUN python3 setup.py install

# Clean up
RUN apt autoremove --purge \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# setup entrypoint
# COPY ./entrypoint.sh /
# ENTRYPOINT ["/entrypoint.sh"]

WORKDIR /app

CMD ["bash"]
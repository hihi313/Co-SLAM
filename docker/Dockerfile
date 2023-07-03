FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04 AS base
# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV ROS_DISTRO noetic
ENV TZ=Asia/Taipei
ENV PATH=/miniconda/bin:$PATH
# for tiny-cuda-nn
ENV TCNN_CUDA_ARCHITECTURES=86
ENV CONDA_ENV=coslam

ARG DEBIAN_FRONTEND=noninteractive
ARG DOCKER_ROOT=./docker
ARG APT_SERVER=http:\/\/mirror01.idc.hinet.net
ARG APT_DPDS=apt_packages.txt
ARG APT_DPDS_BUILD=apt_packages_build.txt
ARG CONDA_URL=https://repo.continuum.io/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh
ARG PY_DPDS=requirements.txt
ARG PY_DPDS2=requirements2.txt

WORKDIR /tmp

USER root

# Change faster apt server
RUN sed -i "s#^\(\s*deb\s*\)\w*:\/\/[^\/]*#\1${APT_SERVER}#g" /etc/apt/sources.list

RUN echo ${PATH}

RUN apt update
COPY ${DOCKER_ROOT}/${APT_DPDS_BUILD} ./
RUN xargs apt install \
    --yes \
    --no-install-recommends \
    < ${APT_DPDS_BUILD}
COPY ${DOCKER_ROOT}/${APT_DPDS} ./
RUN xargs apt install \
    --yes \
    --no-install-recommends \
    < ${APT_DPDS}

RUN curl -sLo ./miniconda.sh ${CONDA_URL} \
    && chmod +x ./miniconda.sh \
    && ./miniconda.sh -b -p /miniconda

# Create the environment:
RUN conda create -n ${CONDA_ENV} python=3.7

# Make RUN commands use the new environment:
# SHELL command must in JSON form & JSON form can't process vars
SHELL ["conda", "run", "-n", "coslam", "/bin/bash", "-c"]

# install python dependencies
RUN python3 -m pip install --upgrade --no-cache-dir pip
COPY ${DOCKER_ROOT}/${PY_DPDS} ./
RUN python3 -m pip install --no-cache-dir \
    --find-links https://download.pytorch.org/whl/cu113/torch_stable.html \
    --requirement ${PY_DPDS}
COPY ${DOCKER_ROOT}/${PY_DPDS2} ./
RUN python3 -m pip install --no-cache-dir \
    --requirement ${PY_DPDS2}

FROM base AS build

# Build extension (marching cubes from neuralRGBD)
COPY ./external/NumpyMarchingCubes ./
RUN cd NumpyMarchingCubes \
    && python3 setup.py install

# Clean up
RUN xargs apt purge ${APT_DPDS_BUILD}
RUN apt autoremove --purge \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# setup entrypoint
COPY ${DOCKER_ROOT}/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

WORKDIR /app

CMD ["bash"]
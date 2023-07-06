ARG DOCKER_ROOT=./docker
ARG APT_SERVER=http:\/\/mirror01.idc.hinet.net
ARG SED_I="s#^\(\s*deb\s*\)\w*:\/\/[^\/]*#\1${APT_SERVER}#g"
ARG CONDA_URL=https://repo.continuum.io/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh
ARG CONDA_DIR=/miniconda
ARG CONDA_ENV=coslam
ARG IMG_BUILD_TAG=11.3.1-cudnn8-devel-ubuntu20.04
ARG IMG_RUN_TAG=11.3.1-cudnn8-runtime-ubuntu20.04

#===============================================================================

FROM nvidia/cuda:${IMG_BUILD_TAG} AS conda

ARG APT_SERVER
ARG SED_I
ARG CONDA_URL
ARG CONDA_DIR
ARG CONDA_ENV
ARG DPDS=curl
ENV PATH=${CONDA_DIR}/bin:$PATH

WORKDIR /tmp
USER root

# Change faster apt server
RUN sed -i ${SED_I} /etc/apt/sources.list

RUN apt update \
    && apt install --yes --no-install-recommends ${DPDS} \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sLo ./install_conda.sh ${CONDA_URL} \
    && chmod +x ./install_conda.sh \
    && ./install_conda.sh -b -p ${CONDA_DIR} \
    && conda init bash \
    && conda clean -ya

RUN conda create -n ${CONDA_ENV} python=3.7

# Remove dependencies
RUN apt purge --yes ${DPDS} \
    && apt autoremove --purge --yes

#===============================================================================

FROM conda AS torch

ARG PY_DPDS=requirements.txt
ARG DOCKER_ROOT

SHELL ["conda", "run", "-n", "coslam", "/bin/bash", "-c"]

COPY ${DOCKER_ROOT}/${PY_DPDS} ./
RUN python3 -m pip install --upgrade --no-cache-dir pip \
    && python3 -m pip install --no-cache-dir \
        --find-links https://download.pytorch.org/whl/cu113/torch_stable.html \
        --requirement ${PY_DPDS} \
    && rm ${PY_DPDS}

#===============================================================================

FROM torch AS dpds

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV TZ=Asia/Taipei
# for tiny-cuda-nn
ENV TCNN_CUDA_ARCHITECTURES=86
ARG DEBIAN_FRONTEND=noninteractive
ARG DPDS=git
ARG PY_DPDS2=requirements2.txt
ARG DOCKER_ROOT

# build dependencies for pip install
RUN apt update \
    && apt install --yes --no-install-recommends ${DPDS} \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# install python dependencies
COPY ${DOCKER_ROOT}/${PY_DPDS2} ./
RUN python3 -m pip install --no-cache-dir \
    --requirement ${PY_DPDS2} \
    && rm ${PY_DPDS2}

# Remove build dependencies
RUN apt purge --yes ${DPDS} \
    && apt autoremove --purge --yes \
    && conda clean -ya

#===============================================================================

FROM dpds AS build_dpds

# Build extension (marching cubes from neuralRGBD)
COPY ./external ./
RUN cd NumpyMarchingCubes \
    && python3 setup.py install

# Clean up
RUN apt autoremove --purge --yes \
    && conda clean -ya \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#===============================================================================

FROM build_dpds AS pack

ARG CONDA_ENV

# Make RUN commands use the new environment:
SHELL ["conda", "run", "-n", "base", "/bin/bash", "-c"]

# pack conda built env
RUN python3 -m pip install --no-cache-dir conda-pack \
    && conda pack --ignore-missing-files -n ${CONDA_ENV} -o ${CONDA_ENV}.tar.gz

#===============================================================================

FROM nvidia/cuda:${IMG_RUN_TAG} AS base

ARG CONDA_URL
ARG CONDA_DIR
ARG CONDA_ENV
ARG DPDS=curl
ENV PATH=${CONDA_DIR}/bin:$PATH

RUN apt update \
    && apt install --yes --no-install-recommends ${DPDS} \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sLo ./install_conda.sh ${CONDA_URL} \
    && chmod +x ./install_conda.sh \
    && ./install_conda.sh -b -p ${CONDA_DIR} \
    && conda init bash \
    && conda clean -ya

# Remove dependencies
RUN apt purge --yes ${DPDS} \
    && apt autoremove --purge --yes

#===============================================================================

FROM base AS final

ARG CONDA_DIR
ARG CONDA_ENV
ARG DOCKER_ROOT
ARG CONDA_ENV_DIR=${CONDA_DIR}/envs/${CONDA_ENV}
ARG APT_DPDS=apt_packages.txt

COPY ${DOCKER_ROOT}/${APT_DPDS} ./
RUN apt update \
    && xargs apt install --yes --no-install-recommends < ${APT_DPDS} \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* ${APT_DPDS}

# recover conda env
COPY --from=pack /tmp/${CONDA_ENV}.tar.gz ./
RUN mkdir -p ${CONDA_ENV_DIR} \
    && tar -xzf ${CONDA_ENV}.tar.gz -C ${CONDA_ENV_DIR}

# Clean up
RUN apt autoremove --purge --yes \
    && conda clean -ya \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app
CMD ["bash", "--login"]

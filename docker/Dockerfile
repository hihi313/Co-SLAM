FROM nvidia/cudagl:11.3.1-runtime-ubuntu20.04 AS conda

ENV APT_SERVER=http:\/\/mirror01.idc.hinet.net
ENV DOCKER_ROOT=./docker

ARG SED_I="s#^\(\s*deb\s*\)\w*:\/\/[^\/]*#\1${APT_SERVER}#g"
ARG CONDA_DIR=/miniconda
ARG CONDA_URL=https://repo.continuum.io/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh

WORKDIR /tmp
USER root

# Change faster apt server
RUN sed -i ${SED_I} /etc/apt/sources.list

RUN apt update \
    && apt install --yes --no-install-recommends curl \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sLo ./install_conda.sh ${CONDA_URL} \
    && chmod +x ./install_conda.sh \
    && ./install_conda.sh -b -p ${CONDA_DIR}
# conda path
ENV PATH=${CONDA_DIR}/bin:$PATH

# Create the environment:
ENV CONDA_ENV=coslam
RUN conda create -n ${CONDA_ENV} python=3.7

# Make RUN commands use the new environment:
RUN conda init bash \
    && echo "conda activate ${CONDA_ENV}" >> ~/.bashrc
SHELL ["conda", "run", "-n", "coslam", "/bin/bash", "-c"]

FROM conda AS torch

ARG PY_DPDS=requirements.txt

COPY ${DOCKER_ROOT}/${PY_DPDS} ./
RUN python3 -m pip install --upgrade --no-cache-dir pip \
    && python3 -m pip install --no-cache-dir \
        --find-links https://download.pytorch.org/whl/cu113/torch_stable.html \
        --requirement ${PY_DPDS} \
    && rm ${PY_DPDS}

FROM torch AS dpds

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV TZ=Asia/Taipei
# for tiny-cuda-nn
ENV TCNN_CUDA_ARCHITECTURES=86

ARG DEBIAN_FRONTEND=noninteractive
ARG BUILD_DPDS=git
ARG PY_DPDS2=requirements2.txt

# build dependencies for pip install
RUN apt update \
    && apt install --yes --no-install-recommends ${BUILD_DPDS} \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# install python dependencies
COPY ${DOCKER_ROOT}/${PY_DPDS2} ./
RUN python3 -m pip install --no-cache-dir \
    --requirement ${PY_DPDS2} \
    && rm ${PY_DPDS2}

# Remove build dependencies
RUN apt purge --yes ${BUILD_DPDS} \
    && apt autoremove --purge --yes \
    && conda clean -ya

FROM dpds AS build_dpds

ARG APT_DPDS=apt_packages.txt
COPY ${DOCKER_ROOT}/${APT_DPDS} ./
RUN apt update \
    && xargs apt install --yes --no-install-recommends < ${APT_DPDS} \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* ${APT_DPDS}

# Build extension (marching cubes from neuralRGBD)
COPY ./external ./
RUN cd NumpyMarchingCubes \
    && python3 setup.py install

# Clean up
RUN apt autoremove --purge --yes \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# setup entrypoint, use the conda env
# COPY ${DOCKER_ROOT}/entrypoint.sh /
# ENTRYPOINT ["/entrypoint.sh"]

WORKDIR /app

CMD ["bash", "--login"]
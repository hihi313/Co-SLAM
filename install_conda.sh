APT_SERVER=http:\/\/mirror01.idc.hinet.net

set -x

sed -i "s#^\(\s*deb\s*\)\w*:\/\/[^\/]*#\1${APT_SERVER}#g" /etc/apt/sources.list
apt update
apt install \
    --yes \
    --no-install-recommends \
    curl
    
curl -sLo ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh \
    && chmod +x ~/miniconda.sh \
    && ~/miniconda.sh -b -p ~/miniconda \
    && rm ~/miniconda.sh \

export PATH=$HOME/miniconda/bin:$PATH
set +x
SCANNET_DIR=/datasets/VSLAM/ScanNet

python3 coslam.py \
    --config ./configs/ScanNet/$1.yaml \
    --input_folder "${SCANNET_DIR}/$1"\
    --output ./output
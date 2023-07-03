#!/bin/bash

SCIPT_DIR=$( dirname "${BASH_SOURCE[0]}" )
SCANNET_DIR=/scannet
OUT_SCANNET_DIR=/datasets/VSLAM/ScanNet

python3 ${SCIPT_DIR}/reader.py \
    --filename ${SCANNET_DIR}/scans/$1/$1.sens \
    --output_path ${OUT_SCANNET_DIR}/$1 \
    --export_poses
    # --export_depth_images \
    # --export_color_images \

# python reader.py --filename [.sens file to export data from] --output_path [output directory to export data to]
# Options:
# --export_depth_images: export all depth frames as 16-bit pngs (depth shift 1000)
# --export_color_images: export all color frames as 8-bit rgb jpgs
# --export_poses: export all camera poses (4x4 matrix, camera to world)
# --export_intrinsics: export camera intrinsics (4x4 matrix)
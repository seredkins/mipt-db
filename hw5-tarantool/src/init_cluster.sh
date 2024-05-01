#!/bin/bash
BASE_PATH=/opt/tarantool/
SRC_PATH=~/instances.enabled/billcl
cd ~
tt init

mkdir -p $SRC_PATH

cp $BASE_PATH/router.lua $SRC_PATH
cp $BASE_PATH/storage.lua $SRC_PATH
cp $BASE_PATH/config.yaml $SRC_PATH
cp $BASE_PATH/instances.yaml $SRC_PATH
cp $BASE_PATH/billcl-scm-1.rockspec $SRC_PATH
#!/bin/bash
BASE_DIR=$(cd "$(dirname "$0")";pwd)
cd $BASE_DIR

action=$1
args=$@


EXE="docker-compose -f ${BASE_DIR}/docker-compose.yml"


function usage(){
    echo "Commands:"
    echo "  install 安装docker以及docker-compose"
    echo "  version 设置操作系统版本"
    echo "  download 下载rpm包"
}

function install_docker(){
    #将docker docker-compose 的安装，放到这里
    #在线安装
    yum install -y yum-utils device-mapper-persistent-data lvm2
    yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    yum makecache fast
    yum -y install docker-ce
    service docker start
    curl -L https://get.daocloud.io/docker/compose/releases/download/1.25.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    #离线安装

}


function set_image_ver(){
    echo '设置操作系统版本'
    vi .env
}

function main(){
    case "${action}" in
        install)
            install_docker
            ;;
        download)
            ${EXE} up
            ${EXE} down
            ;;
        version)
            set_image_ver
            ;;
        *)
            usage
            ;;
    esac
}





main

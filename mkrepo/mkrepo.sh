#!/bin/bash
set -u
set -o pipefail

CUR=$(cd `dirname $0`;pwd)

# 当前目录下的other，可以放一些非官方源的rpm

# 自定义的repo文件 即 rpm包的下载源
# repo文件中的$releasever 是必须安装了centos-release包才能识别
os_ver=$(egrep -o '[0-9]' /etc/redhat-release|head -1)
sed "s/\$releasever/${os_ver}/g" ${CUR}/aliyun.repo > ${CUR}/aliyun${os_ver}.repo
yum_config=${CUR}/aliyun${os_ver}.repo
#yum_config=${CUR}/local.repo
# 待下载的rpm包
rpmlist=${CUR}/rpmlist.txt

# 下载路径
sysroot=/mnt/sysroot/centos/$(egrep -o '[0-9.]+' /etc/redhat-release)


if [ ! -f ${yum_config}  ];then
    echo '${yum_config} 不存在!'
    exit 0
fi
if [ ! -f $rpmlist ];then
    echo "$rpmlist 不存在!"
fi


if  ping www.baidu.com -c 1 &>/dev/null ;then
    echo '===========开始'
else
    echo '网络异常!!!'
    exit 1
fi

chk_yumrepo(){
  if yum list &>/dev/null ;then
      yum makecache fast
  else
      mkdir /etc/yum.repos.d/backup &>/dev/null
      mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/
      yum clean all
      yum makecache fast
  fi
}

install_createrepo (){
  echo "安装createrepo工具"
  yum install createrepo -y -c ${yum_config}
}

down_rpms(){
mkdir ${sysroot}/tmp &>/dev/null
mkdir -p ${sysroot}/Packages/{a..z} &>/dev/null
echo '下载rpm包'
cat ${rpmlist} |xargs |xargs yum -c ${yum_config} --installroot="${sysroot}" --downloadonly --downloaddir="${sysroot}/tmp/" -y install 
echo '调整文件位置'
for name in {a..z};do
    mv -f ${sysroot}/tmp/${name}*.rpm ${sysroot}/Packages/${name}/ 
    mv -f ${sysroot}/tmp/${name^^}*.rpm ${sysroot}/Packages/${name}/ 
done
mv ${sysroot}/tmp/* ${sysroot}/Packages/ &>/dev/null  
rm -rf ${sysroot}/tmp &>/dev/null 
rm -rf ${sysroot}/var &>/dev/null
echo ""
}

add_other_rpm(){
echo "拷贝other下的rpms"
for name in {a..z};do
    cp ${CUR}/other/${name}*.rpm ${sysroot}/Packages/${name}/ &>/dev/null
    #下面是将大写开头的也拷贝到小写字母开头的目录
    cp ${CUR}/other/${name^^}*.rpm ${sysroot}/Packages/${name}/ &>/dev/null
done
  
}


create_repo(){
echo "制作yum源"
  createrepo ${sysroot}/
  \cp -f ${CUR}/startHttp.sh /mnt/sysroot/ &>/dev/null
}

main(){
chk_yumrepo
install_createrepo
down_rpms
add_other_rpm
create_repo
}
main

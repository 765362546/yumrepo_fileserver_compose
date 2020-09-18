# yumrepo_fileserver_compose
使用docker-compose创建不同的操作系统，用于下载基于不同系统的rpm包，然后创建repo仓库
可以以将第三方软件包，放到仓库目录下
利用 python -m SimpleHTTPServer 80 创建简单的http服务，用于rpm以及第三方包的下载   ----- 大部分服务器，都自带python，不需要额外安装软件

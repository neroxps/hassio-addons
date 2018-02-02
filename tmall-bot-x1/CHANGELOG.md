# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.4] - 2018-1-30
- 更换 web 服务器为 nginx。
- 增加 HTTP2 支持。
- 增加 HTTPS 支持，请将证书放置到 ssl/tmall 目录。（chain.pem|fullchain.pem|privkey.pem）

## [0.0.3] - 2018-1-30
- 增加其他 hassio 支持平台适配。

## [0.0.2] - 2018-1-29
### Added
- 添加 LOCAL_MYSQL 选项，可让用户选择使用容器内建数据库还是外置数据库，当 LOCAL_MYSQL=true 时，所有数据库设置选项将会被脚本覆盖。

## [0.0.1] - 2018-1-29
### Added
- 使用 homeassistant/amd64-base 镜像创建 php-apache 环境。
- 仅提供 80 端口，需要利用 [nginx proxy](https://github.com/bestlibre/hassio-addons/tree/master/nginx_proxy) 反向代理，并按照文档配置 SSL。
- 依赖外部数据库。
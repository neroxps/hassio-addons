# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
## [0.3.6] - 2018-3-9
### Added
- 同步自 [https://github.com/c1pher-cn/tmall-bot-x1](https://github.com/c1pher-cn/tmall-bot-x1)，新增频道切换功能。
- 增加 /config/tmall-bot-x1 文件更新流程。

## [0.3.5] - 2018-3-9
### Fixed
- 修复不能用天猫精灵控制的bug

## [0.3.0] ~ [0.3.4] - 2018-3-9
### Added 
- 同步论坛 tmall-bot-x1 版本
- 删除论坛原有多用户模式。
- 修复各种bug。


## [0.2.2] ~ [0.2.7] - 2018-3-9
### Fixed
- 修正各种BUG。
- 优化启动 shell 更新到4.0数据库代码。

## [0.2.1] - 2018-3-9
### Added
- 根据 qebabe 发布的[天猫精灵接入网关 4.0](https://bbs.hassbian.com/thread-2982-1-1.html) 更新，新增传感器支持。

## [0.1.1] - 2018-2-9
### Fixed
- 修复 device 页面密码验证时点击取消后页面依然加载的bug。

## [0.1.0] - 2018-2-8
### Added
- 将 tmall-bot-x1 代码替换为 czweb 修改的代码。
- 添加 device 页面密码验证功能

### Fixed
- 优化 options 选项，简化默认选项。

## [0.0.5] - 2018-2-3
### Added
- 添加 SSL 证书路径选项。

### Fixed
- 修复当 client 修改时，数据库内容不更新情况。


## [0.0.4] - 2018-1-30
### Added
- 更换 web 服务器为 nginx。
- 增加 HTTP2 支持。
- 增加 HTTPS 支持，请将证书放置到 ssl/tmall 目录。（chain.pem|fullchain.pem|privkey.pem）

## [0.0.3] - 2018-1-30
### Added
- 增加其他 hassio 支持平台适配。

## [0.0.2] - 2018-1-29
### Added
- 添加 LOCAL_MYSQL 选项，可让用户选择使用容器内建数据库还是外置数据库，当 LOCAL_MYSQL=true 时，所有数据库设置选项将会被脚本覆盖。

## [0.0.1] - 2018-1-29
### Added
- 使用 homeassistant/amd64-base 镜像创建 php-apache 环境。
- 仅提供 80 端口，需要利用 [nginx proxy](https://github.com/bestlibre/hassio-addons/tree/master/nginx_proxy) 反向代理，并按照文档配置 SSL。
- 依赖外部数据库。

# Changelog

## [0.3.14] - 2019-11-29
### Fixed
- 隐藏 start.sh 启动脚本 curl 回显
- 修复 start.sh 不兼容非 hassio 系统修改 HA_PASSWD 的 bug
- 修复 add.php 和 addVirtualDevice.php 不支持 long live token 导致无法获取设备列表的 bug

## [0.3.12] - 2018-11-05
### Fixed
- 修复设置灯光亮度，音量，调台，灯光颜色会报401认证错误的bug。

## [0.3.12] - 2018-08-18
### Fixed
- 修复脚本语法错误，变量又忘记写$了，我感觉我写的都是shit！！！
- 修复 sed 语句因分隔符用 `/` 导致 URL 替换出bug了。

## [0.3.11] - 2018-08-18
### Fixed
- 修复使用内部数据库无法插入oauth_drives表的bug。

## [0.3.10] - 2018-08-15
### Added
- 适配非 Addons 用户使用。

## [0.3.9] - 2018-07-25
### Fixed
- 适配 hassio api proxy 改动。

## [0.3.7-0.3.8] - 2018-07-06
### Fixed
- 修复语法错误的bug，写变量写少了个$我也是醉了。

## [0.3.6] - 2018-03-09
### Added
- 同步自 [https://github.com/c1pher-cn/tmall-bot-x1](https://github.com/c1pher-cn/tmall-bot-x1)，新增频道切换功能。
- 增加 /config/tmall-bot-x1 文件更新流程。

## [0.3.5] - 2018-03-09
### Fixed
- 修复不能用天猫精灵控制的bug

## [0.3.0] ~ [0.3.4] - 2018-03-09
### Added 
- 同步论坛 tmall-bot-x1 版本
- 删除论坛原有多用户模式。
- 修复各种bug。


## [0.2.2] ~ [0.2.7] - 2018-03-09
### Fixed
- 修正各种BUG。
- 优化启动 shell 更新到4.0数据库代码。

## [0.2.1] - 2018-03-09
### Added
- 根据 qebabe 发布的[天猫精灵接入网关 4.0](https://bbs.hassbian.com/thread-2982-1-1.html) 更新，新增传感器支持。

## [0.1.1] - 2018-02-09
### Fixed
- 修复 device 页面密码验证时点击取消后页面依然加载的bug。

## [0.1.0] - 2018-02-08
### Added
- 将 tmall-bot-x1 代码替换为 czweb 修改的代码。
- 添加 device 页面密码验证功能

### Fixed
- 优化 options 选项，简化默认选项。

## [0.0.5] - 2018-02-03
### Added
- 添加 SSL 证书路径选项。

### Fixed
- 修复当 client 修改时，数据库内容不更新情况。


## [0.0.4] - 2018-01-30
### Added
- 更换 web 服务器为 nginx。
- 增加 HTTP2 支持。
- 增加 HTTPS 支持，请将证书放置到 ssl/tmall 目录。（chain.pem|fullchain.pem|privkey.pem）

## [0.0.3] - 2018-01-30
### Added
- 增加其他 hassio 支持平台适配。

## [0.0.2] - 2018-01-29
### Added
- 添加 LOCAL_MYSQL 选项，可让用户选择使用容器内建数据库还是外置数据库，当 LOCAL_MYSQL=true 时，所有数据库设置选项将会被脚本覆盖。

## [0.0.1] - 2018-01-29
### Added
- 使用 homeassistant/amd64-base 镜像创建 php-apache 环境。
- 仅提供 80 端口，需要利用 [nginx proxy](https://github.com/bestlibre/hassio-addons/tree/master/nginx_proxy) 反向代理，并按照文档配置 SSL。
- 依赖外部数据库。

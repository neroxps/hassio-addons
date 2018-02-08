# 天猫精灵接入网关 (PHP) 

利用 [tmall-bot-x1](https://github.com/c1pher-cn/tmall-bot-x1) 项目及 [https://bbs.hassbian.com/thread-2285-1-1.html](https://bbs.hassbian.com/thread-2285-1-1.html) 制作而成的天猫精灵接入网关。

## 鸣谢

本插件完全基于以下各位大神的代码构建而成，我只是一名搬运工。（排名不分先后）

 * [天猫精灵接入HomeAssistant【智能家居技能接入，非webhook调用】](https://bbs.hassbian.com/thread-1862-1-1.html)
 * [c1pher-cn](https://github.com/c1pher-cn)/[tmall-bot-x1](https://github.com/c1pher-cn/tmall-bot-x1)
 * [bshaffer](https://github.com/bshaffer)/[oauth2-server-php](https://github.com/bshaffer/oauth2-server-php)
 * [SAE搭建天猫精灵接入HA后台，新增设备管理系统](https://bbs.hassbian.com/thread-2285-1-1.html) 
 * [czweb](https://bbs.hassbian.com/home.php?mod=space&uid=2904) 提供基于[SAE搭建天猫精灵接入HA后台，新增设备管理系统](https://bbs.hassbian.com/thread-2285-1-1.html)修改的php程序

## 使用方法

本插件具有几种配置方案，满足各种需求。

### 默认方案（内部数据库-提供 SSL 访问）

默认方案，插件会建立一个数据库，数据库文件存放在插件的 data 目录，根据 hassio 设计，插件的 data 目录默认会存储在本机的 `/usr/share/hassio/addons/data/插件容器名称/` 目录下，使其持久化。

```
{
    "remote_database":{},
    "ssl":{
        "ssl_trusted_certificate":"/ssl/tmall/chain.pem",
        "ssl_certificate":"/ssl/tmall/fullchain.pem",
        "ssl_key":"/ssl/tmall/privkey.pem"
    },
    "client_id":"qwertyuiopasdfghjkl",
    "client_secret":"zxcvbnmasdfghjkl",
    "httpd_error_log":true
}
```
### 外部数据库及外部 SSL 代理

其实本 addons 一开始是使用这个方案，因为我已经在 hassio 部署了 [Nginx Proxy](https://github.com/bestlibre/hassio-addons/tree/master/nginx_proxy)，配合 [certbot](https://github.com/bestlibre/hassio-addons/tree/master/certbot) 插件可以为 homeassistant 提供 SSL 加密访问。

而我的 hassio 也部署了官方的 [mariadb](https://home-assistant.io/addons/mariadb/) 数据库，所以没必要重复部署数据库，可以利用数据库引擎建立一个 tmall 的数据库即可。

#### [Nginx Proxy](https://github.com/bestlibre/hassio-addons/tree/master/nginx_proxy) 配置参考

```
{
  "vhosts": [
    {
      "vhost": "hass.url.com",
      "port": "8123",
      "certname": "hass",
      "default_server": true
    },
    {
      "remote": "addon_8b4631d3_tmall-bot-x1",
      "vhost": "tmall.url.com",
      "certname": "tmall",
      "port": "80"
    }
  ]
}
```
####  [certbot](https://github.com/bestlibre/hassio-addons/tree/master/certbot) 配置参考

**注意：如果设置 `"ssl_only":true` 的话，运行 [certbot](https://github.com/bestlibre/hassio-addons/tree/master/certbot) 之前请停止  [Nginx Proxy](https://github.com/bestlibre/hassio-addons/tree/master/nginx_proxy)，因为二者都必须使用 443 端口，如果有 frp 内网穿透可以穿透80端口的话，建议设置 `"ssl_only":false` 这样就不会冲突了。**

```
{
    "debug":false,
    "email":"email@domain.tld",
    "certificats":[
        {
            "name":"hass",
            "domains":"hass.url.com"
        },
        {
            "name":"tmall",
            "domains":"tmall.url.com"
        }
    ],
    "ssl_only":true
}
```
#### [mariadb](https://home-assistant.io/addons/mariadb/) 配置参考

```
{
  "databases": [
    "homeassistant",
    "tmall"
  ],
  "logins": [
    {
      "username": "hass",
      "host": "homeassistant",
      "password": "homeassistant_mysql_password"
    },
    {
      "username": "tmall",
      "host": "addon_8b4631d3_tmall-bot-x1",
      "password": "tmall_mysql_password"
    }
  ],
  "rights": [
    {
      "username": "hass",
      "host": "homeassistant",
      "database": "homeassistant",
      "grant": "ALL PRIVILEGES ON"
    },
    {
      "username": "tmall",
      "host": "addon_8b4631d3_tmall",
      "database": "tmall",
      "grant": "ALL PRIVILEGES ON"
    }
  ]
}
```
#### [tmall-bot-x1](https://github.com/neroxps/hassio-addons/tree/master/tmall-bot-x1) 外部数据库及外部SSL代理参考

```
{
    "remote_database":{
        "mysql_host":"addon_core_mariadb",
        "mysql_db_name":"tmall",
        "mysql_user":"tmall",
        "mysql_passwd":"tmall_mysql_password",
        "mysql_port":"3306"
    },
    "ssl":{},
    "client_id":"qwertyuiopasdfghjkl",
    "client_secret":"zxcvbnmasdfghjkl",
    "device_user":"tmall",
    "device_passwd":"device_account_passowrd",
    "httpd_error_log":true
}
```
## Options 说明

```
{
    "config_dir_to_config":"bool?",
    "remote_database":{
        "mysql_host":"str?",
        "mysql_db_name":"str?",
        "mysql_user":"str?",
        "mysql_passwd":"str?",
        "mysql_port":"port?"
    },
    "ssl":{
        "ssl_trusted_certificate":"str?",
        "ssl_certificate":"str?",
        "ssl_key":"str?"
    },
    "client_id":"str",
    "client_secret":"str",
    "device_user":"str?",
    "device_passwd":"str?",
    "httpd_log":"bool?",
    "httpd_error_log":"bool?",
    "container_timezone":"str?",
    "debug":"bool?"
}
```
### Option: `config_dir_to_config`

该参数为布尔值 `"config_dir_to_config":"true"` 天猫精灵网关的php程序会放到 `/config/tmall-bot-x1`，`"config_dir_to_config":"false"` 时天猫精灵网关的php程序会放到 `/data/tmall-bot-x1`。

### Option: `remote_database`
 
此 `remote_database` 用于控制是否使用容器内部的数据库还是使用外部数据库。

如果这个对象是空的话例如：`"remote_database":{},`，那么容器会自动建立数据库，供天猫精灵网关使用。（此数据库因只允许容器内部访问，故账号密码固定无需填写）

如果这个对象内部内容符合要求，会连接参数内部填写的数据库，前提是该数据库已建立好数据库（可以是空的数据库，但是必须是建立好，脚本不会帮忙建立数据库）。

* `mysql_host`： 填写容器可访问的远程数据库，可以是ip，也可以是域名，如果是 hassio 建立的数据库，可以直接填写容器名称。
* `mysql_db_name`：数据库名字，该数据库必须已再数据库引擎中创建。
* `mysql_user`：连接数据库的用户名，该用户必须有`mysql_db_name`数据库的操作权限。
* `mysql_passwd`：连接数据库的密码。
* `mysql_port`：数据库的端口，当此项非必选，如不写则默认使用3306端口连接数据库。

### Option: `ssl`

此 `ssl` 用于控制是否使用容器内部 nginx 的 https 配置，需要映射 443 端口出来，当这个对象内部填写了 `ssl_trusted_certificate`、`ssl_certificate`、`ssl_key` 后会启用 https。

如果 `ssl` 对象为空的话，会自动启动 http 配置，方便远端 web proxy 进行代理。

`ssl_trusted_certificate`、`ssl_certificate`、`ssl_key` 的路径可以是 `/config` 作为根目录，也可以用 `/ssl` 作为根目录，具体看你证书放到哪个路径。

* `ssl_trusted_certificate`：chain.pem证书在addons中的路径。
* `ssl_certificate`：fullchain.pem证书在addons中的路径。
* `ssl_key`：privkey.pem证书在addons的路径。

### Option: `client_id` 和 `client_secret`

由用户自定义，必须与 [AliGenie 开发者](https://open.bot.tmall.com/account/login?redirectURL=%2Fconsole%2Fskill%2Flist) 填写的内容一致。

### Option：`device_user` 和 `device_passwd`

由用户自定义，天猫精灵设备管理页面的账号和密码，如果此参数不存在的话，系统会默认为 admin，密码系统自动生成，介时请观察日志寻找密码。
日志内容如下：
```
Device Remote Access:
USERNAME:admin
PASSWORD:3PKZ7fcS9aVpkMjZ59oePt4N5owxGC
```
如果使用 SSL 模式，局域网访问是不需要密码的，但如果源ip不是局域网ip的话，就会要求输入密码。
而不是用 SSL 模式的话，默认是必须使用密码，无论是不是局域网。

### Option：`httpd_log`

布尔值，`true`为显示访问日志，`false`为关闭访问日志。

### Option: `httpd_error_log`

布尔值，`true`为显示错误日志，`false`为关闭错误日志。

### Option: `container_timezone`

时区设置，此选项不写的话，默认为`Asia/Shanghai`。

### Option：`debug`

开启 `set -x`，用于 start.sh 脚本调试。


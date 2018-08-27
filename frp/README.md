# frp

## options:

```
{
    "auto_download":true,
    "frp_version":"0.21.0",
    "debug":true,
    "cmd":[
        "echo 'frp runing'",
        "/share/frp/frps -c /share/frp/frps.ini"
    ]
}
```

- **auto_download 【必选】：** `true` 开启自动下载，并可以修改 `frp_version` 版本号自动更新 frp。`false` 则会关闭所有下载功能。
- **frp_version 【可选】：** 如果不填写版本号的话，默认**每次启动都会**下载github上最新的frp编译版本，如果速度太慢，请到github自行下载后放入 share 目录（无需解压和改名）。（需要将 `auto_download` 设为 true）
- **debug：** 开启脚本调试模式。 
- **cmd：** 容器运行命令，类型为dict，允许自行运行各种命令，但frps或者frpc命令应当为dict最后一个成员。


# frp

## options:

```
{
    "cmd":[
        "echo 'frp runing'",
        "/share/frp/frps -c /share/frp/frps.ini"
    ],
    "frp_version":"0.21.0",
    "debug":"true"
}
```

- **cmd：** 容器运行命令，类型为dict，允许自行运行各种命令，但frps或者frpc命令应当为dict最后一个成员。
<<<<<<< HEAD
- **frp_version 【可选】：** 默认下载github上最新的frp编译版本，如果速度太慢，请到github自行下载后放入 share 目录（无需解压和改名）。
- **debug：** 开启脚本调试模式。 
=======
- **frp_version 【可选】：** 如果不填写版本号的话，默认**每次启动都会**下载github上最新的frp编译版本，如果速度太慢，请到github自行下载后放入 share 目录（无需解压和改名）。
- **debug：** 开启脚本调试模式。 
>>>>>>> 40124259f568e335423fd6dad83235e9424974de

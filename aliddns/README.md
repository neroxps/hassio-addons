# aliyun-ddns-cli

基于阿里云开放api更新动态IP到域名。

本项目参考[chenhw2](https://github.com/chenhw2)/[aliyun-ddns-cli](https://github.com/chenhw2/aliyun-ddns-cli) 制作而成。

# Options

* **akid(必须):**填写阿里云 Access Key ID
* **aksct(必须):**填写阿里云 Access Key Secret
* **domain(必须):**更新域名的全称，必须而完整填写域名。
* **redo(可选):**单位秒，默认是600秒检测一次。
* **ipapi(可选):**可填写自定义获取域名的url，例如:`http://myip.ipip.net`

> 关于如何获取阿里云 Access key 请查看阿里云帮助文档[如何获取AccessKey ID和AccessKey Secret](https://help.aliyun.com/knowledge_detail/38738.html) 

# Support list

- amd64(测试通过)
- i368(未测试)
- armhf(未测试)
- aarch64(未测试)

由于我没有树莓派，请使用的同学测试后反馈给我是否可用，谢谢。
# Changelog

## [0.0.5] - 2018-08-26
### Added
- 增加 `auto_download` 选项，方便使用者自行选择使用自动下载 frp 功能。

### Fixed
- 修复 debug 选项不填写无法启动 addons 的问题。
- 修改下载文件逻辑。
- 修改本地版本检测方法，使用 `frpc --version` 或者 `frps --version` 来进行本地版本检测，抛弃 `.version` 存储本地版本方法。

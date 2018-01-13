# Bluetooth Scan Tracker

利用 Linux 蓝牙工具 `hcitool name $MAC` 方法来鉴别设备是否在蓝牙覆盖范围内，此方法能有效监测 Apple iPhone IPAD 设备。（不支持 BLE 设备，例如小米手环）

## 使用方法

### 1.修改 options

```json
{
  "sleep_time":"2",
  "mqtt_address":"192.168.1.100",
  "mqtt_user":"username",
  "mqtt_password":"password",
  "mqtt_port":"1883",
  "mqtt_topic":"/ble/tracker",
  "blue_list":[
      {
        "name":"tom",
        "mac": "01:23:45:67:89:AB"
      },
      {
        "name":"jack",
        "mac": "01:23:45:67:89:AB"
      },
      {
        "name":"elspie",
        "mac": "01:23:45:67:89:AB"
      },
      {
        "name":"gawain",
        "mac": "01:23:45:67:89:AB"
      }
    ]
}
```
**配置列表**

| 选项 | 必须 | 说明 | 例子 |
|---|---|---|---|
| sleep_time | × | 扫描间隔，默认 5 秒 | 2 |
| mqtt_address | √ | MQTT 地址 | 192.168.1.1 |
| mqtt_user | √ | MQTT 用户名 | username |
| mqtt_password | √ | MQTT 密码 | password |
| mqtt_port | × | MQTT 服务监听端口默认:1883 | 1883 |
| mqtt_topic | √ | MQTT 主题，与 Home Assistant 配置配合使用 | /ble/tracker |
| blue_list | √ | 设备蓝牙mac列表 | 见下方 |
| name | √ | 设备在 Home Assistant 配置使用的名字 | tom |
| mac | √ | 设备的蓝牙 MAC 地址 | 01:23:45:67:89:AB |

### 2.编写 Home Assistant 传感器配置

```
binary_sensor:
  - platform: mqtt
    name: "tom"
    state_topic: "/ble/tracker/tom"
    qos: 0
    payload_on: "enter"
    payload_off: "leave"
    device_class: opening
  - platform: mqtt
    name: "Jack"
    state_topic: "/ble/tracker/jack"
    qos: 0
    payload_on: "enter"
    payload_off: "leave"
    device_class: opening
  - platform: mqtt
    name: "elspie"
    state_topic: "/ble/tracker/elspie"
    qos: 0
    payload_on: "enter"
    payload_off: "leave"
    device_class: opening
  - platform: mqtt
    name: "gawain"
    state_topic: "/ble/tracker/gawain"
    qos: 0
    payload_on: "enter"
    payload_off: "leave"
    device_class: opening

sensor:
  - platform: template
    sensors:
      tom:
        value_template: "{% if states.binary_sensor.tom%}
          {% if is_state('binary_sensor.tom', 'on') %}
            在家
          {% else %}
            离家
          {% endif %}
          {% else %}
            未知
          {% endif %}"

  - platform: template
    sensors:
      jack:
        value_template: "{% if states.binary_sensor.jack%}
          {% if is_state('binary_sensor.jack', 'on') %}
            在家
          {% else %}
            离家
          {% endif %}
          {% else %}
            未知
          {% endif %}"

  - platform: template
    sensors:
      elspie:
        value_template: "{% if states.binary_sensor.elspie%}
          {% if is_state('binary_sensor.elspie', 'on') %}
            在家
          {% else %}
            离家
          {% endif %}
          {% else %}
            未知
          {% endif %}"

  - platform: template
    sensors:
      gawain:
        value_template: "{% if states.binary_sensor.gawain%}
          {% if is_state('binary_sensor.gawain', 'on') %}
            在家
          {% else %}
            离家
          {% endif %}
          {% else %}
            未知
          {% endif %}"


homeassistant:
  customize:
    sensor.tom:
      friendly_name: 'Tom'
      homebridge_hidden: true
      icon: mdi:account
    sensor.jack:
      friendly_name: 'Jack'
      homebridge_hidden: true
      icon: mdi:account
    sensor.elspie:
      friendly_name: 'Elspie'
      homebridge_hidden: true
      icon: mdi:account
    sensor.gawain:
      friendly_name: 'Gawain'
      homebridge_hidden: true
      icon: mdi:account

group:
  family_member:
    view: yes
    name: "家庭成员"
    entities:
      - sensor.tom
      - sensor.jack
      - sensor.elspie
      - sensor.gawain
```
注意事项：
* **binary_sensor** 里面的 **name** 必须和 **options** 里面填写的 **blue_list.name** 一致。
*  **state_topic** 必须和 **options** 里面填写的 **mqtt_topic** 前序一致，并且 **mqtt_topic** 的结尾不能带 `/`，正确的写法：`/ble/tracker`，错误的写法：`/ble/tracker/`。

**Enjoy**

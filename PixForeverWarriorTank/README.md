<p align="center"><img src="banner.png" alt="Forever 防战" width="100%"></p>

# PixForeverWarriorTank

Windows、简体中文、WoW Forever模式防战像素循环，使用12.1 API及秘密值显示机制。仅检查WARRIOR职业，不依赖现代专精编号。独立配置PixForeverWarriorTankDB，不共享其他应用的状态。

## 运行

从仓库根目录执行：

```powershell
uv sync --locked
uv run --locked --directory PixForeverWarriorTank pythonw -m pix
```

点击拷贝插件，将pix/lua安装至Interface/AddOns/PixForeverWarriorTank，执行/reload，再启动截图和循环。程序需要管理员权限，目标进程wow.exe。TOC为120100，参考API源码12.1.0.69933；实际Forever客户端需验证。插件会按旧项目设置UI缩放、抗锯齿及相关CVar，并覆盖技能绑定。

## 配置与操作

怒气上限默认100（100–130，步进5），破甲怒气默认15（12–15，步进1）。目标打断默认开，焦点始终参与；进度默认30%（10–90，步进10），黑名单可编辑，取升序前15个法术ID。
模式按钮自动→单体→AOE，脱战及重载恢复自动。撕裂按钮默认开，跨脱战及重载保存；两个按钮并排，Shift拖动模式按钮共同移动并保存位置。其他配置持久保存。

/pix toggle切换启停，/pix disable关闭，/pix delay [秒]暂停（默认0.4秒），/pix auto、single、aoe切换模式。选中自己暂停全部自动动作。无效当前目标也会暂停焦点打断；普通输出只针对当前目标。

截图失败或帧龄超过0.5秒不发对应动作。动作日志不代表游戏已施法成功。没有额外减伤、自疗、药水或饰品循环。

## 文档与验证

[像素布局](.context/layout.md)、[键位宏](.context/keymap.md)、[循环规则](.context/rotation.md)、[配图来源](.context/banner.prompt.md)。运行Pyright和compileall检查本应用；游戏内需验证新布局、光环、姿态、类型及技能等级切换。

共用根目录Python 3.13、uv环境及build.ps1；构建自动发现本项目，产物为dist/PixForeverWarriorTank/，分发整个目录。许可证为GPLv3。

爆发状态预留：加载或重载时开启60秒窗口，`/pix burst`默认15秒，`/pix burst 30`设置30秒，`/pix burst 0`结束。脱战不重置，面板显示剩余时间（最多60秒），044格与`Context.in_burst`提供状态，当前防战循环不使用。更新后重新拷贝插件、`/reload`并重启桌面程序重新定位188×12布局。

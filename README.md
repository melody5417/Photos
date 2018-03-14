# Photos

```
今天刚接了个 「检测30s内是否有截图并提示」 的需求，调研了2种方案：
1. 注册 UIApplicationUserDidTakeScreenshotNotification ，但是这个通知只在 App 在前台时才有效，遂放弃。
2. 检索图库是否有近 30s 内的截图文件存在。
最后确定用第二种方法，正好自己也没有搞过 iOS 的相册相关开发，所以学习总结一下。
```
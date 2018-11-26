# NSMutableURLRequestRepeatCheck
1. AOP方式，DEBUG模式下启用。
2. 基于URL和HttpBody判断相同请求，如果在预先设置的时间内多次发送相同值的URL和HttpBody，则在控制台打印SameHTTPRequest标识,URL和URLHTTPBody。
3. 重复请求判定时间可以使用类方法修改。
4. 运行一段时间后，在控制台搜索SameHTTPRequest则可以定位到重复请求。
5. 更优化的用法可能是弹出一个提示，或者埋点等。

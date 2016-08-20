2016-5-6
=======

:mopub
```
https://gershengoren-moses.de/mopub-integration-swift-cocoapods/
```

2016-5-3
=======

:identifier

从网上下载的iosproject， 如果选择手机进行运行的时候， 出现证书相关的问题， 注意检查info.plist里面的记录， 一般在开发的时候，xcode是能够自动安装对应的证书的。 如果不知道自己的配置， 可以新建一个项目， 查看里面的info.plist， 然后做对应的修改.

比如说在做开发的时候， bundle identifier 可以随便取， 只需要在info.plist里面设置对应项的名字为`$(PRODUCT_BUNDLE_IDENTIFIER)`就可以自动匹配你取的名字

2016-4-21
========

:plugin
http://alcatraz.io

:resources :animation
Fackbook pop
Spring
swift toolbox

2016-4-19
========

:resources
wireframe.cc
developer.apple.com
projecteuler.net
textcraft.net
freepik.com
blackmoondev.com

2016-4-17
========

:mix :object-c
https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html

:security
```
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSExceptionDomains</key>
  <dict>
    <key>yourserver.com</key>
    <dict>
      <!--Include to allow subdomains-->
      <key>NSIncludesSubdomains</key>
      <true/>
      <!--Include to allow HTTP requests-->
      <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
      <true/>
      <!--Include to specify minimum TLS version-->
      <key>NSTemporaryExceptionMinimumTLSVersion</key>
      <string>TLSv1.1</string>
    </dict>
  </dict>
</dict>

# Lazyway
<key>NSAppTransportSecurity</key>
<dict>
  <!--Include to allow all connections (DANGER)-->
  <key>NSAllowsArbitraryLoads</key>
      <true/>
</dict>
```

:tableview? :tableviewcontroller?


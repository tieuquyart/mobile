### Secure360

360项目git地址:
git clone https://tscastle.cam2cloud.com/transee/Android/App/saxhorn
dev分支为主分支

#### 1. 项目的主要依赖

##### 1.1. RxJava和Rxlifecycle

    项目重度使用了RxJava，重度参考开源项目android-oss的设计（https://github.com/kickstarter/android-oss）。
    app的主要架构主要是基于RxJava的MVVM架构，部分地方设计地并不纯粹。
    此外也使用了一些Rxlifecycle-components，方便解决RxJava带来的内存泄漏问题。
    
    Todo 部分页面MVVM架构由于开发进度和页面复杂度尚未搭建

##### 1.2. ButterKnife

    view绑定的功能基本都是使用butterknife实现的，没有使用其他的绑定方法。

##### 1.3. 崩溃日志收集

    崩溃日志收集使用了HockeySDK，网址为（https://hockeyapp.net）（username: google@waylens.com，password: Waylens_2016）
    Horizon app也使用了这个SDK。
    
    Todo 这个sdk经常会抓不到崩溃日志，建议有时间更换掉（Removed）

##### 1.4. 网络访问（服务端）

    服务端网络访问主要是基于Retrofit、OkHttp，上层基本没有特别特殊的用法。在单例HttpClient的构造中有不太一样的用法（ApiService.java），这一点会在文档后续集中叙述。

##### 1.5. 网络访问（相机端）

    相机端网络访问依赖了Mina，但仅仅是UPNP协议使用了Mina。在有的socket访问的地方，使用了Mina的IoBuffer类，按照相应的结构体读取。

##### 1.6. 图片加载

    无论是网络图片还是相机上的图片都是使用Glide加载的，其中thumbnail的处理（映射转换）是使用GpuImage的。相机上的图片加载（基于VDB socket）实现在com.mk.autosecure.snipe.glide_adapter这个包里面。

##### 1.7. 播放器

    播放器主要使用了ijkPlayer和ExoPlayer，使用ijkPlayer的主要原因是因为ijkPlayer可以使用软解（高分辨率），并且原生支持rtmp。
    ExoPlayer的主要优点是比较稳定，支持一些定制化。在视频分辨率比较低的情况下，可以使用Exoplayer。
    另外对ijkPlayer和ExoPlayer做了一些封装，独立为了 video-sdk，但暂时只提供给了 ToB 的客户，还未接入项目中替换。
    注意ijkplayer中使用的so文件是自行编译的，编译源文件压缩包已上传至FTP(sftp://cchen@tscastle.cam2cloud.com:22097/share/cchen/Documents/IJK.zip)。
    
##### 1.8. 推送

    因为客户群体主要在国外，所以使用了firebase。云端推送token在google账号控制台下，App推送token其实就是google-service.json文件。
    
    注意服务端推送使用的token没有时间限制，不同于iOS的token限制是一年。

##### 1.9. 其他

    数据库使用了GreenDAO，内存泄漏检测使用了leakcanary，卡顿检测使用了blockcanary，此外还依赖了robolectric做单元测试，但还没怎么用。

#### 2. 相机与App之间的通信

##### 2.1. 相机发现

    相机发现是基于mDNS协议，是一种multicast和DNS协作的协议。在目前app主要依赖JmDNS和android的Nsd，这部分的实现
    主要集中在com.mk.autosecure.camera.connectivity这个包里面。JmDNS和Nsd的功能差不多，主要的区别在与，JmDNS会重复
    汇报收到的相机信息，所以JmDNS会相对更保险一些，相当于内含重试机制。
    
    一般来说，相机发现是没有问题的。multicast可以基本保证mDNS报文能够被收到，但是Android存在网卡绑定的问题。即会出现，mDNS
    协议发现了相机，但是UPNP（相机10086端口）连接不上的情况。目前的解决方案是，在手机网络发生改变的时候，通过bindNetworkToProcess类似的函数完成进程的默认网卡的绑定。因为，手机只能通过Wi-Fi和相机连接，所以绑定到Wi-Fi网卡是可以保证连接到相机的。
    
##### 2.2. 相机连接

    相机连接方式有两种：1.Wi-Fi 2.WiFi Direct。前者需要手机输入密码，连接到相机的AP热点，后者无须密码，通过Direct扫描到相机进而连接。
    
    Wi-Fi连接相对稳定，Direct连接是为了解决国内手机连接不分配DNS的相机AP热点时，会被手机系统判定为无网络访问的Wi-Fi，进而把当前连接的AP热点啊切换到其他可用的WiFi。
    
    Direct相关代码均在com.mk.autosecure.direct包下。

##### 2.3. VdtCam相机命令连接，command端口（10086）

    这个端口就是所谓的UPNP端口，通信协议基于xml，Android app端使用Mina框架实现了通信协议。通信协议的实现主要包含在com.mk.autosecure.camera.protocol这个包里面。
    
    VdtCamera包含了常规的命令，详细实现见代码。
    
##### 2.4. EvCam相机命令连接，command端口(10088)

    通信协议基于http，同样使用mina框架实现了通信协议。具体实现是在com.mk.autosecure.camera.protocol包下。
    
    EvCamera包含了常规的命令，详细实现见代码。

##### 2.5. VDB端口，即视频数据端口（8083）

    VDB的具体实现在com.mk.autosecure.snipe这一个包里面，负责视频相关的功能。VDB是直接基于socket实现的，request、response
    还有message queue的实现逻辑和volley非常相似。其实是参考了volley的实现，最大的区别在于snipe是按照队列一个一个发送请求的，这个考虑到相机的请求处理能力，不限制的发送VDB请求会导致大量请求失败，甚至导致相机端出问题。

##### 2.6. Motion-JPEG端口(8081)

    Motion-JPEG是相机实时预览的实现方式，主要实现在com.mk.autosecure.libs.mjpegview。360项目中，使用了openGL来渲染视频，
    所以并没有直接使用MjpegView这个类。
    
##### 2.7. DMS端口(1368)

    DMS的具体实现在com.mk.autosecure.camera.data这一个包里面，负责DMS相关的功能。实现框架和DMS非常相似。
    
    Todo SDK 后续开发需要把 VDB 和 DMS 的相机数据请求这块合并

#### 3. App的主干架构

##### 3.1. MVVM的实现

    360 app的MVVM重度参考了开源项目android-oss。MVVM的基础实现在com.mk.autosecure.libs这个包中。主要包括BaseActivity, ActivityViewModel, BaseFragment, FragmentViewModel, ActivityViewModelManager以及FragmentViewModelManager等等。
    
    在这个MVVM架构中，BaseActivity和BaseFragment其实充当的是view的身份。FragmentViewModel和ActivityViewModel就是对应的ViewModel。BaesActivity通过ActivityViewModelManager获得ViewModel, 也就是说view持有ViewModel的引用，但是ViewModel并不知道view的存在。而且，ViewModel单独持有model。BaseActivity通过
    ViewModel的输入接口以及Rx形式(Observable)的输出接口，完成交互逻辑。
    
    此外，Activity通过@RequiresActivityViewModel注解实现ViewModel的注入。
    
    具体实现可以参考现有代码。

##### 3.2.Dagger2依赖注入的使用

    项目少量使用了Dagger2完成依赖注入的功能，目前仅仅使用了一app层的单例。向外暴露了用户信息、数据库Session、Gson等等。
    app的全局信息最好都放在dagger2里，可以参考com.mk.autosecure.libs.account.CurrentUser的实现，包裹SharedPreference。

##### 3.3.HttpRemuxer

    com.transee.vdb这个包里面包含的是mp4下载库，功能是把一段ts转成为mp4。这部分功能是使用动态库libavfmedia.so完成的。
    动态库中存在反向调用Java代码，所以包名最好不要改动，否则需要改jni的代码。libavfmedia的实际代码由Oliver维护。

##### 3.4. 转码模块（mediatranscoder）

    mediatranscoder这个module是基于MediaCodec和OpenGL的，作用是进行原始视频的dewarp，转为方便观看的视频。
    360的app在转码的时候会比普通的转码过程多一步，即视频帧会在OpenGL上remap一次。
    OpenGL映射的模型在com.waylens.mediatranscoder.engine.surfaces包下。
    decoder模块的输出是OpenGL的surface上，encoder的输入也是这个surface。整个pipeline是由encoder驱动的，一直编码直到decoder解码完所有的帧。
    
    由于360 app的分辨率比较大(大概2k * 2k)，一些硬件性能(MediaCodec)较差的手机是没办法转码360视频的，目前看来主要是解不了，毕竟编码可以自己调节参数，1080p或者720p编码应该是没问题。这个有待于加入软解码或者其他方式解决。

##### 3.5. vrlib的实现和使用

    vrlib这个模块是根据一个开源项目（https://github.com/ashqal/MD360Player4Android）稍稍改动的，主要功能是实现全景视频的渲染。vrlib内部通过InterativeModeManager、ProjectionModeManager等实现全景视频的各种交互模式和映射模式。此外，映射模式是通过com.asha.vrlib.strategy.projection和com.asha.vrlib.objects这两个包完成的。自定义映射模式就是在按照规则在这两个包中增加Projection模式和投影模型。

    后面这个库可能需要跟 GpuImage 选择一个来进行实现。

##### 3.6. maputils

    google提供的maputils，使用在google map上绘制覆盖物或几何图形等。

#### 4. 网络访问方面兼容性的改动

    在360相机只有hotspot，没有client模式的前提下，Android网络栈的兼容性问题是挺棘手的。在连接到相机hotspot Wi-Fi的情况下，不同的Android手机有以下几种不同表现形式。1、一部分手机判断Wi-Fi没有互联网访问，app进程的网络请求被绑定到流量卡的网卡，这种情况下app可以访问服务器，但是无法连接到相机。2、一部分手机不会有这个网络探测，app进程的socket依然绑定在Wi-Fi网卡，这种情况下，app可以连接到服务器，但是不能进行访问服务器。
    
    Android 5.0之前并没有合适的网卡绑定api支持，Android 5.0之后陆续增加了ConnectivityManager.setProcessDefaultNetwork(network)以及bindProcessToNetwork()这些api。这些api的功能都是针对于整个进程而言的，相当于进程的默认网卡会是同一个。目前的做法是，如果连接到360相机Wi-Fi，则一致地把app进程绑定到Wi-Fi网卡。这样默认情况下，app是可以正常和相机通信的。但是，360相机的一些应用场景需要相机和服务端同时访问，比如说相机绑定、连接相机下载firmware。
    所以连接到相机Wi-Fi时，app对服务器的所有网络操作都需要绑定到流量网卡中。这是一个比较复杂的情况，需要分情况处理。app对服务端的访问主要有以下几个，图片加载、rest请求、视频播放以及webview。好在图片加载和rest请求都是基于http的，而OkHttpClient可以指定socket factory, 而android Network类刚好提供了获取socket fractory的接口，所以可以获取cellular网卡的network构造出OkHttpClient提供给glide和retrofit即可。
    
    至于播放器，ijk的网络访问层是基于FFmpeg的，网络访问是native c的代码实现的，所以改起来不方便。因此在服务端基于http访问的视频，可以采用ExoPlayer。ExoPlayer是基于Java的播放器，可以给它传递基于OkHttpClient的网络层，最终可以实现视频播放。
    
    但是相机视频播放还是使用ijkPlayer为好，因为ExoPlayer基于MediaCodec，可能出现硬解码失败的情况，在ExportActivity中低性能手机可能播不了，这个需要换成ijkPlayer。rmtp直播也只能用ijkPlayer，ExoPlayer虽然可以通过rmtp插件完成播放，但是要解决网络问题，还是要在ndk层改动代码。


### Fleet

    在 Secure360 项目的基础上，build.gradle 中定义了 productFlavors，并添加了 buildConfigField 来区分是否是 fleet 版本。

    点击Build，选择 Select Build Variant 可以进行 horn 或者 fleet 的调试运行。

    打包时注意 Secure360 的项目要使用 keystore目录下的 horn.jks，而 fleet 使用 fleet.jks。
    
    服务端网络访问一样是基于Retrofit、OkHttp，具体接口在(FleetApiClient.java)中，接口文档定义在 http://phabricator.waylens.cn/w/

### WaylensVideoSDK

    源码在ftp（sftp://cchen@tscastle.cam2cloud.com:22097/share/cchen/WaylensVideoSDK_SourceCode/WaylensVideoSDK.zip）
    
#### player 模块

    集成了 ijkplayer 和 exoplayer，封装了共有的 player 方法，根据 ijk 和 exo 分别实现。
    
#### preview 模块

    实现了camera的预览

#### vrlib 模块

    实现了全景视频的渲染，与原360项目中的vrlib模块相同，后期需要与 GpuImage 做取舍。
    
#### mediatranscoder 模块

    根据原360项目中的mediatranscoder模块重新封装而成
    
### video-sdk-android

    源码在ftp（sftp://cchen@tscastle.cam2cloud.com:22097/share/cchen/video-sdk-android-release-1.0/video-sdk-android.zip）

    根据 WaylensVideoSDK 源码打包的第一版SDK，已交付到 ToB 用户。


### 之后需要解决的问题 

    ================= 2020年11月起，要求更新的应用需要 Android Q 的适配 ==================（finished）




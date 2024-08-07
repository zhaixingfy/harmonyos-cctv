- 鸿蒙SDK
- C:\Program Files\Huawei\DevEco Studio\sdk\HarmonyOS-NEXT-DB2\openharmony\ets\kits

- http
- https://developer.huawei.com/consumer/cn/training/course/slightMooc/C101717497918284399
- https://developer.huawei.com/consumer/cn/training/result?type1=101718934267126043

- TextInput
- https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V2/ts-basic-components-textinput-0000001427584864-V2

```ts
import { BusinessError } from '@kit.BasicServicesKit'; 
import { camera } from '@kit.CameraKit'; 
import { common } from '@kit.AbilityKit'; 
const context = getContext(this) as common.UIAbilityContext; 
@Entry 
@Component 
struct GetFrontCameraImage { 
  private xComponentController: XComponentController = new XComponentController(); 
  async getCameraImage() { 
    // 1、使用系统相机框架camera模块获取物理摄像头信息。 
    let cameraManager = camera.getCameraManager(context); 
    let camerasInfo: Array<camera.CameraDevice> = cameraManager.getSupportedCameras(); 
    let cameraDevice: camera.CameraDevice = camerasInfo[0]; 
    // 检测相机状态 
    cameraManager.on('cameraStatus', (err: BusinessError, cameraStatusInfo: camera.CameraStatusInfo) => { 
      console.log(`camera : ${cameraStatusInfo.camera.cameraId}`); 
      console.log(`status : : ${cameraStatusInfo.status}`); 
    }); 
    // 2、创建并启动物理摄像头输入流通道 
    // 设置为前置摄像头 camera.CameraPosition.CAMERA_POSITION_FRONT 
    let cameraInput = cameraManager.createCameraInput(camera.CameraPosition.CAMERA_POSITION_FRONT, camera.CameraType.CAMERA_TYPE_DEFAULT); 
    await cameraInput.open(); 
    // 3、拿到物理摄像头信息查询摄像头支持预览流支持的输出格式，结合XComponent提供的surfaceId创建预览输出通道 
    let outputCapability = cameraManager.getSupportedOutputCapability(cameraDevice, camera.SceneMode.NORMAL_PHOTO); 
    let previewProfile = outputCapability.previewProfiles[0]; 
    let surfaceId = this.xComponentController.getXComponentSurfaceId(); 
    let previewOutput = cameraManager.createPreviewOutput(previewProfile, surfaceId); 
    // 4、创建相机会话，在会话中添加摄像头输入流和预览输出流，然后启动会话，预览画面就会在XComponent组件上送显。 
    let captureSession = cameraManager.createSession(camera.SceneMode.NORMAL_PHOTO); 
    captureSession.beginConfig(); 
    captureSession.addInput(cameraInput); 
    captureSession.addOutput(previewOutput); 
    captureSession.commitConfig() 
    captureSession.start(); 
  } 
  build() { 
    Row() { 
      Column({ space: 20 }) { 
        XComponent({ id: 'xComponentId1', type: 'surface', controller: this.xComponentController }) 
          .height(300) 
        Button('打开摄像头') 
          .onClick(() => { 
            // 在调用前确保已经获得相机权限 
            this.getCameraImage(); 
          }) 
      } 
      .width('100%') 
    } 
    .height('100%') 
  } 
}
```

```ts
// 如何检测当前相机服务的状态
import { camera } from '@kit.CameraKit'; 
import { BusinessError } from '@kit.BasicServicesKit'; 
 
let cameraManager = camera.getCameraManager(getContext(this)); 
cameraManager.on('cameraStatus', (err: BusinessError, cameraStatusInfo: camera.CameraStatusInfo) => { 
  console.log(`camera : ${cameraStatusInfo.camera.cameraId}`); 
  console.log(`status: ${cameraStatusInfo.status}`); 
});
```

```ts
// 引入包名
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';

// 每一个httpRequest对应一个HTTP请求任务，不可复用
let httpRequest = http.createHttp();
// 用于订阅HTTP响应头，此接口会比request请求先返回。可以根据业务需要订阅此消息
// 从API 8开始，使用on('headersReceive', Callback)替代on('headerReceive', AsyncCallback)。 8+
httpRequest.on('headersReceive', (header: Object) => {
  console.info('header: ' + JSON.stringify(header));
});

httpRequest.request(// 填写HTTP请求的URL地址，可以带参数也可以不带参数。URL地址需要开发者自定义。请求的参数可以在extraData中指定
  "EXAMPLE_URL",
  {
    method: http.RequestMethod.POST, // 可选，默认为http.RequestMethod.GET
    // 当使用POST请求时此字段用于传递请求体内容，具体格式与服务端协商确定
    extraData: 'data to send',
    expectDataType: http.HttpDataType.STRING, // 可选，指定返回数据的类型
    usingCache: true, // 可选，默认为true
    priority: 1, // 可选，默认为1
    // 开发者根据自身业务需要添加header字段
    header: { 'Accept' : 'application/json' },
    readTimeout: 60000, // 可选，默认为60000ms
    connectTimeout: 60000, // 可选，默认为60000ms
    usingProtocol: http.HttpProtocol.HTTP1_1, // 可选，协议类型默认值由系统自动指定
    usingProxy: false, //可选，默认不使用网络代理，自API 10开始支持该属性
    caPath: '/path/to/cacert.pem', // 可选，默认使用系统预设CA证书，自API 10开始支持该属性
    clientCert: { // 可选，默认不使用客户端证书，自API 11开始支持该属性
      certPath: '/path/to/client.pem', // 默认不使用客户端证书，自API 11开始支持该属性
      keyPath: '/path/to/client.key', // 若证书包含Key信息，传入空字符串，自API 11开始支持该属性
      certType: http.CertType.PEM, // 可选，默认使用PEM，自API 11开始支持该属性
      keyPassword: "passwordToKey" // 可选，输入key文件的密码，自API 11开始支持该属性
    },
    certificatePinning: [ // 可选，支持证书锁定配置信息的动态设置，自API 12开始支持该属性
      {
        publicKeyHash: 'Pin1', // 由应用传入的证书PIN码，自API 12开始支持该属性
        hashAlgorithm: 'SHA-256' // 加密算法，当前仅支持SHA-256，自API 12开始支持该属性
      }, {
        publicKeyHash: 'Pin2', // 由应用传入的证书PIN码，自API 12开始支持该属性
        hashAlgorithm: 'SHA-256' // 加密算法，当前仅支持SHA-256，自API 12开始支持该属性
      }
    ],
    multiFormDataList: [ // 可选，仅当Header中，'content-Type'为'multipart/form-data'时生效，自API 11开始支持该属性
      {
        name: "Part1", // 数据名，自API 11开始支持该属性
        contentType: 'text/plain', // 数据类型，自API 11开始支持该属性
        data: 'Example data', // 可选，数据内容，自API 11开始支持该属性
        remoteFileName: 'example.txt' // 可选，自API 11开始支持该属性
      }, {
        name: "Part2", // 数据名，自API 11开始支持该属性
        contentType: 'text/plain', // 数据类型，自API 11开始支持该属性
        // data/app/el2/100/base/com.example.myapplication/haps/entry/files/fileName.txt
        filePath: `${getContext(this).filesDir}/fileName.txt`, // 可选，传入文件路径，自API 11开始支持该属性
        remoteFileName: 'fileName.txt' // 可选，自API 11开始支持该属性
      }
    ]
  },
  (err: BusinessError, data: http.HttpResponse) => {
    if (!err) {
      // data.result为HTTP响应内容，可根据业务需要进行解析
      console.info('Result:' + JSON.stringify(data.result));
      console.info('code:' + JSON.stringify(data.responseCode));
      console.info('type:' + JSON.stringify(data.resultType));
      // data.header为HTTP响应头，可根据业务需要进行解析
      console.info('header:' + JSON.stringify(data.header));
      console.info('cookies:' + JSON.stringify(data.cookies)); // 自API version 8开始支持cookie
      // 取消订阅HTTP响应头事件
      httpRequest.off('headersReceive');
      // 当该请求使用完毕时，开发者务必调用destroy方法主动销毁该JavaScript Object。
      httpRequest.destroy();
    } else {
      console.info('error:' + JSON.stringify(err));
      // 取消订阅HTTP响应头事件
      httpRequest.off('headersReceive');
      // 当该请求使用完毕时，开发者务必调用destroy方法主动销毁该JavaScript Object。
      httpRequest.destroy();
    }
  });
```

```ts
http.createHttp().request(`https://api.cntv.cn/NewVideo/getVideoListByColumn?id=${v.id}&n=${page.size}&sort=desc&p=${page.cur}&d=&mode=0&serviceId=tvcctv&callback=a`).then((res: http.HttpResponse) => {
  let str = res.result as string
  str = str.substring(str.indexOf('(') + 1, str.lastIndexOf(')'))
  const data: ResVideoMain= (JSON.parse(str) as ResVideo).data
  page.total = data.total
  this.video.list = data.list
}).finally(() => {
  this.video.isLoading = false
})
```

```ts
this.controller = new VideoController()

Video({
  src: this.video.m3u8,
  currentProgressRate: 1,
  controller: this.controller,
}).width('100%').height('100%').objectFit(ImageFit.Contain).autoPlay(true)
```

```ts
// TextInput
Row() {
  TextInput({
    controller: this.textController,
    text: this.msg,
  }).margin(10).border({
    width: 2,
    color: 'red',
    radius: 4,
    style: BorderStyle.Solid
  }).onChange(e => {
    this.msg = e.valueOf()
    console.log(e.valueOf())
  })
}

Row() {
  Text(this.msg).padding(10).backgroundColor('#0a0').textAlign(TextAlign.Center)
}.width('100%').backgroundColor('#0ff').padding(10).justifyContent(FlexAlign.Center)
```

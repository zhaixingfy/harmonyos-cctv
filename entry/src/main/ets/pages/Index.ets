import { http } from '@kit.NetworkKit'
import { display } from '@kit.ArkUI'

import channel from './channel'
import type { AlbumRow } from './channel'

interface ResVideoRow {
  guid: string
  image: string
  title: string
}

interface ResVideoMain {
  total: number
  list: ResVideoRow[]
}

interface ResVideo {
  data: ResVideoMain
}

interface resM3u8 {
  hls_url: string
}

interface Device {
  width: number
  height: number
}

interface PageSelectOption {
  value: string
}

interface Page {
  cur: number
  size: number
  total: number
  pageSelectOptions: PageSelectOption[]
}

interface Video {
  isLoading: boolean
  list: ResVideoRow[]
  itemWidth: string
  m3u8: string
}

interface D {
  idxChannel: number
  idxAlbum: number
}

const createHttp = () => {
  return http.createHttp()
}

@Entry
@Component
struct Index {
  @State logStr: string = '';
  @State d: D = {
    idxChannel: 0,
    idxAlbum: 0,
  };
  @State device: Device = {
    width: 0,
    height: 0,
  };
  @State video: Video = {
    isLoading: true,
    list: [],
    itemWidth: '',
    m3u8: ''
  };
  @State page: Page = {
    cur: 1,
    size: 50,
    total: 0,
    get pageSelectOptions(): PageSelectOption[] {
      return Array(Math.ceil(this.total / this.size)).fill(0).map((_: number, idx: number): PageSelectOption => {
        return { value: `第${ idx + 1 }页` }
      })
    },
  };
  loadM3u8(v: ResVideoRow) {
    createHttp().request('https://vdn.apps.cntv.cn/api/getHttpVideoInfo.do?pid=' + v.guid + '&tai=ipad&client=html5&im=1&tsp=1638039321&vn=2049&vc=D715331B1C1F7749D4F59C17E41BEF27&uid=30184311DE59C6D9827F428CD638263A&wlan=').then((res: http.HttpResponse) => {
      const data: resM3u8 = JSON.parse(res.result as string)
      this.video.m3u8 = data.hls_url
    })
  }
  controller = new VideoController()

  loadData() {
    const d = this.d
    const page = this.page
    const v = channel[d.idxChannel].children[d.idxAlbum]

    this.video.isLoading = true
    this.video.list = []
    createHttp().request(`https://api.cntv.cn/NewVideo/getVideoListByColumn?id=${v.id}&n=${page.size}&sort=desc&p=${page.cur}&d=&mode=0&serviceId=tvcctv&callback=a`).then((res: http.HttpResponse) => {
      let str = res.result as string
      str = str.substring(str.indexOf('(') + 1, str.lastIndexOf(')'))
      const data: ResVideoMain= (JSON.parse(str) as ResVideo).data
      page.total = data.total
      this.video.list = data.list
    }).finally(() => {
      this.video.isLoading = false
    })
  }
  log(msg: string) {
    this.logStr = msg
  }
  init() {
    const device = display.getDefaultDisplaySync()

    this.device.width = px2vp(device.width || 1260)
    this.device.height = px2vp(device.height || 2680)

    const len = Math.ceil(this.device.width / 260)
    this.video.itemWidth = 1 / len * 100 + '%'
    // this.log(this.device.width.toString())
  }
  aboutToAppear(): void {
    this.init()
    this.loadData()

    display.on('change', () => {
      this.init()
    })
  }
  aboutToDisappear(): void {
    this.video.list = []
  }
  build() {
    Flex({
      direction: FlexDirection.Column
    }) {
      Row() {
        Text('CCTV - 鸿蒙客户端').fontColor('#fff').fontWeight(FontWeight.Bold).layoutWeight(1)
        Text('数据源：央视网').fontColor('#aaa').fontSize(13)
        if (this.video.m3u8) {
          Text('关闭').fontColor('#aaa')
          .fontSize(13).margin({left: 12}).backgroundColor('#c30').fontColor('#fff').padding({
            left: 8,
            right: 8,
            top: 2,
            bottom: 2,
          }).borderRadius(4).onClick(() => {
            this.video.m3u8 = ''
          })
        }
      }.width('100%').backgroundColor('#36393f').padding({
        left: 15,
        right: 15,
        top: 10,
        bottom: 10,
      })
      Stack() {
        Flex({
          direction: FlexDirection.Column
        }) {
          Scroll() {
            Row() {
              ForEach(channel, (v: AlbumRow, idx: number) => {
                Text(v.name).padding({
                  left: 10,
                  right: 10,
                  top: 10,
                  bottom: 10,
                })
                  .fontSize(14)
                  .fontColor(idx === this.d.idxChannel ? '#09f' : '#000')
                  .onClick(() => {
                    this.d.idxChannel = idx
                    this.d.idxAlbum = 0
                    this.page.cur = 1
                    this.loadData()
                  })
              })
            }.padding({
              left: 5,
              right: 5,
            })
          }.scrollable(ScrollDirection.Horizontal)
          Divider()
          Scroll() {
            Row() {
              ForEach(channel[this.d.idxChannel].children, (v: AlbumRow, idx: number) => {
                Text(v.name).padding({
                  left: 10,
                  right: 10,
                  top: 10,
                  bottom: 10,
                })
                  .fontSize(14)
                  .fontColor(idx === this.d.idxAlbum ? '#09f' : '#000')
                  .onClick(() => {
                    this.d.idxAlbum = idx
                    this.page.cur = 1
                    this.loadData()
                  })
              })
            }.padding({
              left: 5,
              right: 5,
            })
          }.scrollable(ScrollDirection.Horizontal)
          Divider()

          Scroll() {
            if (!this.video.list.length) {
              Text(this.video.isLoading ? '数据加载中...' : '暂无数据')
            } else {
              Flex({
                wrap: FlexWrap.Wrap,
              }) {
                if (this.logStr) Text(this.logStr).width('100%');
                ForEach(this.video.list, (v: ResVideoRow) => {
                  RelativeContainer() {
                    Image(v.image).width('100%').height('100%').backgroundColor('#ddd')
                    Text(v.title).width('100%').fontSize(12).position({
                      left: 0,
                      bottom: 0,
                    }).backgroundColor('#000').fontColor('#fff').textOverflow({
                      overflow: TextOverflow.Ellipsis
                    }).maxLines(2).padding(5).opacity(.6)
                  }.width(this.video.itemWidth).aspectRatio(1.5).padding(5).onClick(() => {
                    console.log('v.guid is', v.guid)
                    this.loadM3u8(v)
                  })
                })
              }.padding(10).width('100%')
            }
          }.width('100%').height('100%').layoutWeight(1).align(this.video.list.length > 0 ? Alignment.TopStart : Alignment.Center)
          Divider()
          Flex() {
            Column() {
              Text(`${this.page.cur} / ${Math.ceil(this.page.total / this.page.size)}`)
            }.alignSelf(ItemAlign.Center)
            Row() {
              Select(this.page.pageSelectOptions).margin({ left: 10 })
                .value(this.page.pageSelectOptions[0]?.value || '')
                .onSelect((index: number) => {
                  this.page.cur = index + 1
                  this.loadData()
                })
            }.layoutWeight(1)
            Column() {
              Text('个人练习 (摘星fy)').fontSize(13).fontColor('#999')
              Text('QQ: 273259755').fontSize(13).fontColor('#999')
            }.alignSelf(ItemAlign.Center)
          }.width('100%').backgroundColor('#fff').padding({
            top: 10,
            left: 15,
            right: 15,
          })
        }.width('100%').height('100%')

        if (this.video.m3u8) {
          Video({
            src: this.video.m3u8,
            currentProgressRate: 1,
            controller: this.controller,
          }).width('100%').height('100%').objectFit(ImageFit.Contain).autoPlay(true)
        }
      }.layoutWeight(1)
    }.width('100%').height('100%')
  }
}
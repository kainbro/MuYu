import media from '@ohos.multimedia.media';
import common from '@ohos.app.ability.common';

@Entry
@Component
struct Index {
  @State message: string = '当前功德：';
  @State totalGongDe: number = 0;
  @State showGongDe: boolean = false;
  @State auto: boolean = false;

  private avPlayer
  private intervalID
  private speed: number = 500;

  aboutToAppear() {
    // 初始化音乐播放用动avPlayer
    this.avPlayerFdSrcInit();
  }

  aboutToDisappear() {
    this.avPlayer.release();
    clearInterval(this.intervalID);
  }

  async avPlayerFdSrcInit() {
    // 创建avPlayer实例对象
    this.avPlayer = await media.createAVPlayer();
    // 通过UIAbilityContext的resourceManager成员的getRawFd接口获取媒体资源播放地址
    // 返回类型为{fd,offset,length},fd为HAP包fd地址，offset为媒体资源偏移量，length为播放长度
    let context = getContext(this) as common.UIAbilityContext;
    let fileDescriptor = await context.resourceManager.getRawFd('dong.mp3');
    // 为fdSrc赋值触发initialized状态机上报
    this.avPlayer.fdSrc = fileDescriptor;
  }

  private knock() {
    this.totalGongDe++;
    // 点击后先中断上次播放，再重新放
    this.avPlayer.stop(() => {
      this.avPlayer.prepare(() => {
        this.avPlayer.play();
      });
    });

    this.showGongDe = false;
    animateTo({ duration: this.speed }, () => {
      this.showGongDe = true;
    })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        // 总功德数
        Text(this.message + this.totalGongDe)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({top:20})

        // 木鱼图片
        Column() {
          Image($r("app.media.icon")).width(240)
            .onClick(() => {
              this.knock();
            })

          Button('自动挡：'.concat(this.auto ? '开' : '关'))
            .width('120vp')
            .margin({top: 20})
            .align(Alignment.Center)
            .onClick(() => {
              this.auto = !this.auto;
              if (this.auto) {
                this.intervalID = setInterval(() => {
                  this.knock();
                }, this.speed);
              } else {
                clearInterval(this.intervalID);
              }
            })
        }
        .width('100%')
        .margin({top: 180})
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .padding(12)
      .backgroundColor('#2e2e2e')
      .alignItems(HorizontalAlign.Start)

      // 功德+1 文字动效
      if (this.showGongDe) {
        Text('功德+1')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ top: 150 })
          .textAlign(TextAlign.Center)
          .width('100%')
          .transition({ type: TransitionType.All, translate: { y: 100 } , scale: { x: 0, y: 0 }})
      }
    }
    .height('100%')
  }
}


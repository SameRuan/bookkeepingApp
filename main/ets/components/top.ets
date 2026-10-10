import { router } from "@kit.ArkUI"

/**
 * TopBack组件
 * 跳转后页面头部的统一配置
 */
@Component
export struct Top{
  @Prop title :string
  build() {
    Text(`${this.title}`)
      .fontSize(20)
      .fontWeight(700)
      .width('100%')
      .textAlign(TextAlign.Start)
      .padding({ top: 6, bottom: 12, left:20 })  // 增加上下padding
      .fontFamily('HarmonyOS Sans SC')
      .lineHeight(33)
      // .backgroundColor('#FFFFFF')  // 标题栏添加背景色
      .zIndex(1)  // 确保标题在最上层
  }

}

/**
 * TopBack组件
 * 跳转后页面头部的统一配置
 */
@Component
export struct TopBack{
  @Prop title :string
  build() {
    // 顶部标题栏
    Row(){
      // //图标
      // Image($r('app.media.back'))
      //   .width('38')
      //   .height('38')
      //   .onClick(()=>{
      //     router.back()
      //   })
      Text(`${this.title}`)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#5C3B1F')
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFE0B2')
    .height('70')
    .width('100%')
    .border({
      width:{bottom:2},
      color:{bottom: '#75ffab04' }
    })
  }

}
export interface KeepAccountsModel {
  text: string,
  imageName: string,
  icon: Resource
}
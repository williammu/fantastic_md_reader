import { router } from '@kit.ArkUI'

@Entry
@Component
struct SearchPage {
  @State message: string = 'Search Page'

  build() {
    Column() {
      Text(this.message)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin(20)

      Button('返回')
        .onClick(() => {
          router.back()
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
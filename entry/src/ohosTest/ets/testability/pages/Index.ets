import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'testTag';

@Entry
@Component
struct Index {
  @State message: string = 'TestAbility Index';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
    }
    .height('100%')
  }

  aboutToAppear() {
    hilog.info(0x0000, TAG, 'TestAbility Index aboutToAppear');
  }
}

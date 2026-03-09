import { router } from '@kit.ArkUI'
import { MarkdownParser } from '../utils/MarkdownParser'

@Entry
@Component
struct TestPage {
  @State htmlContent: string = ''
  
  aboutToAppear() {
    const testMd = `> 这是一段引用文字。

> 这是第一行引用。
> 这是第二行引用。

- 项目1
- 项目2
  - 子项目1
  - 子项目2`
    
    console.log('=== TEST MARKDOWN ===')
    console.log(testMd)
    
    const result = MarkdownParser.parse(testMd)
    
    console.log('=== PARSED HTML ===')
    // 分段输出
    for (let i = 0; i < result.length; i += 400) {
      console.log(result.substring(i, i + 400))
    }
    
    this.htmlContent = result
  }
  
  build() {
    Column() {
      Text('解析结果：')
        .fontSize(20)
        .margin(10)
      
      Text(this.htmlContent)
        .fontSize(14)
        .fontFamily('monospace')
        .margin(10)
        .padding(10)
        .backgroundColor('#f0f0f0')
        .width('90%')
        .height('70%')
    }
    .width('100%')
    .height('100%')
  }
}

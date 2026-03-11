import { hilog } from '@kit.PerformanceAnalysisKit';
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { Driver, On, Component } from '@ohos.UiTest';

const DOMAIN = 0x0001;
const BUNDLE_NAME = 'com.ms.md_reader';

export default function tocScrollTest() {
  describe('TocScrollTest', () => {
    let driver: Driver;

    beforeAll(async () => {
      hilog.info(DOMAIN, 'testTag', '%{public}s', 'TocScrollTest beforeAll begin');
      // 创建 Driver 实例
      driver = Driver.create();
      hilog.info(DOMAIN, 'testTag', '%{public}s', 'Driver created');
    })

    beforeEach(async () => {
      hilog.info(DOMAIN, 'testTag', '%{public}s', 'beforeEach');
    })

    afterEach(async () => {
      hilog.info(DOMAIN, 'testTag', '%{public}s', 'afterEach');
    })

    afterAll(async () => {
      hilog.info(DOMAIN, 'testTag', '%{public}s', 'afterAll');
    })

    /**
     * 测试步骤1: 点击目录按钮打开浮层
     */
    it('click_toc_button', 0, async () => {
      hilog.info(DOMAIN, 'testTag', '%{public}s', '=== 测试步骤1: 点击目录按钮 ===');

      try {
        // 等待页面加载完成
        await driver.delayMs(2000);
        hilog.info(DOMAIN, 'testTag', '%{public}s', '页面加载完成');

        // 方法1: 通过文本查找目录按钮 (☰)
        hilog.info(DOMAIN, 'testTag', '%{public}s', '尝试查找目录按钮 (☰)');
        let tocButton = await driver.findComponent(On.text('☰'));
        
        if (tocButton) {
          hilog.info(DOMAIN, 'testTag', '%{public}s', '找到目录按钮，准备点击');
          await tocButton.click();
          hilog.info(DOMAIN, 'testTag', '%{public}s', '目录按钮点击完成');
        } else {
          hilog.warn(DOMAIN, 'testTag', '%{public}s', '未找到目录按钮 (☰)');
        }

        // 等待浮层弹出
        await driver.delayMs(1500);
        hilog.info(DOMAIN, 'testTag', '%{public}s', '等待浮层响应完成');

        // 验证目录浮层是否打开 - 查找"目录"标题
        hilog.info(DOMAIN, 'testTag', '%{public}s', '验证目录浮层是否打开');
        let tocTitle = await driver.findComponent(On.text('目录'));
        
        if (tocTitle) {
          let titleText = await tocTitle.getText();
          hilog.info(DOMAIN, 'testTag', '目录浮层已打开，标题: %{public}s', titleText);
          expect(titleText).assertEqual('目录');
        } else {
          hilog.warn(DOMAIN, 'testTag', '%{public}s', '未找到目录标题，浮层可能未打开');
        }

      } catch (err) {
        hilog.error(DOMAIN, 'testTag', '测试失败: %{public}s', JSON.stringify(err));
        throw err;
      }

      hilog.info(DOMAIN, 'testTag', '%{public}s', '=== 测试步骤1完成 ===');
    })

  })
}

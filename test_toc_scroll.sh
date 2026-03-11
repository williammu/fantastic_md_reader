#!/bin/bash

# 目录浮层滚动偏移量自动化测试脚本

DEVICE_SCREEN="/data/local/tmp/test_screen.jpeg"
LOCAL_SCREEN="/tmp/test_screen.jpeg"
LOG_FILE="/tmp/toc_test.log"

# 清理函数
cleanup() {
    rm -f $LOCAL_SCREEN
    hdc shell rm -f $DEVICE_SCREEN 2>/dev/null
}

# 截图并拉取到本地
take_screenshot() {
    local index=$1
    hdc shell snapshot_display -i 0 -f $DEVICE_SCREEN 2>/dev/null
    sleep 0.5
    hdc file recv $DEVICE_SCREEN ${LOCAL_SCREEN%.jpeg}_${index}.jpeg 2>/dev/null
    echo "${LOCAL_SCREEN%.jpeg}_${index}.jpeg"
}

# 点击坐标
click() {
    local x=$1
    local y=$2
    echo "点击坐标: ($x, $y)"
    hdc shell uitest uiInput click $x $y
    sleep 1
}

# 滑动
swipe() {
    local from_x=$1
    local from_y=$2
    local to_x=$3
    local to_y=$4
    echo "滑动: ($from_x, $from_y) -> ($to_x, $to_y)"
    hdc shell uitest uiInput swipe $from_x $from_y $to_x $to_y 1000
    sleep 1
}

# 返回键
press_back() {
    echo "按返回键"
    hdc shell uitest uiInput keyEvent Back
    sleep 1
}

# 获取日志
check_logs() {
    local pattern=$1
    hdc shell hilog -x -T testTag 2>/dev/null | grep "$pattern" | tail -10
}

# 测试步骤
echo "========== 目录浮层滚动偏移量测试 ==========" > $LOG_FILE

# 步骤1: 确保在首页，点击文件
echo "步骤1: 打开 complete_test.md 文件"
click 630 350
sleep 2
SCREEN1=$(take_screenshot 1)
echo "截图保存: $SCREEN1"

# 步骤2: 点击目录按钮 (☰) - 在右上角区域
echo "步骤2: 点击目录按钮"
click 1100 120
sleep 1
SCREEN2=$(take_screenshot 2)
echo "截图保存: $SCREEN2"

# 步骤3: 在目录浮层中向下滑动
echo "步骤3: 在目录浮层中向下滑动"
swipe 630 1200 630 600
sleep 1
SCREEN3=$(take_screenshot 3)
echo "截图保存: $SCREEN3"

# 步骤4: 继续向下滑动
echo "步骤4: 继续向下滑动"
swipe 630 1200 630 600
sleep 1
SCREEN4=$(take_screenshot 4)
echo "截图保存: $SCREEN4"

# 步骤5: 关闭目录浮层 (点击底部区域)
echo "步骤5: 关闭目录浮层"
click 630 2400
sleep 1
SCREEN5=$(take_screenshot 5)
echo "截图保存: $SCREEN5"

# 步骤6: 重新打开目录浮层
echo "步骤6: 重新打开目录浮层"
click 1100 120
sleep 1
SCREEN6=$(take_screenshot 6)
echo "截图保存: $SCREEN6"

# 步骤7: 检查日志
echo "步骤7: 检查日志"
echo "=== 目录相关日志 ===" >> $LOG_FILE
check_logs "TOC" >> $LOG_FILE

echo "=== 测试完成 ==="
echo "日志文件: $LOG_FILE"
echo "截图文件:"
ls -la ${LOCAL_SCREEN%.jpeg}_*.jpeg 2>/dev/null

# 清理
cleanup

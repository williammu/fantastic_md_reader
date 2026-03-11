#!/bin/bash

# 目录浮层滚动偏移量测试脚本 v3
# 在目录浮层内部滑动

DEVICE_SCREEN="/data/local/tmp/test_screen.jpeg"
LOCAL_DIR="/tmp/toc_test_$(date +%s)"
mkdir -p $LOCAL_DIR

echo "测试截图保存目录: $LOCAL_DIR"

# 截图函数
take_screenshot() {
    local name=$1
    hdc shell snapshot_display -i 0 -f $DEVICE_SCREEN 2>/dev/null
    sleep 0.3
    hdc file recv $DEVICE_SCREEN "$LOCAL_DIR/${name}.jpeg" 2>/dev/null
    echo "截图: $LOCAL_DIR/${name}.jpeg"
}

# 点击并验证
click_and_capture() {
    local x=$1
    local y=$2
    local desc=$3
    
    echo ""
    echo "=== $desc ==="
    echo "点击: ($x, $y)"
    take_screenshot "before_${desc}"
    hdc shell uitest uiInput click $x $y
    sleep 1.5
    take_screenshot "after_${desc}"
}

# 滑动并验证
swipe_and_capture() {
    local from_x=$1
    local from_y=$2
    local to_x=$3
    local to_y=$4
    local desc=$5
    
    echo ""
    echo "=== $desc ==="
    echo "滑动: ($from_x, $from_y) -> ($to_x, $to_y)"
    take_screenshot "before_${desc}"
    hdc shell uitest uiInput swipe $from_x $from_y $to_x $to_y 600
    sleep 1.5
    take_screenshot "after_${desc}"
}

echo "========================================"
echo "目录浮层滚动偏移量测试"
echo "========================================"
echo ""
echo "屏幕: 1260 x 2844"
echo "目录浮层高度: 400 (从底部弹出)"
echo "目录浮层Y范围: 2444 - 2844"
echo ""

# 步骤1: 打开文件
echo "步骤1: 打开文件"
click_and_capture 630 350 "open_file"

# 步骤2: 点击目录按钮打开浮层
echo "步骤2: 点击目录按钮"
click_and_capture 1100 120 "open_toc"

# 步骤3: 在目录浮层内滑动
# 浮层在底部，y范围约2444-2844
# 在浮层中间位置滑动: x=630, y=2600 -> y=2400 (向上滑动，内容向下滚动)
echo "步骤3: 在目录浮层内向下滑动"
swipe_and_capture 630 2600 630 2200 "toc_scroll_1"

# 步骤4: 继续滑动
echo "步骤4: 继续滑动"
swipe_and_capture 630 2600 630 2200 "toc_scroll_2"

# 步骤5: 关闭目录浮层 (点击浮层外部)
echo "步骤5: 关闭目录浮层"
click_and_capture 630 1500 "close_toc"

# 步骤6: 重新打开目录浮层
echo "步骤6: 重新打开目录浮层"
click_and_capture 1100 120 "reopen_toc"

echo ""
echo "========================================"
echo "测试完成"
echo "截图目录: $LOCAL_DIR"
echo "========================================"

# 列出所有截图
ls -la $LOCAL_DIR/*.jpeg 2>/dev/null

# 清理
hdc shell rm -f $DEVICE_SCREEN 2>/dev/null

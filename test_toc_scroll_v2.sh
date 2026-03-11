#!/bin/bash

# 目录浮层滚动偏移量自动化测试脚本 v2
# 每次点击后截图验证

DEVICE_SCREEN="/data/local/tmp/test_screen.jpeg"
LOCAL_DIR="/tmp/toc_test_$(date +%s)"
mkdir -p $LOCAL_DIR

echo "测试截图保存目录: $LOCAL_DIR"

# 截图函数 - 带序号
take_screenshot() {
    local name=$1
    hdc shell snapshot_display -i 0 -f $DEVICE_SCREEN 2>/dev/null
    sleep 0.3
    hdc file recv $DEVICE_SCREEN "$LOCAL_DIR/${name}.jpeg" 2>/dev/null
    echo "截图: $LOCAL_DIR/${name}.jpeg"
}

# 点击并截图验证
click_and_verify() {
    local x=$1
    local y=$2
    local desc=$3
    
    echo ""
    echo "=== $desc ==="
    echo "点击坐标: ($x, $y)"
    
    # 点击前截图
    take_screenshot "before_${desc}"
    
    # 执行点击
    hdc shell uitest uiInput click $x $y
    echo "点击完成"
    
    # 等待UI响应
    sleep 1.5
    
    # 点击后截图
    take_screenshot "after_${desc}"
    
    echo "请检查截图: $LOCAL_DIR/after_${desc}.jpeg"
}

# 滑动并截图
swipe_and_verify() {
    local from_x=$1
    local from_y=$2
    local to_x=$3
    local to_y=$4
    local desc=$5
    
    echo ""
    echo "=== $desc ==="
    echo "滑动: ($from_x, $from_y) -> ($to_x, $to_y)"
    
    # 滑动前截图
    take_screenshot "before_${desc}"
    
    # 执行滑动
    hdc shell uitest uiInput swipe $from_x $from_y $to_x $to_y 800
    echo "滑动完成"
    
    # 等待滑动完成
    sleep 1.5
    
    # 滑动后截图
    take_screenshot "after_${desc}"
    
    echo "请检查截图: $LOCAL_DIR/after_${desc}.jpeg"
}

# 返回键
press_back() {
    echo ""
    echo "=== 按返回键 ==="
    hdc shell uitest uiInput keyEvent Back
    sleep 1
    take_screenshot "after_back"
}

# 清理设备上的临时文件
cleanup_device() {
    hdc shell rm -f $DEVICE_SCREEN 2>/dev/null
}

echo "========================================"
echo "目录浮层滚动偏移量测试"
echo "========================================"
echo ""
echo "屏幕尺寸: 1260 x 2844"
echo "目录浮层(bindSheet)高度: 400"
echo "目录浮层Y坐标范围: ~2444 - 2844 (底部往上)"
echo ""

# 测试步骤
echo "开始测试..."

# 步骤1: 点击文件打开
echo ""
echo "步骤1: 打开 complete_test.md 文件"
echo "文件位置大约在 (630, 350)"
click_and_verify 630 350 "open_file"

# 步骤2: 点击目录按钮打开浮层
echo ""
echo "步骤2: 点击目录按钮 (☰)"
echo "目录按钮位置大约在 (1100, 120)"
click_and_verify 1100 120 "open_toc"

# 步骤3: 在目录浮层中滑动
# 目录浮层在底部，高度400，所以滑动区域大约在 y=2500-2800
echo ""
echo "步骤3: 在目录浮层中向下滑动"
echo "目录浮层滑动区域: x=630, y=2500 -> y=2200"
swipe_and_verify 630 2500 630 2200 "toc_scroll_down_1"

# 步骤4: 继续滑动
echo ""
echo "步骤4: 继续在目录浮层中向下滑动"
swipe_and_verify 630 2500 630 2200 "toc_scroll_down_2"

# 步骤5: 关闭目录浮层
# 点击浮层外部或底部区域关闭
echo ""
echo "步骤5: 关闭目录浮层"
echo "点击浮层外部区域 (630, 1500)"
click_and_verify 630 1500 "close_toc"

# 步骤6: 重新打开目录浮层
echo ""
echo "步骤6: 重新打开目录浮层"
click_and_verify 1100 120 "reopen_toc"

# 步骤7: 检查日志
echo ""
echo "=== 检查日志 ==="
hdc shell hilog -x -T testTag 2>/dev/null | grep -E "TOC" | tail -20 > "$LOCAL_DIR/toc_logs.txt"
echo "日志已保存到: $LOCAL_DIR/toc_logs.txt"
cat "$LOCAL_DIR/toc_logs.txt"

echo ""
echo "========================================"
echo "测试完成"
echo "========================================"
echo "所有截图保存在: $LOCAL_DIR"
echo ""
echo "请检查以下截图:"
ls -la $LOCAL_DIR/*.jpeg 2>/dev/null | awk '{print $9, $5}'

# 清理
cleanup_device

#!/usr/bin/env python3
"""
生成应用桌面图标
采用现代简洁的设计风格
"""

from PIL import Image, ImageDraw, ImageFilter
import os

# 颜色定义 - 现代渐变风格
COLORS = {
    'primary_start': '#007AFF',      # 苹果蓝
    'primary_end': '#5856D6',        # 紫色
    'accent': '#FF9500',             # 橙色强调
    'white': '#FFFFFF',
    'shadow': 'rgba(0,0,0,0.15)',
}

def create_gradient_background(size, start_color, end_color):
    """创建渐变背景"""
    img = Image.new('RGBA', size)
    draw = ImageDraw.Draw(img)
    
    w, h = size
    
    # 绘制渐变
    for y in range(h):
        # 计算渐变颜色
        ratio = y / h
        r = int(int(start_color[1:3], 16) * (1 - ratio) + int(end_color[1:3], 16) * ratio)
        g = int(int(start_color[3:5], 16) * (1 - ratio) + int(end_color[3:5], 16) * ratio)
        b = int(int(start_color[5:7], 16) * (1 - ratio) + int(end_color[5:7], 16) * ratio)
        
        draw.line([(0, y), (w, y)], fill=(r, g, b, 255))
    
    return img

def create_modern_icon(size):
    """创建现代风格图标 - M字母书本设计"""
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    w, h = size
    padding = w // 6
    
    # 背景 - 圆角矩形
    bg_radius = w // 5
    
    # 创建渐变背景
    bg = create_gradient_background((w, h), COLORS['primary_start'], COLORS['primary_end'])
    
    # 创建圆角遮罩
    mask = Image.new('L', (w, h), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, w, h], radius=bg_radius, fill=255)
    
    # 应用遮罩
    bg.putalpha(mask)
    img.paste(bg, (0, 0), bg)
    
    # 绘制书本/M字母图标
    book_x = padding
    book_y = padding + h // 16
    book_w = w - padding * 2
    book_h = h - padding * 2 - h // 8
    
    # 书本主体 - 白色圆角矩形
    book_radius = w // 16
    draw.rounded_rectangle(
        [book_x, book_y, book_x + book_w, book_y + book_h],
        radius=book_radius, fill=COLORS['white']
    )
    
    # 书脊阴影
    spine_x = book_x + book_w // 2
    draw.rectangle(
        [spine_x - 2, book_y + 4, spine_x + 2, book_y + book_h - 4],
        fill=(0, 0, 0, 30)
    )
    
    # 绘制 M 字母（Markdown的首字母）
    m_margin = book_w // 5
    m_x = book_x + m_margin
    m_y = book_y + book_h // 4
    m_w = book_w - m_margin * 2
    m_h = book_h // 2
    
    # M 的笔画粗细
    stroke = max(4, w // 24)
    
    # 左竖线
    draw.line(
        [(m_x, m_y), (m_x, m_y + m_h)],
        fill=COLORS['primary_start'], width=stroke
    )
    
    # 右竖线
    draw.line(
        [(m_x + m_w, m_y), (m_x + m_w, m_y + m_h)],
        fill=COLORS['primary_end'], width=stroke
    )
    
    # 左斜线
    draw.line(
        [(m_x, m_y), (m_x + m_w // 2, m_y + m_h // 2)],
        fill=COLORS['primary_start'], width=stroke
    )
    
    # 右斜线
    draw.line(
        [(m_x + m_w, m_y), (m_x + m_w // 2, m_y + m_h // 2)],
        fill=COLORS['primary_end'], width=stroke
    )
    
    # 添加高光效果
    highlight = Image.new('RGBA', (w, h), (255, 255, 255, 0))
    highlight_draw = ImageDraw.Draw(highlight)
    highlight_draw.rounded_rectangle(
        [4, 4, w-4, h//3], radius=bg_radius-4, fill=(255, 255, 255, 40)
    )
    img = Image.alpha_composite(img, highlight)
    
    return img

def create_simple_background(size):
    """创建简单背景（用于layered_image的background层）"""
    img = create_gradient_background(size, COLORS['primary_start'], COLORS['primary_end'])
    
    # 添加圆角
    w, h = size
    radius = w // 5
    
    # 创建遮罩
    mask = Image.new('L', (w, h), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, w, h], radius=radius, fill=255)
    
    # 应用遮罩
    result = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    result.paste(img, (0, 0), mask)
    
    return result

def create_foreground_icon(size):
    """创建前景图标（用于layered_image的foreground层）"""
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    w, h = size
    padding = w // 5
    
    # 书本区域
    book_x = padding
    book_y = padding + h // 20
    book_w = w - padding * 2
    book_h = h - padding * 2 - h // 10
    
    # 书本主体
    book_radius = w // 20
    draw.rounded_rectangle(
        [book_x, book_y, book_x + book_w, book_y + book_h],
        radius=book_radius, fill=COLORS['white']
    )
    
    # 书脊
    spine_x = book_x + book_w // 2
    draw.rectangle(
        [spine_x - 3, book_y + 6, spine_x + 3, book_y + book_h - 6],
        fill=(0, 0, 0, 40)
    )
    
    # M 字母
    m_margin = book_w // 4
    m_x = book_x + m_margin
    m_y = book_y + book_h // 4
    m_w = book_w - m_margin * 2
    m_h = book_h // 2
    
    stroke = max(6, w // 20)
    
    # 左竖
    draw.line([(m_x, m_y), (m_x, m_y + m_h)], fill='#007AFF', width=stroke)
    # 右竖
    draw.line([(m_x + m_w, m_y), (m_x + m_w, m_y + m_h)], fill='#5856D6', width=stroke)
    # 左斜
    draw.line([(m_x, m_y), (m_x + m_w // 2, m_y + m_h // 2)], fill='#007AFF', width=stroke)
    # 右斜
    draw.line([(m_x + m_w, m_y), (m_x + m_w // 2, m_y + m_h // 2)], fill='#5856D6', width=stroke)
    
    return img

def main():
    """主函数"""
    output_dir = "/Users/bytedance/dev/fantastic_md_reader/entry/src/main/resources/base/media"
    os.makedirs(output_dir, exist_ok=True)
    
    # 生成完整图标
    icon_size = (1024, 1024)
    icon = create_modern_icon(icon_size)
    icon.save(os.path.join(output_dir, "icon.png"), "PNG")
    print("Generated: icon.png")
    
    # 生成背景层
    bg = create_simple_background(icon_size)
    bg.save(os.path.join(output_dir, "background.png"), "PNG")
    print("Generated: background.png")
    
    # 生成前景层
    fg = create_foreground_icon(icon_size)
    fg.save(os.path.join(output_dir, "foreground.png"), "PNG")
    print("Generated: foreground.png")
    
    # 生成启动图标
    start_size = (256, 256)
    start_icon = create_modern_icon(start_size)
    start_icon.save(os.path.join(output_dir, "startIcon.png"), "PNG")
    print("Generated: startIcon.png")
    
    print("\nAll app icons generated successfully!")

if __name__ == "__main__":
    main()

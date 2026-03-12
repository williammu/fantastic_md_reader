#!/usr/bin/env python3
"""
生成专业图标资源
使用 PIL 创建各种尺寸的图标
"""

from PIL import Image, ImageDraw, ImageFont
import os

# 图标尺寸定义
SIZES = {
    'app_icon': (1024, 1024),      # App 主图标
    'app_icon_bg': (1024, 1024),   # App 背景
    'app_icon_fg': (1024, 1024),   # App 前景
    'start_icon': (256, 256),      # 启动图标
    'icon_48': (48, 48),           # 功能图标
    'icon_64': (64, 64),
    'icon_96': (96, 96),
    'icon_128': (128, 128),
}

# 颜色定义 - 华为风格
COLORS = {
    'primary': '#007DFF',          # 华为蓝
    'primary_dark': '#0056B3',
    'background': '#F5F7FA',       # 浅灰背景
    'surface': '#FFFFFF',          # 白色表面
    'text': '#2C2C2C',             # 深色文字
    'text_light': '#666666',
    'accent': '#FF6B35',           # 强调色
}

def create_rounded_rect(draw, xy, radius, fill):
    """创建圆角矩形"""
    x1, y1, x2, y2 = xy
    draw.rounded_rectangle(xy, radius=radius, fill=fill)

def create_app_icon(size):
    """创建 App 主图标 - 书本样式"""
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    w, h = size
    padding = w // 8
    
    # 背景渐变效果 - 使用纯色
    bg_color = COLORS['primary']
    draw.rounded_rectangle([0, 0, w, h], radius=w//8, fill=bg_color)
    
    # 书本主体
    book_x = padding
    book_y = padding + h // 16
    book_w = w - padding * 2
    book_h = h - padding * 2 - h // 8
    
    # 书本阴影
    shadow_offset = w // 64
    draw.rounded_rectangle(
        [book_x + shadow_offset, book_y + shadow_offset, 
         book_x + book_w + shadow_offset, book_y + book_h + shadow_offset],
        radius=w//32, fill=(0, 0, 0, 40)
    )
    
    # 书本封面
    draw.rounded_rectangle(
        [book_x, book_y, book_x + book_w, book_y + book_h],
        radius=w//32, fill=COLORS['surface']
    )
    
    # 书脊
    spine_x = book_x + book_w // 2 - w // 128
    draw.rectangle(
        [spine_x, book_y + w//64, spine_x + w//64, book_y + book_h - w//64],
        fill=COLORS['primary_dark']
    )
    
    # 书页线条
    line_color = COLORS['text_light']
    line_y1 = book_y + book_h // 3
    line_y2 = book_y + book_h * 2 // 3
    line_margin = book_w // 6
    
    draw.line([(book_x + line_margin, line_y1), (spine_x - w//64, line_y1)], 
              fill=line_color, width=w//64)
    draw.line([(book_x + line_margin, line_y2), (spine_x - w//64, line_y2)], 
              fill=line_color, width=w//64)
    draw.line([(spine_x + w//32, line_y1), (book_x + book_w - line_margin, line_y1)], 
              fill=line_color, width=w//64)
    draw.line([(spine_x + w//32, line_y2), (book_x + book_w - line_margin, line_y2)], 
              fill=line_color, width=w//64)
    
    return img

def create_start_icon(size):
    """创建启动图标"""
    return create_app_icon(size)

def create_search_icon(size):
    """创建搜索图标"""
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    w, h = size
    stroke = max(2, w // 12)
    
    # 放大镜圆圈
    circle_x = w // 2 - w // 8
    circle_y = h // 2 - h // 8
    circle_r = w // 3
    
    draw.ellipse(
        [circle_x - circle_r, circle_y - circle_r,
         circle_x + circle_r, circle_y + circle_r],
        outline=COLORS['text'], width=stroke
    )
    
    # 手柄
    handle_start = (circle_x + int(circle_r * 0.7), circle_y + int(circle_r * 0.7))
    handle_end = (w - w//6, h - h//6)
    draw.line([handle_start, handle_end], fill=COLORS['text'], width=stroke)
    
    return img

def create_settings_icon(size):
    """创建设置图标 - 齿轮"""
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    w, h = size
    stroke = max(2, w // 12)
    center = (w // 2, h // 2)
    
    # 外圈
    outer_r = w // 2 - w // 8
    draw.ellipse(
        [center[0] - outer_r, center[1] - outer_r,
         center[0] + outer_r, center[1] + outer_r],
        outline=COLORS['text'], width=stroke
    )
    
    # 内圈
    inner_r = w // 6
    draw.ellipse(
        [center[0] - inner_r, center[1] - inner_r,
         center[0] + inner_r, center[1] + inner_r],
        fill=COLORS['text']
    )
    
    # 齿轮齿
    import math
    num_teeth = 8
    for i in range(num_teeth):
        angle = (i * 360 / num_teeth) * math.pi / 180
        tooth_inner_r = outer_r - w // 16
        tooth_outer_r = outer_r + w // 16
        
        x1 = center[0] + tooth_inner_r * math.cos(angle)
        y1 = center[1] + tooth_inner_r * math.sin(angle)
        x2 = center[0] + tooth_outer_r * math.cos(angle)
        y2 = center[1] + tooth_outer_r * math.sin(angle)
        
        draw.ellipse(
            [x2 - w//16, y2 - w//16, x2 + w//16, y2 + w//16],
            fill=COLORS['text']
        )
    
    return img

def create_folder_icon(size):
    """创建文件夹图标"""
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    w, h = size
    stroke = max(2, w // 12)
    
    # 文件夹主体
    folder_h = h * 3 // 4
    folder_y = h // 4
    
    draw.rounded_rectangle(
        [w//8, folder_y, w - w//8, folder_y + folder_h],
        radius=w//16, outline=COLORS['text'], width=stroke
    )
    
    # 文件夹标签
    tab_w = w // 3
    tab_h = h // 6
    draw.rounded_rectangle(
        [w//8, folder_y - tab_h//2, w//8 + tab_w, folder_y + tab_h//2],
        radius=w//32, outline=COLORS['text'], width=stroke
    )
    
    return img

def create_back_icon(size):
    """创建返回箭头图标"""
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    w, h = size
    stroke = max(3, w // 8)
    padding = w // 4
    
    # 左箭头
    draw.line(
        [(w - padding, padding), (padding, h // 2)],
        fill=COLORS['text'], width=stroke
    )
    draw.line(
        [(padding, h // 2), (w - padding, h - padding)],
        fill=COLORS['text'], width=stroke
    )
    
    return img

def create_forward_icon(size):
    """创建前进箭头图标"""
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    w, h = size
    stroke = max(3, w // 8)
    padding = w // 4
    
    # 右箭头
    draw.line(
        [(padding, padding), (w - padding, h // 2)],
        fill=COLORS['text'], width=stroke
    )
    draw.line(
        [(w - padding, h // 2), (padding, h - padding)],
        fill=COLORS['text'], width=stroke
    )
    
    return img

def create_list_icon(size):
    """创建列表/目录图标"""
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    w, h = size
    padding = w // 6
    line_h = (h - padding * 2) // 5
    
    for i in range(3):
        y = padding + i * line_h * 2
        # 圆点
        dot_x = padding + w // 16
        draw.ellipse(
            [dot_x - w//32, y - w//32, dot_x + w//32, y + w//32],
            fill=COLORS['text']
        )
        # 横线
        draw.line(
            [(padding + w//8, y), (w - padding, y)],
            fill=COLORS['text'], width=max(2, w//24)
        )
    
    return img

def create_sun_icon(size):
    """创建太阳图标"""
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    w, h = size
    center = (w // 2, h // 2)
    
    # 中心圆
    inner_r = w // 5
    draw.ellipse(
        [center[0] - inner_r, center[1] - inner_r,
         center[0] + inner_r, center[1] + inner_r],
        fill=COLORS['text']
    )
    
    # 光芒
    import math
    num_rays = 8
    for i in range(num_rays):
        angle = (i * 360 / num_rays) * math.pi / 180
        inner_point = (center[0] + (inner_r + w//16) * math.cos(angle),
                      center[1] + (inner_r + w//16) * math.sin(angle))
        outer_point = (center[0] + (w//2 - w//12) * math.cos(angle),
                      center[1] + (w//2 - w//12) * math.sin(angle))
        draw.line([inner_point, outer_point], fill=COLORS['text'], width=max(2, w//16))
    
    return img

def create_moon_icon(size):
    """创建月亮图标"""
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    w, h = size
    
    # 创建月亮形状 - 使用两个圆相交
    outer_r = w // 2 - w // 8
    inner_r = w // 2 - w // 4
    
    # 主圆
    draw.pieslice(
        [w//2 - outer_r, h//2 - outer_r, w//2 + outer_r, h//2 + outer_r],
        start=270, end=90, fill=COLORS['text']
    )
    
    # 内切圆（挖空）
    offset = w // 8
    draw.pieslice(
        [w//2 - inner_r + offset, h//2 - inner_r, 
         w//2 + inner_r + offset, h//2 + inner_r],
        start=90, end=270, fill=(0, 0, 0, 0)
    )
    
    return img

def create_info_icon(size):
    """创建信息图标"""
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    w, h = size
    stroke = max(2, w // 12)
    
    # 外圈
    outer_r = w // 2 - w // 8
    draw.ellipse(
        [w//2 - outer_r, h//2 - outer_r, w//2 + outer_r, h//2 + outer_r],
        outline=COLORS['text'], width=stroke
    )
    
    # i 点
    dot_r = w // 16
    draw.ellipse(
        [w//2 - dot_r, h//4 - dot_r, w//2 + dot_r, h//4 + dot_r],
        fill=COLORS['text']
    )
    
    # i 竖线
    line_w = w // 12
    line_h = h // 3
    draw.rounded_rectangle(
        [w//2 - line_w//2, h//3 + h//16, w//2 + line_w//2, h//3 + h//16 + line_h],
        radius=line_w//4, fill=COLORS['text']
    )
    
    return img

def create_font_size_icon(size):
    """创建字体大小图标"""
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    w, h = size
    stroke = max(2, w // 12)
    
    # A 字母
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", w//2)
    except:
        font = ImageFont.load_default()
    
    draw.text((w//8, h//4), "A", fill=COLORS['text'], font=font)
    
    # 加号
    plus_x = w * 3 // 4
    plus_y = h // 2
    plus_size = w // 6
    
    draw.line(
        [(plus_x - plus_size, plus_y), (plus_x + plus_size, plus_y)],
        fill=COLORS['text'], width=stroke
    )
    draw.line(
        [(plus_x, plus_y - plus_size), (plus_x, plus_y + plus_size)],
        fill=COLORS['text'], width=stroke
    )
    
    return img

def create_star_icon(size):
    """创建星形图标"""
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    w, h = size
    import math
    
    # 五角星路径
    center_x = w // 2
    center_y = h // 2
    outer_r = w // 2 - w // 8
    inner_r = w // 5
    
    points = []
    for i in range(10):
        angle = (i * 36 - 90) * math.pi / 180
        r = outer_r if i % 2 == 0 else inner_r
        x = center_x + r * math.cos(angle)
        y = center_y + r * math.sin(angle)
        points.append((x, y))
    
    # 绘制填充星形
    draw.polygon(points, fill=COLORS['text'])
    
    return img

def main():
    """主函数 - 生成所有图标"""
    output_dir = "/Users/bytedance/dev/fantastic_md_reader/entry/src/main/resources/base/media"
    
    # 确保输出目录存在
    os.makedirs(output_dir, exist_ok=True)
    
    # 生成 App 图标
    app_icon = create_app_icon(SIZES['app_icon'])
    app_icon.save(os.path.join(output_dir, "icon.png"), "PNG")
    print(f"Generated: icon.png ({SIZES['app_icon']})")
    
    # 生成背景
    bg = Image.new('RGBA', SIZES['app_icon_bg'], COLORS['primary'])
    bg.save(os.path.join(output_dir, "background.png"), "PNG")
    print(f"Generated: background.png")
    
    # 生成前景（书本图标）
    fg = create_app_icon(SIZES['app_icon_fg'])
    fg.save(os.path.join(output_dir, "foreground.png"), "PNG")
    print(f"Generated: foreground.png")
    
    # 生成启动图标
    start_icon = create_app_icon(SIZES['start_icon'])
    start_icon.save(os.path.join(output_dir, "startIcon.png"), "PNG")
    print(f"Generated: startIcon.png ({SIZES['start_icon']})")
    
    # 生成功能图标
    icons_to_generate = [
        ('ic_search', create_search_icon),
        ('ic_settings', create_settings_icon),
        ('ic_folder', create_folder_icon),
        ('ic_back', create_back_icon),
        ('ic_forward', create_forward_icon),
        ('ic_list', create_list_icon),
        ('ic_sun', create_sun_icon),
        ('ic_moon', create_moon_icon),
        ('ic_info', create_info_icon),
        ('ic_font_size', create_font_size_icon),
        ('ic_star', create_star_icon),
    ]
    
    for name, creator in icons_to_generate:
        # 生成 48x48 版本
        icon_48 = creator(SIZES['icon_48'])
        icon_48.save(os.path.join(output_dir, f"{name}_48.png"), "PNG")
        
        # 生成 96x96 版本（高清）
        icon_96 = creator(SIZES['icon_96'])
        icon_96.save(os.path.join(output_dir, f"{name}_96.png"), "PNG")
        
        print(f"Generated: {name}_48.png, {name}_96.png")
    
    print("\nAll icons generated successfully!")

if __name__ == "__main__":
    main()

// 专业图标组件库 - 替代 emoji
// 使用 ArkUI 绘制能力创建简洁现代的图标

// 搜索图标 (放大镜)
@Builder
export function IconSearch(size: number = 24, color: ResourceColor = '#666666') {
  Stack() {
    Circle()
      .width(size * 0.7)
      .height(size * 0.7)
      .stroke(color)
      .strokeWidth(2)
      .fill('transparent')
    Line()
      .startPoint([size * 0.5, size * 0.5])
      .endPoint([size * 0.75, size * 0.75])
      .stroke(color)
      .strokeWidth(2)
      .strokeLineCap(LineCapStyle.Round)
  }
  .width(size)
  .height(size)
}

// 设置图标 (齿轮)
@Builder
export function IconSettings(size: number = 24, color: ResourceColor = '#666666') {
  Stack() {
    Circle()
      .width(size * 0.35)
      .height(size * 0.35)
      .fill(color)
    Circle()
      .width(size * 0.8)
      .height(size * 0.8)
      .stroke(color)
      .strokeWidth(2)
      .fill('transparent')
    ForEach([0, 45, 90, 135, 180, 225, 270, 315], (angle: number) => {
      Circle()
        .width(size * 0.12)
        .height(size * 0.12)
        .fill(color)
        .position({
          x: size / 2 + (size * 0.42) * Math.cos(angle * Math.PI / 180) - size * 0.06,
          y: size / 2 + (size * 0.42) * Math.sin(angle * Math.PI / 180) - size * 0.06
        })
    })
  }
  .width(size)
  .height(size)
}

// 文件图标 (文档)
@Builder
export function IconFile(size: number = 24, color: ResourceColor = '#666666') {
  Stack() {
    Rect()
      .width(size * 0.75)
      .height(size)
      .radius(4)
      .stroke(color)
      .strokeWidth(1.5)
      .fill('transparent')
    Path()
      .commands(`M ${size * 0.5} 0 L ${size * 0.75} 0 L ${size * 0.75} ${size * 0.25} Z`)
      .fill(color)
    Line()
      .startPoint([size * 0.2, size * 0.45])
      .endPoint([size * 0.55, size * 0.45])
      .stroke(color)
      .strokeWidth(1.5)
      .strokeLineCap(LineCapStyle.Round)
    Line()
      .startPoint([size * 0.2, size * 0.6])
      .endPoint([size * 0.55, size * 0.6])
      .stroke(color)
      .strokeWidth(1.5)
      .strokeLineCap(LineCapStyle.Round)
    Line()
      .startPoint([size * 0.2, size * 0.75])
      .endPoint([size * 0.4, size * 0.75])
      .stroke(color)
      .strokeWidth(1.5)
      .strokeLineCap(LineCapStyle.Round)
  }
  .width(size)
  .height(size)
}

// 文件夹图标
@Builder
export function IconFolder(size: number = 48, color: ResourceColor = '#666666') {
  Stack() {
    Rect()
      .width(size)
      .height(size * 0.75)
      .radius(6)
      .stroke(color)
      .strokeWidth(1.5)
      .fill('transparent')
      .position({ y: size * 0.25 })
    Rect()
      .width(size * 0.35)
      .height(size * 0.15)
      .radius(3)
      .stroke(color)
      .strokeWidth(1.5)
      .fill('transparent')
      .position({ x: size * 0.1 })
  }
  .width(size)
  .height(size)
}

// 收藏/星标图标
@Builder
export function IconStar(size: number = 24, color: ResourceColor = '#666666', filled: boolean = false) {
  Stack() {
    Path()
      .commands(getStarPath(size))
      .stroke(color)
      .strokeWidth(1.5)
      .fill(filled ? color : 'transparent')
  }
  .width(size)
  .height(size)
}

function getStarPath(size: number): string {
  const centerX = size / 2
  const centerY = size / 2
  const outerRadius = size * 0.45
  const innerRadius = size * 0.18
  let path = ''
  for (let i = 0; i < 10; i++) {
    const angle = (i * 36 - 90) * Math.PI / 180
    const radius = i % 2 === 0 ? outerRadius : innerRadius
    const x = centerX + radius * Math.cos(angle)
    const y = centerY + radius * Math.sin(angle)
    path += (i === 0 ? 'M ' : 'L ') + `${x} ${y} `
  }
  path += 'Z'
  return path
}

// 返回/箭头图标
@Builder
export function IconBack(size: number = 24, color: ResourceColor = '#666666') {
  Stack() {
    Path()
      .commands(`M ${size * 0.7} ${size * 0.15} L ${size * 0.25} ${size * 0.5} L ${size * 0.7} ${size * 0.85}`)
      .stroke(color)
      .strokeWidth(2)
      .strokeLineCap(LineCapStyle.Round)
      .strokeLineJoin(LineJoinStyle.Round)
      .fill('transparent')
  }
  .width(size)
  .height(size)
}

// 前进/右箭头图标
@Builder
export function IconForward(size: number = 24, color: ResourceColor = '#666666') {
  Stack() {
    Path()
      .commands(`M ${size * 0.3} ${size * 0.15} L ${size * 0.75} ${size * 0.5} L ${size * 0.3} ${size * 0.85}`)
      .stroke(color)
      .strokeWidth(2)
      .strokeLineCap(LineCapStyle.Round)
      .strokeLineJoin(LineJoinStyle.Round)
      .fill('transparent')
  }
  .width(size)
  .height(size)
}

// 更多/三点图标
@Builder
export function IconMore(size: number = 24, color: ResourceColor = '#666666') {
  Row({ space: size * 0.15 }) {
    ForEach([0, 1, 2], () => {
      Circle()
        .width(size * 0.18)
        .height(size * 0.18)
        .fill(color)
    })
  }
  .width(size)
  .height(size)
  .justifyContent(FlexAlign.Center)
}

// 删除图标 (垃圾桶)
@Builder
export function IconDelete(size: number = 24, color: ResourceColor = '#666666') {
  Stack() {
    Line()
      .startPoint([size * 0.25, size * 0.25])
      .endPoint([size * 0.75, size * 0.25])
      .stroke(color)
      .strokeWidth(2)
      .strokeLineCap(LineCapStyle.Round)
    Line()
      .startPoint([size * 0.35, size * 0.25])
      .endPoint([size * 0.35, size * 0.1])
      .stroke(color)
      .strokeWidth(1.5)
    Line()
      .startPoint([size * 0.65, size * 0.25])
      .endPoint([size * 0.65, size * 0.1])
      .stroke(color)
      .strokeWidth(1.5)
    Line()
      .startPoint([size * 0.3, size * 0.1])
      .endPoint([size * 0.7, size * 0.1])
      .stroke(color)
      .strokeWidth(1.5)
      .strokeLineCap(LineCapStyle.Round)
    Rect()
      .width(size * 0.5)
      .height(size * 0.55)
      .radius(2)
      .stroke(color)
      .strokeWidth(1.5)
      .fill('transparent')
      .position({ x: size * 0.25, y: size * 0.3 })
    Line()
      .startPoint([size * 0.4, size * 0.4])
      .endPoint([size * 0.4, size * 0.7])
      .stroke(color)
      .strokeWidth(1.5)
      .strokeLineCap(LineCapStyle.Round)
    Line()
      .startPoint([size * 0.5, size * 0.4])
      .endPoint([size * 0.5, size * 0.7])
      .stroke(color)
      .strokeWidth(1.5)
      .strokeLineCap(LineCapStyle.Round)
    Line()
      .startPoint([size * 0.6, size * 0.4])
      .endPoint([size * 0.6, size * 0.7])
      .stroke(color)
      .strokeWidth(1.5)
      .strokeLineCap(LineCapStyle.Round)
  }
  .width(size)
  .height(size)
}

// 太阳图标 (明亮模式)
@Builder
export function IconSun(size: number = 24, color: ResourceColor = '#666666') {
  Stack() {
    Circle()
      .width(size * 0.5)
      .height(size * 0.5)
      .fill(color)
    ForEach([0, 45, 90, 135, 180, 225, 270, 315], (angle: number) => {
      Line()
        .startPoint([
          size / 2 + (size * 0.32) * Math.cos(angle * Math.PI / 180),
          size / 2 + (size * 0.32) * Math.sin(angle * Math.PI / 180)
        ])
        .endPoint([
          size / 2 + (size * 0.45) * Math.cos(angle * Math.PI / 180),
          size / 2 + (size * 0.45) * Math.sin(angle * Math.PI / 180)
        ])
        .stroke(color)
        .strokeWidth(2)
        .strokeLineCap(LineCapStyle.Round)
    })
  }
  .width(size)
  .height(size)
}

// 月亮图标 (深色模式)
@Builder
export function IconMoon(size: number = 24, color: ResourceColor = '#666666') {
  Stack() {
    Path()
      .commands(`M ${size * 0.55} ${size * 0.15} A ${size * 0.35} ${size * 0.35} 0 1 1 ${size * 0.55} ${size * 0.85} A ${size * 0.25} ${size * 0.25} 0 1 0 ${size * 0.55} ${size * 0.15} Z`)
      .fill(color)
  }
  .width(size)
  .height(size)
}

// 自动主题图标
@Builder
export function IconAutoTheme(size: number = 24, color: ResourceColor = '#666666') {
  Stack() {
    // 太阳半圆
    Circle()
      .width(size * 0.6)
      .height(size * 0.6)
      .stroke(color)
      .strokeWidth(2)
      .fill('transparent')
      .strokeDashArray([size * 0.9, size * 1.0])
      .position({ x: size * 0.05, y: size * 0.2 })
    // 月亮
    Path()
      .commands(`M ${size * 0.65} ${size * 0.25} A ${size * 0.2} ${size * 0.2} 0 1 1 ${size * 0.65} ${size * 0.75} A ${size * 0.15} ${size * 0.15} 0 1 0 ${size * 0.65} ${size * 0.25} Z`)
      .fill(color)
      .position({ x: size * 0.15, y: 0 })
  }
  .width(size)
  .height(size)
}

// 目录/列表图标
@Builder
export function IconList(size: number = 24, color: ResourceColor = '#666666') {
  Column({ space: size * 0.2 }) {
    ForEach([0, 1, 2], () => {
      Row({ space: size * 0.15 }) {
        Circle()
          .width(size * 0.15)
          .height(size * 0.15)
          .fill(color)
        Rect()
          .width(size * 0.6)
          .height(size * 0.12)
          .radius(2)
          .fill(color)
      }
      .width('100%')
    })
  }
  .width(size)
  .height(size)
  .justifyContent(FlexAlign.Center)
}

// 字体大小图标
@Builder
export function IconFontSize(size: number = 24, color: ResourceColor = '#666666') {
  Stack() {
    Text('A')
      .fontSize(size * 0.5)
      .fontWeight(FontWeight.Bold)
      .fontColor(color)
      .position({ x: size * 0.15, y: size * 0.2 })
    Line()
      .startPoint([size * 0.65, size * 0.35])
      .endPoint([size * 0.85, size * 0.35])
      .stroke(color)
      .strokeWidth(2)
      .strokeLineCap(LineCapStyle.Round)
    Line()
      .startPoint([size * 0.75, size * 0.25])
      .endPoint([size * 0.75, size * 0.45])
      .stroke(color)
      .strokeWidth(2)
      .strokeLineCap(LineCapStyle.Round)
  }
  .width(size)
  .height(size)
}

// 刷新图标
@Builder
export function IconRefresh(size: number = 24, color: ResourceColor = '#666666') {
  Stack() {
    // 使用 Circle + strokeDashArray 模拟弧形
    Circle()
      .width(size * 0.8)
      .height(size * 0.8)
      .stroke(color)
      .strokeWidth(2)
      .fill('transparent')
      .strokeDashArray([size * 1.5, size * 1.0])
      .strokeDashOffset(0)
    Path()
      .commands(`M ${size * 0.7} ${size * 0.35} L ${size * 0.75} ${size * 0.15} L ${size * 0.55} ${size * 0.2} Z`)
      .fill(color)
  }
  .width(size)
  .height(size)
}

// 分享图标
@Builder
export function IconShare(size: number = 24, color: ResourceColor = '#666666') {
  Stack() {
    Circle()
      .width(size * 0.18)
      .height(size * 0.18)
      .fill(color)
      .position({ x: size * 0.75, y: size * 0.15 })
    Circle()
      .width(size * 0.18)
      .height(size * 0.18)
      .fill(color)
      .position({ x: size * 0.1, y: size * 0.4 })
    Circle()
      .width(size * 0.18)
      .height(size * 0.18)
      .fill(color)
      .position({ x: size * 0.75, y: size * 0.65 })
    Line()
      .startPoint([size * 0.22, size * 0.46])
      .endPoint([size * 0.68, size * 0.26])
      .stroke(color)
      .strokeWidth(1.5)
    Line()
      .startPoint([size * 0.22, size * 0.54])
      .endPoint([size * 0.68, size * 0.74])
      .stroke(color)
      .strokeWidth(1.5)
  }
  .width(size)
  .height(size)
}

// 信息/关于图标
@Builder
export function IconInfo(size: number = 24, color: ResourceColor = '#666666') {
  Stack() {
    Circle()
      .width(size)
      .height(size)
      .stroke(color)
      .strokeWidth(1.5)
      .fill('transparent')
    Circle()
      .width(size * 0.12)
      .height(size * 0.12)
      .fill(color)
      .position({ x: size * 0.44, y: size * 0.22 })
    Rect()
      .width(size * 0.1)
      .height(size * 0.35)
      .radius(1)
      .fill(color)
      .position({ x: size * 0.45, y: size * 0.42 })
  }
  .width(size)
  .height(size)
}

// 勾选图标
@Builder
export function IconCheck(size: number = 24, color: ResourceColor = '#666666') {
  Stack() {
    Path()
      .commands(`M ${size * 0.2} ${size * 0.5} L ${size * 0.4} ${size * 0.7} L ${size * 0.8} ${size * 0.3}`)
      .stroke(color)
      .strokeWidth(2.5)
      .strokeLineCap(LineCapStyle.Round)
      .strokeLineJoin(LineJoinStyle.Round)
      .fill('transparent')
  }
  .width(size)
  .height(size)
}

// 关闭图标
@Builder
export function IconClose(size: number = 24, color: ResourceColor = '#666666') {
  Stack() {
    Line()
      .startPoint([size * 0.25, size * 0.25])
      .endPoint([size * 0.75, size * 0.75])
      .stroke(color)
      .strokeWidth(2)
      .strokeLineCap(LineCapStyle.Round)
    Line()
      .startPoint([size * 0.75, size * 0.25])
      .endPoint([size * 0.25, size * 0.75])
      .stroke(color)
      .strokeWidth(2)
      .strokeLineCap(LineCapStyle.Round)
  }
  .width(size)
  .height(size)
}

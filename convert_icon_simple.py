#!/usr/bin/env python3
"""
SVGアイコンをPNG形式に変換する簡単なスクリプト
"""

from PIL import Image, ImageDraw, ImageFont
import os
import math

def create_simple_icon():
    """シンプルなアイコンを直接作成"""
    size = 512
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 背景グラデーション（円形）
    center = size // 2
    radius = int(size * 0.4)
    
    # グラデーション効果（複数の円を重ねる）
    for i in range(radius, 0, -2):
        alpha = int(255 * (i / radius) ** 0.5)
        color = (102, 126, 234, alpha)  # 青系
        if i < radius * 0.7:
            color = (118, 75, 162, alpha)  # 紫系
        draw.ellipse([center-i, center-i, center+i, center+i], fill=color)
    
    # 白い円形の背景
    inner_radius = int(radius * 0.6)
    draw.ellipse([center-inner_radius, center-inner_radius, 
                  center+inner_radius, center+inner_radius], 
                 fill=(255, 255, 255, 200))
    
    # カレンダーアイコン
    cal_width = int(inner_radius * 0.8)
    cal_height = int(cal_width * 0.6)
    cal_x = center - cal_width // 2
    cal_y = center - cal_height // 2
    
    # カレンダーの外枠
    draw.rounded_rectangle([cal_x, cal_y, cal_x + cal_width, cal_y + cal_height], 
                          radius=15, fill=(240, 240, 240, 255), 
                          outline=(102, 126, 234, 255), width=3)
    
    # カレンダーのヘッダー
    header_height = int(cal_height * 0.25)
    draw.rounded_rectangle([cal_x, cal_y, cal_x + cal_width, cal_y + header_height], 
                          radius=15, fill=(102, 126, 234, 255))
    
    # カレンダーのグリッド線
    grid_start_y = cal_y + header_height + 10
    grid_end_y = cal_y + cal_height - 10
    grid_left = cal_x + 15
    grid_right = cal_x + cal_width - 15
    
    # 縦線
    for i in range(1, 6):
        x = grid_left + (grid_right - grid_left) * i // 5
        draw.line([x, grid_start_y, x, grid_end_y], fill=(200, 200, 200, 255), width=2)
    
    # 横線
    for i in range(1, 5):
        y = grid_start_y + (grid_end_y - grid_start_y) * i // 4
        draw.line([grid_left, y, grid_right, y], fill=(200, 200, 200, 255), width=2)
    
    # チェックマーク（習慣完了）
    check_x = cal_x + cal_width // 4
    check_y = center
    check_radius = 20
    draw.ellipse([check_x - check_radius, check_y - check_radius,
                  check_x + check_radius, check_y + check_radius],
                 fill=(40, 167, 69, 255), outline=(255, 255, 255, 255), width=3)
    
    # チェックマークの線
    draw.line([check_x - 8, check_y, check_x - 2, check_y + 6], 
              fill=(255, 255, 255, 255), width=4)
    draw.line([check_x - 2, check_y + 6, check_x + 8, check_y - 4], 
              fill=(255, 255, 255, 255), width=4)
    
    # 小さなチェックマーク
    small_check_x = cal_x + cal_width * 3 // 4
    small_check_y = center - 20
    small_radius = 12
    draw.ellipse([small_check_x - small_radius, small_check_y - small_radius,
                  small_check_x + small_radius, small_check_y + small_radius],
                 fill=(23, 162, 184, 255), outline=(255, 255, 255, 255), width=2)
    
    # 小さなチェックマークの線
    draw.line([small_check_x - 5, small_check_y, small_check_x - 1, small_check_y + 4], 
              fill=(255, 255, 255, 255), width=2)
    draw.line([small_check_x - 1, small_check_y + 4, small_check_x + 5, small_check_y - 2], 
              fill=(255, 255, 255, 255), width=2)
    
    # 進行中の習慣（点線円）
    progress_x = cal_x + cal_width * 3 // 4
    progress_y = center + 20
    progress_radius = 15
    
    # 点線円（簡易版）
    for angle in range(0, 360, 30):
        rad = angle * 3.14159 / 180
        x1 = progress_x + (progress_radius - 2) * math.cos(rad)
        y1 = progress_y + (progress_radius - 2) * math.sin(rad)
        x2 = progress_x + progress_radius * math.cos(rad)
        y2 = progress_y + progress_radius * math.sin(rad)
        draw.line([x1, y1, x2, y2], fill=(255, 193, 7, 255), width=3)
    
    # 中心の点
    draw.ellipse([progress_x - 6, progress_y - 6, progress_x + 6, progress_y + 6],
                 fill=(255, 193, 7, 255))
    
    return img

def main():
    # 必要なディレクトリを作成
    os.makedirs("assets", exist_ok=True)
    
    # アイコン作成
    print("🎨 アイコンを作成中...")
    icon = create_simple_icon()
    
    # PNGとして保存
    png_file = "assets/app_icon_512x512.png"
    icon.save(png_file, "PNG")
    
    print(f"✅ アイコン作成完了！")
    print(f"📁 保存場所: {os.path.abspath(png_file)}")
    print(f"📏 サイズ: 512x512px")
    print(f"\nこのPNGファイルをGoogle Play Consoleにアップロードしてください。")

if __name__ == "__main__":
    main() 
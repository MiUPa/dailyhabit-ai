#!/usr/bin/env python3
"""
Google Playストア用画像（Feature graphic, Phone/Tablet screenshots）自動生成スクリプト
"""
from PIL import Image, ImageDraw, ImageFont
import os
import math

def draw_title(draw, text, width, y, font_size=64, color=(255,255,255)):
    try:
        font = ImageFont.truetype("Arial.ttf", font_size)
    except:
        font = ImageFont.load_default()
    bbox = draw.textbbox((0,0), text, font=font)
    w, h = bbox[2] - bbox[0], bbox[3] - bbox[1]
    draw.text(((width-w)//2, y), text, font=font, fill=color)

def draw_subtitle(draw, text, width, y, font_size=36, color=(255,255,255)):
    try:
        font = ImageFont.truetype("Arial.ttf", font_size)
    except:
        font = ImageFont.load_default()
    bbox = draw.textbbox((0,0), text, font=font)
    w, h = bbox[2] - bbox[0], bbox[3] - bbox[1]
    draw.text(((width-w)//2, y), text, font=font, fill=color)

def draw_mock_ui(draw, width, height):
    # シンプルな習慣リスト風UIイメージ
    margin = 60
    box_h = 80
    for i, habit in enumerate(["朝のストレッチ", "水を飲む", "日記を書く", "英語学習", "瞑想"]):
        top = margin + i*(box_h+20)
        left = margin
        right = width - margin
        bottom = top + box_h
        draw.rounded_rectangle([left, top, right, bottom], radius=20, fill=(255,255,255,220), outline=(102,126,234,255), width=3)
        # チェックマーク
        cx = left + 40
        cy = top + box_h//2
        draw.ellipse([cx-18, cy-18, cx+18, cy+18], fill=(40,167,69,255))
        draw.line([cx-8, cy, cx-2, cy+6], fill=(255,255,255,255), width=4)
        draw.line([cx-2, cy+6, cx+8, cy-4], fill=(255,255,255,255), width=4)
        # 習慣名
        try:
            font = ImageFont.truetype("Arial.ttf", 32)
        except:
            font = ImageFont.load_default()
        draw.text((cx+30, cy-18), habit, font=font, fill=(60,60,60))

def create_feature_graphic():
    w, h = 1024, 500
    img = Image.new('RGB', (w, h), (102,126,234))
    draw = ImageDraw.Draw(img)
    # グラデーション風
    for i in range(h):
        color = (102 + i*16//h, 126 + i*20//h, 234 - i*40//h)
        draw.line([(0,i),(w,i)], fill=color)
    draw_title(draw, "DailyHabit", w, 80, font_size=90)
    draw_subtitle(draw, "毎日をもっと良くする習慣アプリ", w, 200, font_size=44)
    draw_mock_ui(draw, w, h)
    return img

def create_phone_screenshot():
    w, h = 1080, 1920
    img = Image.new('RGB', (w, h), (102,126,234))
    draw = ImageDraw.Draw(img)
    for i in range(h):
        color = (102 + i*16//h, 126 + i*20//h, 234 - i*40//h)
        draw.line([(0,i),(w,i)], fill=color)
    draw_title(draw, "毎日の習慣を記録", w, 80, font_size=64)
    draw_mock_ui(draw, w, h)
    return img

def create_tablet7_screenshot():
    w, h = 1200, 1920
    img = Image.new('RGB', (w, h), (102,126,234))
    draw = ImageDraw.Draw(img)
    for i in range(h):
        color = (102 + i*16//h, 126 + i*20//h, 234 - i*40//h)
        draw.line([(0,i),(w,i)], fill=color)
    draw_title(draw, "習慣を可視化", w, 80, font_size=72)
    draw_mock_ui(draw, w, h)
    return img

def create_tablet10_screenshot():
    w, h = 1600, 2560
    img = Image.new('RGB', (w, h), (102,126,234))
    draw = ImageDraw.Draw(img)
    for i in range(h):
        color = (102 + i*16//h, 126 + i*20//h, 234 - i*40//h)
        draw.line([(0,i),(w,i)], fill=color)
    draw_title(draw, "大画面で快適に管理", w, 120, font_size=96)
    draw_mock_ui(draw, w, h)
    return img

def main():
    os.makedirs("assets/store_images", exist_ok=True)
    # Feature graphic
    fg = create_feature_graphic()
    fg.save("assets/store_images/feature_graphic_1024x500.png", "PNG")
    # Phone screenshot
    ph = create_phone_screenshot()
    ph.save("assets/store_images/phone_1080x1920.png", "PNG")
    # 7-inch tablet screenshot
    t7 = create_tablet7_screenshot()
    t7.save("assets/store_images/tablet7_1200x1920.png", "PNG")
    # 10-inch tablet screenshot
    t10 = create_tablet10_screenshot()
    t10.save("assets/store_images/tablet10_1600x2560.png", "PNG")
    print("\n✅ 画像生成完了！assets/store_images/ に保存しました。\n")
    print("Google Play Consoleにアップロードしてください。\n")

if __name__ == "__main__":
    main() 
#!/usr/bin/env python3
"""
スクリーンショットをGoogle Playストア用サイズにリサイズするスクリプト
"""

from PIL import Image
import os

def resize_screenshot(input_path, output_path, target_size):
    """画像をリサイズ"""
    try:
        with Image.open(input_path) as img:
            # アスペクト比を保ちながらリサイズ
            img.thumbnail(target_size, Image.Resampling.LANCZOS)
            
            # 新しい画像を作成（背景色を設定）
            new_img = Image.new('RGB', target_size, (102, 126, 234))
            
            # 元画像を中央に配置
            x = (target_size[0] - img.width) // 2
            y = (target_size[1] - img.height) // 2
            new_img.paste(img, (x, y))
            
            # 保存
            new_img.save(output_path, 'PNG')
            print(f"✅ リサイズ完了: {output_path}")
            return True
    except Exception as e:
        print(f"❌ エラー: {e}")
        return False

def main():
    # 出力ディレクトリを作成
    os.makedirs("assets/store_screenshots", exist_ok=True)
    
    # 入力ファイルとリサイズ設定
    files_and_sizes = {
        "screenshot_phone.png": (1080, 1920),
        "screenshot_tablet7.png": (1200, 1920),
        "screenshot_tablet10.png": (1600, 2560),
        "screenshot_feature.png": (1024, 500)
    }
    
    # 各ファイルをリサイズ
    for input_file, target_size in files_and_sizes.items():
        if os.path.exists(input_file):
            output_file = f"assets/store_screenshots/{input_file.replace('.png', '')}_{target_size[0]}x{target_size[1]}.png"
            resize_screenshot(input_file, output_file, target_size)
        else:
            print(f"⚠️  ファイルが見つかりません: {input_file}")
    
    print(f"\n📝 撮影手順:")
    print(f"1. screenshot_phone.png - スマホサイズで撮影")
    print(f"2. screenshot_tablet7.png - 7インチタブレットサイズで撮影")
    print(f"3. screenshot_tablet10.png - 10インチタブレットサイズで撮影")
    print(f"4. screenshot_feature.png - 横長サイズで撮影")
    
    print(f"\n🎉 リサイズ完了！")
    print(f"📁 保存場所: assets/store_screenshots/")
    print(f"📝 Google Play Consoleにアップロードしてください。")

if __name__ == "__main__":
    main() 
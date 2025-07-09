#!/usr/bin/env python3
"""
SVGアイコンをPNG形式に変換するスクリプト
"""

import cairosvg
import os

def convert_svg_to_png(svg_path, png_path, size=512):
    """SVGファイルをPNGに変換"""
    try:
        # SVGをPNGに変換
        cairosvg.svg2png(
            url=svg_path,
            write_to=png_path,
            output_width=size,
            output_height=size
        )
        print(f"✅ 変換成功: {png_path}")
        return True
    except Exception as e:
        print(f"❌ 変換エラー: {e}")
        return False

def main():
    # 必要なディレクトリを作成
    os.makedirs("assets", exist_ok=True)
    
    # SVGファイルのパス
    svg_file = "assets/app_icon_512x512.svg"
    png_file = "assets/app_icon_512x512.png"
    
    # 変換実行
    if os.path.exists(svg_file):
        success = convert_svg_to_png(svg_file, png_file, 512)
        if success:
            print(f"\n🎉 アイコン変換完了！")
            print(f"📁 保存場所: {os.path.abspath(png_file)}")
            print(f"📏 サイズ: 512x512px")
            print(f"\nこのPNGファイルをGoogle Play Consoleにアップロードしてください。")
        else:
            print("❌ 変換に失敗しました。")
    else:
        print(f"❌ SVGファイルが見つかりません: {svg_file}")

if __name__ == "__main__":
    main() 
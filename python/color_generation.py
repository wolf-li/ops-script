import colorsys
import sys

# 将十六进制颜色转换为 RGB
def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip('#')  # 去掉 # 前缀
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

# 将 RGB 转换为十六进制颜色
def rgb_to_hex(rgb):
    return '#%02x%02x%02x' % rgb

if __name__ == "__main__":
    # 获取命令行输入
    base_color = sys.argv[1]  # 基础颜色，例如 "#140300"
    n = int(sys.argv[2])      # 配色数量，例如 5

    # 将基础颜色转换为 RGB
    r, g, b = hex_to_rgb(base_color)
    # 归一化到 [0, 1]
    r /= 255.0
    g /= 255.0
    b /= 255.0

    # 转换为 HSL
    h, l, s = colorsys.rgb_to_hls(r, g, b)

    # 根据数量生成配色
    if n == 1:
        print(base_color)  # 如果 n=1，直接输出基础颜色
    else:
        for i in range(n):
            # 生成新的亮度值，均匀分布在 (0, 1) 之间
            new_l = (i + 1) / (n + 1)
            # 转换回 RGB
            new_r, new_g, new_b = colorsys.hls_to_rgb(h, new_l, s)
            # 缩放到 [0, 255] 并取整
            new_r = round(new_r * 255)
            new_g = round(new_g * 255)
            new_b = round(new_b * 255)
            # 转换为十六进制
            new_hex = rgb_to_hex((new_r, new_g, new_b))
            print(new_hex)

import os
import imageio

path = 'F:/Figure/caseSG3/fig_add/slice/'
pic_lst = os.listdir(path)
gif_images = []
for name in pic_lst:
    filename = os.path.join(path, name)
    gif_images.append(imageio.imread(filename))  # 读取图片

imageio.mimsave('slice.gif', gif_images, 'GIF', duration=0.5)
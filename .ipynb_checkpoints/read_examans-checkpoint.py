# coding=utf-8

import re
import os
import xlwt
import codecs


path = '/Users/xiaoyu/Downloads/2-910/'
file_list = []  # 开始为空列表
def vstdir(path):
    for x in os.listdir(path):
        sub_path = os.path.join(path, x)
        if os.path.isdir(sub_path):
            vstdir(sub_path)
        else:
            if '.sql' in sub_path or '.txt' in sub_path:
                file_list.append(sub_path)
vstdir(path)

with open('answers.txt', 'w') as f:
    for i, pt in enumerate(file_list, start=1):
        print(pt)
        f.write(pt + '\n')
        f.write(f"\n================================{i}====================================\n")
        try:
            with open(pt, encoding='gbk') as f1:
                s = f1.read()
                f.write(s)
        except UnicodeDecodeError:
            with open(pt, encoding='utf-8') as f1:
                s = f1.read()
                f.write(s)
        f.write('\n')
    f.close()

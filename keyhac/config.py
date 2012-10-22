# coding: utf-8
# 設定開始
import sys
import os
sys.path.append(os.environ.get('HOME') + '/git/dotfiles/keyhac')
import MyConfig

def configure(km):
    MyConfig.MyConfig(km)

# vim:se et ts=4 sts=4 sw=4 fdm=marker:

# ターゲットをiOSに指定
TARGET := iphone:clang:latest:14.5
# アーキテクチャは荒野行動用のarm64
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = KnivesOutESP

# ここに相棒の Tweak.x や 他のソースファイルを書くじょ
KnivesOutESP_FILES = Tweak.x
KnivesOutESP_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

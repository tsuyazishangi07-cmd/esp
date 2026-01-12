TARGET := iphone:clang:latest:14.5
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = KnivesOutESP
# ここが超重要！ CoreGraphics を追加したじょ！
KnivesOutESP_FRAMEWORKS = UIKit CoreGraphics Foundation
KnivesOutESP_FILES = Tweak.x
KnivesOutESP_CFLAGS = -fobjc-arc
include $(THEOS_MAKE_PATH)/tweak.mk
# これを Makefile の最後に書き足してだじょ！
KnivesOutESP_CFLAGS += -Wno-deprecated-declarations -Wno-unused-variable

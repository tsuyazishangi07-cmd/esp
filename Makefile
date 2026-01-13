TARGET := iphone:clang:latest:14.5
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = KnivesOutESP

KnivesOutESP_FILES = Tweak.x
KnivesOutESP_FRAMEWORKS = UIKit CoreGraphics Foundation
KnivesOutESP_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk

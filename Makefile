export TARGET = iphone:clang:14.5:14.5
export ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = KnivesOutESP
KnivesOutESP_FILES = Tweak.x
KnivesOutESP_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

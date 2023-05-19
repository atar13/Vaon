ARCHS = arm64 arm64e
SDKVERSION = 14.5
SYSROOT = $(THEOS)/sdks/iPhoneOS14.5.sdk

TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Vaon

Vaon_FILES = Vaon.xm 
Vaon_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
Vaon_FRAMEWORKS += QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += vaonprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

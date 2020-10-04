export ARCHS = arm64 arm64e 
# export SDKVERSION = 13.5
SYSROOT = $(THEOS)/sdks/iPhoneOS13.5.sdk
THEOS_DEVICE_IP = 100.113.189.255

TARGET := iphone:clang:13.0:latest
INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Vaon

Vaon_FILES = Vaon.xm 
Vaon_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
Vaon_FRAMEWORKS += QuartzCore
Vaon_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += vaonprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

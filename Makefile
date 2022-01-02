ARCHS = arm64 arm64e
SDKVERSION = 14.3
SYSROOT = $(THEOS)/sdks/iPhoneOS14.4.sdk

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

final:
	make package FINALPACKAGE=1
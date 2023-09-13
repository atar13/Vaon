export ARCHS = arm64 arm64e
export SDKVERSION = 14.5
export SYSROOT = $(THEOS)/sdks/iPhoneOS14.5.sdk

ifeq ($(THEOS_PACKAGE_SCHEME), rootless)
export TARGET = iphone:clang:latest:14.0
else
export TARGET = iphone:clang:latest:13.0
endif

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Vaon

Vaon_FILES = Vaon.xm 
Vaon_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
Vaon_FRAMEWORKS += QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += vaonprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

final_package_rootful: clean 
	$(MAKE) package FINALPACKAGE=1

final_package_rootless: clean 
	$(MAKE) package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless

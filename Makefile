export ARCHS = arm64 arm64e 
export SDKVERSION = 13.3

TARGET := iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Vaon

Vaon_FILES = Vaon.x
Vaon_CFLAGS = -fobjc-arc
Vaon_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

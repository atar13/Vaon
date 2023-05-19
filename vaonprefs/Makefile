ARCHS = arm64 arm64e
SDKVERSION = 14.5
TARGET := iphone:clang:latest:14.0
SYSROOT = $(THEOS)/sdks/iPhoneOS14.5.sdk

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = VaonPrefs

VaonPrefs_FILES = VaonRootListController.m
VaonPrefs_FRAMEWORKS = UIKit
VaonPrefs_PRIVATE_FRAMEWORKS = Preferences
VaonPrefs_INSTALL_PATH = /Library/PreferenceBundles
VaonPrefs_CFLAGS = -fobjc-arc
VaonPrefs_LIBRARIES = colorpicker

include $(THEOS_MAKE_PATH)/bundle.mk

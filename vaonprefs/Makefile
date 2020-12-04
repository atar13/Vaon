ARCHS = arm64 arm64e
TARGET := iphone:clang:13.0:latest
# SYSROOT = $(THEOS)/sdks/iPhoneOS13.5.sdk 

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = VaonPrefs

VaonPrefs_FILES = VaonRootListController.m
VaonPrefs_FRAMEWORKS = UIKit
VaonPrefs_PRIVATE_FRAMEWORKS = Preferences
VaonPrefs_INSTALL_PATH = /Library/PreferenceBundles
VaonPrefs_CFLAGS = -fobjc-arc
VaonPrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

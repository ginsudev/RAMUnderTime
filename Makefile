ARCHS = arm64 arm64e
THEOS_DEVICE_IP = localhost -p 2222
TARGET := iphone:clang:14.4:13.0
INSTALL_TARGET_PROCESSES = SpringBoard
PACKAGE_VERSION = 2.0.2

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = RAMUnderTime

RAMUnderTime_FILES = $(shell find Sources/RAMUnderTime -name '*.swift') $(shell find Sources/RAMUnderTimeC -name '*.m' -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')
RAMUnderTime_SWIFTFLAGS = -ISources/RAMUnderTimeC/include
RAMUnderTime_CFLAGS = -fobjc-arc -ISources/RAMUnderTimeC/include

include $(THEOS_MAKE_PATH)/tweak.mk

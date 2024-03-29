ARCHS = arm64 arm64e
THEOS_DEVICE_IP = root@localhost -p 2222
TARGET = iphone:clang:15.2:14.5
INSTALL_TARGET_PROCESSES = SpringBoard
PACKAGE_VERSION = 3.2

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = RAMUnderTime

RAMUnderTime_FILES = $(shell find Sources/RAMUnderTime -name '*.swift') $(shell find Sources/RAMUnderTimeC -name '*.m' -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')
RAMUnderTime_SWIFTFLAGS = -ISources/RAMUnderTimeC/include
RAMUnderTime_CFLAGS = -fobjc-arc -ISources/RAMUnderTimeC/include

include $(THEOS_MAKE_PATH)/tweak.mk

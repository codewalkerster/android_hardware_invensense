# Copyright (C) 2008 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# Modified 2011 by InvenSense, Inc

ifeq ($(BOARD_HAVE_MPU3050_SENSORS),true)

LOCAL_PATH := $(call my-dir)

ifneq ($(TARGET_SIMULATOR),true)

# InvenSense fragment of the HAL
include $(CLEAR_VARS)

LOCAL_MODULE := libinvensense_hal
#yyd- 111222
LOCAL_MODULE_TAGS := optional
#LOCAL_MODULE_TAGS := eng
LOCAL_CFLAGS := -DLOG_TAG=\"Sensors\"

LOCAL_SRC_FILES := SensorBase.cpp
LOCAL_SRC_FILES += MPLSensor.cpp
#LOCAL_SRC_FILES += MPLSensorSysApi.cpp

LOCAL_C_INCLUDES += $(LOCAL_PATH)/../mlsdk/platform/include
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../mlsdk/platform/include/linux
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../mlsdk/platform/linux
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../mlsdk/mllite
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../mlsdk/mldmp
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../mlsdk/external/aichi
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../mlsdk/external/akmd

LOCAL_SHARED_LIBRARIES := liblog libcutils libutils libdl
LOCAL_SHARED_LIBRARIES += libmllite libmlplatform

#Additions for SysPed
LOCAL_SHARED_LIBRARIES += libmplmpu
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../mlsdk/mldmp

LOCAL_CPPFLAGS += -DLINUX=1
LOCAL_CPPFLAGS += -DMPL_LIB_NAME=\"libmplmpu.so\"
LOCAL_CPPFLAGS += -DAICHI_LIB_NAME=\"libami.so\"
LOCAL_CPPFLAGS += -DAKM_LIB_NAME=\"libakmd.so\"
#LOCAL_LDFLAGS := -rdynamic
LOCAL_PRELINK_MODULE := false

include $(BUILD_SHARED_LIBRARY)

endif # !TARGET_SIMULATOR

# Build a temporary HAL that links the InvenSense .so
include $(CLEAR_VARS)
#yyd- 111222
#LOCAL_MODULE := sensors.$(TARGET_PRODUCT)
LOCAL_MODULE := sensors.$(TARGET_DEVICE)
LOCAL_MODULE_PATH := $(TARGET_OUT_SHARED_LIBRARIES)/hw

# Additions
LOCAL_SHARED_LIBRARIES += libmplmpu
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../mlsdk/platform/include
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../mlsdk/platform/include/linux
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../mlsdk/platform/linux
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../mlsdk/mllite
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../mlsdk/mldmp
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../mlsdk/external/aichi
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../mlsdk/external/akmd
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../mlsdk/mldmp

LOCAL_PRELINK_MODULE := false
#yyd- 111222
LOCAL_MODULE_TAGS := optional
#LOCAL_MODULE_TAGS := eng 
LOCAL_CFLAGS := -DLOG_TAG=\"Sensors\"

LOCAL_SRC_FILES := sensors_mpl.cpp 
LOCAL_SRC_FILES += SensorBase.cpp

#LOCAL_LDFLAGS:=-rdynamic
LOCAL_SHARED_LIBRARIES := libinvensense_hal libcutils libutils libdl
include $(BUILD_SHARED_LIBRARY)

endif

EXEC = polldmp$(STATIC_APP_SUFFIX)

MK_NAME = $(notdir $(CURDIR)/$(firstword $(MAKEFILE_LIST)))

CROSS = $(ANDROID_ROOT)/prebuilt/linux-x86/toolchain/arm-eabi-4.4.0/bin/arm-eabi-
COMP  = $(CROSS)gcc
LINK  = $(CROSS)gcc 

MLSDK_ROOT     = ../../..
ML_COMMON_DIR  = $(MLSDK_ROOT)/mlapps/common
MPL_DIR        = $(MLSDK_ROOT)/mldmp
AICHI_DIR      = $(MLSDK_ROOT)/external/aichi
AKM_DIR        = $(MLSDK_ROOT)/external/akmd
MLLITE_DIR     = $(MLSDK_ROOT)/mllite
MLPLATFORM_DIR = $(MLSDK_ROOT)/platform

OBJFOLDER=$(CURDIR)/obj

include $(MLSDK_ROOT)/Android-common.mk

CFLAGS += $(CMDLINE_CFLAGS)
CFLAGS += -Wall -fpic
CFLAGS += -mthumb-interwork -fno-exceptions -ffunction-sections -funwind-tables -fstack-protector -fmessage-length=0 -fno-short-enums
CFLAGS += -D_REENTRANT -DLINUX -DANDROID
CFLAGS += -I$(MLLITE_DIR) 
CFLAGS += -I$(MPL_DIR)
CFLAGS += -I$(MLPLATFORM_DIR)/include 
CFLAGS += -I$(MLPLATFORM_DIR)/include/linux
CFLAGS += -I$(MLPLATFORM_DIR)/linux
CFLAGS += -I$(MLSDK_ROOT)/mlutils 
CFLAGS += -I$(MLSDK_ROOT)/mltools/debugsupport
CFLAGS += -I$(AICHI_DIR) 
CFLAGS += -I$(AKM_DIR)
CFLAGS += -I$(ML_COMMON_DIR) 
CFLAGS += -I$(MLSDK_ROOT)/external/aichi

LLIBS = -lc -lm -lutils -lcutils -lgcc

PRE_LFLAGS += -Wl,-T,$(ANDROID_ROOT)/build/core/armelf.x
PRE_LFLAGS += $(ANDROID_ROOT)/out/target/product/$(PRODUCT)/obj/lib/crtend_android.o
PRE_LFLAGS += $(ANDROID_ROOT)/out/target/product/$(PRODUCT)/obj/lib/crtbegin_dynamic.o

LFLAGS += $(CMDLINE_LFLAGS)
LFLAGS += -rdynamic -nostdlib -fpic
LFLAGS += -Wl,--gc-sections -Wl,--no-whole-archive
LFLAGS += -Wl,-dynamic-linker,/system/bin/linker
LFLAGS += -L$(MPL_DIR)/mpl/$(TARGET) 
LFLAGS += -L$(MLLITE_DIR)/mpl/$(TARGET)
LFLAGS += $(ANDROID_LINK)

LRPATH += -Wl,-rpath,$(ANDROID_ROOT)/out/target/product/$(PRODUCT)/obj/lib:$(ANDROID_ROOT)/out/target/product/$(PRODUCT)/system/lib:$(MPL_DIR)/mpl/$(TARGET):$(MLLITE_DIR)/mpl/$(TARGET):

VPATH += $(ML_COMMON_DIR) $(MLLITE_DIR)

####################################################################################################
## sources

ML_LIBS  = $(MPL_DIR)/mpl/$(TARGET)/$(LIB_PREFIX)$(MPL_LIB_NAME).$(STATIC_LIB_EXT)
ML_LIBS += $(AICHI_DIR)/mpl/$(TARGET)/$(LIB_PREFIX)$(AICHI_LIB_NAME).$(STATIC_LIB_EXT)
#ML_LIBS += $(AICHI_DIR)/mpl/$(TARGET)/$(AICHI_EXT_LIB)
ML_LIBS += $(AKM_DIR)/mpl/$(TARGET)/$(LIB_PREFIX)$(AKM_LIB_NAME).$(STATIC_LIB_EXT)
ML_LIBS += $(AKM_DIR)/mpl/$(TARGET)/$(AKM_EXT_LIB)
ML_LIBS += $(MLLITE_DIR)/mpl/$(TARGET)/$(LIB_PREFIX)$(MLLITE_LIB_NAME).$(STATIC_LIB_EXT)
ML_LIBS += $(MLPLATFORM_DIR)/linux/$(LIB_PREFIX)$(MLPLATFORM_LIB_NAME).$(STATIC_LIB_EXT)

ML_SRCS  = polldmp.c
ML_SRCS += $(ML_COMMON_DIR)/mlsetup.c
ML_SRCS += $(ML_COMMON_DIR)/helper.c
ML_SRCS += $(ML_COMMON_DIR)/mlerrorcode.c
ML_SRCS += $(MLLITE_DIR)/mlmath.c

ML_OBJS = $(addsuffix .o, $(ML_SRCS))
ML_OBJS_DST = $(addprefix $(OBJFOLDER)/,$(notdir $(ML_OBJS)))

####################################################################################################
## rules

.PHONY: all clean cleanall install

all: $(EXEC) $(MK_NAME)

$(EXEC) : $(OBJFOLDER) $(ML_OBJS_DST) $(ML_LIBS) $(MK_NAME)
	@$(call echo_in_colors, "\n<linking $(EXEC) with objects $(ML_OBJS_DST) and libraries $(ML_LIBS)\n")
	$(LINK) $(PRE_LFLAGS) $(ML_OBJS_DST) -o $(EXEC) $(LFLAGS) $(LLIBS) $(ML_LIBS) $(LLIBS) $(LRPATH) 

$(OBJFOLDER) : 
	@$(call echo_in_colors, "\n<creating object's folder 'obj/'>\n")
	mkdir obj

$(ML_OBJS_DST) : $(OBJFOLDER)/%.c.o : %.c $(MK_NAME)
	@$(call echo_in_colors, "\n<compile $< to $(OBJFOLDER)/$(notdir $@)>\n")
	$(COMP) $(CFLAGS) $(ANDROID_INCLUDES) $(MLSDK_INCLUDES) -o $@ -c $<

clean : 
	rm -fR $(OBJFOLDER)

cleanall : 
	rm -fR $(EXEC) $(OBJFOLDER)

install : $(EXEC)
	cp -f $(EXEC) $(INSTALL_DIR)

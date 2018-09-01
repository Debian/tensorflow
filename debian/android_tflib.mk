# TensorFlow library for Android

include debian/flags.mk

TFLIB_SRCS := $(shell cat android_tf_lib_cc.txt)
TFLIB_OBJS := $(addprefix $(BDIR), $(TFLIB_SRCS:.cc=.o))

SHLIB := libtensorflow.so.1.10.1a

$(BDIR)/$(SHLIB): $(TFLIB_OBJS)
	$(CXX) -shared -o $@ $(TFLIB_OBJS) $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) $(LIBS)

# XXX: adding a "-w" argument to let GCC shutup or you'll get a giant buildlog.
$(BDIR)%.o: %.cc
	@mkdir -p $(dir $@)
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) -w

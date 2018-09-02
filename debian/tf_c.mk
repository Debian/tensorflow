# find tensorflow/c -type f -name '*.cc' | grep -v test | grep -v python | grep -v experimental

include debian/flags.mk

X_TF_C := $(BDIR)/tf_c.a

TF_C_SRCS := \
tensorflow/c/checkpoint_reader.cc \
tensorflow/c/eager/c_api_debug.cc \
tensorflow/c/eager/c_api.cc \
tensorflow/c/c_api_function.cc \
tensorflow/c/c_api.cc \
tensorflow/c/tf_status_helper.cc

TF_C_OBJS := $(addprefix $(BDIR), $(TF_C_SRCS:.cc=.o))

$(BDIR)/tf_c.a: $(TF_C_OBJS)
	ar rcs $@ $(TF_C_OBJS)

$(BDIR)%.o: %.cc
	@mkdir -p $(dir $@)
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) -w

include debian/flags.mk
include debian/globs.mk

X_TF_SHLIB: $(BDIR)/libtensorflow.so

TF_CC_OPS_SRCS := $(wildcard $(BDIR)/tensorflow/cc/ops/*.cc)
TF_CC_OPS_SRCS := $(filter-out $(BDIR)/tensorflow/cc/ops/debug_ops.cc, $(TF_CC_OPS_SRCS))
TF_CC_OPS_OBJS := $(TF_CC_OPS_SRCS:.cc=.o)

$(BDIR)%.o: $(BDIR)%.cc
       @mkdir -p $(dir $@)
       $(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) -w

$(BDIR)/libtensorflow.so: \
		$(TF_PROTO_OBJS) $(PBT_OBJS) \
		$(CORE_OBJS) $(TF_CC_OBJS) $(TF_C_OBJS) $(TF_CC_OPS_OBJS)
	$(CXX) -shared -fPIC $(CXXFLAGS) $(LDFLAGS) $(INCLUDES) $(LIBS) \
		$(TF_PROTO_OBJS) $(PBT_OBJS) $(TF_CC_OPS_OBJS) \
		$(CORE_OBJS) $(TF_CC_OBJS) $(TF_C_OBJS) \
		-o $(BDIR)/libtensorflow.so.$(VERSION) \
		-Wl,--soname=libtensorflow.so.$(SOVERSION) \
		-Wl,--allow-multiple-definition
	ln -sr $(BDIR)/libtensorflow.so.$(VERSION) $(BDIR)/libtensorflow.so.$(SOVERSION)
	ln -sr $(BDIR)/libtensorflow.so.$(VERSION) $(BDIR)/libtensorflow.so

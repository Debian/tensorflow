include debian/flags.mk
include debian/globs.mk

X_TF_SHLIB: $(BDIR)/libtensorflow.so

$(BDIR)/libtensorflow.so: \
		$(TF_PROTO_OBJS) $(PBT_OBJS) \
		$(CORE_OBJS) $(TF_CC_OBJS) $(TF_C_OBJS)
	$(CXX) -shared -fPIC $(CXXFLAGS) $(LDFLAGS) $(INCLUDES) $(LIBS) \
		$(TF_PROTO_OBJS) $(PBT_OBJS) \
		$(CORE_OBJS) $(TF_CC_OBJS) $(TF_C_OBJS) \
		-o $(BDIR)/libtensorflow.so.$(VERSION) \
		-Wl,--soname=libtensorflow.so.$(SOVERSION) \
		-Wl,--allow-multiple-definition
	ln -sr $(BDIR)/libtensorflow.so.$(VERSION) $(BDIR)/libtensorflow.so.$(SOVERSION)
	ln -sr $(BDIR)/libtensorflow.so.$(VERSION) $(BDIR)/libtensorflow.so

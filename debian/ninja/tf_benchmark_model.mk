# TF tool tf_benchmark_model

include debian/flags.mk

BENCHMARK_SRCS := \
tensorflow/core/util/reporter.cc \
tensorflow/tools/benchmark/benchmark_model.cc \
tensorflow/tools/benchmark/benchmark_model_main.cc

BENCHMARK_OBJS := $(addprefix $(BDIR), $(BENCHMARK_SRCS:.cc=.o))

$(BDIR)%.o: %.cc
	@mkdir -p $(dir $@)
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES)

$(BDIR)/tf_benchmark_model: $(BENCHMARK_OBJS)
	$(CXX) -o $@ $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) $(LIBS) \
		-ltensorflow -L$(BDIR) $(BENCHMARK_OBJS)

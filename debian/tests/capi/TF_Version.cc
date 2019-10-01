#include <iostream>

#include "gtest/gtest.h"
#include "tensorflow/c/c_api.h"

TEST(CAPI, Version) {
	std::cout << TF_Version() << std::endl;
	EXPECT_STRNE("", TF_Version());
}

GTEST_API_ int main(int argc, char** argv) {
  testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}

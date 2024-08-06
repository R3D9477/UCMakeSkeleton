#------------------------------------------------------------------------------------------------------
# Compiler's safety flags.

string(TOUPPER ${CMAKE_CXX_COMPILER_ID} SFF_POSTFIX)
set(SAFETY_FLAGS_FILE "${PROJECT_SOURCE_DIR}/CMakeLists.txt_c_Project_SafetyFlags_${SFF_POSTFIX}.cmake")
if(EXISTS "${SAFETY_FLAGS_FILE}")
  include("${SAFETY_FLAGS_FILE}")
endif()

message("SAFETY_FLAGS_FILE: ${SAFETY_FLAGS_FILE}")
message("SAFETY_FLAGS: ${SAFETY_FLAGS}")

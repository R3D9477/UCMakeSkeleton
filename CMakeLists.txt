cmake_minimum_required(VERSION 3.16)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(IGNORE_Qt TRUE)

get_filename_component(OUTPUT_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
project(${OUTPUT_NAME} VERSION 0.1 LANGUAGES CXX)

#------------------------------------------------------------------------------------------------------

# - DEFINE THE LIST OF THE SOURCES (CURRENT TARGET) BELOW IN VARIABLE SCAN_SOURCES_FOLDER
# - ATTACH EXTERNAL LIBRARIES AT THE BOTTOM OF THAT FILE
list(APPEND SCAN_SOURCES_FOLDER ".")

#------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------

include(CMakeLists.txt_z_Utils.cmake)

#------------------------------------------------------------------------------------------------------

include(CMakeLists.txt_z_Utils_Qt.cmake) # Add Qt application

if(NOT QT_APP_ADDED)
  add_executable(${OUTPUT_NAME} ${${PROJECT_NAME}_SOURCES}) # Add application
endif()

include(CMakeLists.txt_z_Utils_SafetyFlags.cmake)
target_compile_options(${OUTPUT_NAME} PRIVATE ${SAFETY_FLAGS}) # Compiler's safety flags

include(CMakeLists.txt_z_Utils_VCRuntime.cmake) # Add VCRuntime libs if needed

include(CMakeLists.txt_z_Utils_Boost.cmake) # Add Boost if it possible

#------------------------------------------------------------------------------------------------------

target_include_directories(${OUTPUT_NAME} PUBLIC ${${PROJECT_NAME}_INCLUDES})

#------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------
# ATTACH EXTERNAL LIBRARIES

set(EXT_LIBS_FILE "${PROJECT_SOURCE_DIR}/CMakeLists.txt_a_Project_Libs.cmake")
if(EXISTS "${EXT_LIBS_FILE}")
  include("${EXT_LIBS_FILE}")
endif()

#------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------
# ADD TESTS

set(EXT_LIBS_FILE "${PROJECT_SOURCE_DIR}/CMakeLists.txt_b_Project_Tests.cmake")
if(EXISTS "${EXT_LIBS_FILE}")
  include("${EXT_LIBS_FILE}")
endif()

cmake_minimum_required(VERSION 3.16)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(IGNORE_Qt TRUE)

get_filename_component(OUTPUT_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
project(${OUTPUT_NAME} VERSION 0.1 LANGUAGES CXX)

# - DEFINE THE LIST OF THE SOURCES (CURRENT TARGET) BELOW IN VARIABLE SCAN_SOURCES_FOLDER
# - ATTACH EXTERNAL LIBRARIES AT THE BOTTOM OF THAT FILE
list(APPEND SCAN_SOURCES_FOLDER ".")

#------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------
# Scan project's sources folders.

set(SOURCE_MASK *.c *.cc *.cpp *.cxx *.c++ *.h *.hh *.hpp *.hxx *.h++ *.tcc *.tpp *.ipp *.qrc)

function(get_sources_from_dir DEST_SRCs_VAR DEST_INCs_VAR SRC_DIR)
  unset(DIR_SRCs_FOUND)
  foreach(SRC_MASK ${SOURCE_MASK})
    file(GLOB DIR_SRCs "${SRC_DIR}/${SRC_MASK}")
    if(NOT "${DIR_SRCs}" STREQUAL "")
      set(DIR_SRCs_FOUND true)
      get_filename_component(DIR_SRCs "${DIR_SRCs}" ABSOLUTE)
      if(NOT "${DIR_SRCs}" IN_LIST ${DEST_SRCs_VAR})
        list(APPEND ${DEST_SRCs_VAR} ${DIR_SRCs})
        set(${DEST_SRCs_VAR} ${${DEST_SRCs_VAR}} PARENT_SCOPE)
      endif()
    endif()
  endforeach()
  if(${DIR_SRCs_FOUND})
    get_filename_component(SRC_DIR "${SRC_DIR}" ABSOLUTE)
    if(NOT "${SRC_DIR}" IN_LIST ${DEST_INCs_VAR})
      list(APPEND ${DEST_INCs_VAR} ${SRC_DIR})
      set(${DEST_INCs_VAR} ${${DEST_INCs_VAR}} PARENT_SCOPE)
    endif()
  endif()
endfunction()

foreach(SRC_FOLDER ${SCAN_SOURCES_FOLDER})
  get_sources_from_dir(${PROJECT_NAME}_SOURCES ${PROJECT_NAME}_INCLUDES ${SRC_FOLDER})
endforeach()

#------------------------------------------------------------------------------------------------------
# Scan project's unit tests sources folder.

file(READ "conanfile.txt" CONAN_PACKAGES)
set(GTEST_REQUIRED FALSE)
set(BOOST_REQUIRED FALSE)
if("${CONAN_PACKAGES}" MATCHES "gtest")
  set(GTEST_REQUIRED TRUE)
endif()
if("${CONAN_PACKAGES}" MATCHES "boost")
  set(BOOST_REQUIRED TRUE)
endif()

enable_testing()

set(SOURCE_MASK_TEST *.c *.cc *.cpp *.cxx *.c++)

function(target_add_tests_from_folder TARGET_NAME FOLDER_PATH)
  set(CMAKE_CXX_FLAGS "--coverage")
  foreach(SRC_MASK_TEST ${SOURCE_MASK_TEST})
    file(GLOB TEST_SRCs "${FOLDER_PATH}/${SRC_MASK_TEST}")
    foreach(TEST_SRC ${TEST_SRCs})
      get_filename_component(TEST_NAME ${TEST_SRC} NAME_WE)
      set(TEST_TARGET_NAME ${TEST_NAME})
      add_executable(${TEST_TARGET_NAME} "${TEST_SRC}")
      target_include_directories(${TEST_TARGET_NAME} PUBLIC ${${TARGET_NAME}_INCLUDES})
      if(${GTEST_REQUIRED})
        find_package(GTest REQUIRED)
        target_link_libraries(${TEST_TARGET_NAME} PUBLIC gtest::gtest)
      endif()
      if(${BOOST_REQUIRED})
        find_package(Boost REQUIRED COMPONENTS unit_test_framework)
        target_link_libraries(${TEST_TARGET_NAME} PUBLIC Boost::unit_test_framework)
      endif()
      get_target_property(target_type ${TARGET_NAME} TYPE)
      if (NOT target_type STREQUAL "EXECUTABLE")
        target_link_libraries(${TEST_TARGET_NAME} PUBLIC ${TARGET_NAME})
      endif ()
      add_test(${TEST_TARGET_NAME} ${TEST_TARGET_NAME})
    endforeach()
  endforeach()
endfunction()

#------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------
# Add Qt application (if possible).

# Comment the line below if you're using QtCreator, but Qt is no needed
find_package(QT NAMES Qt6 Qt5 COMPONENTS Core Quick REQUIRED)

if(QT_FOUND AND NOT IGNORE_Qt)
  # Based on default templates of CMakeLists.txt for Qt5 and Qt6

  find_package(Qt${QT_VERSION_MAJOR} COMPONENTS Core Quick Widgets REQUIRED)

  set(CMAKE_INCLUDE_CURRENT_DIR ON)

  set(CMAKE_AUTOUIC ON)
  set(CMAKE_AUTOMOC ON)
  set(CMAKE_AUTORCC ON)

  if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    set(OUTPUT_NAME "app${OUTPUT_NAME}")
    qt_add_executable(${OUTPUT_NAME} ${${PROJECT_NAME}_SOURCES})
    file(GLOB_RECURSE MODULE_QMLs RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.qml)
    if(NOT "${MODULE_QMLs}" STREQUAL "")
      qt_add_qml_module(${OUTPUT_NAME} URI ${PROJECT_NAME} VERSION 1.0 QML_FILES ${MODULE_QMLs})
    endif()
    # Define target properties for Android with Qt 6 as:
    #  set_property(TARGET ${OUTPUT_NAME} APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
    #         ${CMAKE_CURRENT_SOURCE_DIR}/android)
    # For more information, see https://doc.qt.io/qt-6/qt-add-executable.html#target-creation
  else()
    if(ANDROID)
      add_library(${OUTPUT_NAME} SHARED ${${PROJECT_NAME}_SOURCES})
      # Define properties for Android with Qt 5 after find_package() calls as:
      #  set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
    else()
      add_executable(${OUTPUT_NAME} ${${PROJECT_NAME}_SOURCES})
    endif()

  endif()

  set_target_properties(${OUTPUT_NAME} PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.${OUTPUT_NAME}"
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
  )

  function(target_add_Qt TARGET_NAME)
    target_compile_definitions(${TARGET_NAME} PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
    target_link_libraries(${TARGET_NAME} PUBLIC Qt::Core Qt::Quick Qt::Widgets)
  endfunction()

  target_add_Qt(${OUTPUT_NAME})

#------------------------------------------------------------------------------------------------------
# Add common application (if Qt is not exists).

else()
  add_executable(${OUTPUT_NAME} ${${PROJECT_NAME}_SOURCES})
endif()

#------------------------------------------------------------------------------------------------------

target_include_directories(${OUTPUT_NAME} PUBLIC ${${PROJECT_NAME}_INCLUDES})

#------------------------------------------------------------------------------------------------------
# Compiler's safety flags.

string(TOUPPER ${CMAKE_CXX_COMPILER_ID} SFF_POSTFIX)
set(SAFETY_FLAGS_FILE "${PROJECT_SOURCE_DIR}/CMakeLists.txt_SafetyFlags_${SFF_POSTFIX}.cmake")
if(EXISTS "${SAFETY_FLAGS_FILE}")
  include("${SAFETY_FLAGS_FILE}")
endif()

message("SAFETY_FLAGS_FILE: ${SAFETY_FLAGS_FILE}")
message("SAFETY_FLAGS: ${SAFETY_FLAGS}")

target_compile_options(${OUTPUT_NAME} PRIVATE ${SAFETY_FLAGS})

#------------------------------------------------------------------------------------------------------
# Add VCRuntime libs if needed.

if(MSVC)
  set(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP true)
  include(InstallRequiredSystemLibraries)
  file(COPY ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS} DESTINATION .)
endif()

#------------------------------------------------------------------------------------------------------
# Add Boost if it possible.
#  https://cmake.org/cmake/help/latest/module/FindBoost.html#hints
#  https://doc.qt.io/qtcreator/creator-build-settings-cmake.html

function(target_add_boost TARGET_NAME)
  find_package(Boost REQUIRED COMPONENTS ALL CONFIG)
  if(Boost_FOUND)
    message("Boost version is " ${Boost_VERSION})
    target_link_libraries(${TARGET_NAME} PUBLIC Boost::boost)
    if(WIN32)
      target_link_libraries(${TARGET_NAME} PUBLIC ws2_32)
    else()
      target_link_libraries(${TARGET_NAME} PUBLIC pthread)
    endif()
  endif()
endfunction()

target_add_boost(${OUTPUT_NAME})

#------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------
# ATTACH EXTERNAL LIBRARIES

set(EXT_LIBS_FILE "${PROJECT_SOURCE_DIR}/CMakeLists.txt_Libs.cmake")
if(EXISTS "${EXT_LIBS_FILE}")
  include("${EXT_LIBS_FILE}")
endif()

#------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------
# ADD TESTS

target_add_tests_from_folder(${OUTPUT_NAME} "test")

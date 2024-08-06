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

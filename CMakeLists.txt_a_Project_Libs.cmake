# ATTACH EXTERNAL LIBRARIES BELOW...

add_subdirectory("lib/somelib")
target_link_libraries(${OUTPUT_NAME} PUBLIC "somelib")

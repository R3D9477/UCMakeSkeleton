#------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------
# Add Qt application (if possible).

if(NOT IGNORE_Qt)

    # Comment the line below if you're using QtCreator, but Qt is no needed
    find_package(QT NAMES Qt6 Qt5 COMPONENTS Core Quick REQUIRED)

    if(QT_FOUND)
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
        set(QT_APP_ADDED TRUE)

    endif()
    
endif()

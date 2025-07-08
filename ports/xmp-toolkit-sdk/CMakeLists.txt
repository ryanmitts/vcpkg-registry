cmake_minimum_required(VERSION 3.16)
project(XMPToolkitSDK LANGUAGES CXX)

if(NOT DEFINED SOURCE_PATH)
    message(FATAL_ERROR "SOURCE_PATH must be defined")
endif()

# Platform defines
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(XMP_PLATFORM_DEFS
        -DWIN_ENV -DWIN64 -D_WIN64=1
        -DNOMINMAX -DUNICODE -D_UNICODE
    )
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(XMP_PLATFORM_DEFS -DMAC_ENV)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(XMP_PLATFORM_DEFS -DUNIX_ENV)
else()
    message(FATAL_ERROR "Unsupported platform: ${CMAKE_SYSTEM_NAME}")
endif()

# Include directories
include_directories(
    "${SOURCE_PATH}"
    "${SOURCE_PATH}/public/include"
    "${SOURCE_PATH}/public/include/client-glue"
    "${SOURCE_PATH}/XMPCore"
    "${SOURCE_PATH}/XMPCore/Interfaces"
    "${SOURCE_PATH}/XMPFiles"
    "${SOURCE_PATH}/XMPFiles/source"
    "${SOURCE_PATH}/XMPFiles/source/FormatSupport"
    "${SOURCE_PATH}/XMPFiles/source/PluginHandler"
    "${SOURCE_PATH}/XMPCommon"
    "${SOURCE_PATH}/XMPCommon/Utilities"
    "${SOURCE_PATH}/XMPCommon/Interfaces"
    "${SOURCE_PATH}/XMPCommon/ImplHeaders"
    "${SOURCE_PATH}/third-party/zuid/interfaces"
    "${SOURCE_PATH}/XMPFilesPlugins/api/source"
)

# Platform-specific includes
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    include_directories("${SOURCE_PATH}/XMPCore/resource/win")
    include_directories("${SOURCE_PATH}/XMPFiles/resource/win")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    include_directories("${SOURCE_PATH}/XMPCore/resource/linux")
    include_directories("${SOURCE_PATH}/XMPFiles/resource/linux")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    include_directories("${SOURCE_PATH}/XMPCore/resource/mac")
    include_directories("${SOURCE_PATH}/XMPFiles/resource/mac")
endif()

# XMPCommon source
file(GLOB XMPCommon_SRC "${SOURCE_PATH}/XMPCommon/source/*.cpp")

# XMPCore source
file(GLOB XMPCore_SRC "${SOURCE_PATH}/XMPCore/source/*.cpp")
list(APPEND XMPCore_SRC
    ${SOURCE_PATH}/source/UnicodeConversions.cpp
    ${SOURCE_PATH}/source/XML_Node.cpp
    ${SOURCE_PATH}/source/XMP_LibUtils.cpp
    ${SOURCE_PATH}/third-party/zuid/interfaces/MD5.cpp
)

# XMPFiles source
set(XMPFiles_SRC
    ${SOURCE_PATH}/XMPFiles/source/HandlerRegistry.cpp
    ${SOURCE_PATH}/XMPFiles/source/WXMPFiles.cpp
    ${SOURCE_PATH}/XMPFiles/source/XMPFiles.cpp
    ${SOURCE_PATH}/XMPFiles/source/XMPFiles_Impl.cpp
    ${SOURCE_PATH}/XMPFiles/source/PluginHandler/FileHandlerInstance.cpp
    ${SOURCE_PATH}/XMPFiles/source/PluginHandler/HostAPIImpl.cpp
    ${SOURCE_PATH}/XMPFiles/source/PluginHandler/Module.cpp
    ${SOURCE_PATH}/XMPFiles/source/PluginHandler/PluginManager.cpp
    ${SOURCE_PATH}/XMPFiles/source/PluginHandler/XMPAtoms.cpp
    ${SOURCE_PATH}/source/UnicodeConversions.cpp
    ${SOURCE_PATH}/source/SafeStringAPIs.cpp
    ${SOURCE_PATH}/source/PerfUtils.cpp
    ${SOURCE_PATH}/source/XIO.cpp
    ${SOURCE_PATH}/source/IOUtils.cpp
    ${SOURCE_PATH}/source/XML_Node.cpp
    ${SOURCE_PATH}/source/XMP_LibUtils.cpp
    ${SOURCE_PATH}/source/XMP_ProgressTracker.cpp
    ${SOURCE_PATH}/source/XMPFiles_IO.cpp
)

file(GLOB FILEHANDLERS_SRC "${SOURCE_PATH}/XMPFiles/source/FileHandlers/*.cpp")
file(GLOB FORMATSUPPORT_SRC "${SOURCE_PATH}/XMPFiles/source/FormatSupport/*.cpp")
file(GLOB FORMATSUPPORT_AIFF_SRC "${SOURCE_PATH}/XMPFiles/source/FormatSupport/AIFF/*.cpp")
file(GLOB FORMATSUPPORT_IFF_SRC "${SOURCE_PATH}/XMPFiles/source/FormatSupport/IFF/*.cpp")
file(GLOB FORMATSUPPORT_WAVE_SRC "${SOURCE_PATH}/XMPFiles/source/FormatSupport/WAVE/*.cpp")
file(GLOB NATIVEMETADATA_SRC "${SOURCE_PATH}/XMPFiles/source/NativeMetadataSupport/*.cpp")

list(APPEND XMPFiles_SRC
    ${FILEHANDLERS_SRC}
    ${FORMATSUPPORT_SRC}
    ${FORMATSUPPORT_AIFF_SRC}
    ${FORMATSUPPORT_IFF_SRC}
    ${FORMATSUPPORT_WAVE_SRC}
    ${NATIVEMETADATA_SRC}
)

# Platform-specific source
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    list(APPEND XMPFiles_SRC
        ${SOURCE_PATH}/XMPFiles/source/PluginHandler/OS_Utils_WIN.cpp
        ${SOURCE_PATH}/source/Host_IO-Win.cpp
    )
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    list(APPEND XMPFiles_SRC
        ${SOURCE_PATH}/XMPFiles/source/PluginHandler/OS_Utils_Linux.cpp
        ${SOURCE_PATH}/source/Host_IO-POSIX.cpp
    )
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    list(APPEND XMPFiles_SRC
        ${SOURCE_PATH}/XMPFiles/source/PluginHandler/OS_Utils_Mac.cpp
        ${SOURCE_PATH}/source/Host_IO-POSIX.cpp
    )
endif()

# Dependencies
find_package(ZLIB REQUIRED)
find_package(expat CONFIG REQUIRED)

# Build targets
add_library(XMPCoreStatic STATIC ${XMPCore_SRC} ${XMPCommon_SRC})
add_library(XMPFilesStatic STATIC ${XMPFiles_SRC})

target_link_libraries(XMPCoreStatic PRIVATE expat::expat ZLIB::ZLIB)
target_link_libraries(XMPFilesStatic PRIVATE XMPCoreStatic ZLIB::ZLIB)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    target_link_libraries(XMPCoreStatic PRIVATE rpcrt4 ole32)
    target_link_libraries(XMPFilesStatic PRIVATE rpcrt4 ole32)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    find_library(COREFOUNDATION_FRAMEWORK CoreFoundation)
    find_library(CORESERVICES_FRAMEWORK CoreServices)
    target_link_libraries(XMPCoreStatic PRIVATE ${COREFOUNDATION_FRAMEWORK} ${CORESERVICES_FRAMEWORK})
    target_link_libraries(XMPFilesStatic PRIVATE ${COREFOUNDATION_FRAMEWORK} ${CORESERVICES_FRAMEWORK})
endif()

# Definitions
target_compile_definitions(XMPCoreStatic PRIVATE 
    XML_GE=0 
    BUILDING_XMPCORE_LIB=1 
    BUILDING_XMPCORE_AS_STATIC=1
    XMP_COMPONENT_INT_NAMESPACE=AdobeXMPCore_Int
    XMP_INCLUDE_XMPFILES=1
    ${XMP_PLATFORM_DEFS}
)
target_compile_definitions(XMPFilesStatic PRIVATE 
    XML_GE=0 
    BUILDING_XMPFILES_LIB=1 
    BUILDING_XMPFILES_AS_STATIC=1
    XMP_COMPONENT_INT_NAMESPACE=AdobeXMPFiles_Int
    XMP_INCLUDE_XMPFILES=1
    ${XMP_PLATFORM_DEFS}
)

# Output names
set_target_properties(XMPCoreStatic PROPERTIES OUTPUT_NAME "XMPCoreStatic")
set_target_properties(XMPFilesStatic PROPERTIES OUTPUT_NAME "XMPFilesStatic")

# Installation for vcpkg layout
install(DIRECTORY "${SOURCE_PATH}/public/include/"
        DESTINATION include
        FILES_MATCHING PATTERN "*.hpp" PATTERN "*.h" PATTERN "*.incl_cpp")

install(TARGETS XMPCoreStatic XMPFilesStatic
        EXPORT XMPToolkitSDKTargets
        ARCHIVE DESTINATION lib)

# Config and export files for find_package support
include(CMakePackageConfigHelpers)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/XMPToolkitSDK-config-version.cmake"
    VERSION 1.0.0
    COMPATIBILITY SameMajorVersion
)

configure_package_config_file(
    "${CMAKE_CURRENT_LIST_DIR}/XMPToolkitSDK-config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/XMPToolkitSDK-config.cmake"
    INSTALL_DESTINATION lib/cmake/XMPToolkitSDK
    NO_SET_AND_CHECK_MACRO
    NO_CHECK_REQUIRED_COMPONENTS_MACRO
)

install(EXPORT XMPToolkitSDKTargets
    FILE XMPToolkitSDK-targets.cmake
    NAMESPACE XMPToolkitSDK::
    DESTINATION lib/cmake/XMPToolkitSDK
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/XMPToolkitSDK-config.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/XMPToolkitSDK-config-version.cmake"
    DESTINATION lib/cmake/XMPToolkitSDK
)

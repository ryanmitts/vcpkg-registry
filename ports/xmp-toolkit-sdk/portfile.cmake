vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO adobe/XMP-Toolkit-SDK
    REF "v2025.03"
    SHA512 b2282b53b954b3e0b173733c80f3e5580cc7ee7a0b54117516dc396d538c33837dc359385773ddd639bf70a7497e1d625de3b93b5b80ef189ff894a2dcba7763
    HEAD_REF main
)

# Patch includes to use system zlib/expat instead of bundled ones
file(GLOB_RECURSE XMP_SOURCE_FILES
    "${SOURCE_PATH}/XMPCore/*.cpp"
    "${SOURCE_PATH}/XMPCore/*.hpp"
    "${SOURCE_PATH}/XMPFiles/*.cpp"
    "${SOURCE_PATH}/XMPFiles/*.hpp"
    "${SOURCE_PATH}/XMPCommon/*.cpp"
    "${SOURCE_PATH}/XMPCommon/*.hpp"
)

foreach(file IN LISTS XMP_SOURCE_FILES)
    file(READ "${file}" file_content)
    string(REPLACE "#include \"third-party/expat/lib/expat.h\"" "#include <expat.h>" file_content "${file_content}")
    string(REPLACE "#include \"third-party/zlib/zlib.h\""       "#include <zlib.h>"   file_content "${file_content}")
    string(REPLACE "#include \"third-party/zlib/deflate.h\""    "#include <deflate.h>" file_content "${file_content}")
    string(REPLACE "#include \"third-party/zlib/inflate.h\""    "#include <inflate.h>" file_content "${file_content}")
    string(REPLACE "#include \"third-party/zlib/zutil.h\""      "#include <zutil.h>"   file_content "${file_content}")
    file(WRITE "${file}" "${file_content}")
endforeach()

file(REMOVE_RECURSE "${SOURCE_PATH}/third-party/zlib")
file(REMOVE_RECURSE "${SOURCE_PATH}/third-party/expat")

# Configure with external CMakeLists in the overlay
vcpkg_cmake_configure(
    SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}"
    OPTIONS -DSOURCE_PATH="${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME XMPToolkitSDK
    CONFIG_PATH lib/cmake/XMPToolkitSDK
)

# Install usage and copyright info
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

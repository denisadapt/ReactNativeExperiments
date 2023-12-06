cmake_minimum_required(VERSION 3.4.1)

add_library( mylibrary
        SHARED
        ../mylib/mylibrary.cpp
        ../mylib/MyLibraryWrapper.cpp)

find_library( log-lib
        log )

target_link_libraries( mylibrary
        ${log-lib} )
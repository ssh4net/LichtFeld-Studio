# SPDX-FileCopyrightText: 2026 LichtFeld Studio Authors
#
# SPDX-License-Identifier: GPL-3.0-or-later

include_guard(GLOBAL)

set(ARGS_SOURCE_DIR "" CACHE PATH "Path to a taywee/args checkout or install tree containing args.hxx")

function(lfs_setup_args)
    find_package(args CONFIG QUIET)
    if(TARGET taywee::args)
        return()
    endif()

    if(TARGET args::args)
        add_library(taywee::args INTERFACE IMPORTED)
        set_target_properties(taywee::args PROPERTIES INTERFACE_LINK_LIBRARIES args::args)
        return()
    endif()

    if(TARGET args)
        add_library(taywee::args INTERFACE IMPORTED)
        set_target_properties(taywee::args PROPERTIES INTERFACE_LINK_LIBRARIES args)
        return()
    endif()

    find_path(ARGS_INCLUDE_DIR
        NAMES args.hxx
        HINTS "${ARGS_SOURCE_DIR}"
        PATH_SUFFIXES . include args include/args
        DOC "Directory containing args.hxx")

    if(NOT ARGS_INCLUDE_DIR)
        message(FATAL_ERROR
            "Could not find taywee/args. Provide an args CMake package, set "
            "ARGS_SOURCE_DIR to the taywee/args checkout or install tree, or "
            "add that checkout/root parent to CMAKE_PREFIX_PATH.")
    endif()

    add_library(lfs_args INTERFACE)
    add_library(taywee::args ALIAS lfs_args)
    target_include_directories(lfs_args INTERFACE "${ARGS_INCLUDE_DIR}")

    message(STATUS "Using taywee/args headers from: ${ARGS_INCLUDE_DIR}")
endfunction()

# SPDX-FileCopyrightText: 2026 LichtFeld Studio Authors
#
# SPDX-License-Identifier: GPL-3.0-or-later

include_guard(GLOBAL)

set(IMPLOT_SOURCE_DIR "" CACHE PATH "Path to an ImPlot source checkout containing implot.h and implot.cpp")

function(lfs_setup_implot)
    find_package(implot CONFIG QUIET)
    if(TARGET implot::implot)
        return()
    endif()

    if(TARGET implot)
        add_library(implot::implot INTERFACE IMPORTED)
        set_target_properties(implot::implot PROPERTIES INTERFACE_LINK_LIBRARIES implot)
        return()
    endif()

    set(_implot_roots)
    if(IMPLOT_SOURCE_DIR)
        list(APPEND _implot_roots "${IMPLOT_SOURCE_DIR}")
    endif()

    foreach(_prefix IN LISTS CMAKE_PREFIX_PATH)
        list(APPEND _implot_roots
            "${_prefix}"
            "${_prefix}/implot"
            "${_prefix}/ImPlot"
            "${_prefix}/include"
            "${_prefix}/include/implot")
    endforeach()

    set(_implot_root "")
    foreach(_candidate IN LISTS _implot_roots)
        if(EXISTS "${_candidate}/implot.h" AND EXISTS "${_candidate}/implot.cpp")
            set(_implot_root "${_candidate}")
            break()
        endif()
    endforeach()

    if(NOT _implot_root)
        message(FATAL_ERROR
            "Could not find ImPlot. Provide an implot CMake package, set "
            "IMPLOT_SOURCE_DIR to the ImPlot source checkout, or add that "
            "checkout/root parent to CMAKE_PREFIX_PATH.")
    endif()

    set(_implot_sources
        "${_implot_root}/implot.cpp"
        "${_implot_root}/implot_items.cpp")

    add_library(lfs_implot STATIC ${_implot_sources})
    add_library(implot::implot ALIAS lfs_implot)
    target_include_directories(lfs_implot PUBLIC "${_implot_root}")
    target_link_libraries(lfs_implot PUBLIC imgui::imgui)

    message(STATUS "Using ImPlot source checkout: ${_implot_root}")
endfunction()

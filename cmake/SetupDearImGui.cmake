# SPDX-FileCopyrightText: 2026 LichtFeld Studio Authors
#
# SPDX-License-Identifier: GPL-3.0-or-later

include_guard(GLOBAL)

set(IMGUI_SOURCE_DIR "" CACHE PATH "Path to a Dear ImGui source checkout containing imgui.h and imgui.cpp")

function(lfs_setup_dear_imgui)
    find_package(imgui CONFIG QUIET)
    if(TARGET imgui::imgui)
        return()
    endif()

    if(TARGET imgui)
        add_library(imgui::imgui INTERFACE IMPORTED)
        set_target_properties(imgui::imgui PROPERTIES INTERFACE_LINK_LIBRARIES imgui)
        return()
    endif()

    set(_imgui_roots)
    if(IMGUI_SOURCE_DIR)
        list(APPEND _imgui_roots "${IMGUI_SOURCE_DIR}")
    endif()

    foreach(_prefix IN LISTS CMAKE_PREFIX_PATH)
        list(APPEND _imgui_roots
            "${_prefix}"
            "${_prefix}/imgui"
            "${_prefix}/DearImGui"
            "${_prefix}/dear-imgui"
            "${_prefix}/include"
            "${_prefix}/include/imgui")
    endforeach()

    set(_imgui_root "")
    foreach(_candidate IN LISTS _imgui_roots)
        if(EXISTS "${_candidate}/imgui.h" AND EXISTS "${_candidate}/imgui.cpp")
            set(_imgui_root "${_candidate}")
            break()
        endif()
    endforeach()

    if(NOT _imgui_root)
        message(FATAL_ERROR
            "Could not find Dear ImGui. Provide an imgui CMake package, set "
            "IMGUI_SOURCE_DIR to the official Dear ImGui source checkout, or add "
            "that checkout/root parent to CMAKE_PREFIX_PATH.")
    endif()

    set(_imgui_sources
        "${_imgui_root}/imgui.cpp"
        "${_imgui_root}/imgui_draw.cpp"
        "${_imgui_root}/imgui_tables.cpp"
        "${_imgui_root}/imgui_widgets.cpp")

    if(EXISTS "${_imgui_root}/misc/cpp/imgui_stdlib.cpp")
        list(APPEND _imgui_sources "${_imgui_root}/misc/cpp/imgui_stdlib.cpp")
    endif()

    if(NOT EXISTS "${_imgui_root}/backends/imgui_impl_sdl3.cpp")
        message(FATAL_ERROR
            "Dear ImGui source at '${_imgui_root}' does not contain "
            "backends/imgui_impl_sdl3.cpp, which LichtFeld Studio requires.")
    endif()
    list(APPEND _imgui_sources "${_imgui_root}/backends/imgui_impl_sdl3.cpp")

    add_library(lfs_imgui STATIC ${_imgui_sources})
    add_library(imgui::imgui ALIAS lfs_imgui)
    target_include_directories(lfs_imgui PUBLIC
        "${_imgui_root}"
        "${_imgui_root}/backends")
    if(EXISTS "${_imgui_root}/misc/cpp")
        target_include_directories(lfs_imgui PUBLIC "${_imgui_root}/misc/cpp")
    endif()
    target_link_libraries(lfs_imgui PUBLIC SDL3::SDL3)

    message(STATUS "Using Dear ImGui source checkout: ${_imgui_root}")
endfunction()

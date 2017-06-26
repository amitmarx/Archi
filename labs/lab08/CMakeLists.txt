cmake_minimum_required(VERSION 3.6)
project(lab08)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set(SOURCE_FILES T0/myELF.c)
add_executable(lab08 ${SOURCE_FILES})
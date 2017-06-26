cmake_minimum_required(VERSION 3.6)
project(lab09)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set(SOURCE_FILES T0/task0.c)
add_executable(lab09 ${SOURCE_FILES})
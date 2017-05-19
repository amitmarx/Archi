cmake_minimum_required(VERSION 3.6)
project(T2)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set(SOURCE_FILES main.c)
add_executable(T2 ${SOURCE_FILES})
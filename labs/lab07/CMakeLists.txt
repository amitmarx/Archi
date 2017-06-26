cmake_minimum_required(VERSION 3.6)
project(lab07)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set(SOURCE_FILES T0/hexeditplus.c)
add_executable(lab07 ${SOURCE_FILES})
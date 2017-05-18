cmake_minimum_required(VERSION 3.6)
project(testClion)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set(SOURCE_FILES myshell.c LineParser.c LineParser.h JobControl.c JobControl.h)
add_executable(testClion ${SOURCE_FILES})
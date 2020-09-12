cmake_minimum_required(VERSION 3.0.0)

project(example)

set(ANTLR_JAR_LOCATION "${PROJECT_SOURCE_DIR}/antlr_480_jar/antlr-4.8-complete.jar")
set(ANTLR4CPP_ROOT "${PROJECT_SOURCE_DIR}/antlr_480_cpp")

include(${PROJECT_SOURCE_DIR}/cmake/antlr4cpp_generator.cmake)
generate_antlr_cpp_parser(JSON "${PROJECT_SOURCE_DIR}/json_grammer" "${PROJECT_SOURCE_DIR}/JSON/json_cpp_parser" "example_parser" False True True True)
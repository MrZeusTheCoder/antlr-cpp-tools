# Highly inspired by HDLConvertor's Antlr4 C++ Parser generator. https://github.com/Nic30/hdlConvertor
# Thank you, Nic30!

# Copyright (c) 2020 Elijah Hopp
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

find_package(Java COMPONENTS Runtime)
include(UseJava)

##############################################################################################
# antlr4 settings
##############################################################################################
if(NOT DEFINED ANTLR_JAR_LOCATION)
	message(FATAL_ERROR "Please define a path to the ANTLR jar in the CMake variable \"ANTLR_JAR_LOCATION\"")
endif()

if(NOT EXISTS ${ANTLR_JAR_LOCATION})
	message(FATAL_ERROR "It appears that the ANTLR jar file specified to be at \"${ANTLR_JAR_LOCATION}\" does not exist.")
endif()

if(NOT DEFINED ANTLR4CPP_ROOT)
	message(FATAL_ERROR "Please define the CMake variable \"ANTLR4CPP_ROOT\"")
endif()

find_path(ANTLR4CPP_INCLUDE_DIRS antlr4-runtime.h
	HINTS "${ANTLR4CPP_ROOT}/usr/include/antlr4-runtime/"
		"${ANTLR4CPP_ROOT}/include/antlr4-runtime/"
	PATH_SUFFIXES antlr4-runtime)

if(NOT ANTLR4CPP_INCLUDE_DIRS)
	message(FATAL_ERROR "Cannot find the ANTLR4 C++ Runtime include directory in the root \"${ANTLR4CPP_ROOT}\"")
endif()

message(STATUS "Found ANTLR C++ Runtime include directory at \"${ANTLR4CPP_INCLUDE_DIRS}\"")
include_directories(${ANTLR4CPP_INCLUDE_DIRS})

# [todo] rather explicitly specify static/dynamic antlr linking
find_library(ANTLR4CPP_LIBRARIES 
	libantlr4-runtime.dll libantlr4-runtime.so
	libantlr4-runtime.a libantlr4-runtime.dylib
	antlr4-runtime-static.lib
	HINTS "${ANTLR4CPP_ROOT}/usr/lib"
	      "${ANTLR4CPP_ROOT}/lib")

if(NOT ANTLR4CPP_LIBRARIES)
	message(FATAL_ERROR "Cannot find ANTLR C++ Runtime libraries in the root \"${ANTLR4CPP_ROOT}\"")
else()
	message(STATUS "Found ANTLR C++ Runtime libraries at \"${ANTLR4CPP_LIBRARIES}\"")
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
	add_compile_definitions(ANTLR4CPP_STATIC)
endif()

##############################################################################################
# antlr4 utils
##############################################################################################
if(NOT ANTLR_GRAMMAR_ROOT)
	message(FATAL_ERROR "Please specify the root directory where your ANTLR4 grammer files are in the CMake variable \"ANTLR_GRAMMAR_ROOT\"")
endif()


# @param name The name of the parser grammar and parser itself.
# @param grammer_folder The name of folder where grammer is stored.
# @param parser_output_folder The *exact* folder where the generated C++ parser include files are placed.
# @param lexer_parser_separate if ON the ${name}Lexer.g4 ${name}Parser.g4 is used otherwise just ${name}.g4
# @param generate_listener Wether or not to generate listener code.
# @param generate_visitor Wether or not to generate visitor code. 
# @param build_parser Wether or not to create library targets from the generated parser
macro(generate_antlr_cpp_parser name grammer_folder parser_output_folder 
								namespace lexer_parser_separate
								generate_visitor generate_listener build_parser)

	set(GENERATED_INC
		${parser_output_folder}/${name}Lexer.h
		${parser_output_folder}/${name}Parser.h
	)
	set(GENERATED_SRC
		${parser_output_folder}/${name}Lexer.cpp
		${parser_output_folder}/${name}Parser.cpp
	)	

	set(ANTLR_GEN_ARGS)
	if (${generate_visitor})
		list(APPEND ANTLR_GEN_ARGS "-visitor")
	else()
	    list(APPEND ANTLR_GEN_ARGS "-no-visitor")
	endif()
	if (${generate_listener})
		list(APPEND ANTLR_GEN_ARGS "-listener")
	else()
	 	list(APPEND ANTLR_GEN_ARGS "-no-listener")
	endif()

	#Delete generated files on clean.
	set_property(DIRECTORY PROPERTY ADDITIONAL_MAKE_CLEAN_FILES
	   "${parser_output_folder}")

	if(${lexer_parser_separate})
		set(GRAMMARS
			${grammer_folder}/${name}Lexer.g4
        	${grammer_folder}/${name}Parser.g4)
	else()
		set(GRAMMARS
			${grammer_folder}/${name}.g4)
	endif()

	execute_process(
		COMMAND
		${CMAKE_COMMAND} -E make_directory ${parser_output_folder}
		COMMAND
		"${Java_JAVA_EXECUTABLE}" -jar "${ANTLR_JAR_LOCATION}"
		-Xexact-output-dir
		-Dlanguage=Cpp ${ANTLR_GEN_ARGS} -package ${namespace}
		-o ${parser_output_folder}
		${GRAMMARS}
	)

	file(GLOB SRC
		"${parser_output_folder}/*.cpp"
	)
	
	if(CMAKE_SYSTEM_NAME MATCHES "Linux")
		#Suppress warnings on generated code.
		set_property(SOURCE ${SRC} PROPERTY
			COMPILE_FLAGS -Wno-unused-parameter)
	endif()

	if(${build_parser})
		add_library(${name}_parser_lib STATIC
			${SRC})
		target_include_directories(${name}_parser_lib PRIVATE ${parser_output_folder})

	endif()
endmacro()

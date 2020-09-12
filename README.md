# antlr-cpp-tools
Some assorted tools for use with ANTLR's C++ Target

## antlr4cpp_generator

> ¡ WARNING ! This CMake file has only been tested with ANTLR 4.8 and it's respective C++ runtime which was built from source.

antlr4cpp_generator generates parsers in a flexible way. It requires some environment variables.

**Required env variables:**
| Name | Description |
|------|-------------|
| ANTLR_JAR_LOCATION | The location of the ANTLR4 JAR file. (i.e. `antlr-4.8-complete.jar` which can be installed or downloaded) |
| ANTLR4CPP_ROOT | The location of the ANTLR4 C++ Runtime installation (i.e. `/usr/`). These can also be custom build. It tries to find the built library and the headers in here. |

It holds a macro called `generate_antlr_cpp_parser`. It takes some arguments:

| Argument (in order) | Description | Type |
|---------------------|-------------|------|
| name | The name of the parser grammar and parser itself. | Path |
| grammer_folder | The name of folder where grammer is stored. | Path |
| parser_output_folder | The *exact* folder where the generated C++ parser include files are placed. | Path | 
| lexer_parser_separate | If on `name`Lexer.g4 `name`Parser.g4 is used as the grammer files, otherwise just `name`.g4 is used. | Bool |
| generate_listener | Wether or not to generate listener code. | Bool |
| generate_visitor | Wether or not to generate visitor code.  | Bool |
| build_parser | Wether or not to create library targets from the generated parser. The name of this target is `name`_parser_lib | Bool |

An example of how to use this can be found in `antlr4cpp_gen_example`. Note that this only has binaries for Linux. It should be looking for Antlr4 on the system. This is only an example, and is kinda bloated.
cmake_minimum_required(VERSION 3.16)
project(__APP_NAME__ CXX)
add_executable(__APP_NAME__ main.cpp)
install(TARGETS __APP_NAME__ RUNTIME DESTINATION bin)

cmake_minimum_required(VERSION 3.0)
project(rssReader)

# Find the required packages
find_package(Qt5 COMPONENTS Core Quick REQUIRED)

# Add your project files
set(SOURCES
    main.cpp
    configGeneral.qml
)

# Create an executable or library target
add_executable(${PROJECT_NAME} ${SOURCES})

# Link against the required libraries
target_link_libraries(${PROJECT_NAME}
    Qt5::Core
    Qt5::Quick
)
################################################################################
# Build the Module
################################################################################

CORAL_GENERATE_MODULE( GENERATED_SOURCES qt )

INCLUDE_DIRECTORIES( ${CMAKE_CURRENT_SOURCE_DIR} ${CORAL_INCLUDE_DIRS} ${QT_INCLUDE_DIR} ${CMAKE_CURRENT_BINARY_DIR}/generated )

FILE( GLOB _SOURCE_FILES *.cpp )
FILE( GLOB _HEADER_FILES *.h )

ADD_LIBRARY( qt MODULE ${_HEADER_FILES} ${_SOURCE_FILES} ${GENERATED_SOURCES} )

CORAL_DEFAULT_TARGET_PROPERTIES( qt )
CORAL_MODULE_TARGET_PROPERTIES( qt )

TARGET_LINK_LIBRARIES( qt ${CORAL_LIBRARIES} ${QT_LIBRARIES} )

################################################################################
# Source Groups
################################################################################

SOURCE_GROUP( "@Generated" FILES ${GENERATED_SOURCES} )


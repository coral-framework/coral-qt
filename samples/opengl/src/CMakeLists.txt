################################################################################
# Build the Module
################################################################################

SET( CORAL_PATH ${CMAKE_SOURCE_DIR}/samples ${CORAL_PATH} )

CORAL_GENERATE_MODULE( _MODULE_SOURCES opengl )

INCLUDE_DIRECTORIES( ${CMAKE_CURRENT_SOURCE_DIR} ${CORAL_INCLUDE_DIRS} ${CMAKE_CURRENT_BINARY_DIR}/generated )

FILE( GLOB _SOURCE_FILES *.cpp )
FILE( GLOB _HEADER_FILES *.h )

ADD_LIBRARY( opengl MODULE ${_HEADER_FILES} ${_SOURCE_FILES} ${_MODULE_SOURCES} ${_MOC_SOURCES} )

CORAL_DEFAULT_TARGET_PROPERTIES( opengl )
CORAL_MODULE_TARGET_PROPERTIES( opengl )

TARGET_LINK_LIBRARIES( opengl ${CORAL_LIBRARIES} ${OPENGL_gl_LIBRARY} ${OPENGL_glu_LIBRARY} )

SET_TARGET_PROPERTIES( opengl PROPERTIES PROJECT_LABEL "OpenGL sample module" )

################################################################################
# Source Groups
################################################################################

SOURCE_GROUP( "@Generated" FILES ${_MODULE_SOURCES} )

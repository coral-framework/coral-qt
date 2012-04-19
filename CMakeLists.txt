################################################################################
# Coral Qt Module
################################################################################

CMAKE_MINIMUM_REQUIRED( VERSION 2.6 )

PROJECT( CORAL_QT )

################################################################################
# Setup Qt
################################################################################

SET( QT_MIN_VERSION "4.7.0" ) # minimum Qt version required
FIND_PACKAGE( Qt4 ${QT_MIN_VERSION} REQUIRED )
SET( QT_USE_QTUITOOLS 1 )
SET( QT_USE_QTOPENGL  1 )
INCLUDE( ${QT_USE_FILE} )

################################################################################
# Setup Coral
################################################################################

# Load Coral's CMake package
file( TO_CMAKE_PATH "$ENV{CORAL_ROOT}" CORAL_ROOT_ENV )
set( CMAKE_MODULE_PATH "${CORAL_ROOT}/cmake" "${CORAL_ROOT_ENV}/cmake" ${CMAKE_MODULE_PATH} )
find_package( Coral REQUIRED )

SET( CORAL_PATH
	"${CMAKE_BINARY_DIR}/modules"
	"${CMAKE_SOURCE_DIR}/modules"
	${CORAL_PATH}
)

################################################################################
# Installation
################################################################################

# install shared library
INSTALL( DIRECTORY ${CMAKE_BINARY_DIR}/modules/qt DESTINATION modules )

# install CSL files
INSTALL( DIRECTORY ${CMAKE_SOURCE_DIR}/modules/ DESTINATION modules )

################################################################################
# Packaging
################################################################################

SET( CPACK_PACKAGE_NAME					"coral-qt" )
SET( CPACK_PACKAGE_VERSION_MAJOR		"0" )
SET( CPACK_PACKAGE_VERSION_MINOR		"5" )
SET( CPACK_PACKAGE_VERSION_PATCH		"2" )
SET( CPACK_PACKAGE_DESCRIPTION_SUMMARY	"A module for integrating [Qt](http://qt.nokia.com/) into Coral" )

INCLUDE( CPack )

################################################################################
# Subdirectories
################################################################################

ADD_SUBDIRECTORY( src )
ADD_SUBDIRECTORY( samples/opengl/src )

ENABLE_TESTING()
ADD_SUBDIRECTORY( tests )

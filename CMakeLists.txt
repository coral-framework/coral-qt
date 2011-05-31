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

# Resolve the CORAL_ROOT
FILE( TO_CMAKE_PATH "$ENV{CORAL_ROOT}" CORAL_ROOT )

# Add Coral's CMake dir to the CMAKE_MODULE_PATH
SET( CMAKE_MODULE_PATH ${CORAL_ROOT}/cmake ${CMAKE_MODULE_PATH} )

# Load Coral's CMake package
FIND_PACKAGE( Coral REQUIRED )

# Configure the coral path
SET( CORAL_PATH
	"${CORAL_ROOT}/modules"
	"${CMAKE_BINARY_DIR}/modules"
	"${CMAKE_SOURCE_DIR}/modules"
)

################################################################################
# Global Coral-Qt Settings
################################################################################

# The official Coral Version
SET( CORAL_VERSION_MAJOR	"0" )
SET( CORAL_VERSION_MINOR	"5" )
SET( CORAL_VERSION_PATCH	"2" )
SET( CORAL_VERSION "${CORAL_VERSION_MAJOR}.${CORAL_VERSION_MINOR}.${CORAL_VERSION_PATCH}" )

################################################################################
# Installation
################################################################################

# enforce a safe default CMAKE_INSTALL_PREFIX
IF( NOT CMAKE_INSTALL_PREFIX MATCHES "coral-qt" )
	SET( CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}/coral-qt" )
ENDIF()

# install shared library
INSTALL( DIRECTORY ${CMAKE_BINARY_DIR}/modules/qt DESTINATION modules )

# install CSL files
INSTALL( DIRECTORY ${CMAKE_SOURCE_DIR}/modules/ DESTINATION modules )

################################################################################
# Packaging
################################################################################
SET( CPACK_PACKAGE_NAME					"coral-qt" )
SET( CPACK_PACKAGE_VERSION_MAJOR		"${CORAL_VERSION_MAJOR}" )
SET( CPACK_PACKAGE_VERSION_MINOR		"${CORAL_VERSION_MINOR}" )
SET( CPACK_PACKAGE_VERSION_PATCH		"${CORAL_VERSION_PATCH}" )
SET( CPACK_PACKAGE_DESCRIPTION_SUMMARY	"A module for integrating [Qt](http://qt.nokia.com/) into Coral" )

IF( WIN32 )
	SET( CPACK_GENERATOR "ZIP" )
ELSE()
	SET( CPACK_GENERATOR "TBZ2" )
ENDIF()

INCLUDE( CPack )

################################################################################
# Subdirectories
################################################################################

ADD_SUBDIRECTORY( src )
ADD_SUBDIRECTORY( samples/opengl/src )

ENABLE_TESTING()
ADD_SUBDIRECTORY( tests )

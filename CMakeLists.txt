################################################################################
# Coral Qt Module
################################################################################

CMAKE_MINIMUM_REQUIRED( VERSION 2.6 )

PROJECT( CORAL_QT )

################################################################################
# Setup Coral
################################################################################

# Add Coral's cmake dir to the CMAKE_MODULE_PATH
FILE( TO_CMAKE_PATH "$ENV{CORAL_ROOT}" CORAL_ROOT )

SET( CMAKE_MODULE_PATH ${CORAL_ROOT}/cmake ${CMAKE_MODULE_PATH} )

FIND_PACKAGE( Coral REQUIRED )

# Request Qt4 support for this project
SET( QT_MIN_VERSION "4.6.0" ) # minimum Qt version required
FIND_PACKAGE( Qt4 ${QT_MIN_VERSION} REQUIRED )
SET( QT_USE_QTUITOOLS 1 )
INCLUDE( ${QT_USE_FILE} )

# Configure the coral path
SET( CORAL_PATH
	"${CORAL_ROOT}/modules"
	"${CMAKE_BINARY_DIR}/modules"
	"${CMAKE_SOURCE_DIR}/modules"
)

################################################################################
# Subdirectories
################################################################################

ADD_SUBDIRECTORY( src )

ENABLE_TESTING()
ADD_SUBDIRECTORY( tests )

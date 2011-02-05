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
# Subdirectories
################################################################################

ADD_SUBDIRECTORY( src )
ADD_SUBDIRECTORY( samples/opengl/src )

ENABLE_TESTING()
ADD_SUBDIRECTORY( tests )

################################################################################
# Build the Module
################################################################################

CORAL_GENERATE_MODULE( _GENERATED_FILES qt )

INCLUDE_DIRECTORIES( ${CMAKE_CURRENT_SOURCE_DIR} ${CORAL_INCLUDE_DIRS} ${QT_INCLUDE_DIR} ${CMAKE_CURRENT_BINARY_DIR}/generated )

FILE( GLOB _SOURCE_FILES *.cpp )
FILE( GLOB _HEADER_FILES *.h )

SET( _MOC_HEADERS
	${CMAKE_CURRENT_SOURCE_DIR}/EventHub.h
	${CMAKE_CURRENT_SOURCE_DIR}/GLWidget.h
	${CMAKE_CURRENT_SOURCE_DIR}/AbstractItemModel.h
	${CMAKE_CURRENT_SOURCE_DIR}/TimerCallbackNotifier.h	
)

# Generate moc_*.cpp files from mocable headers
QT4_WRAP_CPP( _MOC_SOURCES ${_MOC_HEADERS} )

ADD_LIBRARY( qt MODULE ${_HEADER_FILES} ${_SOURCE_FILES} ${_GENERATED_FILES} ${_MOC_SOURCES} )

CORAL_TARGET( qt )
CORAL_MODULE_TARGET( "qt" qt )

TARGET_LINK_LIBRARIES( qt ${CORAL_LIBRARIES} ${QT_LIBRARIES} )

################################################################################
# Source Groups
################################################################################

SOURCE_GROUP( "@Generated" FILES ${_GENERATED_FILES} ${_MOC_SOURCES} )

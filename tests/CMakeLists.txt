################################################################################
# Run the test scripts with CTest
################################################################################

SET( CORAL_PATH ${CORAL_PATH} ${CMAKE_CURRENT_SOURCE_DIR} )
CORAL_GET_PATH_STRING( coralPathStr )

ADD_TEST( tests COMMAND ${CORAL_LAUNCHER} -p ${coralPathStr} lua.Launcher test ${CMAKE_CURRENT_SOURCE_DIR}/TestWindow.ui )

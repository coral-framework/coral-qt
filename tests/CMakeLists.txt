################################################################################
# Run the test scripts with CTest
################################################################################

CORAL_GET_PATH_STRING( coralPathStr )

ADD_TEST( tests COMMAND cd ${CMAKE_SOURCE_DIR}/tests && ${CORAL_LAUNCHER} -p ${coralPathStr} lua.Launcher test )


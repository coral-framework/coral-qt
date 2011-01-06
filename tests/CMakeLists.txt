################################################################################
# Run the test scripts with CTest
################################################################################

SET( CORAL_PATH ${CORAL_PATH} ${CORAL_QT_SOURCE_DIR} )
CORAL_GET_PATH_STRING( coralPathStr )

ADD_TEST(
	NAME tests
	COMMAND ${CORAL_LAUNCHER} -p ${coralPathStr} lua.Launcher testkit.ModuleLauncher tests -o ./output/unittests.xml
)

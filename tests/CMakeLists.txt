################################################################################
# Run the test scripts with CTest
################################################################################

# Adds the tests resources to the Coral Path, so it can be found while running
# the modules tests
SET( CORAL_PATH ${CORAL_PATH} ${CORAL_QT_SOURCE_DIR}/tests/test_resources )

CORAL_GET_PATH_STRING( coralPathStr )

ADD_TEST(
	NAME tests
	COMMAND ${CORAL_LAUNCHER} --mode $<CONFIGURATION> -p ${coralPathStr}
		lua.Launcher testkit.TestRunner ${CORAL_QT_SOURCE_DIR}/tests -o output/unitTests.xml
)

################################################################################
# Run the test scripts with CTest
################################################################################

CORAL_GET_PATH_STRING( coralPathStr )

ADD_TEST(
	NAME tests
	COMMAND ${CORAL_LAUNCHER} --mode $<CONFIGURATION> -p "${coralPathStr},${CORAL_QT_SOURCE_DIR}/tests/resources"
		lua.Launcher testkit.TestRunner ${CORAL_QT_SOURCE_DIR}/tests -o output/UnitTests.xml
)

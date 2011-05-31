################################################################################
# Run the test scripts with CTest
################################################################################

ADD_TEST(
	NAME tests
	COMMAND ${CORAL_LAUNCHER} --mode $<CONFIGURATION> -p ${CORAL_QT_SOURCE_DIR}/tests/resources
		lua.Launcher testkit.TestRunner ${CORAL_QT_SOURCE_DIR}/tests -o output/UnitTests.xml
)

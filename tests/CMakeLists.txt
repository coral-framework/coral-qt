################################################################################
# Run the test scripts with CTest
################################################################################

SET( CORAL_PATH ${CORAL_PATH} ${CORAL_QT_SOURCE_DIR} )
CORAL_GET_PATH_STRING( coralPathStr )

MESSAGE( ">>>>>" ${coralPathStr} )

ADD_TEST(
	NAME tests
	COMMAND ${CORAL_LAUNCHER} --mode $<CONFIGURATION> -p ${coralPathStr}
		lua.Launcher testkit.TestRunner tests -o output/unitTests.xml
)

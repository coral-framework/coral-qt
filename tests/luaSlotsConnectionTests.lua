require "testkit.unitTests"
local lfs = require "lfs"
local qt = require "qt"
local path = require "path"

--TODO: Find a good place for this function
-------------------------------------------------------------------------------
-- Converts a module name and a module filename into a string representing the 
-- absolute file path  file inside module's folder. It does not checks whether 
-- the file actually exists inside corresponding module folder.
-------------------------------------------------------------------------------
local function findModuleFile( moduleName, moduleFilename )
	-- Initializes commmon paths
	local moduleDirPath = moduleName:gsub( '%.', '/' )
	local coralPaths = co.getPaths()

	-- For each repository
	for i, repositoryDir in ipairs( coralPaths ) do
		local moduleDir = repositoryDir .. '/' .. moduleDirPath
		if path.isDir( moduleDir ) then
			return moduleDir .. '/' .. moduleFilename
		end
	end

	error( "cannot find folder path for module '" .. moduleName .. "'" )
end

local file = findModuleFile( "tests", "TestWindow.ui" ) 

local mockState = false
local function slotCheckedMock( checked )
	mockState = checked
end

function singleLuaFunctionCouldBeUsedAsASlotTest()
	local w = qt.loadUi( file )
	w.checkBox:connect( "toggled(bool)", slotCheckedMock )
	assertTrue( not w.checkBox.checked, "The checkbox was initialized to checked" )

	w.checkBox.checked = true

	assertTrue( mockState, "The mockState variable was not changed to the checkbox value" )
end

function multipleLuaFunctionCouldBeUsedAsSlotsTest()
	local w = qt.loadUi( file )
	local hits = 0
	w.txtInput:connect( "textChanged()", function() hits = hits + 1 end )
	w.txtInput:connect( "textChanged()", function() hits = hits + 2 end )

	w.txtInput.plainText = "changing text"

	assertEquals( hits, 3, "2 slots where connected to a signal but they where not both signaled." )
end


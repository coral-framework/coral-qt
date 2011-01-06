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
	print ("Finding in module ", moduleName )
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

function aWindowShouldBeInvisibleWhenLoaded()
	local widget = qt.loadUi( file )
	assertTrue( not widget.visible, "widget visible when opened" )
end


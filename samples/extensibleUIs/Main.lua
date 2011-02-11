local qt = require "qt"

local M = {}
M.pluginList = {}

-- configure search paths
qt.setSearchPaths( "coral", co.getPaths() )

-- Locate all lua scripts file in plugins folder and require
-- them, saving all in global plugin list table
local function requirePlugins( dir )
	for filename in lfs.dir( dir ) do
		if filename ~= "." and filename ~= ".." and not path.isDir( dir .. '/' .. filename ) then
			local pluginFile = filename:match( "(.+)%.lua$" )
			if pluginFile then 
				local ok, plugin = pcall( require, pluginFile )
				if ok then
					table.insert( M.pluginList, plugin )
				else
					error( plugin )
				end
			end
		end
	end	
end

-- loads main form
M.mainWindow = qt.loadUi( "coral:/extensibleUIs/ExtensibleUIs.ui" )
M.mainWindow.visible = true

qt.exec()


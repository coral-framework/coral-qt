local qt = require "qt"
local lfs = require "lfs"
local path = require "path"

-- loads main form
-- configure search paths
qt.setSearchPaths( "coral", co.getPaths() )

local M = {}
M.pluginList = {}

local icons =
{
	load = qt.Icon( "coral:/extensibleUIs/icons/load.png" ),
	unload = qt.Icon( "coral:/extensibleUIs/icons/unload.png" )
}

-- Locate all lua scripts file in plugins folder and require
-- them, saving all in global plugin list table
local function requirePlugins( dir )
	for filename in lfs.dir( dir ) do
		if filename ~= "." and filename ~= ".." and not path.isDir( dir .. '/' .. filename ) then
			local pluginFile = filename:match( "(.+)%.lua$" )
			if pluginFile then 
				local ok, ret = pcall( require, "extensibleUIs.plugins." .. pluginFile )
				if ok then
					if type( ret ) == "table" then
						table.insert( M.pluginList, ret )
					end
				else
					error( ret )
				end
			end
		end
	end	
end

M.mainWindow = qt.loadUi( "coral:/extensibleUIs/ExtensibleUIs.ui" )

local function extractModuleDir()
	local uiPath = co.findModuleFile( "extensibleUIs", "ExtensibleUIs.ui" )
	return string.sub( uiPath, 1, string.len( uiPath ) - 16 )
end

local moduleDir = extractModuleDir()

requirePlugins( moduleDir .. "/plugins" )
print( "Total of " .. #M.pluginList .. " plugins found" )

for k, v in ipairs( M.pluginList ) do
	local action = M.mainWindow.menuPlugins:addAction( v.name, v.icon )
	local subMenu = qt.Menu()
	action:setMenu( subMenu )
	local loadAction = subMenu:addAction( "load", icons.load )
	local unloadAction = subMenu:addAction( "unload", icons.unload )
	unloadAction.enabled = false
	loadAction:connect( "triggered()", function() v.load( M.mainWindow ); loadAction.enabled = false; unloadAction.enabled = true end )
	unloadAction:connect( "triggered()", function() v.unload( M.mainWindow ) loadAction.enabled = true; unloadAction.enabled = false end )
end

local function showHelp()
	if not M.messageDialog then
		M.messageDialog = qt.new( "QMessageBox" )
		M.messageDialog.windowIcon = qt.Icon( "coral:/extensibleUIs/icons/coral_32.png" )
		M.messageDialog.icon = qt.MessageBox.Information
		M.messageDialog.text = "To extend UI, select one of available plugins from Plugins menu in main toolbar. Select 'load' to load the plugin or 'unload' to remove extended widgets from UI."
	end
	M.messageDialog:invoke( "exec()" )
end

M.mainWindow.actionExtendingUI:connect( "triggered()", showHelp )

M.mainWindow.windowTitle = "Extensible UIs Sample Application!"
M.mainWindow.visible = true

qt.exec()


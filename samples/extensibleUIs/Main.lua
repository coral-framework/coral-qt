-------------------------------------------------------------------------------
--- Required modules
-------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------
--- Utility functions
-------------------------------------------------------------------------------
-- Locate all lua scripts file in plugins folder and require
-- them, saving returned modules in the global plugins table
local function requirePlugins( dir )
	for filename in lfs.dir( dir ) do
		if filename ~= "." and filename ~= ".." and not path.isDir( dir .. '/' .. filename ) then
			local pluginFile = filename:match( "(.+)%.lua$" )
			if pluginFile then 
				local ok, ret = pcall( require, "extensibleUIs.plugins." .. pluginFile )
				if ok then
					-- make sure the current plugin script returns a table
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

local function extractModuleDir()
	local uiPath = co.findModuleFile( "extensibleUIs", "ExtensibleUIs.ui" )
	return string.sub( uiPath, 1, string.len( uiPath ) - 16 )
end

local function showHelp()
	if not M.messageDialog then
		M.messageDialog = qt.new( "QMessageBox" )
		M.messageDialog.windowIcon = qt.Icon( "coral:/extensibleUIs/icons/coral_32.png" )
		M.messageDialog.icon = qt.MessageBox.Information

		local helpMsg = 	"To extend UI, select one of available plugins from Plugins "
		helpMsg = helpMsg .. "Menu in main ToolBar. Select 'load' to load the plugin "
		helpMsg = helpMsg .. "or 'unload' to remove extended widgets from UI."

		M.messageDialog.text = helpMsg
	end

	M.messageDialog:invoke( "exec()" )
end

local function setupUi()
	-- loads main window ui file
	M.mainWindow = qt.loadUi( "coral:/extensibleUIs/ExtensibleUIs.ui" )

	-- acquires module directory
	local moduleDir = extractModuleDir()

	-- obtains the plugin list
	requirePlugins( moduleDir .. "/plugins" )

	-- creates the 'Plugins' menu in the menubar
	for k, v in ipairs( M.pluginList ) do
		-- main plugins menu
		local action = M.mainWindow.menuPlugins:addAction( v.name, v.icon )
		local subMenu = qt.Menu()
		action:setMenu( subMenu )

		-- creates menu entries for each plugin
		local loadAction = subMenu:addAction( "load", icons.load )
		local unloadAction = subMenu:addAction( "unload", icons.unload )
		unloadAction.enabled = false

		local onLoadActionTriggered = function() 
			v.load( M.mainWindow ) 
			loadAction.enabled = false 
			unloadAction.enabled = true 
		end

		local onUnloadActionTriggered = function()
			v.unload( M.mainWindow ) 
			loadAction.enabled = true 
			unloadAction.enabled = false
		end
		
		-- connectes load an unload action slots
		loadAction:connect( "triggered()", onLoadActionTriggered )
		unloadAction:connect( "triggered()", onUnloadActionTriggered )
	end

	M.mainWindow.actionExtendingUI:connect( "triggered()", showHelp )

	M.mainWindow.windowTitle = "Extensible UIs Sample Application!"
	M.mainWindow.visible = true
end

setupUi()

qt.exec()


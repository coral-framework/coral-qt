local qt = require "qt"
local ListItemModel = require "itemModel.MyListModel"

-- configure search paths
qt.setSearchPaths( "coral", co.getPaths() )

local mainWindow = qt.loadUi( "coral:/itemModel/ListViewDialog.ui" )
local model = ListItemModel()
mainWindow.visible = true
mainWindow.listView:setModel( model )

local function on_btnSelect_clicked()
	local number = tonumber( mainWindow.lineNumber.text )
	mainWindow.listView:setItemSelection( number, true )
end

local function on_btnDeselect_clicked()
	local number = tonumber( mainWindow.lineNumber.text )
	mainWindow.listView:setItemSelection( number, false )
end

local function on_btnDeselectAll_clicked()
	mainWindow.listView:clearSelection()
end

mainWindow.btnSelect:connect( "clicked()", on_btnSelect_clicked )
mainWindow.btnDeselect:connect( "clicked()", on_btnDeselect_clicked )
mainWindow.btnDeselectAll:connect( "clicked()", on_btnDeselectAll_clicked )

qt.exec()


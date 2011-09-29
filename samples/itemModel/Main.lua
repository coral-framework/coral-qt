local qt = require "qt"
local ListItemModel = require "itemModel.MyListModel"

-- configure search paths
qt.setSearchPaths( "coral", co.getPaths() )

local data = { "First Row", "Second Row", "Third Row" }

local mainWindow = qt.loadUi( "coral:/itemModel/ListViewDialog.ui" )
local model = ListItemModel( data )
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

local function on_btnRemove_clicked()
	local position = tonumber( mainWindow.lineRemove.text )

	model:beginRemoveColumns( -1, position, position )
	table.remove( data, position )
	model:endRemoveColumns()
	mainWindow.listView:invoke( "update()" )
end

mainWindow.btnSelect:connect( "clicked()", on_btnSelect_clicked )
mainWindow.btnDeselect:connect( "clicked()", on_btnDeselect_clicked )
mainWindow.btnDeselectAll:connect( "clicked()", on_btnDeselectAll_clicked )
mainWindow.btnRemove:connect( "clicked()", on_btnRemove_clicked )

qt.exec()


local qt = require "qt"
local ListItemModel = require "itemModel.MyListModel"

-- configure search paths
qt.setSearchPaths( "coral", co.getPaths() )

local mainWindow = qt.loadUi( "coral:/itemModel/ListViewDialog.ui" )

local model = ListItemModel()
mainWindow.visible = true
mainWindow.listView:setModel( model )
mainWindow.listView:setItemSelection( model, 2, true )

qt.exec()


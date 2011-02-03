local qt = require "qt"
local ListItemModel = require "itemModel.MyListModel"

-- configure search paths
qt.setSearchPaths( "coral", co.getPaths() )

local mainWindow = qt.loadUi( "coral:/itemModel/ListViewDialog.ui" )

qt.assignModelToView( mainWindow.listView, ListItemModel() )

mainWindow.visible = true

qt.exec()


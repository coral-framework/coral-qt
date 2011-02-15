local qt = require "qt"
local ListItemModel = require "itemModel.MyListModel"

-- configure search paths
qt.setSearchPaths( "coral", co.getPaths() )

local mainWindow = qt.loadUi( "coral:/itemModel/ListViewDialog.ui" )

mainWindow.listView:setModel( ListItemModel() )

print( mainWindow.visible )
mainWindow.visible = true

qt.exec()


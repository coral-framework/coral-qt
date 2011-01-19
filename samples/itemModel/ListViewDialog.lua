local qt = require "qt"
local ListItemModel = require "samples.itemModel.MyListModel"

local mainWindow = qt.loadUi( co.findModuleFile( "samples.itemModel", "ListViewDialog.ui" ) )

qt.assignModelToView( mainWindow.listView, ListItemModel() )

mainWindow.visible = true

qt.exec()


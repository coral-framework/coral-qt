local qt = require "qt"
local lfs = require "lfs"
local path = require "path"
local ListItemModel = require "samples.itemModel.MyListModel"

local mainWindow = qt.loadUi( qt.findModuleFile( "samples.itemModel", "ListViewDialog.ui" ) )

qt.assignModelToView( mainWindow.listView, ListItemModel() )

mainWindow.visible = true

qt.exec()


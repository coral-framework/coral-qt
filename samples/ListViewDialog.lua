local qt = require "qt"
local lfs = require "lfs"
local path = require "path"

local mainWindow = qt.loadUi( findModuleFile( "tests", "ListViewTest.ui" ) )

co.system.services:addServiceImplementation( co.Type "qt.IAbstractItemModel", "qt.AbstractItemModel" )
local model = co.getService( "qt.IAbstractItemModel" )

local modelDelegate = co.getService( "qt.IAbstractItemModelDelegate" )
model.delegate = modelDelegate

qt.assignModelToView( mainWindow.listView, model )

mainWindow.visible = true

qt.exec()


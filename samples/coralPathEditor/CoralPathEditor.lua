-------------------------------------------------------------------------------
--- Required modules
-------------------------------------------------------------------------------
local qt = require "qt"
local AbstractListModel = require "qt.AbstractListModel"

local currentSelected = -1

-- loads main form
local mainWindow = qt.loadUi( co.findModuleFile( "samples.coralPathEditor", "MainWindow.ui" ) )

-- gets coral path list
local coralPathList = co.getPaths()

-------------------------------------------------------------------------------
--- Utility functions
-------------------------------------------------------------------------------
local function getPathString( pathList )
	if #pathList == 0 then
		return ""
	end

	local path = pathList[1]
	for i = 2, #pathList do
		path = path .. ":" .. pathList[i]

	end

	return path
end

local function checkCoPathHasChanged( currentPath )
	return currentPath ~= getPathString( co.getPaths() );
end

local function selectDirectory()
	return qt.getExistingDirectory( mainWindow, "Open Directory", "" )
end

-------------------------------------------------------------------------------
--- List model to show coral path entries
-------------------------------------------------------------------------------
local CoralPathListModel = AbstractListModel( "qt.samples.coralPathEditor.CoralPathListModel" )

function CoralPathListModel:getData( index, role )
	if role == "DisplayRole" or role == "EditRole" then
		return coralPathList[index]
	end
	return nil
end

function CoralPathListModel:getHorizontalHeaderData( section, role )
	return nil
end

function CoralPathListModel:getVerticalHeaderData( section, role )
	return nil
end

function CoralPathListModel:getRowCount( parentIndex )
	return #coralPathList
end

function CoralPathListModel:itemClicked( view, index )
	currentSelected = index
	mainWindow.btnRemoveFolder.enabled = true
end

function createCoralPathListModel()
	-- creates the model instance
	local model = co.new( "qt.AbstractItemModel" ).itemModel

	-- creates a new instance of item model delegate along with a data setter function
	local listDelegate = CoralPathListModel{}

	-- sets the list delegate into the model
	model.delegate = listDelegate.delegate

	return model
end

-- creates the list model
local listModel = createCoralPathListModel()

function update()
	local currentPath = getPathString( coralPathList )
	mainWindow.coralPath.text = currentPath
	listModel:notifyDataChanged( 0, #coralPathList )

	mainWindow.btnSave.enabled = checkCoPathHasChanged( currentPath )
end

-------------------------------------------------------------------------------
--- Slots
-------------------------------------------------------------------------------
local function onBtnAddFolderClicked()
	table.insert( coralPathList, selectDirectory() )
	update()
end

local function onbtnRemoveFolderClicked()
	if currentSelected == -1 then
		return
	end

	table.remove( coralPathList, currentSelected )
	update()

	if #coralPathList == 0 then
		mainWindow.btnRemoveFolder.enabled = false
	end
end

local function onBtnSavePathClicked()
	mainWindow.btnSave.enabled = false
	mainWindow.statusbar:invoke( "showMessage(QString,int)", "Coral Path Saved!", 5000 )
end
-------------------------------------------------------------------------------
--- Initializations
-------------------------------------------------------------------------------
mainWindow.coralPath.text = getPathString( coralPathList )

-- connect signals to module's slots
mainWindow.btnAddFolder:connect( "clicked()", onBtnAddFolderClicked )
mainWindow.btnRemoveFolder:connect( "clicked()", onbtnRemoveFolderClicked )
mainWindow.btnSave:connect( "clicked()", onBtnSavePathClicked )

-- assign my model to ui view
qt.assignModelToView( mainWindow.listView, listModel )

mainWindow.visible = true

qt.exec()


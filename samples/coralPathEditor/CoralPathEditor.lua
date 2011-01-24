-------------------------------------------------------------------------------
--- Required modules
-------------------------------------------------------------------------------
local qt = require "qt"
local AbstractListModel = require "qt.AbstractListModel"

local currentSelected = -1

-- gets coral path list
local coralPathList = co.getPaths()

qt.setSearchPaths( "coral", coralPathList )

-- loads main form
local editorDialog = qt.loadUi( "coral:/samples/coralPathEditor/EditorDialog.ui" )

-------------------------------------------------------------------------------
--- Utility functions
-------------------------------------------------------------------------------
local function selectDirectory()
	return qt.getExistingDirectory( editorDialog, "Open Directory", "" )
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

function CoralPathListModel:getFlags( index )
	return qt.ItemIsSelectable + qt.ItemIsEnabled;	
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
	listModel:notifyDataChanged( 0, #coralPathList )
end

-------------------------------------------------------------------------------
--- Slots
-------------------------------------------------------------------------------
local function onBtnAddFolderClicked()
	local dir = selectDirectory()
	if dir == "" then
		return
	end

	table.insert( coralPathList, dir )
	co.addPath( dir )
	update()
end

-------------------------------------------------------------------------------
--- Initializations
-------------------------------------------------------------------------------

-- connect signals to module's slots
editorDialog.btnAddFolder:connect( "clicked()", onBtnAddFolderClicked )

-- assign my model to ui view
qt.assignModelToView( editorDialog.listView, listModel )

editorDialog.windowTitle = "Coral Path Editor"
editorDialog.visible = true

qt.exec()


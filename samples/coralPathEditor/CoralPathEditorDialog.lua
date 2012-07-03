-------------------------------------------------------------------------------
--- Required modules
-------------------------------------------------------------------------------
local qt = require "qt"
local AbstractListModel = require "qt.AbstractListModelDelegate"

local M = {}

-------------------------------------------------------------------------------
--- Utility functions
-------------------------------------------------------------------------------
local function selectDirectory()
	return qt.getExistingDirectory( M.editorDialog, "Open Directory", "" )
end

-------------------------------------------------------------------------------
--- List model to show coral path entries
-------------------------------------------------------------------------------
local CoralPathListModel = AbstractListModel( "qt.samples.coralPathEditor.CoralPathListModel" )

function CoralPathListModel:getData( index, role )
	if role == "DisplayRole" or role == "EditRole" then
		return M.coralPathList[index]
	end

	if role == "DecorationRole" then
		return M.defaultIcon
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
	return #M.coralPathList
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

function update()
	M.listModel:notifyDataChanged( 0, #M.coralPathList )
	M.editorDialog.labelStatus.text = "Total of " .. #M.coralPathList .. " folders in path."
end

-------------------------------------------------------------------------------
--- Slots
-------------------------------------------------------------------------------
local function onBtnAddFolderClicked()
	local dir = selectDirectory()
	if dir == "" then
		return
	end

	table.insert( M.coralPathList, dir )
	table.insert( M.addedPathList, dir )
	update()
end

local function onBtnApplyClicked()
	for k, v in ipairs( M.addedPathList ) do
		co.addPath( v )
	end
	M.editorDialog:invoke( "accept()" )
end

-------------------------------------------------------------------------------
--- Initializations
-------------------------------------------------------------------------------
local function initialize()
	-- initialize coral path list
	M.coralPathList = co.getPaths()
	M.addedPathList = {}

	-- update Qt search paths
	qt.setSearchPaths( "coral", M.coralPathList )

	-- load default folder icon (or clause to avoid re-initializations)
	M.defaultIcon = M.defaultIcon or qt.Icon( "coral:/coralPathEditor/icons/folder_256.png" )

	M.editorDialog = qt.loadUi( "coral:/coralPathEditor/CoralPathEditorDialog.ui" )

	M.listModel = createCoralPathListModel()

	-- connect signals to module's slots
	M.editorDialog.btnAddFolder:connect( "clicked()", onBtnAddFolderClicked )
	M.editorDialog.btnApply:connect( "clicked()", onBtnApplyClicked )

	-- assign my model to ui view
	M.editorDialog.listView:setModel( M.listModel )

	M.editorDialog.windowTitle = "Coral Path Editor"
	
	update()
end

local function dialogResult( code )
	M.resultCode = code	
end

function M:show()
	initialize()
	self.editorDialog:connect( "finished(int)", dialogResult )
	self.editorDialog:invoke( "exec()" )
	return M.resultCode == 1
end

return M


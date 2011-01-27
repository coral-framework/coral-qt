-------------------------------------------------------------------------------
--- Required modules
-------------------------------------------------------------------------------
local qt = require "qt"
local lfs = require "lfs"
local path = require "path"
local AbstractItemModel = require "qt.AbstractItemModel"
local coralPathEditor = require "coralPathEditor.CoralPathEditor"

local TypeTreeModel = AbstractItemModel( "qt.samples.coralTypeBrowser.TypeTreeModel" )

-- configure search paths
qt.setSearchPaths( "coral", co.getPaths() )

-- loads main form
local mainWindow = qt.loadUi( "coral:/coralTypeBrowser/MainWindow.ui" )

local icons = 
{
	namespace 		= qt.Icon( "coral:/coralTypeBrowser/png/package_256.png" ),
	complexType 	= qt.Icon( "coral:/coralTypeBrowser/png/complex_type_64.png" ),
	primitiveType 	= qt.Icon( "coral:/coralTypeBrowser/png/primitive_type_64.png" ),
	attribute 		= qt.Icon( "coral:/coralTypeBrowser/png/attribute.png" )
}

local typeIcons =
{
	-- map icons for primitive types
	["TK_BOOLEAN"] 		= icons.primitiveType,
	["TK_INT8"] 		= icons.primitiveType,
	["TK_UINT8"] 		= icons.primitiveType,
	["TK_INT16"] 		= icons.primitiveType,
	["TK_UINT16"] 		= icons.primitiveType,
	["TK_INT32"] 		= icons.primitiveType,
	["TK_UINT32"] 		= icons.primitiveType,
	["TK_INT64"] 		= icons.primitiveType,
	["TK_UINT64"] 		= icons.primitiveType,
	["TK_FLOAT"] 		= icons.primitiveType,
	["TK_DOUBLE"] 		= icons.primitiveType,
	["TK_STRING"] 		= icons.primitiveType,

	-- map icons for complex types
	["TK_ANY"] 			= icons.complexType,
	["TK_ARRAY"] 		= icons.complexType,
	["TK_ENUM"] 		= icons.complexType,
	["TK_EXCEPTION"] 	= icons.complexType,
	["TK_STRUCT"] 		= icons.complexType,
	["TK_NATIVECLASS"] 	= icons.complexType,
	["TK_INTERFACE"] 	= icons.complexType,
	["TK_COMPONENT"] 	= icons.complexType
}

-------------------------------------------------------------------------------
--- Utility functions
-------------------------------------------------------------------------------
-- Recursively loads all types from the given directory by 
-- locating CSL files
local function loadTypesIn( dir, parentModuleName )
	assert( path.isDir( dir ) )
	for filename in lfs.dir( dir ) do
		if filename ~= "." and filename ~= ".." and path.isDir( dir .. '/' .. filename ) then
			local nextModuleName = filename
			if parentModuleName ~= "" then
				nextModuleName = parentModuleName .. '.' .. nextModuleName
			end

			loadTypesIn( dir .. '/' .. filename, nextModuleName )
		else
			local typeName = filename:match( "(.+)%.csl$" )
			if typeName then 
				local t = co.Type[parentModuleName .. '.' .. typeName]
			end
		end
	end	
end

-- Loads all types reachable from coral path
local function loadAllTypes()
	local coralPaths = co.getPaths()

	for i, repositoryDir in ipairs( coralPaths ) do
		-- avoid fatal CSL parsing errors
		pcall( loadTypesIn, repositoryDir, "" )
	end
end

-------------------------------------------------------------------------------
--- Tree structure to represent coral type hierarchy data
-------------------------------------------------------------------------------
local TypeTree = {}

-- TypeTree is used as metatable for new TypeTree instances
TypeTree.__index = TypeTree

local function isValidIndex( index )
	return index >= 0
end

function TypeTree:add( element, icon, parentIndex )
	-- creates a node data
	local node = { data = element, icon = icon, index = self.nextIndex, parent = parentIndex, children = {} }
	self[node.index] = node
	self.nextIndex = self.nextIndex + 1

	-- node is not a toplevel node, it has a valid parent index
	if isValidIndex( parentIndex ) then
		table.insert( self[parentIndex].children, node )

		-- tracks elements row within parent list
		node.row = #self[parentIndex].children
	else
		-- this node is a toplevel element (invalid parent)
		-- we must track toplevel elements (see BrowserTreeModel:getIndex() 
		-- and BrowserTreeModel:getRowCount())
		table.insert( self.toplevelElements, node )
		node.row = #self.toplevelElements
	end

	return node.index
end

function TypeTree:addType( currentType, parentIndex )
	local currentIndex = self:add( currentType, typeIcons[currentType.kind], parentIndex or -1 )
	local childTypes = currentType.types

	if not childTypes then return end

	for i, v in ipairs( childTypes ) do
		self:addType( v, currentIndex )
	end
end

function TypeTree:addNamespace( namespace, parentIndex )
	-- adds namespace to type tree
	local currentIndex = self:add( namespace, icons.namespace, parentIndex or -1 )
	
	local childNS = namespace.childNamespaces
	if not childNS then return end

	for i, v in ipairs( childNS ) do
		self:addNamespace( v, currentIndex )
	end

	-- adds all namespace types recursively
	for i, v in ipairs( namespace.types ) do
		self:addType( v, currentIndex )
	end
end

function TypeTree:new()
	local self = setmetatable( {}, TypeTree )

	self.nextIndex = 1
	self.toplevelElements = {}

	-- forces loading all types
	loadAllTypes()

	self:addNamespace( co.system.types.rootNS )

	return self
end

-- constructs and initialize a new coral type tree
local typeTree = TypeTree:new()

-------------------------------------------------------------------------------
--- Tree model to show coral type hierarchy
-------------------------------------------------------------------------------
function TypeTreeModel:getIndex( row, col, parentIndex )
	if isValidIndex( parentIndex ) then
		return typeTree[parentIndex].children[row+1].index
	else
		return typeTree.toplevelElements[row+1].index
	end
end

function TypeTreeModel:getParentIndex( index )
	return typeTree[index].parent
end

function TypeTreeModel:getRow( index )
	return typeTree[index].row - 1
end

function TypeTreeModel:getColumn( index )
	return 0
end

function TypeTreeModel:getData( index, role )
	if role == "DisplayRole" or role == "EditRole" then
		-- check whether this is the root namespace (empty name)
		if typeTree[index].data.name == "" then
			return  "<root namespace>"
		end
		return typeTree[index].data.name
	end

	if role == "DecorationRole" then
		return typeTree[index].icon
	end

	return nil
end

function TypeTreeModel:getFlags( index )
	return qt.ItemIsSelectable + qt.ItemIsEnabled
end

function TypeTreeModel:getHorizontalHeaderData( section, role )
	if section == 0 and role == "DisplayRole" then
		return "Coral Type Hierarchy"
	end

	return nil
end

function TypeTreeModel:getVerticalHeaderData( section, role )
	return nil -- no vertical header used
end

function TypeTreeModel:getColumnCount( parentIndex )
	-- checks whether there is any element in the tree
	if typeTree.nextIndex == 1 then
		return 0
	end

	-- every parent is at column 0
	-- root element has one column if typeTree contains any data
	if not isValidIndex( parentIndex ) then
		return 1
	end

	if #typeTree[parentIndex].children > 0 then
		return 1
	else
		return 0
	end
end

function TypeTreeModel:getRowCount( parentIndex )
	if not isValidIndex( parentIndex ) then
		return #typeTree.toplevelElements
	end
	
	return #typeTree[parentIndex].children
end

function createTypeTreeModel()
	-- creates the model instance
	local model = co.new( "qt.AbstractItemModel" ).itemModel

	-- creates a new instance of item model delegate along with a data setter function
	local treeDelegate = TypeTreeModel{}

	-- sets the list delegate into the model
	model.delegate = treeDelegate.delegate

	return model
end

-- creates the list model
local treeModel = createTypeTreeModel()

-------------------------------------------------------------------------------
--- Slots
-------------------------------------------------------------------------------
local function onActionEditCoralPathTriggered()
	coralPathEditor:show()

	-- updates type tree
	typeTree = TypeTree:new()
	treeModel:notifyDataChanged( 1, typeTree.nextIndex - 1 )
end

-------------------------------------------------------------------------------
--- Initializations
-------------------------------------------------------------------------------

-- assigns my model to ui view
qt.assignModelToView( mainWindow.treeView, treeModel )

mainWindow.actionEditCoralPath:connect( "triggered()", onActionEditCoralPathTriggered )

mainWindow.visible = true

qt.exec()


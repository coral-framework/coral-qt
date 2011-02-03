-------------------------------------------------------------------------------
--- Required modules
-------------------------------------------------------------------------------
local qt = require "qt"
local lfs = require "lfs"
local path = require "path"
local AbstractItemModel = require "qt.AbstractItemModel"
local coralPathEditor = require "coralPathEditor.CoralPathEditor"

local M = {}

local TypeTreeModel = AbstractItemModel( "qt.samples.coralTypeBrowser.TypeTreeModel" )

-- configure search paths
qt.setSearchPaths( "coral", co.getPaths() )

-- loads main form
M.mainWindow = qt.loadUi( "coral:/coralTypeBrowser/MainWindow.ui" )

-- icon files
M.icons = 
{
	attribute 		= qt.Variant:fromIcon( "coral:/coralTypeBrowser/png/attribute.png" ),
	component 		= qt.Variant:fromIcon( "coral:/coralTypeBrowser/png/component.png" ),
	enum		 	= qt.Variant:fromIcon( "coral:/coralTypeBrowser/png/enum.png" ),
	exception	 	= qt.Variant:fromIcon( "coral:/coralTypeBrowser/png/exception.png" ),
	facet		 	= qt.Variant:fromIcon( "coral:/coralTypeBrowser/png/facet.png" ),
	interface	 	= qt.Variant:fromIcon( "coral:/coralTypeBrowser/png/interface.png" ),
	method 			= qt.Variant:fromIcon( "coral:/coralTypeBrowser/png/method.png" ),
	namespace 		= qt.Variant:fromIcon( "coral:/coralTypeBrowser/png/package_64.png" ),
	nativeClass		= qt.Variant:fromIcon( "coral:/coralTypeBrowser/png/native_class.png" ),
	primitiveType 	= qt.Variant:fromIcon( "coral:/coralTypeBrowser/png/primitive_type.png" ),
	receptacle	 	= qt.Variant:fromIcon( "coral:/coralTypeBrowser/png/receptacle.png" ),
	struct		 	= qt.Variant:fromIcon( "coral:/coralTypeBrowser/png/struct.png" ),
	docs			= qt.Variant:fromIcon( "coral:/coralTypeBrowser/png/docs.png" )
}

M.typeIcons =
{
	-- map icons for complex types
	["TK_ENUM"] 		= M.icons.enum,
	["TK_EXCEPTION"] 	= M.icons.exception,
	["TK_STRUCT"] 		= M.icons.struct,
	["TK_NATIVECLASS"] 	= M.icons.nativeClass,
	["TK_INTERFACE"] 	= M.icons.interface,
	["TK_COMPONENT"] 	= M.icons.component
}

-- fonts for some specific item data in the view
M.fonts =
{
	-- font used to render doc items
	docs = qt.Variant:fromFont( "Arial", 11, 50, true ) 
}

M.colors =
{
	-- color for doc items
	docs = qt.Variant:fromColor( 85, 200, 85 )
}

-------------------------------------------------------------------------------
--- Utility functions
-------------------------------------------------------------------------------
local function loadType( typeName, parentModuleName )
	return co.Type[parentModuleName .. '.' .. typeName]
end

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
				pcall( loadType, typeName, parentModuleName )
			end
		end
	end	
end

-- Loads all types reachable from coral path
local function loadAllTypes()
	local coralPaths = co.getPaths()

	for i, repositoryDir in ipairs( coralPaths ) do
		-- avoid fatal CSL parsing errors
		loadTypesIn( repositoryDir, "" )
	end
end

-- Gets the group name base on the number of elements in it.
-- Used by TypeTree::addMethodGroup() and TypeTree::addMemberGroup()
local function getGroupName( groupName, numberOfElements )
	local name = numberOfElements .. " " .. groupName
	if numberOfElements > 1 then
		name = name .. "s"
	end

	return name
end

-- Returns a string with the full method signature extracted from methodInfo
local function extractMethodSignature( methodInfo )
	local signature = methodInfo.name .. "("
	for i, v in ipairs( methodInfo.parameters ) do
		local parameter = ""
		if v.isIn and v.isOut then
			parameter = parameter .. " inout "
		elseif v.isIn then
			parameter = parameter .. " in "
		else
			parameter = parameter .. " out "
		end

		parameter = parameter .. v.type.name .. " " .. v.name
		if i ~= #methodInfo.parameters then
			parameter = parameter .. ","
		else
			parameter = parameter .. " "
		end
		signature = signature .. parameter .. " "		
	end
	if methodInfo.returnType then
		return methodInfo.returnType.name .. " " .. signature .. ")"
	end

	return "void " .. signature .. ")"
end

local function isValidIndex( index )
	return index >= 0
end

-------------------------------------------------------------------------------
--- Tree structure to represent coral type hierarchy data
-------------------------------------------------------------------------------
local TypeTree = {}

-- TypeTree is used as metatable for new TypeTree instances
TypeTree.__index = TypeTree

-- Add an element (method, attribute, type or namespace)
function TypeTree:add( element, parentIndex )
	-- creates a node data
	local node = { 
					data = element.data, 
					icon = element.icon, 
					font = element.font,
					color = element.color,
					index = self.nextIndex, 
					parent = parentIndex, 
					children = {} 
	}
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

-- Creates a group with all docs for the given member or type with name 'fullName'
-- (e.g: types.MyType:myMethod or type.MyType)
function TypeTree:addDocs( fullName, parentIndex )
	local docs = co.system.types:getDocumentation( fullName )
	if not docs or docs == "" then
		return
	end

	local docsGroupIndex = self:add( { data = "docs", icon = M.icons.docs }, parentIndex )
	self:add( { data = docs, font = M.fonts.docs, color = M.colors.docs }, docsGroupIndex )
end

-- Creates a group of members (if any), extracted from field 'fieldName' of table currentType,
-- and adds it to type tree as child of index parentIndex.
function TypeTree:addMemberGroup( currentType, fieldName, groupName, icon, parentIndex )
	if currentType[fieldName] and #currentType[fieldName] > 0 then
		local group = { data = getGroupName( groupName, #currentType[fieldName] ), icon = icon }
		local groupIndex = self:add( group, parentIndex or -1 )
		for i, v in ipairs( currentType[fieldName] ) do
			local memberIndex = self:add( { data = v.name .. " : " .. v.type.name, icon = icon }, groupIndex )
			
			-- adds documentation for member attribute
			self:addDocs( currentType.fullName .. ":" .. v.name, memberIndex )
		end
	end
end

-- Creates a group of methods, extracted from field 'fieldName' of table currentType,
-- and adds it to type tree as child of index parentIndex
function TypeTree:addMethodGroup( currentType, fieldName, groupName, icon, parentIndex )
	if currentType[fieldName] and #currentType[fieldName] > 0 then
		local group = { data = getGroupName( groupName, #currentType[fieldName] ), icon = icon }
		local groupIndex = self:add( group, parentIndex or -1 )
		for i, v in ipairs( currentType[fieldName] ) do
			local methodIndex = self:add( { data = extractMethodSignature( v ), icon = icon }, groupIndex )

			-- adds documentation for member method
			self:addDocs( currentType.fullName .. ":" .. v.name, methodIndex )

			-- extracts method exceptions
			if v.exceptions and #v.exceptions > 0 then
				local exceptionsIndex = self:add( { data = "throws", icon = M.icons.exception }, methodIndex )
				for j, v2 in ipairs( v.exceptions ) do
					self:add( { data = v2.name, icon = M.icons.exception }, exceptionsIndex )
				end
			end
		end
	end
end

function TypeTree:addMembers( currentType, parentIndex )
	-- add facets and receptacles (components only)
	self:addMemberGroup( currentType, "facets", "facet", M.icons.facet, parentIndex )
	self:addMemberGroup( currentType, "receptacles", "receptacle", M.icons.receptacle, parentIndex )

	-- add methods (native class and interface only)
	self:addMethodGroup( currentType, "memberMethods", "method", M.icons.method, parentIndex )
	
	-- add attributes (all types)
	self:addMemberGroup( currentType, "memberAttributes", "attribute", M.icons.attribute, parentIndex )
end

function TypeTree:addType( currentType, parentIndex )
	local currentIndex = self:add( { data = currentType.name, icon = M.typeIcons[currentType.kind] or M.icons.primitiveType }, parentIndex or -1 )

	-- adds documentation for type
	self:addDocs( currentType.fullName, currentIndex )

	local childTypes = currentType.types
	if childType then
		for i, v in ipairs( childTypes ) do
			self:addType( v, currentIndex )
		end
	end

	self:addMembers( currentType, currentIndex )
end

function TypeTree:addNamespace( namespace, parentIndex )
	-- adds namespace to type tree
	local currentIndex = self:add( { data = namespace.name, icon = M.icons.namespace }, parentIndex or -1 )
	
	local childNS = namespace.childNamespaces
	if childNS then
		for i, v in ipairs( childNS ) do
			self:addNamespace( v, currentIndex )
		end
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
		if #typeTree[parentIndex].children == 0 then
			return -1
		end
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
	local data = nil
	if role == "DisplayRole" or role == "EditRole" then
		-- check whether this is the root namespace (empty name)
		if typeTree[index].data == "" then
			data = "<root namespace>"
		else
			data = typeTree[index].data
		end
	elseif role == "TextAlignmentRole" then
		data = qt.AlignLeft + qt.AlignJustify
	elseif role == "DecorationRole" then
		data = typeTree[index].icon
	elseif role == "FontRole" then
		data = typeTree[index].font
	elseif role == "ForegroundRole" then
		data = typeTree[index].color
	end
	return data
end

function TypeTreeModel:getFlags( index )
	return qt.ItemIsSelectable + qt.ItemIsEnabled
end

function TypeTreeModel:getHorizontalHeaderData( section, role )
	if section == 0 and role == "DisplayRole" then
		return qt.Variant( "Coral Type Hierarchy" )
	end

	return qt.Variant()
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

function TypeTreeModel:itemClicked( view, index )
	--local action = M.menu:exec()
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
	M.mainWindow.treeView:invoke( "reset()" )
	treeModel:notifyDataChanged( 1, typeTree.nextIndex - 1 )
end

local function onButtonCloseClicked()
	M.mainWindow:invoke( "close()" )
end

-------------------------------------------------------------------------------
--- Initializations
-------------------------------------------------------------------------------
local function createMenu()
	M.menu = qt.Menu()

	-- adds a new action using the given menu and text
	local newAction = M.menu:addAction( M.icons.docs, "test" )
	newAction.data = "Action0"
	
	newAction = M.menu:addAction( M.icons.docs, "test2" )
	newAction.data = "Action1"
end

--createMenu()

-- assigns my model to ui view
qt.assignModelToView( M.mainWindow.treeView, treeModel )

M.mainWindow.actionEditCoralPath:connect( "triggered()", onActionEditCoralPathTriggered )
M.mainWindow.btnClose:connect( "clicked()", onButtonCloseClicked )

M.mainWindow.visible = true

qt.exec()


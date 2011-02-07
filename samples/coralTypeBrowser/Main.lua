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
	attribute 		= qt.Icon( "coral:/coralTypeBrowser/icons/attribute.png" ),
	component 		= qt.Icon( "coral:/coralTypeBrowser/icons/component.png" ),
	enum		 	= qt.Icon( "coral:/coralTypeBrowser/icons/enum.png" ),
	exception	 	= qt.Icon( "coral:/coralTypeBrowser/icons/exception.png" ),
	facet		 	= qt.Icon( "coral:/coralTypeBrowser/icons/facet.png" ),
	interface	 	= qt.Icon( "coral:/coralTypeBrowser/icons/interface.png" ),
	method 			= qt.Icon( "coral:/coralTypeBrowser/icons/method.png" ),
	namespace 		= qt.Icon( "coral:/coralTypeBrowser/icons/package_64.png" ),
	nativeClass		= qt.Icon( "coral:/coralTypeBrowser/icons/native_class.png" ),
	primitiveType 	= qt.Icon( "coral:/coralTypeBrowser/icons/primitive_type.png" ),
	receptacle	 	= qt.Icon( "coral:/coralTypeBrowser/icons/receptacle.png" ),
	struct		 	= qt.Icon( "coral:/coralTypeBrowser/icons/struct.png" ),
	docs			= qt.Icon( "coral:/coralTypeBrowser/icons/docs.png" )
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
	docs = qt.Font( "Arial", 11, 50, true ) 
}

M.colors =
{
	-- color for doc items
	docs = qt.Color( 85, 200, 85 )
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
					docs = element.docs,
					fullName = element.fullName,
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

function getDocs( coType, memberName )
	if memberName then
		return co.system.types:getDocumentation( coType.fullName .. ":" .. memberName )
	else
		return co.system.types:getDocumentation( coType.fullName )
	end
end

-- Creates a group of members (if any), extracted from field 'fieldName' of table currentType,
-- and adds it to type tree as child of index parentIndex.
function TypeTree:addGenericMembers( currentType, fieldName, groupName, icon, parentIndex )
	if currentType[fieldName] and #currentType[fieldName] > 0 then
		for i, v in ipairs( currentType[fieldName] ) do
			self:add( { data = v.name .. " : " .. v.type.name, 
						icon = icon, docs = getDocs( currentType, v.name ), 
						fullName = v.type.fullName,
						type = fieldName }, parentIndex )
		end
	end
end

function TypeTree:addMemberAttributes( currentType, fieldName, groupName, icon, parentIndex )
	if currentType[fieldName] and #currentType[fieldName] > 0 then
		for i, v in ipairs( currentType[fieldName] ) do
			local data = "attribute " .. v.name .. " : " .. v.type.name
			if data.isReadOnly then
				data = data .. " [readonly]"
			end
			self:add( { data = data, 
						icon = icon, 
						docs = getDocs( currentType, v.name ), 
						fullName = v.type.fullName, 
						type = "attribute" }, 
						parentIndex )
		end
	end
end

-- Creates a group of methods, extracted from field 'fieldName' of table currentType,
-- and adds it to type tree as child of index parentIndex
function TypeTree:addMethods( currentType, fieldName, groupName, icon, parentIndex )
	if currentType[fieldName] and #currentType[fieldName] > 0 then
		for i, v in ipairs( currentType[fieldName] ) do
			local methodIndex = self:add( { data = extractMethodSignature( v ), icon = icon, 
											docs = getDocs( currentType, v.name ), 
											fullName = currentType.fullName .. ":" .. v.name, 
											type = "method"  }, parentIndex )

			-- extracts method exceptions
			if v.exceptions and #v.exceptions > 0 then
				local exceptionsIndex = self:add( { data = "throws", icon = M.icons.exception }, methodIndex )
				for j, v2 in ipairs( v.exceptions ) do
					self:add( { data = v2.name, 
								icon = M.icons.exception, 
								fullName = currentType.fullName .. ":" .. v2.name, 
								type = "exception" }, exceptionsIndex )
				end
			end
		end
	end
end

function TypeTree:addTypeMembers( currentType, parentIndex )
	-- add facets and receptacles (components only)
	self:addGenericMembers( currentType, "facets", "facet", M.icons.facet, parentIndex )
	self:addGenericMembers( currentType, "receptacles", "receptacle", M.icons.receptacle, parentIndex )

	-- add attributes (all types)
	self:addMemberAttributes( currentType, "memberAttributes", "attribute", M.icons.attribute, parentIndex )

	-- add methods (native class and interface only)
	self:addMethods( currentType, "memberMethods", "method", M.icons.method, parentIndex )
end

function TypeTree:addType( currentType, parentIndex )
	local currentIndex = self:add( { data = currentType.name, 
									 icon = M.typeIcons[currentType.kind] or M.icons.primitiveType, 
									 docs = getDocs( currentType ), 
									 fullName = currentType.fullName }, parentIndex or -1 )

	local childTypes = currentType.types
	if childType then
		for i, v in ipairs( childTypes ) do
			self:addType( v, currentIndex )
		end
	end

	self:addTypeMembers( currentType, currentIndex )
end

function TypeTree:addNamespace( namespace, parentIndex )
	-- adds namespace to type tree
	local currentIndex = self:add( { data = namespace.name, icon = M.icons.namespace, fullName = namespace.fullName }, parentIndex or -1 )
	
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

local function getDocsHtml( fullName, docs )
	local docsHtml = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">"
	docsHtml = docsHtml .. "<html><head><meta name=\"qrichtext\" content=\"1\ /><style type=\"text/css\">p, li { white-space: pre-wrap; } </style></head>"
	docsHtml = docsHtml .. "<body style=\" font-family:'Sans'; font-size:10pt; font-weight:400; font-style:normal;\">"
	if fullName and fullName ~= "" then
		docsHtml = docsHtml .. "<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><span style=\" font-weight:600; color:#000000;\">".. fullName .. "<br><br></span>"
	end

	local finalDocs = "<span style=\" font-weight:400; color:#00aa00;\">" .. ( docs or "" ) .. "</span>"
	if not docs or docs == "" then
		finalDocs = "<span style=\" font-weight:400; color:#7f7f7f;\">" .. "&lt;no documentation available&gt;" .. "</span>"
	end
	docsHtml = docsHtml .. finalDocs
	docsHtml = docsHtml .. "</p></body></html>"
	return docsHtml
end

function TypeTreeModel:itemClicked( view, index )
	local element = typeTree[index]	
	M.docsTextBrowser.html = getDocsHtml( element.fullName, element.docs )
	if element.docs and element.docs ~= "" then
		M.docsTextBrowser.enabled = true
	else
		M.docsTextBrowser.enabled = false
	end
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
	M.treeView:invoke( "reset()" )
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

local function setupUi()
	M.treeView = qt.new( "QTreeView" )
	M.treeView.objectName = "treeView"

	M.treeView.minimumWidth = 700
	local splitter = qt.new( "QSplitter" )
	splitter:addWidget( M.treeView )

	local docsSplitter = qt.new( "QSplitter" )

	M.docsTextBrowser = qt.new( "QTextBrowser" )
	M.docsTextBrowser.plainText = "<no documentation available>"
	M.docsTextBrowser.enabled = false
	docsSplitter:addWidget( M.docsTextBrowser )

	splitter:addWidget( M.docsTextBrowser )

	local layout = qt.new( "QVBoxLayout" )
	layout:addWidget( splitter )
	M.mainWindow.mainFrame:setLayout( layout )

	-- assigns my model to ui view
	M.treeView:setModel( treeModel )

	-- setup signal and slot connections
	M.mainWindow.actionEditCoralPath:connect( "triggered()", onActionEditCoralPathTriggered )
	M.mainWindow.btnClose:connect( "clicked()", onButtonCloseClicked )
end

setupUi()

M.mainWindow.visible = true

qt.exec()


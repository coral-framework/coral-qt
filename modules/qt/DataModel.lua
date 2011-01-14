local M = {}

function M:addItem( parentIndex, item )
	-- set item's parent
	item.parent = parentIndex

	-- acquire parent item
	parentItem = self.itemHash[parentIndex]
		
	-- setup parent's children table
	parentItem.children = parentItem.children or {}

	-- insert the new child at the end of children table
	table.insert( parentItem.children, item.index )

	-- atach the new item into the item hash
	self.numItems = self.numItems + 1
	item.index = self.numItems
	self.itemHash[item.index] = item

	if parentIndex == -1 then
		table.insert( self.toplevelItems, item.index )
	end

	return item.index
end

function M:setItem( index, item )
	self.itemHash[index] = item
end

function M:getItem( index )
	return self.itemHash[index]
end

function M:setVerticalHeaderData( section, data )
	model.vheader[section] = data
end

function M:setHorizontalHeaderData( section, data )
	model.hheader[section] = data
end

-- returns the parent of the given index
function M:getParent( index )
	if not self.itemHash[index] then
		return nil
	end

	return self.itemHash[index].parent
end

-- retrieves the current row count for the given parentIndex
-- it is usually the same as the number of children of parentIndex
function M:getRowCount( parentIndex )

local function createDataModel( model )
	-- vertical header data
	model.vheader = {}
	-- horizontal header data
	model.hheader = {}
	-- item pool used to quick access an item
	model.itemHash = {}

	-- store top-level items in order to track row count
	-- for the root level (invalid parent index)
	model.toplevelItems = {}

	model.numItems = 0

	return model
end

function DataModel()
	return createDataModel( {} )
end

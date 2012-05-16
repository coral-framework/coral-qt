-------------------------------------------------------------------------------
-- Returns an AbstractListModel component prototype factory
-------------------------------------------------------------------------------
local AbstractItemModelDelegate = require "qt.AbstractItemModelDelegate"

local AbstractListModel = {}

function AbstractItemModelDelegate:getIndex( row, col, parentIndex )
	return row + 1
end

function AbstractItemModelDelegate:getParentIndex( index )
	return -1
end

function AbstractItemModelDelegate:getColumnCount( parentIndex )
	if parentIndex == -1 then
		return 1
	end
	return 0
end

function AbstractItemModelDelegate:getRow( index )
	return 0
end

function AbstractItemModelDelegate:getColumn( index )
	return 0
end

return function( componentName )
	local prototype = AbstractItemModelDelegate( componentName )
	for k, v in pairs( AbstractItemModelDelegate ) do
		prototype[k] = v
	end
	return prototype
end

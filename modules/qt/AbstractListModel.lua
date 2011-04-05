-------------------------------------------------------------------------------
-- Returns an AbstractListModel component prototype factory
-------------------------------------------------------------------------------
local AbstractItemModel = require "qt.AbstractItemModel"

local AbstractListModel = {}

function AbstractListModel:getIndex( row, col, parentIndex )
	return row + 1
end

function AbstractListModel:getParentIndex( index )
	return -1
end

function AbstractListModel:getColumnCount( parentIndex )
	if parentIndex == -1 then
		return 1
	end
	return 0
end

function AbstractListModel:getRow( index )
	return 0
end

function AbstractListModel:getColumn( index )
	return 0
end

return function( componentName )
	local prototype = AbstractItemModel( componentName )
	for k, v in pairs( AbstractListModel ) do
		prototype[k] = v
	end
	return prototype
end

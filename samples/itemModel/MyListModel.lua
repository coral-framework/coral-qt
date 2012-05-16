local qt = require "qt"
local AbstractListModelDelegate = require "qt.AbstractListModelDelegate"

local MyListModelDelegate = AbstractListModelDelegate( "qt.samples.MyListModel" )

function MyListModelDelegate:getData( index, role )
	if role == "DisplayRole" or role == "EditRole" then
		return self.data[index]
	end
	return nil
end

function MyListModelDelegate:getFlags( index )
	return qt.ItemIsSelectable + qt.ItemIsEnabled
end

function MyListModelDelegate:getHorizontalHeaderData( section, role )
	return nil
end

function MyListModelDelegate:getVerticalHeaderData( section, role )
	return nil
end

function MyListModelDelegate:getRowCount( parentIndex )
	return #self.data
end

function MyListModelDelegate:getRow( index )
	return index
end

return function( data )
	-- creates the model instance
	local model = co.new( "qt.AbstractItemModel" ).itemModel

	-- creates a new instance of item model delegate along with a data setter function
	local listDelegate = MyListModelDelegate{ data = data }
	
	-- sets the list delegate into the model
	model.delegate = listDelegate.delegate

	return model
end


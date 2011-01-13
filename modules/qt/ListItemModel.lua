-------------------------------------------------------------------------------
-- IAbstractItemModelDelegate component that implements Qt's item model delegate
-------------------------------------------------------------------------------
local ItemModelDelegate = co.Component { name = "qt.ListItemModelDelegate", provides = { delegate = "qt.IAbstractItemModelDelegate" } }

function ItemModelDelegate.delegate:getData( index, role )
	if role == "DisplayRole" or role == "EditRole" then
		return self.data[index + 1]
	end
	return nil
end

function ItemModelDelegate.delegate:getColumnCount( parentIndex )
	return 0;
end

function ItemModelDelegate.delegate:getRowCount( parentIndex )
	return #self.data
end

function ItemModelDelegate.delegate:getIndex( row, col, parentIndex )
	return 0;
end

function ItemModelDelegate.delegate:getHorizontalHeaderData( col, role )
	return "BAR?FOO!"
end

function ItemModelDelegate.delegate:getVerticalHeaderData( row, role )
	return "BAR?FOO!"
end

function ItemModelDelegate.delegate:getParentIndex( itemIndex )
	return 0;
end

function ListItemModel( list )
	-- creates the model instance
	local model = co.new( "qt.AbstractItemModel" ).itemModel

	-- creates a new instance of item model delegate along with a data setter function
	local listDelegate = ItemModelDelegate{ data = list }
	
	-- sets the list delegate into the model
	model.delegate = listDelegate.delegate

	return model
end

return ListItemModel

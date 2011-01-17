local AbstractListModel = require "qt.AbstractListModel"

local MyListModel = AbstractListModel( "qt.samples.MyListModel" )

function MyListModel:getData( index, role )
	if role == "DisplayRole" or role == "EditRole" then
		return self.data[index]
	end
	return nil
end

function MyListModel:getHorizontalHeaderData( section, role )
	return nil
end

function MyListModel:getVerticalHeaderData( section, role )
	return nil
end

function MyListModel:getRowCount( parentIndex )
	return #self.data
end

return function()
	-- creates the model instance
	local model = co.new( "qt.AbstractItemModel" ).itemModel

	-- creates a new instance of item model delegate along with a data setter function
	local listDelegate = MyListModel{ data = { "First Row", "Second Row", "Third Row" } }
	
	-- sets the list delegate into the model
	model.delegate = listDelegate.delegate

	return model
end

-------------------------------------------------------------------------------
-- Returns an AbstractItemModel component prototype factory
-------------------------------------------------------------------------------
return function( componentName )
	local AbstractItemModel = co.Component { name = componentName, provides = { delegate = "qt.IAbstractItemModelDelegate" } }

	-- defines a default empty implementation for AbstractItemViewDelegate signal handling methods
	AbstractItemModel.itemActivated = function( self, view, index ) end
	AbstractItemModel.itemClicked = function( self, view, index ) end
	AbstractItemModel.itemDoubleClicked = function( self, view, index ) end
	AbstractItemModel.itemEntered = function( self, view, index ) end
	AbstractItemModel.itemPressed = function( self, view, index ) end

	return AbstractItemModel
end


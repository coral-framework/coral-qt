-------------------------------------------------------------------------------
-- Returns an AbstractItemModelDelegate component prototype factory
-------------------------------------------------------------------------------
return function( componentName )
	local AbstractItemModelDelegate = co.Component { name = componentName, provides = { delegate = "qt.IAbstractItemModelDelegate" } }

	-- defines a default empty implementation for AbstractItemViewDelegate signal handling methods
	AbstractItemModelDelegate.itemActivated = function( self, view, index ) end
	AbstractItemModelDelegate.itemClicked = function( self, view, index ) end
	AbstractItemModelDelegate.itemDoubleClicked = function( self, view, index ) end
	AbstractItemModelDelegate.itemEntered = function( self, view, index ) end
	AbstractItemModelDelegate.itemPressed = function( self, view, index ) end
	AbstractItemModelDelegate.setData = function( self, index, data, role ) end
	AbstractItemModelDelegate.mimeData = function( self, indexes, mimeData ) end
	AbstractItemModelDelegate.mimeTypes = function( self, result ) return {} end
	AbstractItemModelDelegate.dropMimeData = function( self, mimeDta, action, row, column, parentIndex ) return false end
	
	return AbstractItemModelDelegate
end


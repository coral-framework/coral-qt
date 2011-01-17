-------------------------------------------------------------------------------
-- Returns an AbstractItemModel component prototype factory
-------------------------------------------------------------------------------
return function( componentName )
	local AbstractItemModel = co.Component { name = componentName, provides = { delegate = "qt.IAbstractItemModelDelegate" } }
	return AbstractItemModel
end


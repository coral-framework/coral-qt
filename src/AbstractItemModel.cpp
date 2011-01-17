/*
 * Coral Qt Module
 * See copyright notice in LICENSE.md
 */

#include "AbstractItemModel_Base.h"
#include <QAbstractItemModel>
#include <qt/IAbstractItemModelDelegate.h>
#include <qt/ItemDataRole.h>
#include <ValueConverters.h>

namespace
{
	const int ID_INVALID = -1;
}

inline co::int32 getInternalId( const QModelIndex& index )
{
	return index.isValid() ? static_cast<co::int32>( index.internalId() ) : ID_INVALID;
}

namespace qt {

class AbstractItemModel : public QAbstractItemModel, public qt::AbstractItemModel_Base
{
public:
	AbstractItemModel()
	{
		_delegate = 0;
	}

	virtual ~AbstractItemModel()
	{;}

	virtual int	rowCount( const QModelIndex& parent = QModelIndex() ) const
	{
		return _delegate->getRowCount( getInternalId( parent ) );
	}

	virtual int	columnCount( const QModelIndex& parent = QModelIndex() ) const
	{
		return _delegate->getColumnCount( getInternalId( parent ) );
	}

	virtual QVariant data( const QModelIndex& index, int role = Qt::DisplayRole ) const
	{
		qt::ItemDataRole itemRole = static_cast<qt::ItemDataRole>( role );

		co::Any value;
		_delegate->getData( getInternalId( index ), itemRole, value );
		if( !value.isValid() )
			return QVariant();

		return anyToVariant( value );
	}

	virtual QVariant headerData( int section, Qt::Orientation orientation, int role = Qt::DisplayRole ) const
	{
		qt::ItemDataRole itemRole = static_cast<qt::ItemDataRole>( role );
		co::Any value;
		if( orientation == Qt::Horizontal )
			_delegate->getHorizontalHeaderData( section, itemRole, value );
		else
			_delegate->getVerticalHeaderData( section, itemRole, value );

		if( !value.isValid() )
			return QVariant();

		return anyToVariant( value );
	}

	virtual QModelIndex	index( int row, int column, const QModelIndex& parent = QModelIndex() ) const
	{
		co::int32 itemIndex = _delegate->getIndex( row, column, getInternalId( parent ) );

		if( itemIndex == ID_INVALID )
			return QModelIndex();

		return createIndex( row, column, itemIndex );
	}

	virtual QModelIndex	parent( const QModelIndex& index ) const
	{
		co::int32 parentIndex = _delegate->getParentIndex( getInternalId( index ) );

		if( parentIndex == ID_INVALID )
			return QModelIndex();

		return createIndex( _delegate->getRow( parentIndex ), 0, parentIndex );
	}

	virtual Qt::ItemFlags flags( const QModelIndex & index ) const
	{
		if( !index.isValid() )
			return QAbstractItemModel::flags( index ) | Qt::ItemIsDropEnabled;

		return QAbstractItemModel::flags( index ) | Qt::ItemIsEditable | Qt::ItemIsDragEnabled | Qt::ItemIsDropEnabled;
	}

	virtual qt::IAbstractItemModelDelegate* getDelegate()
	{
		return _delegate;
	}

	virtual void setDelegate( qt::IAbstractItemModelDelegate* delegate )
	{
		_delegate = delegate;
	}

private:
	qt::IAbstractItemModelDelegate* _delegate;
};

} // namespace qt

CORAL_EXPORT_COMPONENT( qt::AbstractItemModel, AbstractItemModel )

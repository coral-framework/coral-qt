/*
 * Coral Qt Module
 * See copyright notice in LICENSE.md
 */

#include "AbstractItemModel_Base.h"
#include <QAbstractItemModel>
#include <qt/IAbstractItemModelDelegate.h>
#include <qt/ItemDataRole.h>
#include <ValueConverters.h>

namespace qt {

class AbstractItemModel : public QAbstractItemModel, public qt::AbstractItemModel_Base
{
public:
	AbstractItemModel()
	{
		_delegate = 0;
	}

	virtual int	rowCount( const QModelIndex & parent = QModelIndex() ) const
	{
		if( parent.isValid() )
			return 0;

		return 3;
	}

	virtual int	columnCount( const QModelIndex & parent = QModelIndex() ) const
	{
		return parent.isValid() ? 0 : 1;
	}

	virtual QVariant data( const QModelIndex& index, int role = Qt::DisplayRole ) const
	{
		qt::ItemDataRole itemRole = static_cast<qt::ItemDataRole>( role );

		co::Any value = _delegate->getData( index.row(), itemRole );

		if( !value.isValid() )
			return QVariant();

		return anyToVariant( value );
	}

	virtual QVariant headerData( int section, Qt::Orientation orientation, int role = Qt::DisplayRole ) const
	{
		co::Any value = ( orientation == Qt::Horizontal ) ?
						_delegate->getHorizontalHeaderData( section, static_cast<qt::ItemDataRole>( role ) ) :
						_delegate->getVerticalHeaderData( section, static_cast<qt::ItemDataRole>( role ) );

		return anyToVariant( value );
	}

	virtual QModelIndex	index( int row, int column, const QModelIndex& parent = QModelIndex() ) const
	{
		return createIndex( row, column, 0 );
	}

	virtual QModelIndex	parent( const QModelIndex& index ) const
	{
		return QModelIndex();
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

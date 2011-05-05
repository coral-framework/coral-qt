/*
 * Coral Qt Module
 * See copyright notice in LICENSE.md
 */

#include "AbstractItemModel.h"
#include <ValueConverters.h>
#include <co/Exception.h>
#include <QTextDocument>
#include <qt/Variant.h>
#include <sstream>

#include <co/Exception.h>
#include <co/IllegalArgumentException.h>
#include <QAbstractItemView>

namespace
{
	const int ID_INVALID = -1;
}

inline co::int32 getInternalId( const QModelIndex& index )
{
	return index.isValid() ? static_cast<co::int32>( index.internalId() ) : ID_INVALID;
}

namespace qt {

AbstractItemModel::AbstractItemModel()
{
	_delegate = 0;
}

AbstractItemModel::~AbstractItemModel()
{;}

int	AbstractItemModel::rowCount( const QModelIndex& parent ) const
{
	assertDelegateValid();
	return _delegate->getRowCount( getInternalId( parent ) );
}

int	AbstractItemModel::columnCount( const QModelIndex& parent ) const
{
	assertDelegateValid();
	return _delegate->getColumnCount( getInternalId( parent ) );
}

QVariant AbstractItemModel::data( const QModelIndex& index, int role ) const
{
	assertDelegateValid();

	qt::ItemDataRole itemRole = static_cast<qt::ItemDataRole>( role );

	co::Any value;
	_delegate->getData( getInternalId( index ), itemRole, value );

	QVariant result;
	anyToVariant( value, QMetaType::QVariant, result );
	return result;
}

QVariant AbstractItemModel::headerData( int section, Qt::Orientation orientation, int role ) const
{
	assertDelegateValid();

	qt::ItemDataRole itemRole = static_cast<qt::ItemDataRole>( role );

	co::Any value;
	if( orientation == Qt::Horizontal )
		_delegate->getHorizontalHeaderData( section, itemRole, value );
	else
		_delegate->getVerticalHeaderData( section, itemRole, value );

	QVariant result;
	anyToVariant( value, QMetaType::QVariant, result );
	return result;
}

QModelIndex	AbstractItemModel::index( int row, int column, const QModelIndex& parent ) const
{
	assertDelegateValid();

	co::int32 itemIndex = _delegate->getIndex( row, column, getInternalId( parent ) );

	if( itemIndex == ID_INVALID )
		return QModelIndex();

	return makeIndex( row, column, itemIndex );
}

QModelIndex	AbstractItemModel::parent( const QModelIndex& index ) const
{
	assertDelegateValid();

	co::int32 parentIndex = _delegate->getParentIndex( getInternalId( index ) );

	if( parentIndex == ID_INVALID )
		return QModelIndex();

	return makeIndex( _delegate->getRow( parentIndex ), 0, parentIndex );
}

Qt::ItemFlags AbstractItemModel::flags( const QModelIndex& index ) const
{
	assertDelegateValid();

	if( !index.isValid() )
		return Qt::NoItemFlags;

	co::int32 flags = _delegate->getFlags( getInternalId( index ) );

	Qt::ItemFlags qtFlags;
	if( flags & Qt::ItemIsSelectable )
		qtFlags |= Qt::ItemIsSelectable;

	if( flags & Qt::ItemIsEditable )
		qtFlags |= Qt::ItemIsEditable;

	if( flags & Qt::ItemIsDragEnabled )
		qtFlags |= Qt::ItemIsDragEnabled;

	if( flags & Qt::ItemIsDropEnabled )
		qtFlags |= Qt::ItemIsDropEnabled;

	if( flags & Qt::ItemIsUserCheckable )
		qtFlags |= Qt::ItemIsUserCheckable;

	if( flags & Qt::ItemIsEnabled )
		qtFlags |= Qt::ItemIsEnabled;

	if( flags & Qt::ItemIsTristate )
		qtFlags |= Qt::ItemIsTristate;

	return qtFlags;
}

qt::IAbstractItemModelDelegate* AbstractItemModel::getDelegate()
{
	return _delegate;
}

void AbstractItemModel::setDelegate( qt::IAbstractItemModelDelegate* delegate )
{
	_delegate = delegate;
}

void AbstractItemModel::notifyDataChanged( co::int32 fromIndex, co::int32 toIndex )
{
	assertDelegateValid();

	QModelIndex from = makeIndex( _delegate->getRow( fromIndex ), _delegate->getColumn( fromIndex ), fromIndex );
	QModelIndex to = makeIndex( _delegate->getRow( toIndex ), _delegate->getColumn( toIndex ), toIndex );

	emit dataChanged( from, to );
}

void AbstractItemModel::setItemSelection( const QObjectWrapper& view, int index, bool selectionState )
{
	QAbstractItemView* qtView = qobject_cast<QAbstractItemView*>( view.get() );
	if( !qtView )
		CORAL_THROW( co::IllegalArgumentException,
					 "cannot assign model to view: 'view' object is not a subclass of QAbstractItemView" );

	QModelIndex modelIndex = makeIndex( _delegate->getRow( index ), _delegate->getColumn( index ), index );
	QItemSelectionModel* sm = qtView->selectionModel();
	if( !sm )
	{
		sm = new QItemSelectionModel( this );
		qtView->setSelectionModel( sm );
	}

	sm->select( modelIndex, selectionState ? QItemSelectionModel::Select : QItemSelectionModel::Deselect );
}

void AbstractItemModel::activated( const QModelIndex& index )
{
	assertDelegateValid();
	_delegate->itemActivated( QObjectWrapper( QObject::sender() ), getInternalId( index ) );
}

void AbstractItemModel::clicked( const QModelIndex& index )
{
	assertDelegateValid();
	_delegate->itemClicked( QObjectWrapper( QObject::sender() ), getInternalId( index ) );
}

void AbstractItemModel::doubleClicked( const QModelIndex& index )
{
	assertDelegateValid();
	_delegate->itemDoubleClicked( QObjectWrapper( QObject::sender() ), getInternalId( index ) );
}

void AbstractItemModel::entered( const QModelIndex& index )
{
	assertDelegateValid();
	_delegate->itemEntered( QObjectWrapper( QObject::sender() ), getInternalId( index ) );
}

void AbstractItemModel::pressed( const QModelIndex& index )
{
	assertDelegateValid();
	_delegate->itemPressed( QObjectWrapper( QObject::sender() ), getInternalId( index ) );
}

void AbstractItemModel::assertDelegateValid() const
{
	if( !_delegate )
		CORAL_THROW( co::Exception, "delegate attribute not set" );
}

CORAL_EXPORT_COMPONENT( AbstractItemModel, AbstractItemModel )

} // namespace qt

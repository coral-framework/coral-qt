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

void AbstractItemModel::installModel( const Object& view )
{
	QAbstractItemView* qtView = qobject_cast<QAbstractItemView*>( view.get() );
	assert( qtView );
	qtView->setModel( this );

	// connect AbstractItemView slots to model signals (to allow signal forwarding to delegate of IAbstractItemModel)
	QObject::connect( this, SIGNAL( dataChanged( QModelIndex,QModelIndex )), qtView, SLOT( dataChanged(QModelIndex,QModelIndex) ) );
	QObject::connect( qtView, SIGNAL( activated( const QModelIndex& ) ), this, SLOT( activated( const QModelIndex& ) ) );
	QObject::connect( qtView, SIGNAL( clicked( const QModelIndex& ) ), this, SLOT( clicked( const QModelIndex& ) ) );
	QObject::connect( qtView, SIGNAL( doubleClicked( const QModelIndex& ) ), this, SLOT( doubleClicked( const QModelIndex& ) ) );
	QObject::connect( qtView, SIGNAL( entered( const QModelIndex& ) ), this, SLOT( entered( const QModelIndex& ) ) );
	QObject::connect( qtView, SIGNAL( pressed( const QModelIndex& ) ), this, SLOT( pressed( const QModelIndex& ) ) );
}

void AbstractItemModel::installSelectionModel( const Object& view )
{
	QAbstractItemView* qtView = qobject_cast<QAbstractItemView*>( view.get() );
	assert( qtView );
	qtView->setSelectionModel( _selectionModel );
}

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
    
    co::int32 parentIndex = getInternalId( parent );
	co::int32 itemIndex = _delegate->getIndex( row, column, parentIndex );
    
	if( itemIndex == ID_INVALID )
		return QModelIndex();

	return makeIndex( row, column, itemIndex );
}

QModelIndex	AbstractItemModel::parent( const QModelIndex& index ) const
{
	assertDelegateValid();

    co::int32 elementIndex = getInternalId( index );    
    co::int32 parentIndex = _delegate->getParentIndex( elementIndex );

	if( parentIndex == ID_INVALID )
		return QModelIndex();

	return makeIndex( _delegate->getRow( parentIndex ), _delegate->getColumn( parentIndex ), parentIndex );
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
	return _delegate.get();
}

void AbstractItemModel::setDelegate( qt::IAbstractItemModelDelegate* delegate )
{
	_delegate = delegate;
}
    
void AbstractItemModel::reset()
{
    // by now just notify begin and end (the model has already been modified)
    beginResetModel();
    endResetModel();
}

void AbstractItemModel::beginInsertColumns( co::int32 parentIndex, co::int32 startCol, co::int32 endCol )
{
    assertDelegateValid();
    
    // by now just notify columns are inserted using begin and end (the model has already been modified)
    QModelIndex parent;
    // check whether parent index is a valid index. Otherwise it has no column or row (root index)
    if( parentIndex != ID_INVALID  )
        parent = makeIndex( _delegate->getRow( parentIndex ), _delegate->getColumn( parentIndex ), parentIndex );
    QAbstractItemModel::beginInsertColumns( parent, startCol, endCol );
}
    
void AbstractItemModel::endInsertColumns()
{
    QAbstractItemModel::endInsertColumns();
}
    
void AbstractItemModel::beginRemoveColumns( co::int32 parentIndex, co::int32 startCol, co::int32 endCol )
{
    assertDelegateValid();
    
    // by now just notify begin and end (the model has already been modified)
    QModelIndex parent;
    // check whether parent index is a valid index. Otherwise it has no column or row (root index)
    if( parentIndex != ID_INVALID )
        parent = makeIndex( _delegate->getRow( parentIndex ), _delegate->getColumn( parentIndex ), parentIndex );
    QAbstractItemModel::beginRemoveColumns( parent, startCol, endCol );
}
    
void AbstractItemModel::endRemoveColumns()
{
    QAbstractItemModel::endRemoveColumns();    
}
    
void AbstractItemModel::beginInsertRows( co::int32 parentIndex, co::int32 startRow, co::int32 endRow )
{
    assertDelegateValid();
    
    // by now just notify begin and end (the model has already been modified)
    QModelIndex parent;
    // check whether parent index is a valid index. Otherwise it has no column or row (root index)
    if( parentIndex != ID_INVALID  )
        parent = makeIndex( _delegate->getRow( parentIndex ), _delegate->getColumn( parentIndex ), parentIndex );
    QAbstractItemModel::beginInsertRows( parent, startRow, endRow );
}
    
void AbstractItemModel::endInsertRows()
{
    QAbstractItemModel::endInsertRows();
}
    
void AbstractItemModel::beginRemoveRows( co::int32 parentIndex, co::int32 startRow, co::int32 endRow )
{
    assertDelegateValid();
    
    // by now just notify begin and end (the model has already been modified)
    QModelIndex parent;
    // check whether parent index is a valid index. Otherwise it has no column or row (root index)
    if( parentIndex != ID_INVALID )
        parent = makeIndex( _delegate->getRow( parentIndex ), _delegate->getColumn( parentIndex ), parentIndex );
    QAbstractItemModel::beginRemoveRows( parent, startRow, endRow );
}
    
void AbstractItemModel::endRemoveRows()
{
    QAbstractItemModel::endRemoveRows();
}
 
void AbstractItemModel::notifyDataChanged( co::int32 fromIndex, co::int32 toIndex )
{
	assertDelegateValid();
	QModelIndex from = makeIndex( _delegate->getRow( fromIndex ), _delegate->getColumn( fromIndex ), fromIndex );
	QModelIndex to = makeIndex( _delegate->getRow( toIndex ), _delegate->getColumn( toIndex ), toIndex );

	emit dataChanged( from, to );
}

void AbstractItemModel::setItemSelection( co::int32 index, bool selectionState )
{
	if( !_selectionModel )
		return;

	_selectionModel->select( makeIndex( _delegate->getRow( index ), _delegate->getColumn( index ), index ), selectionState?QItemSelectionModel::Select:QItemSelectionModel::Deselect );
}

void AbstractItemModel::clearSelection()
{
	if( !_selectionModel )
		return;

	_selectionModel->clearSelection();
}

void AbstractItemModel::activated( const QModelIndex& index )
{
	assertDelegateValid();
	_delegate->itemActivated( qt::Object( QObject::sender() ), getInternalId( index ) );
}

void AbstractItemModel::clicked( const QModelIndex& index )
{
	assertDelegateValid();
	_delegate->itemClicked( qt::Object( QObject::sender() ), getInternalId( index ) );
}

void AbstractItemModel::doubleClicked( const QModelIndex& index )
{
	assertDelegateValid();
	_delegate->itemDoubleClicked( qt::Object( QObject::sender() ), getInternalId( index ) );
}

void AbstractItemModel::entered( const QModelIndex& index )
{
	assertDelegateValid();
	_delegate->itemEntered( qt::Object( QObject::sender() ), getInternalId( index ) );
}

void AbstractItemModel::pressed( const QModelIndex& index )
{
	assertDelegateValid();
	_delegate->itemPressed( qt::Object( QObject::sender() ), getInternalId( index ) );
}

void AbstractItemModel::assertDelegateValid() const
{
	if( !_delegate )
		CORAL_THROW( co::Exception, "delegate attribute not set" );
}

CORAL_EXPORT_COMPONENT( AbstractItemModel, AbstractItemModel )

} // namespace qt

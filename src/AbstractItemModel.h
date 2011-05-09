#ifndef _ABSTRACTITEMMODEL_H_
#define _ABSTRACTITEMMODEL_H_

#include <QAbstractItemModel>
#include "AbstractItemModel_Base.h"
#include <qt/IAbstractItemModelDelegate.h>
#include <qt/ItemDataRole.h>

namespace qt {

class AbstractItemModel : public QAbstractItemModel, public qt::AbstractItemModel_Base
{
	Q_OBJECT

public:
	AbstractItemModel();

	virtual ~AbstractItemModel();

	virtual int	rowCount( const QModelIndex& parent = QModelIndex() ) const;

	virtual int	columnCount( const QModelIndex& parent = QModelIndex() ) const;

	virtual QVariant data( const QModelIndex& index, int role ) const;

	virtual QVariant headerData( int section, Qt::Orientation orientation, int role ) const;

	virtual QModelIndex	index( int row, int column, const QModelIndex& parent = QModelIndex() ) const;

	virtual QModelIndex	parent( const QModelIndex& index ) const;

	virtual Qt::ItemFlags flags( const QModelIndex & index ) const;

	virtual qt::IAbstractItemModelDelegate* getDelegate();

	virtual void setDelegate( qt::IAbstractItemModelDelegate* delegate );

	virtual void notifyDataChanged( co::int32 fromIndex, co::int32 toIndex );

	virtual void setItemSelection( const QObjectWrapper& view, co::int32 index, bool selectionState );

public slots:
	void activated( const QModelIndex& index );

	void clicked( const QModelIndex& index );

	void doubleClicked( const QModelIndex& index );

	void entered( const QModelIndex& index );

	void pressed( const QModelIndex& index );

private:
	void assertDelegateValid() const;

	// Portable wrap for createIndex() for gcc-32
	inline QModelIndex makeIndex( int row, int col, int id ) const
	{
		// explicity casts to int because gcc 32-bits can't resolve createIndex()
		// overload (between int or pointer) since they have the same size in 32-bits platforms
		return createIndex( row, col, static_cast<int>( id ) );
	}

private:
	qt::IAbstractItemModelDelegate* _delegate;
};

} // namespace qt

#endif // _ABSTRACTITEMMODEL_H_

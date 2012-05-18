#ifndef _ABSTRACTITEMMODEL_H_
#define _ABSTRACTITEMMODEL_H_

#include <QAbstractItemModel>
#include <QAbstractItemView>
#include <QItemSelectionModel.h>
#include <qt/IItemSelectionModel.h>
#include "AbstractItemModel_Base.h"
#include <qt/IAbstractItemModelDelegate.h>

#include <co/RefPtr.h>

namespace qt {

class AbstractItemModel : public QAbstractItemModel, public qt::AbstractItemModel_Base
{
	Q_OBJECT

public:
	AbstractItemModel();

	virtual ~AbstractItemModel();

	void installModel( const Object& view );

	void installSelectionModel( const Object& view );

	virtual int	rowCount( const QModelIndex& parent = QModelIndex() ) const;

	virtual int	columnCount( const QModelIndex& parent = QModelIndex() ) const;

	virtual bool setData( const QModelIndex& index, const QVariant& data, int role = Qt::EditRole );

	virtual QVariant data( const QModelIndex& index, int role ) const;

	virtual QVariant headerData( int section, Qt::Orientation orientation, int role ) const;

	virtual QModelIndex	index( int row, int column, const QModelIndex& parent = QModelIndex() ) const;

	virtual QModelIndex	parent( const QModelIndex& index ) const;

	virtual Qt::ItemFlags flags( const QModelIndex & index ) const;

	virtual QStringList mimeTypes() const;

	virtual bool dropMimeData( const QMimeData* data, Qt::DropAction action, int row, int column, const QModelIndex& parent );

	virtual QMimeData* mimeData( const QModelIndexList& indexes ) const;

	virtual Qt::DropActions AbstractItemModel::supportedDropActions() const;

	virtual qt::IAbstractItemModelDelegate* getDelegate();

	void setDelegate( qt::IAbstractItemModelDelegate* delegate );
    
    void reset();
    
    void beginInsertColumns( co::int32 parentIndex, co::int32 startCol, co::int32 endCol );
	void endInsertColumns();
	void beginRemoveColumns( co::int32 parentIndex, co::int32 startCol, co::int32 endCol );
	void endRemoveColumns();
	void beginInsertRows( co::int32 parentIndex, co::int32 startRow, co::int32 endRow );
	void endInsertRows();
	void beginRemoveRows( co::int32 parentIndex, co::int32 startRow, co::int32 endRow );
	void endRemoveRows();

	void notifyDataChanged( co::int32 fromIndex, co::int32 toIndex );

	void setItemSelection( co::int32 index, bool selectionState );

	void clearSelection();

public slots:
	void activated( const QModelIndex& index );

	void clicked( const QModelIndex& index );

	void doubleClicked( const QModelIndex& index );

	void entered( const QModelIndex& index );

	void pressed( const QModelIndex& index );

private:
	void assertDelegateValid() const;

	// Portable wrap for createIndex() for gcc-32
	inline QModelIndex makeIndex( int row, int col, int ident ) const
	{
		// explicity casts to int because gcc 32-bits can't resolve createIndex()
		// overload (between int or pointer) since they have the same size in 32-bits platforms
		return createIndex( row, col, static_cast<int>( ident ) );
	}

private:
	QItemSelectionModel* _selectionModel;
	co::RefPtr<qt::IAbstractItemModelDelegate> _delegate;
};

} // namespace qt

#endif // _ABSTRACTITEMMODEL_H_

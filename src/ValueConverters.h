/*
 * Coral Qt Module
 * See copyright notice in LICENSE.md
 */

#ifndef _VALUE_CONVERTERS_H_
#define _VALUE_CONVERTERS_H_

#include <co/Any.h>

#include <QVariant>
#include <QGenericArgument>
#include <QGenericReturnArgument>

QVariant anyToVariant( const co::Any& value );
void variantToAny( const QVariant& v, co::Any& value );
QGenericArgument anyToArgument( const co::Any& value );

#endif // _VALUE_CONVERTERS_H_

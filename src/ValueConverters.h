/*
 * Coral Qt Module
 * See copyright notice in LICENSE.md
 */

#ifndef _VALUECONVERTERS_H_
#define _VALUECONVERTERS_H_

#include <co/Any.h>
#include <QVariant>
#include <QGenericArgument>

QVariant anyToVariant( const co::Any& value );
void variantToAny( const QVariant& v, co::Any& value );
void anyToArgument( const co::Any& any, const QByteArray& argType, QVariant& var, QGenericArgument& arg );

#endif // _VALUECONVERTERS_H_

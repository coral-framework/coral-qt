/*
 * Coral Qt Module
 * See copyright notice in LICENSE.md
 */

#ifndef _VALUECONVERTERS_H_
#define _VALUECONVERTERS_H_

#include <co/Any.h>
#include <QVariant>
#include <QGenericArgument>

void anyToVariant( const co::Any& any, int expectedTypeId, QVariant& var );
void anyToVariant( const co::Any& any, const char* expectedTypeId, QVariant& var );
void variantToArgument( QVariant& var, QGenericArgument& arg );
void variantToAny( const QVariant& v, co::Any& value );

#endif // _VALUECONVERTERS_H_

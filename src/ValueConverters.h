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
/* 
    Converts a variant into one or more any values.
    Retrieves the number of expanded values.
    A single Qt value can be expanded up to 4 coral values.
    For instance: A QPoint can be expanded into two doubles.
*/
int variantToAny( const QVariant& v, co::Any& value0, co::Any& value1, co::Any& value2, co::Any& value3 );

#endif // _VALUECONVERTERS_H_

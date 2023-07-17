/*------------------------------------------------------------------------*/
/*                                                                        */
/*  ARRAY.CPP                                                             */
/*                                                                        */
/*  Copyright Borland International 1991                                  */
/*  All Rights Reserved                                                   */
/*                                                                        */
/*------------------------------------------------------------------------*/

#if !defined( CHECKS_H )
#include <Checks.h>
#endif  // CHECKS_H

#if !defined( __ARRAY_H )
#include <Array.h>
#endif  // __ARRAY_H

void Array::add( Object& toAdd )
{
    lastElementIndex++;
    while( ptrAt( lastElementIndex ) != ZERO &&
           lastElementIndex <= upperbound
         )
        lastElementIndex++;

    if( lastElementIndex > upperbound )
        reallocate( lastElementIndex - lowerbound + 1 );

    setData( lastElementIndex, &toAdd );
    itemsInContainer++;
    CHECK( itemsInContainer > 0 );
}

void Array::addAt( Object& toAdd, int atIndex )
{
    PRECONDITION( atIndex >= lowerbound );
    if( atIndex > upperbound )
        reallocate( atIndex - lowerbound + 1 );

    if( ptrAt( atIndex ) != ZERO )
        {
        delete ptrAt( atIndex );
        }

    setData( atIndex, &toAdd );
}

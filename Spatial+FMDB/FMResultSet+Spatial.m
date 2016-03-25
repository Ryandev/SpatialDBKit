/*
 FMResultSet+SpatialDBKit.h
 SpatialDBKit
 
 Created by Andrea Cremaschi on 11/03/13.
 Copyright (c) 2013 redcluster.eu. All rights reserved.
 */


#import "FMResultSet+Spatial.h"

#import <objc/runtime.h>
#import <ShapeKit/ShapeKit.h>
#import <spatialite/gaiageo.h>


void _swizzleMethods(Class c, SEL orig, SEL new)
{
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);

    bool didAdd = class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));

    if( didAdd )
    {
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
    else
    {
        method_exchangeImplementations(origMethod, newMethod);
    }
}


@implementation FMResultSet (Spatial)

static bool _hasSwizzled = NO;

+(void) addBehaviour
{
    if ( !_hasSwizzled )
    {
        _hasSwizzled = YES;

        _swizzleMethods(FMResultSet.class, @selector(objectForColumnIndex:), @selector(_swizzleObjectForColumnIndex:));
    }
}

+(void) removeBehaviour
{
    if ( _hasSwizzled )
    {
        _hasSwizzled = NO;
        
        _swizzleMethods(FMResultSet.class, @selector(_swizzleObjectForColumnIndex:), @selector(objectForColumnIndex:));
    }
}


#pragma mark - private

-(void*) _sqliteStatement
{
    /* workaround for 'receiver type *** for instance message is a forward declaration' */
    NSObject *statementObject = (NSObject*)_statement;
    void *returnValue = (__bridge void *)([statementObject valueForKey:@"_statement"]);
    return returnValue;
}

-(ShapeGeometry*) _geometryForColumnIndex:(int)columnIdx
{
    ShapeGeometry *returnGeometry = nil;
    
    if ( columnIdx < 0 )
    {
        /* invalid column */
    }
    else if ( sqlite3_column_type(self._sqliteStatement, columnIdx) == SQLITE_NULL )
    {
        /* no data */
    }
    else
    {
        const void *blobData = sqlite3_column_blob(self._sqliteStatement, columnIdx);
        int blobSize = sqlite3_column_bytes(self._sqliteStatement, columnIdx);
        
        gaiaGeomCollPtr geom = gaiaFromSpatiaLiteBlobWkb(blobData, blobSize);
        
        if ( geom )
        {
            returnGeometry = [ShapeGeometry geometryWithGeosGeometry:gaiaToGeos(geom)];

            gaiaFreeGeomColl(geom);
        }
    }

    return returnGeometry;
}

-(id) _swizzleObjectForColumnIndex:(int)columnIdx
{
    id returnObject = nil;
    
    int columnType = sqlite3_column_type(self._sqliteStatement, columnIdx);

    if ( columnType == SQLITE_BLOB )
    {
        returnObject = [self _geometryForColumnIndex:columnIdx];
    }
    
    if ( !returnObject )
    {
        returnObject = [self _swizzleObjectForColumnIndex:columnIdx];
    }

    return returnObject;
}

@end

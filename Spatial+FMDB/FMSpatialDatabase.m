/*
 FMResultSet+SpatialDBKit.h
 SpatialDBKit
 
 Created by Andrea Cremaschi on 11/03/13.
 Copyright (c) 2013 redcluster.eu. All rights reserved.
 */


#import "FMSpatialDatabase.h"

#import <spatialite/spatialite.h>

#import "FMResultSet+Spatial.h"



@implementation FMSpatialDatabase

-(id) init
{
    if (( self = [super init] ))
    {
        [self _spatialiteInit];
    }
    
    return self;
}

-(void) dealloc
{
    [self _spatialiteTerm];
}


+(NSString*) spatialiteVersion
{
    return [NSString stringWithFormat:@"%s", spatialite_version()];
}

#pragma mark - private


static NSInteger _initCount = 0;


-(void) _spatialiteInit
{
    _initCount += 1;
    
    if ( _initCount == 1 )
    {
#ifdef DEBUG
        NSLog(@"FMDB-Spatialite (init)");
#endif

        spatialite_init_geos();
        _spatialiteConn = spatialite_alloc_connection();
        spatialite_init_ex(_db, _spatialiteConn, 1);
        
        
        [FMResultSet addBehaviour];
    }
}

-(void) _spatialiteTerm
{
    _initCount -= 1;
    
    if ( _initCount == 0 )
    {
#ifdef DEBUG
        NSLog(@"FMDB-Spatialite (term)");
#endif

        spatialite_cleanup_ex(_spatialiteConn);
        
        [FMResultSet removeBehaviour];
    }
}

@end


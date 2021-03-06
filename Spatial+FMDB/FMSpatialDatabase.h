/*
 FMResultSet+SpatialDBKit.h
 SpatialDBKit
 
 Created by Andrea Cremaschi on 11/03/13.
 Copyright (c) 2013 redcluster.eu. All rights reserved.
 */



@class FMDatabase;

#import <FMDB/FMDatabase.h>

@interface FMSpatialDatabase : FMDatabase
{
@private
    void *_spatialiteConn;
}

+(NSString*) spatialiteVersion;

@end

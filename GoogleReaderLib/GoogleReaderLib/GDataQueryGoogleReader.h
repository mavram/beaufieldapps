//
//  GDataQueryGoogleReader.h
//  GoogleReaderLib
//
//  Created by mircea on 10-07-05.
//  Copyright BeaufieldAtelier 2010. All rights reserved.
//


#import "GDataQuery.h"


/*

 n	count           Number of items returns in a set of items (default 20)

 r	order           By default, items starts now, and go back time. You can change that by specifying
                    this key to the value o (default value is d)

 ot	start_time      The time (unix time, number of seconds from January 1st, 1970 00:00 UTC) from which to start to get items.
                    Only works for order r=o mode. If the time is older than one month ago, one month ago will be used instead.

 xt	exclude_target	Another set of items suffix, to be excluded from the query. For exemple, you can query all items from a feed
                    that are not flagged as read. This value start with feed/ or user/, not with !http:// or www

 c	continuation	a string used for continuation process. Each feed return not all items, but only a certain number of items.
                    You'll find in the atom feed (under the name gr:continuation) a string called continuation. Just add that string
                    as argument for this parameter, and you'll retrieve next items.

*/


@interface GDataQueryGoogleReader : GDataQuery 


+ (GDataQueryGoogleReader *)readerQueryWithFeedURL:(NSURL *)feedURL;


- (NSInteger)count;
- (void)setCount:(NSInteger)number;

- (NSDate *)startTime;
- (void)setStartTime:(NSDate *)date;

- (NSString *)continuation;
- (void)setContinuation:(NSString *)str;

- (NSString *)excludeTarget;
- (void)setExcludeTarget:(NSString *)str;
  
@end


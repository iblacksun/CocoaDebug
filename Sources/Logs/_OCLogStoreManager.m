//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_OCLogStoreManager.h"
#import "_NetworkHelper.h"

@interface _OCLogStoreManager ()
{
    dispatch_semaphore_t semaphore;
}
@end

@implementation _OCLogStoreManager

+ (instancetype)shared
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        semaphore = dispatch_semaphore_create(1);
        
        self.normalLogArray = [NSMutableArray arrayWithCapacity:[[_NetworkHelper shared] logMaxCount]];
        self.printfLogArray = [NSMutableArray arrayWithCapacity:[[_NetworkHelper shared] logMaxCount]];
        self.webLogArray = [NSMutableArray arrayWithCapacity:[[_NetworkHelper shared] logMaxCount]];
    }
    return self;
}

- (void)addLog:(_OCLogModel *)log
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    if (log.logType == CocoaDebugLogTypeNormal)
    {
        //normal
        if ([self.normalLogArray count] >= [[_NetworkHelper shared] logMaxCount]) {
            if (self.normalLogArray.count > 0) {
                [self.normalLogArray removeObjectAtIndex:0];
            }
        }
        
        [self.normalLogArray addObject:log];
    }
    else if (log.logType == CocoaDebugLogTypePrintf)
    {
        //printf
        if ([self.printfLogArray count] >= [[_NetworkHelper shared] logMaxCount]) {
            if (self.printfLogArray.count > 0) {
                [self.printfLogArray removeObjectAtIndex:0];
            }
        }
        
        [self.printfLogArray addObject:log];
    }
    else
    {
        //web
        if ([self.webLogArray count] >= [[_NetworkHelper shared] logMaxCount]) {
            if (self.webLogArray.count > 0) {
                [self.webLogArray removeObjectAtIndex:0];
            }
        }
        
        [self.webLogArray addObject:log];
    }
    
    dispatch_semaphore_signal(semaphore);
}

- (void)removeLog:(_OCLogModel *)log
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    if (log.logType == CocoaDebugLogTypeNormal)
    {
        //normal
        [self.normalLogArray removeObject:log];
    }
    else if (log.logType == CocoaDebugLogTypeNormal)
    {
        //printf
        [self.printfLogArray removeObject:log];
    }
    else
    {
        //web
        [self.webLogArray removeObject:log];
    }
    
    dispatch_semaphore_signal(semaphore);
}

- (void)resetNormalLogs
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self.normalLogArray removeAllObjects];
    dispatch_semaphore_signal(semaphore);
}

- (void)resetPrintfLogs
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self.printfLogArray removeAllObjects];
    dispatch_semaphore_signal(semaphore);
}

- (void)resetWebLogs
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self.webLogArray removeAllObjects];
    dispatch_semaphore_signal(semaphore);
}

@end

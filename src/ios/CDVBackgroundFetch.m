////
//  CDVBackgroundGeoLocation
//
//  Created by Chris Scott <chris@transistorsoft.com> on 2013-06-15
//  Largely based upon http://www.mindsizzlers.com/2011/07/ios-background-location/
//
#import "CDVBackgroundFetch.h"
#import <Cordova/CDVJSON.h>

@implementation CDVBackgroundFetch
{
    void (^_completionHandler)(UIBackgroundFetchResult);
    BOOL enabled;
    NSString *fetchCallbackId;
}

- (CDVPlugin*) initWithWebView:(UIWebView*) theWebView
{
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(onFetch:)
        name:@"BackgroundFetch"
        object:nil];
    
    return self;
}

- (void) configure:(CDVInvokedUrlCommand*)command
{    
    NSLog(@"- CDVBackgroundFetch configure");
    
    fetchCallbackId = command.callbackId;
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    [[UIApplication sharedApplication].delegate self];
     
}

-(void) onFetch:(NSNotification *) notification
{
    NSLog(@"- CDVBackgroundFetch onFetch");
    
    if (_completionHandler) {
        NSLog(@"- CDVBackgroundFetch onFetch found existing completionHandler block!");
        _completionHandler(UIBackgroundFetchResultNewData);
    }
    _completionHandler = [notification.object copy];
    
    // Inform javascript a background-fetch event has occurred.
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* result = nil;
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:fetchCallbackId];
    }];
}
-(void) finish:(CDVInvokedUrlCommand*)command
{
    NSLog(@"- CDVBackgroundFetch finish");
    [self stopBackgroundTask];
}
-(void) stopBackgroundTask
{
    UIApplication *app = [UIApplication sharedApplication];
    if (_completionHandler) {
        NSLog(@"- CDVBackgroundFetch stopBackgroundTask (remaining t: %f)", app.backgroundTimeRemaining);
        _completionHandler(UIBackgroundFetchResultNewData);
        _completionHandler = nil;
    }
}

// If you don't stopMonitorying when application terminates, the app will be awoken still when a
// new location arrives, essentially monitoring the user's location even when they've killed the app.
// Might be desirable in certain apps.
- (void)applicationWillTerminate:(UIApplication *)application 
{
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

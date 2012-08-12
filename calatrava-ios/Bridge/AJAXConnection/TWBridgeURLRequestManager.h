#import <Foundation/Foundation.h>

#import "AJAXConnection.h"
#import "JsRuntime.h"

@interface TWBridgeURLRequestManager : NSObject<JsRtRequestDelegate, AJAXConnectionDelegate>
{
  id<JsRuntime> jsRt;
  NSMutableDictionary *outstandingConnections;
  UINavigationController *root;
}

+ (TWBridgeURLRequestManager *)sharedManager;

- (id)attachToRuntime:(id<JsRuntime>)rt under:(UINavigationController *)newRoot;

@end

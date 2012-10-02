#import "TWBridgeURLRequestManager.h"

static TWBridgeURLRequestManager *bridge_instance = nil;

@implementation TWBridgeURLRequestManager

+ (TWBridgeURLRequestManager *)sharedManager
{
  if (!bridge_instance) {
    bridge_instance = [[TWBridgeURLRequestManager alloc] init];
  }
  return bridge_instance;
}

- (id)init
{
  self = [super init];
  if (self)
  {
    outstandingConnections = [NSMutableDictionary dictionaryWithCapacity:5];
  }
  return self;
}

- (id)attachToRuntime:(id<JsRuntime>)rt under:(UINavigationController *)newRoot
{
  jsRt = rt;
  root = newRoot;
  
  [jsRt setRequestDelegate:self];
  
  return self;
}

- (id)requestFrom:(NSString *)requestId
              url:(NSString *)url
               as:(NSString *)method
             with:(NSString *)body
       headers:(NSDictionary *)headers
{
  AJAXConnection *outgoing = [[AJAXConnection alloc] initWithRequestId:requestId
                                                                   url:url
                                                                  root:root
                                                            andHeaders:headers];
  
  [outstandingConnections setObject:outgoing forKey:requestId];
  [outgoing setHttpMethod:method];
  if (body) {
    [outgoing setHttpBody:body];
  }
  [outgoing setDelegate:self];
  
  [outgoing execute];
  
  return self;
}

- (void)receivedData:(NSString*)data from:(NSString *)requestId
{
  [jsRt callJsFunction:@"calatrava.inbound.successfulResponse"
              withArgs:@[requestId, data]];
  [outstandingConnections removeObjectForKey:requestId];
}

- (void)failedWithError:(NSError*)error from:(NSString *)requestId
{
  [jsRt callJsFunction:@"calatrava.inbound.failureResponse"
              withArgs:@[requestId, [NSNumber numberWithInt:400], @"Failed."]];
  [outstandingConnections removeObjectForKey:requestId];
}

@end

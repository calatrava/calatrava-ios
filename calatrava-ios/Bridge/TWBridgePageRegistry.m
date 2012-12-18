#import "TWBridgePageRegistry.h"

static TWBridgePageRegistry *bridge_instance = nil;

@interface TWBridgePageRegistry()
- (id)ensurePageWithProxyId:(NSString *)proxyId;
- (id)ensurePageWithName:(NSString *)target;
- (NSString *)convertPageNameToClassName:(NSString *)pageName;
@end

@implementation TWBridgePageRegistry

@synthesize currentPage;

+ (TWBridgePageRegistry *)sharedRegistry
{
  if (!bridge_instance)
  {
    bridge_instance = [[TWBridgePageRegistry alloc] init];
  }
  return bridge_instance;
}

- (id)init
{
  self = [super init];
  if (self)
  {
    pageProxyIds = [NSMutableDictionary dictionaryWithCapacity:8];
    pageObjects  = [NSMutableDictionary dictionaryWithCapacity:8];
  }
  
  return self;
}

- (id)attachToRuntime:(id<JsRuntime>)rt under:(UINavigationController *)newRoot
{
  jsRt = rt;
  root = newRoot;
  
  [jsRt setPageDelegate:self];
  [jsRt setTimerDelegate:self];
  
  return self;
}

- (id)dispatchEvent:(NSString *)event fromProxy:(NSString *)proxyId withArgs:(NSArray *)args
{
  NSMutableArray *eventDescriptor = [NSMutableArray arrayWithCapacity:2];
  [eventDescriptor addObject:proxyId];
  [eventDescriptor addObject:event];
  [eventDescriptor addObjectsFromArray:args];
  
  [jsRt callJsFunction:@"calatrava.inbound.dispatchEvent"
              withArgs:eventDescriptor];

  return self;
}

- (id)registerProxy:(NSString *)proxyId forPage:(NSString *)name
{
  [pageProxyIds setObject:[self convertPageNameToClassName:name] forKey:proxyId];
  return self;
}

- (id)attachHandlerTo:(NSString *)proxyId forEvent:(NSString *)name
{
  id pageObject = [self ensurePageWithProxyId:proxyId];
  
  [pageObject attachHandler:proxyId forEvent:name];
  return self;
}

- (id)valueFrom:(NSString *)proxy forField:(NSString *)field returnedTo:(NSString *)getId
{
  BaseUIViewController *pageObject = [self ensurePageWithProxyId:proxy];
  
  id fieldValue = [pageObject valueForField:field];
  [jsRt callJsFunction:@"calatrava.inbound.fieldRead" withArgs:@[proxy, getId, fieldValue]];
  return fieldValue;
}

- (id)render:(NSString *)proxy with:(NSDictionary *)dataMsg
{
  BaseUIViewController *pageObject = [self ensurePageWithProxyId:proxy];
  [pageObject render:dataMsg];
  return self;
}

- (id)registerPage:(id)page named:(NSString *)name
{
  [pageObjects setObject:page forKey:name];
  return self;
}

- (id)changeToPage:(NSString *)target
{
  NSLog(@"Change to Page: %@", target);
  currentPage = [self ensurePageWithName:target];

  [currentPage scrollToTop];

  if([[root viewControllers] containsObject:currentPage]) {
    [root popToViewController:currentPage animated:YES];
  } else{
    [root pushViewController:currentPage animated:YES];
  }

  return self;
}

- (void)alert:(NSString *)message
{
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
  [alert show];
}

- (id)openUrl:(NSString *)url
{
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
  return self;
}

- (void)timerFired:(NSTimer*)theTimer
{
  NSString *timerId = (NSString *)[theTimer userInfo];
  NSLog(@"Firing timer %@", timerId);
  [jsRt callJsFunction:@"calatrava.inbound.fireTimer"
              withArgs:@[timerId]];
}

- (id)startTimer:(NSString *)timerId timeout:(int)timeout
{
  [NSTimer scheduledTimerWithTimeInterval:timeout
                                   target:self
                                 selector:@selector(timerFired:)
                                 userInfo:timerId
                                  repeats:NO];
  return self;
}

- (id)ensurePageWithProxyId:(NSString *)proxyId
{
  return [self ensurePageWithName:[pageProxyIds objectForKey:proxyId]];
}

- (id)ensurePageWithName:(NSString *)pageName
{
  NSLog(@"pageName: %@", pageName);
  pageName = [self convertPageNameToClassName:pageName];
  NSLog(@"capitalized pageName: %@", pageName);
  
  id page = [pageObjects objectForKey:pageName];
  NSLog(@"page: %@", page);
  
  if (!page)
  {
    NSString *viewControllerName = [pageName stringByAppendingString:@"ViewController"];
    id factory = NSClassFromString(viewControllerName);
    NSLog(@"VC: %@", viewControllerName);
    page = [[factory alloc] initWithNibName:nil bundle:nil];
    [pageObjects setObject:page forKey:pageName];
  }
  
  return page;
}

- (NSString *)convertPageNameToClassName:(NSString *)pageName {
  return [pageName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[pageName substringToIndex:1] uppercaseString]];
}
@end

#import "WebRuntime.h"

@implementation WebRuntime

@synthesize pageDelegate;
@synthesize timerDelegate;
@synthesize requestDelegate;
@synthesize uiDelegate;

- (id)init
{
  if (self = [super init])
  {
    rtWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 100.0)];
    
    [rtWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/webRuntime.html", [[NSBundle mainBundle] bundlePath]]]]];
    [rtWebView setDelegate:self];
  }
  return self;
}

- (void)loadJsFile:(NSString *)path
{
  [rtWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"tw.bridge.native.load('%@');", path]];
}

- (void)callJsFunction:(NSString *)function withArgs:(NSArray *)args
{
  NSString *arg = [args componentsJoinedByString:@", "];
  [rtWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@);", function, arg]];
}

-            (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
            navigationType:(UIWebViewNavigationType)navigationType
{
  // Intercept custom location change, URL begins with "native-call:"
  NSString *funcPrefix = @"native-call:";
  NSString *requestString = [[request URL] absoluteString];
  NSLog(@"Web RT loading: %@", requestString);
  if ([requestString hasPrefix:funcPrefix])
  {
    NSString *function = [requestString substringFromIndex:[funcPrefix length]];
    NSString *argsJson = [rtWebView stringByEvaluatingJavaScriptFromString:@"tw.bridge.native.getArgs();"];
    NSLog(@"Targeting: %@", function);
    NSLog(@"With args: %@", argsJson);
    NSArray *args = (NSArray *)[NSJSONSerialization JSONObjectWithData:[argsJson dataUsingEncoding:NSASCIIStringEncoding]
                                                               options:0
                                                                 error:nil];
    
    if ([function isEqualToString:@"log"]) {
      NSLog(@"WebRTLog: %@", args);
    } else if ([function isEqualToString:@"changePage"]) {
      [pageDelegate changeToPage:[args objectAtIndex:0]];
    } else if ([function isEqualToString:@"registerProxyForPage"]) {
      [pageDelegate registerProxy:[args objectAtIndex:0] forPage:[args objectAtIndex:1]];
    } else if ([function isEqualToString:@"attachProxyEventHandler"]) {
      [pageDelegate attachHandlerTo:[args objectAtIndex:0] forEvent:[args objectAtIndex:1]];
    } else if ([function isEqualToString:@"renderProxy"]) {
      [pageDelegate render:[args objectAtIndex:0] with:[args objectAtIndex:1]];
    } else if ([function isEqualToString:@"valueOfProxyField"]) {
      [pageDelegate valueFrom:[args objectAtIndex:0] forField:[args objectAtIndex:1]];
    } else if ([function isEqualToString:@"issueRequest"]) {
      [requestDelegate requestFrom:[args objectAtIndex:0]
                               url:[args objectAtIndex:1]
                                as:[args objectAtIndex:2]
                              with:[args objectAtIndex:3]
                           headers:[args objectAtIndex:4]];
    } else if ([function isEqualToString:@"startTimerWithTimeout"]) {
      [timerDelegate startTimer:[args objectAtIndex:0] timeout:[[args objectAtIndex:1] integerValue]];
    } else if ([function isEqualToString:@"openUrl"]) {
      [uiDelegate openUrl:[args objectAtIndex:0]];
    } else {
      NSLog(@"Unknown function call!");
    }
  }
  else
  {
    NSLog(@"Unknown RT load cancelled.");
  }
  
  // Always cancel the location change
  return NO;
}

@end

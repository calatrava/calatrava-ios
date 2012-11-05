#import "WebRuntime.h"

@interface WebRuntime()

- (NSString *)argsToString:(NSArray *)args;

@end

@implementation WebRuntime

@synthesize pageDelegate;
@synthesize timerDelegate;
@synthesize requestDelegate;
@synthesize uiDelegate;
@synthesize pluginDelegate;

- (id)init
{
  if (self = [super init])
  {
    rtWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 100.0)];
    
    isLoadingHtml = YES;
    outstandingScriptLoads = 0;
    filesToLoad = [[NSMutableArray alloc] init];
    functionsToCall = [[NSMutableArray alloc] init];
    [rtWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/webRuntime.html", [[NSBundle mainBundle] bundlePath]]]]];
    [rtWebView setDelegate:self];
  }
  return self;
}

- (void)loadJsFile:(NSString *)path
{
  if (isLoadingHtml)
  {
    [filesToLoad addObject:path];
  }
  else
  {
    NSLog(@"Loading: %@", path);
    ++outstandingScriptLoads;
    [rtWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"calatrava.bridge.native.load('%@');", path]];
  }
}

- (void)callJsFunction:(NSString *)function withArgs:(NSArray *)args
{
  if (isLoadingHtml || outstandingScriptLoads > 0)
  {
    NSArray *storeArgs = args == nil ? [NSArray array] : args;
    [functionsToCall addObject:@{ @"function" : function,
     @"args" : storeArgs }];
  }
  else
  {
    NSString *funcCall = [NSString stringWithFormat:@"%@(%@);", function, [self argsToString:args]];
    NSString *returnVal = [rtWebView stringByEvaluatingJavaScriptFromString:funcCall];
    NSLog(@"Function '%@' returned: %@", funcCall, returnVal);
  }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
  isLoadingHtml = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
  isLoadingHtml = NO;
  for (NSString *file in filesToLoad) {
    [self loadJsFile:file];
  }
  [filesToLoad removeAllObjects];
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
    NSArray *functionAndArgs = [[requestString substringFromIndex:[funcPrefix length]] componentsSeparatedByString:@"&"];
    NSString *function = [functionAndArgs objectAtIndex:0];
    NSString *argsJson = [rtWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"calatrava.bridge.native.getArgs('%@');", [functionAndArgs objectAtIndex:1]]];
    NSLog(@"Targeting: %@", function);
    NSLog(@"With args: %@", argsJson);
    NSArray *args = (NSArray *)[NSJSONSerialization JSONObjectWithData:[argsJson dataUsingEncoding:NSUTF8StringEncoding]
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
      [pageDelegate render:[args objectAtIndex:1] with:[args objectAtIndex:0]];
    } else if ([function isEqualToString:@"valueOfProxyField"]) {
      [pageDelegate valueFrom:[args objectAtIndex:0] forField:[args objectAtIndex:1] returnedTo:[args objectAtIndex:2]];
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
    } else if ([function isEqualToString:@"loadComplete"]) {
      --outstandingScriptLoads;
      if (outstandingScriptLoads == 0) {
        for (NSDictionary *call in functionsToCall) {
          [self callJsFunction:[call objectForKey:@"function"]
                      withArgs:[call objectForKey:@"args"]];
        }
        [functionsToCall removeAllObjects];
      }
    } else if ([function isEqualToString:@"callPlugin"]) {
      [pluginDelegate callPlugin:[args objectAtIndex:0]
                          method:[args objectAtIndex:1]
                        withArgs:[args objectAtIndex:2]];
    } else {
      NSLog(@"Unknown function call!");
    }
    return NO;
  }
  else
  {
    if (![requestString hasSuffix:@"webRuntime.html"]) {
      NSLog(@"Unknown RT load cancelled.");
      return NO;
    } else {
      return YES;
    }
  }
}

- (NSString *)argsToString:(NSArray *)args
{
  NSMutableArray *formattedArgs = [[NSMutableArray alloc] initWithCapacity:[args count]];
  for (id arg in args)
  {
    NSString *formatted;
    if ([arg isKindOfClass:[NSString class]]) {
      formatted = [NSString stringWithFormat:@"\"%@\"", arg];
    } else if ([arg isKindOfClass:[NSNumber class]]) {
      formatted = arg;
    } else if ([arg isKindOfClass:[NSDictionary class]] || [arg isKindOfClass:[NSArray class]]) {
      NSError *err;
      NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arg options:0 error:&err];
      formatted = [[NSString alloc] initWithBytes:[jsonData bytes]
                                                        length:[jsonData length]
                                                      encoding:NSUTF8StringEncoding];
    }
    [formattedArgs addObject:formatted];
  }
  
  return [formattedArgs componentsJoinedByString:@", "];
}

@end

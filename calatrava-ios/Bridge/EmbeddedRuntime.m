#import "EmbeddedRuntime.h"
#include "JavascriptCore-dlsym.h"

static EmbeddedRuntime *nativeBridge = nil;

@interface EmbeddedRuntime ()

+ (EmbeddedRuntime *)nativeBridge;

- (id)log:(NSString *)msg;

- (id)changeToPage:(NSString *)targetPage;

- (id)registerProxy:(NSString *)proxy forPage:(NSString *)name;
- (id)attachHandlerTo:(NSString *)proxy forEvent:(NSString *)name;
- (id)valueFrom:(NSString *)proxy forField:(NSString *)field;
- (id)render:(JSValueRefAndContextRef)dataMsg onProxy:(NSString *)proxy;

- (id)requestFrom:(NSString *)reqId
              url:(NSString *)url
               as:(NSString *)method
             with:(NSString *)body
       andHeaders:(JSValueRefAndContextRef)headers;

- (id)startTimer:(NSString *)timerId timeout:(int)timeout;

- (id)openUrl:(NSString *)url;

@end

@implementation EmbeddedRuntime

@synthesize pageDelegate;
@synthesize timerDelegate;
@synthesize requestDelegate;
@synthesize uiDelegate;

+ (EmbeddedRuntime *)nativeBridge
{
  return nativeBridge;
}

- (id) init
{
  if (self = [super init])
  {
    nativeBridge = self;

    // Fetch JS symbols
    [JSCocoaSymbolFetcher populateJavascriptCoreSymbols];

    jsCore = [JSCocoaController sharedController];
    [jsCore setUseJSLint:NO];
    
    // TODO: Load the embedded bridge
    [self loadJsFile:[NSString stringWithFormat:@"%@/embeddedBridge.js",
                      [[NSBundle mainBundle] bundlePath]]];
  }
  return self;
}

- (void) loadJsFile:(NSString *)path
{
  [jsCore evalJSFile:path];
}

- (void) callJsFunction:(NSString *)function withArgs:(NSArray *)args
{
  [jsCore callJSFunctionNamed:function withArgumentsArray:args];
}

- (id)log:(NSString *)msg
{
  NSLog(@"From JS: %@", msg);
  return self;
}

- (id)changeToPage:(NSString *)targetPage
{
  [pageDelegate changeToPage:targetPage];
  return targetPage;
}

- (id)registerProxy:(NSString *)proxy forPage:(NSString *)name
{
  [pageDelegate registerProxy:proxy forPage:name];
  return self;
}

- (id)attachHandlerTo:(NSString *)proxy forEvent:(NSString *)name
{
  [pageDelegate attachHandlerTo:proxy forEvent:name];
  return self;
}

- (id)valueFrom:(NSString *)proxy forField:(NSString *)field
{
  [pageDelegate valueFrom:proxy forField:field];
  return self;
}

- (id)render:(JSValueRefAndContextRef)dataMsg onProxy:(NSString *)proxy
{
  NSDictionary *objectFromJavascript = nil;
  [JSCocoaFFIArgument unboxJSValueRef:dataMsg.value
                             toObject:&objectFromJavascript
                            inContext:dataMsg.ctx];
  [pageDelegate render:proxy with:objectFromJavascript];
  return self;
}

- (id)requestFrom:(NSString *)reqId
              url:(NSString *)url
               as:(NSString *)method
             with:(NSString *)body
       andHeaders:(JSValueRefAndContextRef)headers
{
  NSDictionary *headersFromJs;
  [JSCocoaFFIArgument unboxJSValueRef:headers.value
                             toObject:&headersFromJs
                            inContext:headers.ctx];
  [requestDelegate requestFrom:reqId url:url as:method with:body headers:headersFromJs];
  return self;
}

- (id)startTimer:(NSString *)timerId timeout:(int)timeout
{
  [timerDelegate startTimer:timerId timeout:timeout];
  return self;
}

- (id)openUrl:(NSString *)url
{
  [uiDelegate openUrl:url];
  return self;
}

@end

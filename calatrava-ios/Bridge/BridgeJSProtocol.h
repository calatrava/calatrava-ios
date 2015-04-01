
#import <JavaScriptCore/JavaScriptCore.h>

@protocol BridgeJSProtocol <JSExport>

- (void)changeToPage:(NSString *)target;
- (void)registerProxy:(NSString *)proxy forPage:(NSString *)name;
- (void)attachHandlerTo:(NSString *)proxy forEvent:(NSString *)name;
- (void)valueFrom:(NSString *)proxy forField:(NSString *)field returnedTo:(NSString *)getId;
- (void)render:(NSString *)proxy with:(NSDictionary *)dataMsg;
- (void)requestFrom:(NSString *)reqId
              url:(NSString *)url
               as:(NSString *)method
             with:(NSString *)body
          headers:(NSDictionary *)headers;
- (void)openUrl:(NSString *)url;
- (void)startTimer:(NSString *)timerId timeout:(int)timeout;
- (void)callPlugin:(NSString *)plugin
          method:(NSString *)method
        withArgs:(NSDictionary *)args;
- (void)log:(NSString *)string;

@end

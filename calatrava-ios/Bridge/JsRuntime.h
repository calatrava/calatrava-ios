#import <Foundation/Foundation.h>

@protocol JsRtPageDelegate <NSObject>

- (id)changeToPage:(NSString *)target;

- (id)registerProxy:(NSString *)proxy forPage:(NSString *)name;
- (id)attachHandlerTo:(NSString *)proxy forEvent:(NSString *)name;
- (id)valueFrom:(NSString *)proxy forField:(NSString *)field returnedTo:(NSString *)getId;
- (id)render:(NSString *)proxy with:(NSDictionary *)dataMsg;

@end

@protocol JsRtRequestDelegate <NSObject>

- (id)requestFrom:(NSString *)reqId
              url:(NSString *)url
               as:(NSString *)method
             with:(NSString *)body
          headers:(NSDictionary *)headers;

@end

@protocol JsRtUiDelegate <NSObject>

- (id)openUrl:(NSString *)url;

@end

@protocol JsRtTimerDelegate <NSObject>

- (id)startTimer:(NSString *)timerId timeout:(int)timeout;

@end

@protocol JsRtPluginDelegate <NSObject>

- (id)callPlugin:(NSString *)plugin
          method:(NSString *)method
        withArgs:(NSDictionary *)args;

@end

@protocol JsRuntime <NSObject>

- (void)loadJsFile:(NSString *)path;
- (void)callJsFunction:(NSString *)function withArgs:(NSArray *)args;

- (id)setPageDelegate:(id<JsRtPageDelegate>)delegate;
- (id)setRequestDelegate:(id<JsRtRequestDelegate>)delegate;
- (id)setUiDelegate:(id<JsRtUiDelegate>)delegate;
- (id)setTimerDelegate:(id<JsRtTimerDelegate>)delegate;
- (id)setPluginDelegate:(id<JsRtPluginDelegate>)delegate;

@end

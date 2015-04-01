
#import "JSCoreRuntime.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface JSCoreRuntime(){
    JSContext *context;
}

@end

@implementation JSCoreRuntime

- (id)init
{
    if (self = [super init])
    {
        context = [[JSContext alloc]init];
        context[@"nativeRuntime"] = self;
    }
    return self;
}

- (void)loadJsFile:(NSString *)path
{
    NSString *jsString = [self stringFromFile:path];
    [context evaluateScript:jsString];
}

-(NSString*)stringFromFile:(NSString*)filePath{
    NSError *error;
    
    NSString *javascriptFile =[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];

    if (error) {
        NSLog(@"Error:%@",error);
    }
    
    return javascriptFile;
}

- (id)callJsFunction:(NSString *)function withArgs:(NSArray *)args
{
    JSValue *functionValue = [context evaluateScript:function];
    return [functionValue callWithArguments:args];
}

- (void)changeToPage:(NSString *)target{
    [self.pageDelegate changeToPage:target];
}

- (void)log:(NSString *)string{
    NSLog(@"%@",string);
}

- (void)registerProxy:(NSString *)proxy forPage:(NSString *)name{
    [self.pageDelegate registerProxy:proxy forPage:name];
}
- (void)attachHandlerTo:(NSString *)proxy forEvent:(NSString *)name{
    [self.pageDelegate attachHandlerTo:proxy forEvent:name];
}
- (void)valueFrom:(NSString *)proxy forField:(NSString *)field returnedTo:(NSString *)getId{
    [self.pageDelegate valueFrom:proxy forField:field returnedTo:getId];
}
- (void)render:(NSString *)proxy with:(NSDictionary *)dataMsg{
    [self.pageDelegate render:proxy with:dataMsg];
}
- (void)requestFrom:(NSString *)reqId
                url:(NSString *)url
                 as:(NSString *)method
               with:(NSString *)body
            headers:(NSDictionary *)headers{
    [self.requestDelegate requestFrom:reqId url:url as:method with:body headers:headers];
}
- (void)openUrl:(NSString *)url{
    [self.uiDelegate openUrl:url];
}
- (void)startTimer:(NSString *)timerId timeout:(int)timeout{
    [self.timerDelegate startTimer:timerId timeout:timeout];
}
- (void)callPlugin:(NSString *)plugin
            method:(NSString *)method
          withArgs:(NSDictionary *)args{
    [self.pluginDelegate callPlugin:plugin method:method withArgs:args];
}

@end



#import "JSCoreRuntime.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface JSCoreRuntime(){
    JSContext *context;
}

- (NSString *)argsToString:(NSArray *)args;
- (id)objectFromArgs:(NSArray *) args
             AtIndex:(int)index;

@end

@implementation JSCoreRuntime

@synthesize pageDelegate;
@synthesize timerDelegate;
@synthesize requestDelegate;
@synthesize uiDelegate;
@synthesize pluginDelegate;

- (id)init
{
    if (self = [super init])
    {
        context = [[JSContext alloc]init];
        filesToLoad = [[NSMutableArray alloc] init];
        functionsToCall = [[NSMutableArray alloc] init];
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

- (void)callJsFunction:(NSString *)function withArgs:(NSArray *)args
{
  NSString *funcCall = [NSString stringWithFormat:@"%@(%@);", function, [self argsToString:args]];
  JSValue *returnVal = [context evaluateScript:funcCall];
  NSLog(@"Function '%@' returned: %@", funcCall, returnVal.toString);
}

- (NSString *)argsToString:(NSArray *)args
{
    NSMutableArray *formattedArgs = [[NSMutableArray alloc] initWithCapacity:[args count]];
    for (id arg in args)
    {
        NSString *formatted;
        if ([arg isKindOfClass:[NSString class]]) {
            formatted = [arg stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
            formatted = [NSString stringWithFormat:@"\"%@\"", [formatted stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]];
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

- (id)objectFromArgs:(NSArray *) args
             AtIndex:(int)index
{
    id obj = [args objectAtIndex:index];
    if (obj == [NSNull null])
    {
        return nil;
    }
    else
    {
        return obj;
    }
}

- (void)changeToPage:(NSString *)target{
    [self.pageDelegate changeToPage:target];
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


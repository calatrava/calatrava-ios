
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

@end


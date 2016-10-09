//
//  ZCBaseRequest.m
//  SZCEvolution
//
//  Created by choice-ios1 on 16/9/29.
//  Copyright © 2016年 albertjson. All rights reserved.
//

#import "ZCBaseRequest.h"
#import "ZCHTTPError.h"
#import <AFNetworking.h>
#import <JSONModel.h>

@interface ZCBaseRequest()
{
    id _responseModel;
}

@end

@implementation ZCBaseRequest

- (instancetype)getParseJSONModel
{
    NSString * modelClassName = [self modelClassName];
    if (modelClassName==nil||[modelClassName isEqualToString:@""]) {
        return self.responseJSONObject;
    }
    return _responseModel;
}
- (NSString*)modelClassName;
{
    return nil;
}
/*
 1. 若需要定义json--model，可在以下方法中处理  class ： YTKNetworkAgent
 - (void)handleRequestResult:(NSURLSessionTask *)task responseObject:(id)responseObject
 2. 需要进一步处理error，例如error message定义等等，也在上面方法进行处理
 3. 需要把服务端正常返回的错误格式的数据定义为http的错误，待处理
 4. 需要把token失效的问题统一处理的错误，待处理
 @param success <#success description#>
 @param failure <#failure description#>
 */

/*
///  The validator will be used to test if `responseJSONObject` is correctly formed.
- (nullable id)jsonValidator
{
    //此方法有两个作用
    1. 校验返回的数据格式与此方法内数据格式是否一致[此方法内可缺省，不是所有参数都要写，但是必须要写，为了统一处理错误]
    2. 校验返回的数据字段类型，防止给不符合该字段的类型导致程序的异常
    如果返回的数据有可能为null，则格式需指定为NSObject类型的
}
 */

//以下四个方法子类可以原始拥有，也可以`[super requestCompletePreprocessor];`进行基础上编写，也可以直接重写。但是一般情况下建议继承的基础上

///  Called on background thread after request succeded but before switching to main thread. Note if
///  cache is loaded, this method WILL be called on the main thread, just like `requestCompleteFilter`.
- (void)requestCompletePreprocessor
{
    //json转model
    [self JSONConvertModel];
}
- (void)JSONConvertModel
{
    NSLog(@"---%@",[self modelClassName]);
    
    NSString * modelClassName = [self modelClassName];
    if (!modelClassName||[modelClassName isEqualToString:@""]) {
        return;
    }
    Class modelClass = NSClassFromString(modelClassName);
    
    NSError * error = nil;
    
    if ([self.responseJSONObject isKindOfClass:[NSDictionary class]]) {
        
        _responseModel = [[modelClass alloc] initWithDictionary:self.responseJSONObject error:&error];
        
    }else if ([self.responseJSONObject isKindOfClass:[NSArray class]]){
        
        _responseModel = [modelClass arrayOfModelsFromDictionaries:self.responseJSONObject error:&error];
        
    }else{
        //此处为请求成功但是返回的数据既不是字典又不是数组，理论上是"<null>"但是这里不需要做处理,AF已过滤掉
    }
    
    //后面可以换成断言
    NSLog(@"[ZCBaseRequest]--[JSONMODELError]=%@",error);
}

///  Called on the main thread after request succeeded.
- (void)requestCompleteFilter
{
    
}

///  Called on background thread after request succeded but before switching to main thread. See also
///  `requestCompletePreprocessor`.
- (void)requestFailedPreprocessor
{
    //可以在此方法内处理token失效的情况，所有http请求统一走此方法，即会统一调用

    //note：子类如需继承，必须必须调用 [super requestFailedPreprocessor];
    
    NSError * error = self.error;
    
    if ([error.domain isEqualToString:AFURLResponseSerializationErrorDomain])
    {
        //AFNetworking处理过的错误
        
    }else if ([error.domain isEqualToString:YTKRequestValidationErrorDomain])
    {
        //猿题库处理过的错误
        
    }else{
        //系统级别的domain错误，无网络等[NSURLErrorDomain]
        //根据error的code去定义显示的信息，保证显示的内容可以便捷的控制
    }
    //初始化httpError的值
    //self.httpError = [[ZCHTTPError alloc] initWithDomain:<#(nonnull NSErrorDomain)#> code:<#(NSInteger)#> userInfo:<#(nullable NSDictionary *)#>];

}

///  Called on the main thread when request failed.
- (void)requestFailedFilter
{
    
}

@end

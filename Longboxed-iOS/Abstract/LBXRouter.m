//
//  LBXRouter.m
//  Longboxed-iOS
//
//  Created by johnrhickey on 7/8/14.
//  Copyright (c) 2014 Longboxed. All rights reserved.
//

#import "LBXRouter.h"
#import "LBXEndpoints.h"
#import "NSString+URLQuery.h"

#import "NSData+Base64.h"

#import <UICKeyChainStore.h>

@implementation LBXRouter

- (NSString *)baseURLString
{
    return @"http://longboxed-staging.herokuapp.com";
}

- (void)setAuth
{
    UICKeyChainStore *store = [UICKeyChainStore keyChainStore];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", store[@"username"], store[@"password"]];
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodingWithLineLength:80]];
    [[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:@"Authorization" value:authValue];
}

// Routing
//- (RKRouter *)routerWithQueryParameters:(NSDictionary *)parameters
//{
//    RKRouter *router = [[RKRouter alloc] initWithBaseURL:[NSURL URLWithString:self.baseURLString]];
//    
//    NSDictionary *endpointDict = [LBXEndpoints endpoints];
//    
//    // Issues
//    [router.routeSet addRoute:[RKRoute routeWithName:@"Issues Collection"
//                                         pathPattern:[NSString addQueryStringToUrlString:endpointDict[@"Issues Collection"]
//                                                                          withDictionary:parameters]
//                                              method:RKRequestMethodGET]]; // Required parameter is ?date=2014-06-25
//    
//    [router.routeSet addRoute:[RKRoute routeWithName:@"Issues Collection for Current Week"
//                                         pathPattern:endpointDict[@"Issues Collection for Current Week"]
//                                              method:RKRequestMethodGET]];
//    
//    [router.routeSet addRoute:[RKRoute routeWithName:@"Issue"
//                                         pathPattern:endpointDict[@"Issue"]
//                                              method:RKRequestMethodGET]];
//    
//    // Titles
//    [router.routeSet addRoute:[RKRoute routeWithName:@"Titles Collection"
//                                         pathPattern:[NSString addQueryStringToUrlString:endpointDict[@"Titles Collection"]
//                                                                          withDictionary:parameters]
//                                              method:RKRequestMethodGET]]; // Optional parameter is ?page=2
//    
//    [router.routeSet addRoute:[RKRoute routeWithName:@"Title"
//                                         pathPattern:endpointDict[@"Title"]
//                                              method:RKRequestMethodGET]];
//    
//    [router.routeSet addRoute:[RKRoute routeWithName:@"Issues for Title"
//                                         pathPattern:[NSString addQueryStringToUrlString:endpointDict[@"Issues for Title"]
//                                                                          withDictionary:parameters]
//                                              method:RKRequestMethodGET]]; // Optional parameter is ?page=2
//    
//    [router.routeSet addRoute:[RKRoute routeWithName:@"Autocomplete for Title"
//                                         pathPattern:[NSString addQueryStringToUrlString: endpointDict[@"Autocomplete for Title"] withDictionary:parameters]
//                                              method:RKRequestMethodGET]]; // Required parameter is ?search=spider
//    
//    // Publishers
//    [router.routeSet addRoute:[RKRoute routeWithName:@"Publisher Collection"
//                                         pathPattern:endpointDict[@"Publisher Collection"]
//                                              method:RKRequestMethodGET]];
//    
//    [router.routeSet addRoute:[RKRoute routeWithName:@"Publisher"
//                                         pathPattern:endpointDict[@"Publisher"]
//                                              method:RKRequestMethodGET]];
//    
//    [router.routeSet addRoute:[RKRoute routeWithName:@"Titles for Publisher"
//                                         pathPattern:[NSString addQueryStringToUrlString:endpointDict[@"Titles for Publisher"]
//                                                                          withDictionary:parameters]
//                                              method:RKRequestMethodGET]]; // Optional parameter is ?page=2
//    
//    // Users
//    [router.routeSet addRoute:[RKRoute routeWithName:@"Login"
//                                         pathPattern:endpointDict[@"Login"]
//                                              method:RKRequestMethodGET]];
//    
//    [router.routeSet addRoute:[RKRoute routeWithName:@"User Pull List"
//                                         pathPattern:endpointDict[@"User Pull List"]
//                                              method:RKRequestMethodGET]];
//    
//    [router.routeSet addRoute:[RKRoute routeWithName:@"Bundle Resources for User"
//                                         pathPattern:endpointDict[@"Bundle Resources for User"]
//                                              method:RKRequestMethodGET]];
//    
//    [router.routeSet addRoute:[RKRoute routeWithName:@"Latest Bundle"
//                                         pathPattern:endpointDict[@"Latest Bundle"]
//                                              method:RKRequestMethodGET]];
    
//    return router;
//}


@end
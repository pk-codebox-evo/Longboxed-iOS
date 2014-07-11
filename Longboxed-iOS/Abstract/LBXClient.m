//
//  LBXClient.m
//  Longboxed-iOS
//
//  Created by johnrhickey on 6/29/14.
//  Copyright (c) 2014 Longboxed. All rights reserved.
//

#import "LBXClient.h"
#import "LBXMap.h"
#import "LBXRouter.h"
#import "LBXDescriptors.h"

#import "NSData+Base64.h"

#import <UICKeyChainStore.h>

@interface LBXClient()

@property (nonatomic) NSURLSession *session;

@end

@implementation LBXClient

- (instancetype)init {
    if (self = [super init]) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self;
}

// TODO: Remove this
- (void)fetch:(NSString *)location withCredentials:(BOOL)credentials completion:(void (^)(id, NSURLResponse*, NSError*))completion {
    [self.class setNetworkActivityIndicatorVisible:YES];
    
    NSString *urlString = [NSString stringWithFormat:@"http://www.longboxed.com/api/v1/%@",location];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // Auth if necessary
    if (credentials) {
        UICKeyChainStore *store = [UICKeyChainStore keyChainStore];
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", store[@"username"], store[@"password"]];
        NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodingWithLineLength:80]];
        [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    }
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self.class setNetworkActivityIndicatorVisible:NO];
        
        if (error) {
            NSLog(@"%@",error);
            
            if (completion) {
                completion(nil, response, error);
            }
        }
        else {
            NSError *error2 = nil;
            id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            if (error2) {
                NSLog(@"%@",error2);
            }
            if (completion) {
                completion(json, response, error2);
            }
        }
    }];
    [task resume];
}

- (void)fetchWithRouteName:(NSString *)routeName object:(id)object queryParameters:(NSDictionary *)parameters credentials:(BOOL)credentials completion:(void (^)(RKMappingResult*, RKObjectRequestOperation*, NSError*))completion {
    
    // Set up the routers with NSString names and parameters
    RKRouter *APIRouter = [LBXRouter routerWithQueryParameters:parameters];

    // Set up the object mapping and response descriptors
    NSArray *responseDescriptors = [LBXDescriptors responseDescriptors];
    
    // Create the URL request with the proper routing
    LBXTitle *title = [LBXTitle new];
    title.titleID = [NSNumber numberWithInt:1];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[APIRouter URLForObject:object method:RKRequestMethodPOST]];
    
    // Auth
    if (credentials) {
        UICKeyChainStore *store = [UICKeyChainStore keyChainStore];
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", store[@"username"], store[@"password"]];
        NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodingWithLineLength:80]];
        [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    }
    
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:responseDescriptors];
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (completion) {
            completion(mappingResult, operation, nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Operation failed with error: %@", error);
        if (completion) {
            completion(nil, operation, error);
        }
    }];
    
    [objectRequestOperation start];
}

// Issues
// TODO: Add pagination parameter to the rest of the methods? Maybe?
- (void)fetchIssuesCollectionWithDate:(NSDate *)date page:(NSNumber*)page completion:(void (^)(NSArray *, RKObjectRequestOperation *, NSError *))completion
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    // For debugging
//    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
//    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    NSDictionary *parameters = @{@"date" : [formatter stringFromDate:date]};
    [self fetchWithRouteName:@"Issues Collection" object:nil queryParameters:parameters credentials:NO completion:^(RKMappingResult *mappingResult, RKObjectRequestOperation *response, NSError *error) {
        completion(mappingResult.array, response, error);
    }];
}

- (void)fetchThisWeeksComicsWithCompletion:(void (^)(NSArray*, RKObjectRequestOperation*, NSError*))completion {
    [self fetchWithRouteName:@"Issues Collection for Current Week" object:nil queryParameters:nil credentials:NO completion:^(RKMappingResult *mappingResult, RKObjectRequestOperation *response, NSError *error) {
        completion(mappingResult.array, response, error);
    }];
}

- (void)fetchIssue:(NSNumber*)issueID withCompletion:(void (^)(LBXIssue*, RKObjectRequestOperation*, NSError*))completion {
    // Create an LBXIssue object for the payload
    LBXIssue *requestIssue = [LBXIssue new];
    requestIssue.issueID = issueID;
    
    [self fetchWithRouteName:@"Issue" object:requestIssue queryParameters:nil credentials:NO completion:^(RKMappingResult *mappingResult, RKObjectRequestOperation *response, NSError *error) {
        completion(mappingResult.firstObject, response, error);
    }];
}

// Titles
- (void)fetchTitlesWithCompletion:(void (^)(NSArray*, RKObjectRequestOperation*, NSError*))completion {
    [self fetchWithRouteName:@"Titles Collection" object:nil queryParameters:nil credentials:NO completion:^(RKMappingResult *mappingResult, RKObjectRequestOperation *response, NSError *error) {
        completion(mappingResult.array, response, error);
    }];
}

- (void)fetchTitle:(NSNumber*)titleID withCompletion:(void (^)(LBXTitle*, RKObjectRequestOperation*, NSError*))completion {
    // Create an LBXIssue object for the payload
    LBXTitle *requestTitle = [LBXTitle new];
    requestTitle.titleID = titleID;
    
    [self fetchWithRouteName:@"Title" object:requestTitle queryParameters:nil credentials:NO completion:^(RKMappingResult *mappingResult, RKObjectRequestOperation *response, NSError *error) {
        completion(mappingResult.firstObject, response, error);
    }];
}

- (void)fetchIssuesForTitle:(NSNumber*)titleID withCompletion:(void (^)(NSArray*, RKObjectRequestOperation*, NSError*))completion {
    // Create an LBXTitle object for the payload
    LBXTitle *requestTitle = [LBXTitle new];
    requestTitle.titleID = titleID;
    
    [self fetchWithRouteName:@"Issues for Title" object:requestTitle queryParameters:nil credentials:NO completion:^(RKMappingResult *mappingResult, RKObjectRequestOperation *response, NSError *error) {
        completion(mappingResult.array, response, error);
    }];
}

// Publishers
- (void)fetchPublishersWithCompletion:(void (^)(NSArray *, RKObjectRequestOperation*, NSError*))completion {
    [self fetchWithRouteName:@"Publisher Collection" object:nil queryParameters:nil credentials:NO completion:^(RKMappingResult *mappingResult, RKObjectRequestOperation *response, NSError *error) {
        completion(mappingResult.array, response, error);
    }];
}

- (void)fetchPublisher:(NSNumber*)publisherID withCompletion:(void (^)(LBXPublisher*, RKObjectRequestOperation*, NSError*))completion {
    // Create an LBXPublisher object for the payload
    LBXPublisher *requestPublisher = [LBXPublisher new];
    requestPublisher.publisherID = publisherID;
    [self fetchWithRouteName:@"Publisher" object:requestPublisher queryParameters:nil credentials:NO completion:^(RKMappingResult *mappingResult, RKObjectRequestOperation *response, NSError *error) {
        completion(mappingResult.firstObject, response, error);
    }];
}

- (void)fetchTitlesForPublisher:(NSNumber*)publisherID withCompletion:(void (^)(NSArray*, RKObjectRequestOperation*, NSError*))completion {
    // Create an LBXPublisher object for the payload
    LBXPublisher *requestPublisher = [LBXPublisher new];
    requestPublisher.publisherID = publisherID;
    [self fetchWithRouteName:@"Titles for Publisher" object:requestPublisher queryParameters:nil credentials:NO completion:^(RKMappingResult *mappingResult, RKObjectRequestOperation *response, NSError *error) {
        completion(mappingResult.array, response, error);
    }];
}


// Users
- (void)fetchLogInWithCompletion:(void (^)(LBXUser*, RKObjectRequestOperation*, NSError*))completion {
    [self fetchWithRouteName:@"Login" object:nil queryParameters:nil credentials:YES completion:^(RKMappingResult *mappingResult, RKObjectRequestOperation *response, NSError *error) {
        
        // Store the user ID
        LBXUser *user = [LBXUser new];
        user = mappingResult.firstObject;
        UICKeyChainStore *store = [UICKeyChainStore keyChainStore];
        [UICKeyChainStore setString:[NSString stringWithFormat:@"%@", user.userID] forKey:@"id"];
        [store synchronize];
        
        completion(mappingResult.firstObject, response, error);
    }];
}

- (void)fetchPullListWithCompletion:(void (^)(NSArray*, RKObjectRequestOperation*, NSError*))completion {
    // Create a user with the id to put in the URL path
    LBXUser *user = [LBXUser new];
    UICKeyChainStore *store = [UICKeyChainStore keyChainStore];
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    user.userID = [f numberFromString:store[@"id"]];
    
    [self fetchWithRouteName:@"User Pull List" object:user queryParameters:nil credentials:YES completion:^(RKMappingResult *mappingResult, RKObjectRequestOperation *response, NSError *error) {
        completion(mappingResult.array, response, error);
    }];
}

- (void)addTitleToPullList:(NSNumber*)titleID withCompletion:(void (^)(NSArray*, RKObjectRequestOperation*, NSError*))completion {
    // Create a user with the id to put in the URL path
    LBXUser *user = [LBXUser new];
    UICKeyChainStore *store = [UICKeyChainStore keyChainStore];
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    user.userID = [f numberFromString:store[@"id"]];
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);

    
    NSDictionary *parameters = @{@"title_id" : [titleID stringValue]};
    
    [self fetchWithRouteName:@"Add Title to Pull List" object:user queryParameters:parameters credentials:YES completion:^(RKMappingResult *mappingResult, RKObjectRequestOperation *response, NSError *error) {
        completion(mappingResult.array, response, error);
    }];
}

- (void)removeTitleFromPullList:(NSNumber*)titleID withCompletion:(void (^)(NSArray*, RKObjectRequestOperation*, NSError*))completion {
    // Create a user with the id to put in the URL path
    LBXUser *user = [LBXUser new];
    UICKeyChainStore *store = [UICKeyChainStore keyChainStore];
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    user.userID = [f numberFromString:store[@"id"]];
    
    NSDictionary *parameters = @{@"title_id" : [titleID stringValue]};
    
    [self fetchWithRouteName:@"Remove Title from Pull List" object:user queryParameters:parameters credentials:YES completion:^(RKMappingResult *mappingResult, RKObjectRequestOperation *response, NSError *error) {
        completion(mappingResult.array, response, error);
    }];
}

- (void)fetchBundlesWithCompletion:(void (^)(id, NSURLResponse*, NSError*))completion {
    [self fetch:[NSString stringWithFormat:@"users/%@/bundles/", [UICKeyChainStore keyChainStore][@"id"]] withCredentials:YES completion:completion];
}








// http://oleb.net/blog/2009/09/managing-the-network-activity-indicator/
+ (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible {
    static NSUInteger kNetworkIndicatorCount = 0;
    
    if (setVisible) {
        kNetworkIndicatorCount++;
    }
    else {
        kNetworkIndicatorCount--;
    }
    
    // The assertion helps to find programmer errors in activity indicator management.
    // Since a negative NumberOfCallsToSetVisible is not a fatal error,
    // it should probably be removed from production code.
    NSAssert(kNetworkIndicatorCount >= 0, @"Network Activity Indicator was asked to hide more often than shown");
    
    // Display the indicator as long as our static counter is > 0.
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(kNetworkIndicatorCount > 0)];
    });
}

@end

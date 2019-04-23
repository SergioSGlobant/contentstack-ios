//
//  FallbackTest.m
//  ContentstackTest
//
//  Created by Uttam Ukkoji on 23/04/19.
//  Copyright © 2019 Contentstack. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Contentstack/Contentstack.h>

static NSInteger kRequestTimeOutInSeconds = 400;

@interface FallbackTest :  XCTestCase {
    Stack *csStack;
    Config *config;
}

@end

@implementation FallbackTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    config = [[Config alloc] init];
//    config.host = @"api.blz-contentstack.com";
//    csStack = [Contentstack stackWithAPIKey:@"bltdd35c1a9e76490cc" accessToken:@"cs8bfa982bac402ba16e91d2b6" environmentName:@"env1" config:config];
    
    config = [[Config alloc] init];
    config.host = @"dev3-new-api.contentstack.io";//@"cdn.contentstack.io";//@"stagcontentstack.global.ssl.fastly.net";//@"dev-cdn.contentstack.io";
    csStack = [Contentstack stackWithAPIKey:@"bltd72a21ff3caad6d4" accessToken:@"cs25757e03ba946c3360ccb5ac" environmentName:@"env1" config:config];
}

- (void)waitForRequest {
    [self waitForExpectationsWithTimeout:kRequestTimeOutInSeconds handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Could not perform operation (Timed out) ~ ERR: %@", error.userInfo);
        }
    }];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark -
#pragma mark Test Case - Header


- (void)testGetEntryFallback {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch Set Header"];
    Entry *entry = [[csStack contentTypeWithName:@"product"] entryWithUID:@"bltf6156698a6494737"];
    entry.language = MARATHI_INDIA;
//    [entry addParamKey:@"locale" andValue:@"mr-in"];
    
    [entry fetch:^(ResponseType type, NSError * _Nullable error) {
        XCTAssertEqual(entry.language, HINDI_INDIA);
        
        [expectation fulfill];
    }];
    [self waitForRequest];
}

- (void)testGetQueryFallback {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch Set Header"];
    Query *query = [[csStack contentTypeWithName:@"product"] query];
    [query language: MARATHI_INDIA];
    //    [entry addParamKey:@"locale" andValue:@"mr-in"];
    
    [query find:^(ResponseType type, QueryResult * _Nullable result, NSError * _Nullable error) {
        for (Entry *entry in result.getResult) {
            XCTAssertEqual(entry.language, HINDI_INDIA);
        }
        [expectation fulfill];
    }];
    [self waitForRequest];
}
@end

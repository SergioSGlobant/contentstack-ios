//
//  SyncTest.m
//  ContentstackTest
//
//  Created by Uttam Ukkoji on 04/07/18.
//  Copyright © 2018 Contentstack. All rights reserved.
//

#import <Contentstack/Contentstack.h>
#import <XCTest/XCTest.h>

static NSInteger kRequestTimeOutInSeconds = 60;

@interface SyncTest : XCTestCase {
    Stack *csStack;
    Config *config;
    CGFloat count;
    NSString *syncToken;
    NSDateFormatter *formatter;
}
@end

@implementation SyncTest

- (void)setUp {
    [super setUp];
    // Blizaard Config
//    Config *_config = [[Config alloc] init];
//    _config.host = @"cdn.blz-contentstack.com";
//    syncToken = @"blt8d1e3075c44837c3057913";//Prod
//    csStack = [Contentstack stackWithAPIKey:@"blt59ea7afd1eb58d12" accessToken:@"cs20ec62a477546ef68ded62a8" environmentName:@"web" config:_config];
    
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
//     Prod
//    Config *_config = [[Config alloc] init];
//    _config.host = @"cdn.contentstack.io";
//    syncToken = @"blt74a4b24a43188ae05d3bf9";//Prod
//    csStack = [Contentstack stackWithAPIKey:@"blt477ba55f9a67bcdf" accessToken:@"cs7731f03a2feef7713546fde5" environmentName:@"web" config:_config];
//
    //EU
//    Config *_config = [[Config alloc] init];
//    _config.region = EU;
//    _config.host = @"cdn.contentstack.com";
//    syncToken = @"blt438285a6a99ba1f262e181";//stage
//    csStack = [Contentstack stackWithAPIKey:@"bltec63b57f491547fe" accessToken:@"cs5834dc67621234eb68fce5dd" environmentName:@"web" config:_config];
    
//    Stag
    Config *_config = [[Config alloc] init];
    _config.host = @"cdn.contentstack.io";
    syncToken = @"blt37f6aa8e41cbb327c6c6d3";//stage
    csStack = [Contentstack stackWithAPIKey:@"blt477ba55f9a67bcdf" accessToken:@"cs7731f03a2feef7713546fde5" environmentName:@"web" config:_config];

    //Dev
//    Config *_config = [[Config alloc] init];
//    _config.host = @"dev-cdn.contentstack.io";
//    syncToken = @"blt37f6aa8e41cbb327c6c6d3";//Dev
//    csStack = [Contentstack stackWithAPIKey:@"blt3095c4e04a3d69e6" accessToken:@"csb4aacc6e090dfd2e8c1b01cd" environmentName:@"web" config:_config];

    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:SSSSSZ";
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

- (void)testSync {
    count = 0;
    XCTestExpectation *expectation = [self expectationWithDescription:@"Sync"];
    [csStack sync:^(SyncStack * _Nullable syncStack, NSError * _Nullable error) {
        count += syncStack.items.count;
        if (syncStack.syncToken != nil) {
            XCTAssertEqual(syncStack.totalCount, count);
            [expectation fulfill];
        }
    }];
    
    [self waitForRequest];
}

- (void)testSyncToken {
    count = 0;

    XCTestExpectation *expectation = [self expectationWithDescription:@"Sync"];
    [csStack syncToken:syncToken completion:^(SyncStack * _Nullable syncStack, NSError * _Nullable error) {
        count += syncStack.items.count;
        if (syncStack.syncToken != nil) {
            XCTAssertEqual(syncStack.totalCount, syncStack.totalCount);
            [expectation fulfill];
        }
    }];
    [self waitForRequest];
}

- (void)testSyncFromDate {
    XCTestExpectation *expectation = [self expectationWithDescription:@"SyncFromDate"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:1534617000];
    
    [csStack syncFrom:date completion:^(SyncStack * _Nullable syncStack, NSError * _Nullable error) {
        for (NSDictionary *item in syncStack.items) {
            if ([[item objectForKey:@"event_at"] isKindOfClass:[NSString class]]) {
                NSDate *daatee = [formatter dateFromString:[[item objectForKey:@"event_at"] stringByReplacingOccurrencesOfString:@"." withString:@""]];
                XCTAssertLessThanOrEqual(date.timeIntervalSince1970, daatee.timeIntervalSince1970);
            }
        }
        if (syncStack.syncToken != nil) {
            [expectation fulfill];
        }
            
        }];
    [self waitForRequest];
}

- (void)testSyncPublishType {
    XCTestExpectation *expectation = [self expectationWithDescription:@"SyncPublishType"];
    [csStack syncPublishType:(ENTRY_DELETED) completion:^(SyncStack * _Nullable syncStack, NSError * _Nullable error) {
        for (NSDictionary *item in syncStack.items) {
            if ([[item objectForKey:@"type"] isKindOfClass:[NSString class]]) {
                XCTAssertTrue([[item objectForKey:@"type"] isEqualToString:@"entry_deleted"]);
            }
        }
        if (syncStack.syncToken != nil) {
            [expectation fulfill];
        }

    }];
    [self waitForRequest];
}

- (void)testSyncOnlyClass {
    XCTestExpectation *expectation = [self expectationWithDescription:@"SyncOnlyClass"];
    [csStack syncOnly:@"session" completion:^(SyncStack * _Nullable syncStack, NSError * _Nullable error) {
        for (NSDictionary *item in syncStack.items) {
            if ([[item objectForKey:@"content_type_uid"] isKindOfClass:[NSString class]]) {
                XCTAssertTrue([[item objectForKey:@"content_type_uid"] isEqualToString:@"session"]);
            }
        }
        if (syncStack.syncToken != nil) {
            [expectation fulfill];
        }    }];
    [self waitForRequest];
}

-(void)testSyncOnlyWithLocale {
    XCTestExpectation *expectation = [self expectationWithDescription:@"SyncOnlyWithLocale"];
    [csStack syncOnly:@"session" locale:@"en-us" from:nil completion:^(SyncStack * _Nullable syncStack, NSError * _Nullable error) {
        for (NSDictionary *item in syncStack.items) {
            if ([[item objectForKey:@"content_type_uid"] isKindOfClass:[NSString class]]) {
                XCTAssertTrue([[item objectForKey:@"content_type_uid"] isEqualToString:@"session"]);
            }
            if ([[item objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *data = [item objectForKey:@"data"];
                if ([data valueForKeyPath:@"publish_details.locale"] != nil && [[data objectForKey:@"publish_details.locale"] isKindOfClass:[NSString class]]) {
                    XCTAssertTrue([[data objectForKey:@"publish_details.locale"] isEqualToString:@"en-us" ]);
                }
            }
        }
        if (syncStack.syncToken != nil) {
            [expectation fulfill];
        }
    }];
    [self waitForRequest];
}

- (void)testSyncOnlyClassAndDate {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:1534617000];

    XCTestExpectation *expectation = [self expectationWithDescription:@"SyncOnlyClassAndDate"];
    [csStack syncOnly:@"session" from:date completion:^(SyncStack * _Nullable syncStack, NSError * _Nullable error) {
        for (NSDictionary *item in syncStack.items) {
            if ([[item objectForKey:@"content_type_uid"] isKindOfClass:[NSString class]]) {
                XCTAssertTrue([[item objectForKey:@"content_type_uid"] isEqualToString:@"session"]);
            }
            if ([[item objectForKey:@"event_at"] isKindOfClass:[NSString class]]) {
                NSDate *daatee = [formatter dateFromString:[[item objectForKey:@"event_at"] stringByReplacingOccurrencesOfString:@"." withString:@""]];
                XCTAssertLessThanOrEqual(date.timeIntervalSince1970, daatee.timeIntervalSince1970);
            }
        }
        if (syncStack.syncToken != nil) {
            [expectation fulfill];
        }    }];
    [self waitForRequest];
}

-(void)testSyncLocal {
    XCTestExpectation *expectation = [self expectationWithDescription:@"SyncLocal"];
    [csStack syncLocale:@"en-us" completion:^(SyncStack * _Nullable syncStack, NSError * _Nullable error) {
        for (NSDictionary *item in syncStack.items) {
            if ([[item objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *data = [item objectForKey:@"data"];
                if ([data valueForKeyPath:@"publish_details.locale"] != nil && [[data objectForKey:@"publish_details.locale"] isKindOfClass:[NSString class]]) {
                    XCTAssertTrue([[data objectForKey:@"publish_details.locale"] isEqualToString:@"en-us" ]);
                }
            }
        }
        if (syncStack.syncToken != nil) {
            [expectation fulfill];
        }
    }];
    [self waitForRequest];
}


-(void)testSyncLocaleWithDate {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:1534617000];

    XCTestExpectation *expectation = [self expectationWithDescription:@"SyncLocaleWithDate"];
    [csStack syncLocale:@"en-us" from:date completion:^(SyncStack * _Nullable syncStack, NSError * _Nullable error) {
        for (NSDictionary *item in syncStack.items) {
            if ([[item objectForKey:@"event_at"] isKindOfClass:[NSString class]]) {
                NSDate *daatee = [formatter dateFromString:[[item objectForKey:@"event_at"] stringByReplacingOccurrencesOfString:@"." withString:@""]];
                XCTAssertLessThanOrEqual(date.timeIntervalSince1970, daatee.timeIntervalSince1970);
            }
            if ([[item objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *data = [item objectForKey:@"data"];
                if ([data objectForKey:@"publish_details.locale"] != nil && [[data objectForKey:@"publish_details.locale"] isKindOfClass:[NSString class]]) {
                    XCTAssertTrue([[data objectForKey:@"publish_details.locale"] isEqualToString:@"en-us" ]);
                }
            }
        }
        if (syncStack.syncToken != nil) {
            [expectation fulfill];
        }
    }];
    [self waitForRequest];
}



@end

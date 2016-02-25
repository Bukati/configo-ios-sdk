//
//  CFGConfigValueFetcherTests.m
//  ConfigoSDK
//
//  Created by Natan Abramov on 2/24/16.
//  Copyright © 2016 Configo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>

#import "CFGConfigValueFetcher.h"
#import "CFGConfig.h"

#import "NNLogger.h"

@interface CFGConfigValueFetcherTests : XCTestCase
@property (nonatomic, strong) CFGConfigValueFetcher *valueFetcher;
@end

@implementation CFGConfigValueFetcherTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _valueFetcher = [[CFGConfigValueFetcher alloc] initWithConfig: [self mockConfig]];
    _valueFetcher.fallbackConfig = [self mockFallbackConfig];
    NNLogDebug(@"Value Fetcher Config", _valueFetcher.config);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Config Value Tests

- (void)testHighLevelFetch {
    id string = [_valueFetcher configValueForKeyPath: @"string" fallbackValue: nil];
    XCTAssertEqual(string, @"value");
    
    id integerObj = [_valueFetcher configValueForKeyPath: @"integer" fallbackValue: nil];
    NSNumber *expectedIntegerObj = @1;
    XCTAssertEqual(integerObj, expectedIntegerObj);
    
    id floatObj = [_valueFetcher configValueForKeyPath: @"float" fallbackValue: nil];
    NSNumber *expectedFloatObj = @1.2;
    XCTAssertEqualObjects(floatObj, expectedFloatObj);
}

- (void)testNestedValues {
    id nestedValue = [_valueFetcher configValueForKeyPath: @"dict.key" fallbackValue: nil];
    XCTAssertEqual(@"value", nestedValue);
}

- (void)testTwiceNestedValue {
    id twiceNestedValue = [_valueFetcher configValueForKeyPath: @"dict.dict.key" fallbackValue: nil];
    XCTAssertEqual(@"inner", twiceNestedValue);
}

- (void)testArrayAccess {
    id firstArrayValue = [_valueFetcher configValueForKeyPath: @"array[0]" fallbackValue: nil];
    XCTAssertEqual(@1, firstArrayValue);
}

- (void)testArrayOutOfBounds {
    id outOfBoundsVal = [_valueFetcher configValueForKeyPath: @"array[1000]" fallbackValue: nil];
    XCTAssertNil(outOfBoundsVal);
}

- (void)testDictInArray {
    id keyInDictArray = [_valueFetcher configValueForKeyPath: @"array[3].key" fallbackValue: nil];
    XCTAssertEqual(@"value", keyInDictArray);
}

- (void)testFallbackValue {
    id value = [_valueFetcher configValueForKeyPath: @"undefinedKey" fallbackValue: @"value"];
    XCTAssertEqual(value, @"value");
}

- (void)testFallbackConfig {
    id fallbackVal = [_valueFetcher configValueForKeyPath: @"fallback" fallbackValue: nil];
    XCTAssertEqualObjects(@"fallbackVal", fallbackVal);
}

- (void)testFallbackToValue_skipFallbackConfig {
    id fallbackVal = [_valueFetcher configValueForKeyPath: @"fallback" fallbackValue: @"otherFallbackVal"];
    XCTAssertEqualObjects(@"otherFallbackVal", fallbackVal);
}

#pragma mark - Feature Flag Tests

- (void)testFeatureFlag {
    BOOL flag = [_valueFetcher featureFlagForKey: @"feature2" fallback: NO];
    XCTAssertTrue(flag);
}

- (void)testNotDefinedFeature {
    BOOL flag = [_valueFetcher featureFlagForKey: @"noSuchFeature" fallback: NO];
    XCTAssertFalse(flag);
}

- (void)testFallbackFeature {
    BOOL flag = [_valueFetcher featureFlagForKey: @"fallbackFeature" fallback: NO];
    XCTAssertTrue(flag);
}

#pragma mark - Helpers

- (CFGConfig *)mockConfig {
    NSDictionary *config = [self mockConfigDict];
    NSArray *features = [self mockFeaturesArray];
    return [[CFGConfig alloc] initWithConfig: config features: features];
}

- (CFGConfig *)mockFallbackConfig {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: [self mockConfigDict]];
    dict[@"fallback"] = @"fallbackVal";
    NSMutableArray *arr = [NSMutableArray arrayWithArray: [self mockFeaturesArray]];
    arr[0] = @"fallbackFeature";
    return [[CFGConfig alloc] initWithConfig: dict features: arr];
}

- (NSDictionary *)mockConfigDict {
    return @{
             @"string" : @"value",
             @"integer" : @1,
             @"float" : @1.2,
             @"array" : @[@1,
                          @"Hi",
                          @3.5,
                          @{@"key" : @"value"}
                          ],
             @"dict" : @{
                     @"key" : @"value",
                     @"key2" : @"value2",
                     @"dict" : @{
                             @"key" : @"inner"
                             }
                     }
             };
}

- (NSArray *)mockFeaturesArray {
    return @[@"feature1", @"feature2", @"feature3"];
}

@end
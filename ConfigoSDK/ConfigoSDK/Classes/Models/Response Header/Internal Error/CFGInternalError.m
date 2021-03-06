//
//  CFGInternalError.m
//  ConfigoSDK
//
//  Created by Natan Abramov on 19/08/15.
//  Copyright (c) 2015 Configo. All rights reserved.
//

#import "CFGInternalError.h"
#import "CFGConstants.h"

#import "NNJSONUtilities.h"
#import "NSDictionary+NNAdditions.h"

static NSString *const kStatusCodeKey = @"statusCode";
static NSString *const kDescriptionKey = @"description";
static NSString *const kDevStackKey = @"dev_stack";

static NSString *const kInternalErrorSubdomain = @"internalError";

@implementation CFGInternalError

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if(self = [super initWithDictionary: dict]) {
        _statusCode = [NNJSONUtilities validIntegerFromObject: dict[kStatusCodeKey]];
        _errorDescription = [NNJSONUtilities validObjectFromObject: dict[kDescriptionKey]];
        _devStack = [NNJSONUtilities validObjectFromObject: dict[kDevStackKey]];
    }
    return self;
}

- (NSDictionary *)jsonRepresentation {
    return [self dictionaryRepresentation];
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict nnSafeSetObject: @(_statusCode) forKey: kStatusCodeKey];
    [dict nnSafeSetObject: _errorDescription forKey: kDescriptionKey];
    [dict nnSafeSetObject: _devStack forKey: kDevStackKey];
    return dict;
}

- (NSError *)error {
    NSString *errorDomain = [NSString stringWithFormat: @"%@.%@", CFGErrorDomain, kInternalErrorSubdomain];
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : _errorDescription};
    NSError *error = [NSError errorWithDomain: errorDomain code: _statusCode userInfo: userInfo];
    return error;
}

@end

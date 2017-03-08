//
//  HLPdfManager.h
//  Printer
//
//  Created by Jack.lihongliang on 2017/3/8.
//  Copyright © 2017年 Jack.lihongliang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLPdfManager : NSObject

+ (instancetype)sharedManger;
- (void)createPdfWithFileName:(NSString *)fileName content:(NSString *)content;

@end

//
//  HLPdfManager.m
//  Printer
//
//  Created by Jack.lihongliang on 2017/3/8.
//  Copyright © 2017年 Jack.lihongliang. All rights reserved.
//

#import "HLPdfManager.h"
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

static HLPdfManager *_pdfManager = nil;

@interface HLPdfManager ()
{
    CGFloat _height;
    CGFloat _width;
}

@end

@implementation HLPdfManager

+ (instancetype)sharedManger {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_pdfManager) {
            _pdfManager = [[HLPdfManager alloc] init];
        }
    });
    return _pdfManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _height = [UIScreen mainScreen].bounds.size.height;
        _width = [UIScreen mainScreen].bounds.size.width;
    }
    return self;
}

- (void)createPdfWithFileName:(NSString *)fileName content:(NSString *)content {
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    if ([fileName hasSuffix:@".pdf"] || [fileName hasSuffix:@".PDF"]) {
        
    }else {
        fileName = [fileName stringByAppendingString:@".pdf"];
    }
    NSString *pdfFilePath = [documentPath stringByAppendingPathComponent:fileName];
    CFStringRef stringRef = (__bridge CFStringRef)content;
    CFAttributedStringRef currentText = CFAttributedStringCreate(NULL, stringRef, NULL);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(currentText);
    
    CGRect frameRect = CGRectMake(0, 0, _width, -_height+64);
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, NULL, frameRect);
    
    CFRange currentRange = CFRangeMake(0, 0);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, NULL);
    CGPathRelease(framePath);
    
    UIGraphicsBeginPDFContextToFile(pdfFilePath, CGRectZero, NULL);
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, _width, _height-64), NULL);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    CGContextTranslateCTM(currentContext, 0, 0);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    CTFrameDraw(frameRef, currentContext);
    CFRelease(frameRef);
    CFRelease(stringRef);
    CFRelease(framesetter);
    
    UIGraphicsEndPDFContext();
    
}

@end

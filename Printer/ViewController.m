//
//  ViewController.m
//  Printer
//
//  Created by Jack.lihongliang on 2017/3/6.
//  Copyright © 2017年 Jack.lihongliang. All rights reserved.
//

#import "ViewController.h"
#import "HLPdfManager.h"
#import <QuickLook/QuickLook.h>
#import <CoreText/CoreText.h>

@interface ViewController ()<QLPreviewControllerDelegate, QLPreviewControllerDataSource>
{
    CGFloat _height;
    CGFloat _width;
}
@property (copy, nonatomic) NSString *filePath;

@end

@implementation ViewController

- (void)viewDidLoad {
    _height = [UIScreen mainScreen].bounds.size.height;
    _width = [UIScreen mainScreen].bounds.size.width;
    [super viewDidLoad];
    [self createPdf];
    [self showPDFFile];
    [self setupUI];
}

- (void)setupUI {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"pdf" style:UIBarButtonItemStylePlain target:self action:@selector(openClick)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)createPdf {
    NSString *fileName = @"Invoice.PDF";
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *pdfFilePath = [documentPath stringByAppendingPathComponent:fileName];
    _filePath = pdfFilePath;
    NSLog(@"%@", pdfFilePath);
    NSString *textToDraw = @"这里是pdf文件中的内容,哈哈,我是内容.";
    
    CFStringRef stringRef = (__bridge CFStringRef)textToDraw;
    
    CFAttributedStringRef currentText = CFAttributedStringCreate(NULL, stringRef, NULL);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(currentText);
    
    CGRect frameRect = CGRectMake(0, 0, _width, -_height+64); // 这里用过负数 是因为下面翻转了
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, NULL, frameRect);
    
    CFRange currentRange = CFRangeMake(0, 0);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, NULL);
    CGPathRelease(framePath);
    
    UIGraphicsBeginPDFContextToFile(pdfFilePath, CGRectZero, NULL);
    
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, _width, _height-64), NULL);
    // 获取上下文.
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    // 把文字变成矩阵已知状态。这将确保没有旧缩放因子被留在原处。
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    
    //文本坐标翻转 由于Core Graphics 的坐标是从左下角开始，而UIKit的坐标是从左上角开始，所以需做一个变换：
    CGContextTranslateCTM(currentContext, 0, 0);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    // 绘制帧
    CTFrameDraw(frameRef, currentContext);
    
    CFRelease(frameRef);
    CFRelease(stringRef);
    CFRelease(framesetter);
    
    //关闭PDF上下文
    UIGraphicsEndPDFContext();
}

- (void)showPDFFile {
    NSString* fileName = @"Invoice.PDF";
    
    NSArray *arrayPaths =
    NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    NSString *path = [arrayPaths objectAtIndex:0];
    NSString* pdfFileName = [path stringByAppendingPathComponent:fileName];
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, _width, _height-64)];
    
    NSURL *url = [NSURL fileURLWithPath:pdfFileName];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView setScalesPageToFit:YES];
    [webView loadRequest:request];
    
    [self.view addSubview:webView];
}

// 预览文件 (系统自带了打印功能)
- (void)openClick {
    QLPreviewController *vc = [[QLPreviewController alloc] init];
    vc.delegate = self;
    vc.dataSource = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    NSURL *url = [NSURL fileURLWithPath:_filePath];
    return url;
}

// 这个方法就是直接弹出打印界面
- (void)print {
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    NSData *myPDFData = [NSData dataWithContentsOfFile:_filePath];
    if  (pic && [UIPrintInteractionController canPrintData:myPDFData] ) {
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputGeneral;
        printInfo.jobName = [_filePath lastPathComponent];
        printInfo.duplex = UIPrintInfoDuplexLongEdge;
        pic.printInfo = printInfo;
        pic.showsPageRange = YES;
        pic.printingItem = myPDFData;
        
        void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
        ^(UIPrintInteractionController *pic, BOOL completed, NSError *error) {
            if (!completed && error)
                NSLog(@"FAILED! due to error in domain %@ with error code %ld",
                      error.domain, (long)error.code);
        };
        [pic presentAnimated:YES completionHandler:completionHandler];
    }
}


@end

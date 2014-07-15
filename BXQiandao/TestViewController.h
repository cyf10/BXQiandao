//
//  TestViewController.h
//  MMLocationManager
//
//  Created by fengchaoyi on 7/11/14.
//  Copyright (c) 2014 com.mark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestViewController : UIViewController<UIWebViewDelegate, UIActionSheetDelegate>
{
    NSMutableData *receivedData;
}
@property (strong, nonatomic) IBOutlet UIWebView *webview;


@end

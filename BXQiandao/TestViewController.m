//
//  TestViewController.m
//  MMLocationManager
//
//  Created by fengchaoyi on 7/11/14.
//  Copyright (c) 2014 com.mark. All rights reserved.
//

#define IS_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
#define CLIENT_ID @"452221487049-atcotath4kcq9a5sna28n6rbo659ja74.apps.googleusercontent.com"
#define CLIENT_SECRET @"AWXEZ765hzwbpUGEa5P2yyg5"
#define REDIRECT_URI @"http://localhost"
#define GRANT_TYPE @"authorization_code"
#define RESPONSE_TYPE @"code"
#define TOKEN_URL @"https://accounts.google.com/o/oauth2/token"
#define OAUTH_URL @"https://accounts.google.com/o/oauth2/auth"
#define OAUTH_SCOPE @"https://www.googleapis.com/auth/userinfo.email"
#define OAUTH_EMAIL @"https://www.googleapis.com/oauth2/v1/tokeninfo"


#import "TestViewController.h"
#import "MMLocationManager.h"
#import "DKCircleButton.h"
#import "DXAlertView.h"

@interface TestViewController ()

@property(nonatomic,strong)UILabel *textLabel;
@property NSMutableDictionary *emailrecord;
@property BOOL authComplete;
@property(nonatomic,strong) NSString *filename;

@end

@implementation TestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // email配置文件
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *plistPath1 = [paths objectAtIndex:0];
        _filename = [plistPath1 stringByAppendingPathComponent:@"email.plist"];
        NSFileManager *fileManager = [[NSFileManager alloc]init];
        if(![fileManager fileExistsAtPath:_filename]){
            if(![fileManager createFileAtPath:_filename contents:nil attributes:nil])
            {
                NSLog(@"create file error");
            }
        }
        _emailrecord = [[NSMutableDictionary alloc] initWithContentsOfFile:_filename];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self loadMyView];
}

-(void)loadMyView{
    if (!_emailrecord){
        _emailrecord = [[NSMutableDictionary alloc]init];
    }
    // Do any additional setup after loading the view.
    _textLabel.text = @"";
    _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, IS_IOS7 ? 30 : 10, 320, 60)];
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.font = [UIFont systemFontOfSize:15];
    _textLabel.textColor = [UIColor blackColor];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.numberOfLines = 0;
    
    NSString *mail =[_emailrecord valueForKey:@"email"];
    if ([_emailrecord valueForKey:@"email"] == NULL){
        _textLabel.text = @"还没登录哦，点击下方按钮登陆";
        self.authComplete = false;
    }else{
        _textLabel.text = [NSString stringWithFormat:@"已登录为%@，\n请点击下方按钮签到\n（你不开定位的话我没反应的。。）", mail];
        self.authComplete = true;
    }
    
    [self.view addSubview:_textLabel];
    
    //签到按钮
    DKCircleButton *button1 = [[DKCircleButton alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    
    button1.center = CGPointMake(160, 200);
    button1.titleLabel.font = [UIFont systemFontOfSize:22];
    [button1 setTitleColor:[UIColor colorWithWhite:1 alpha:1.0] forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor colorWithWhite:1 alpha:1.0] forState:UIControlStateSelected];
    [button1 setTitleColor:[UIColor colorWithWhite:1 alpha:1.0] forState:UIControlStateHighlighted];
    [button1 setTitle:NSLocalizedString(@"签到", nil) forState:UIControlStateNormal];
    [button1 setTitle:NSLocalizedString(@"签到", nil) forState:UIControlStateSelected];
    [button1 setTitle:NSLocalizedString(@"签到", nil) forState:UIControlStateHighlighted];
    if (self.authComplete){
        [button1 addTarget:self action:@selector(check) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [button1 addTarget:self action:@selector(menu) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:button1];
    
    DKCircleButton *button2 = [[DKCircleButton alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    button2.center = CGPointMake(250, 400);
    button1.titleLabel.font = [UIFont systemFontOfSize:18];
    button2.animateTap = NO;
    [button2 setTitleColor:[UIColor colorWithWhite:1 alpha:1.0] forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor colorWithWhite:1 alpha:1.0] forState:UIControlStateSelected];
    [button2 setTitleColor:[UIColor colorWithWhite:1 alpha:1.0] forState:UIControlStateHighlighted];
    [button2 setTitle:NSLocalizedString(@"debug", nil) forState:UIControlStateNormal];
    [button2 setTitle:NSLocalizedString(@"debug", nil) forState:UIControlStateSelected];
    [button2 setTitle:NSLocalizedString(@"debug", nil) forState:UIControlStateHighlighted];
    [button2 addTarget:self action:@selector(cleanAll) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
}

//上午签到1 下午签到2
-(void)check
{
    __block __weak TestViewController *wself = self;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger year = [components year];
    NSInteger month = [components month];
    NSInteger day = [components day];
    NSString *today = [NSString stringWithFormat:@"%d-%d-%d", year, month, day];
    NSLog(@"today is %@", today);
    
    NSInteger hour = [components hour];
    
    [[MMLocationManager shareLocation] getLocationCoordinate:^(CLLocationCoordinate2D locationCorrrdinate) {
        
        float latitude = locationCorrrdinate.latitude - 37.785834;//纬度
        float longtitude = locationCorrrdinate.longitude - (-122.406417);//经度
        if (fabs(latitude) < 0.1 && fabs(longtitude) < 0.1){
            //签到成功
//            [self.record setObject:@"1" forKey:today];
            NSString *checktime = (hour < 11)?@"您今天签到的工作时间是:全天":@"您今天签到的工作时间是:下午";
            
            DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"签到成功" contentText:checktime leftButtonTitle:@"OK" rightButtonTitle:nil];
            [alert show];
            [wself setLabelText:[NSString stringWithFormat:@"签到成功！"]];
        }else{
            //签到失败
            DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"签到失败" contentText:@"你跟公司的距离太远啦，到了再签到哦！" leftButtonTitle:@"OK" rightButtonTitle:@"Fine"];
            [alert show];
            [wself setLabelText:[NSString stringWithFormat:@"签到失败！您跟我们的距离差的是%f, %f",latitude,longtitude]];
        }
        
    }];
}

-(void)menu
{
//    IBActionSheet *actionSheet = [[IBActionSheet alloc]initWithTitle:@"不要帮别人签到哦" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"登出" otherButtonTitles:@"帮助", nil];
//    [actionSheet showInView:self.view];
    
    self.webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 30, 320, 440)];
    [self.webview setDelegate:self];
    
    NSString *urlAddress = [NSString stringWithFormat:@"%@?redirect_uri=%@&response_type=%@&client_id=%@&scope=%@", OAUTH_URL, REDIRECT_URI, RESPONSE_TYPE, CLIENT_ID, OAUTH_SCOPE];
    NSLog(@"URLaddress:%@",urlAddress);
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSMutableURLRequest *requestObj = [NSMutableURLRequest requestWithURL:url];
    [self.webview loadRequest:requestObj];
    self.authComplete = false;
    
    [self.view addSubview:self.webview];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    //    [indicator startAnimating];
    if ([[[request URL] host] isEqualToString:@"localhost"]) {
        // Extract oauth_verifier from URL query
        NSString* verifier = nil;
        NSArray* urlParams = [[[request URL] query] componentsSeparatedByString:@"&"];
        for (NSString* param in urlParams) {
            NSArray* keyValue = [param componentsSeparatedByString:@"="];
            NSString* key = [keyValue objectAtIndex:0];
            if ([key isEqualToString:@"code"]) {
                verifier = [keyValue objectAtIndex:1];
                NSLog(@"%@",verifier);
                //[self doAuthLogin:code];
                break;
            }
        }
        
        if (verifier) {
            NSString *data = [NSString stringWithFormat:@"code=%@&client_id=%@&client_secret=%@&redirect_uri=%@&grant_type=authorization_code", verifier,CLIENT_ID,CLIENT_SECRET,REDIRECT_URI];
            NSString *url = [NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/token"];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
            NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
        } else {
            [self.webview removeFromSuperview];
            DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"认证失败" contentText:@"认证失败，请重新尝试！" leftButtonTitle:@"OK" rightButtonTitle:nil];
            [alert show];
        }
        
        [webView removeFromSuperview];
        
        return NO;
        
    }
    
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    receivedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[NSString stringWithFormat:@"%@", error]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:receivedData options:kNilOptions error:&error];
    
    //到这一步时认证已经完成了，接下来要拿email address
    NSString *idtoken = [dictionary valueForKey:@"id_token"];
    NSString *par = [NSString stringWithFormat:@"id_token=%@", idtoken];
    NSString *url = [NSString stringWithFormat:@"https://www.googleapis.com/oauth2/v1/tokeninfo"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[par dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSString *email = [dic valueForKey:@"email"];
    
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"认证成功！" contentText:[NSString stringWithFormat:@"您签到的email地址为：%@", email] leftButtonTitle:@"OK" rightButtonTitle:@"OK"];
    [alert show];
    
    [_emailrecord setObject:email forKey:@"email"];
    [_emailrecord writeToFile:_filename atomically:YES];
    [self loadMyView];
    
}


-(void)setLabelText:(NSString *)text
{
    NSLog(@"text %@",text);
    _textLabel.text = text;
}

-(void)cleanAll{
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"debug专用，没事别乱点，\n出了bug什么的再点我！" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"清空所有数据!" otherButtonTitles:nil, nil];
    [sheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [actionSheet destructiveButtonIndex]){
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:_filename]){
            [fileManager removeItemAtPath:_filename error:nil];
        }
        self.authComplete = false;
        self.emailrecord = [[NSMutableDictionary alloc]init];
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"重头再来！" contentText:@"程序已经被重置了" leftButtonTitle:nil rightButtonTitle:@"OK"];
        [alert show];
        [self loadMyView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

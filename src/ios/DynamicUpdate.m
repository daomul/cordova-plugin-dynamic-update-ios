//
//  CustomPlugin.m
//  demo
//
//  Created by Axiba on 16/1/18.
//
//


#import <Cordova/CDV.h>
#import "DynamicUpdate.h"

@interface DynamicUpdate ()
@property (nonatomic, weak) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *connectionData;
@property (nonatomic, weak) NSString *callbackId;

@end

@implementation DynamicUpdate

#pragma mark -- CDVInvokedUrlCommand method

/**
 *  download zip file from the url service
 */
-(void)download:(CDVInvokedUrlCommand *)command
{
    //拿到传入的参数
    NSString* path = [command argumentAtIndex:0 withDefault:nil];

    //文件地址
    NSString *urlAsString = @"http://files.cnblogs.com/files/daomul/UIWebViewDemo.zip";
    NSURL    *url = [NSURL URLWithString:urlAsString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _connectionData = [[NSMutableData alloc] init];
    NSURLConnection *newConnection = [[NSURLConnection alloc]
                                      initWithRequest:request
                                      delegate:self
                                      startImmediately:YES];
    self.connection = newConnection;
    if (self.connection == nil){
        [self reBackCDVResult:@"data connection error"];
    }

}

#pragma mark -- private method

/**
 * take SSZipArchive unzip the files
 */
-(void)unzip:(NSString *)zipPath destinationPath:(NSString *)destinationPath
{
    @try {
        NSError *error;

        //获取安装文件目录
        NSArray *arr = [[NSBundle mainBundle] pathsForResourcesOfType:nil inDirectory:@"www"];
        NSMutableString *strpath = [[NSMutableString alloc]init];
        strpath = [self spliteString:[arr objectAtIndex:0]];
        NSFileManager *manager = [NSFileManager defaultManager];

        //判断www目录是否已存在，存在则将其先移除
        if ([manager fileExistsAtPath:strpath])
        {
            //removing destination, so soucer may be copied
            if ([manager removeItemAtPath:strpath error:&error])
            {
                if([SSZipArchive unzipFileAtPath:zipPath toDestination:strpath overwrite:YES password:nil error:&error delegate:self]) {

                    if (arr.count > 0) {
                        error=nil;
                        [self.webView reload];

                        [self reBackCDVResult:@"update sucess"];
                    }

                } else {
                    [self reBackCDVResult:@"unzip error"];
                }

            }
        }

    } @catch(NSException* exception) {
        [self reBackCDVResult:@"unzip error"];
    }
}
-(NSMutableString *)spliteString:(NSString *)str
{
    NSMutableString *newStr = [[NSMutableString alloc]init];
    NSArray *array = [str componentsSeparatedByString:@"/"];
    for (int i = 0; i < [array count] - 1; i++) {
        [newStr appendString:[array objectAtIndex:i]];
        [newStr appendString:@"/"];
    }
    return newStr;
}
-(void)reBackCDVResult:(NSString *)message
{
    CDVPluginResult * result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [self.commandDelegate sendPluginResult:result callbackId:_callbackId];
}

#pragma mark -- NSURLConnection Delegate

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self reBackCDVResult:[NSString stringWithFormat:@"%@",error]];
}
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_connectionData appendData:data];
}
- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    /* do something with the data here */

    NSLog(@"下载成功");
    NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *storePath = [applicationDocumentsDir stringByAppendingPathComponent:@"UIWebViewDemo.zip"];

    BOOL iSucess = [_connectionData writeToFile:storePath atomically:YES];
    if (iSucess) {
        NSLog(@"保存成功.");

        [self unzip:storePath destinationPath:applicationDocumentsDir];
    }
    else
    {
        NSLog(@"保存失败.");
        [self reBackCDVResult:@"save error"];
    }
}
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [_connectionData setLength:0];
}
@end

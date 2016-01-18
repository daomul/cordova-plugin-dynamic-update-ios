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
@property (nonatomic, weak) NSMutableData *connectionData;
@property (nonatomic, weak) NSString *callbackId;

@end

@implementation DynamicUpdate

-(BOOL)download:(CDVInvokedUrlCommand *)command
{
    //拿到传入的参数
    NSString* path = [command argumentAtIndex:0 withDefault:nil];
    
    //文件地址
    NSString *urlAsString = @"http://files.cnblogs.com/zhuqil/UIWebViewDemo.zip";
    NSURL    *url = [NSURL URLWithString:urlAsString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSMutableData *data = [[NSMutableData alloc] init];
    self.connectionData = data;
    NSURLConnection *newConnection = [[NSURLConnection alloc]
                                      initWithRequest:request
                                      delegate:self
                                      startImmediately:YES];
    self.connection = newConnection;
    if (self.connection != nil){
        NSLog(@"Successfully created the connection");
    } else {
        NSLog(@"Could not create the connection");
    }
    
    NSLog(@"writeToFile");
    
    return true;
}
- (void) connection:(NSURLConnection *)connection
   didFailWithError:(NSError *)error{
    NSLog(@"An error happened");
    NSLog(@"%@", error);
}
- (void) connection:(NSURLConnection *)connection
     didReceiveData:(NSData *)data{
    NSLog(@"Received data");
    [self.connectionData appendData:data];
}
- (void) connectionDidFinishLoading
:(NSURLConnection *)connection{
    /* 下载的数据 */
    
    NSLog(@"下载成功");
    if ([self.connectionData writeToFile:@"update.zip" atomically:YES]) {
        NSLog(@"保存成功.");
        CDVPluginResult * result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"下载成功"];
        [self.commandDelegate sendPluginResult:result callbackId:_callbackId];
    }
    else
    {
        NSLog(@"保存失败.");
        CDVPluginResult * result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"下载失败"];
        [self.commandDelegate sendPluginResult:result callbackId:_callbackId];
    }
    
    /* do something with the data here */
}
- (void) connection:(NSURLConnection *)connection
 didReceiveResponse:(NSURLResponse *)response{
    [self.connectionData setLength:0];
}
@end
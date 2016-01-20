//
//  CustomPlugin.h
//  demo
//
//  Created by Axiba on 16/1/18.
//
//

#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>
#import "SSZipArchive.h"

@interface DynamicUpdate : CDVPlugin<SSZipArchiveDelegate>
{}

-(void)download:(CDVInvokedUrlCommand *)command;

@end

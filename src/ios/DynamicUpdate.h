//
//  CustomPlugin.h
//  demo
//
//  Created by Axiba on 16/1/18.
//
//

#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>

@interface DynamicUpdate : CDVPlugin
{}

-(BOOL)download:(CDVInvokedUrlCommand *)command;

@end

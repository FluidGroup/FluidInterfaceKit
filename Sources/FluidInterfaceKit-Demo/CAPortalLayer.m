//
//  CAPortalLayer.m
//  FluidInterfaceKit-Demo
//
//  Created by Muukii on 2022/01/31.
//

#import <QuartzCore/QuartzCore.h>

CALayer * makePortalLayer() {
  
  id class = NSClassFromString(@"CAPortalLayer");
  
  CALayer *instance = [[class alloc] init];
  
  return instance;
}


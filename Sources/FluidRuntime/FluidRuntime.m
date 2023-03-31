//
//  FluidRuntime.m
//  
//
//  Created by Muukii on 2023/03/31.
//

#import "include/FluidRuntime.h"

UIView * makeFromClass(id class) {
  UIView *instance = [[class alloc] init];
  return instance;
}

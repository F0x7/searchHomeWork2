//
//  Section.h
//  searchHomeWork2
//
//  Created by Fox Lis on 09.10.15.
//  Copyright © 2015 Egor Bakaykin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Section : NSObject
@property(strong, nonatomic) NSString* sectionName;
@property(strong, nonatomic) NSMutableArray* sectionItems;
@end

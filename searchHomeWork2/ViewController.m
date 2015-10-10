//
//  ViewController.m
//  searchHomeWork2
//
//  Created by Fox Lis on 09.10.15.
//  Copyright © 2015 Egor Bakaykin. All rights reserved.
//

#import "ViewController.h"
#import "MyCell.h"
#import "Student.h"
#import "Section.h"

@interface ViewController ()
@property(strong, nonatomic) NSOperation* operation;
@property(strong, nonatomic) NSOperationQueue* operationQueue;
@property(strong, nonatomic) NSMutableArray* studentsList;
@property(strong, nonatomic) NSArray* sections;
@end

static const NSInteger studentsCount = 500;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.operationQueue = [[NSOperationQueue alloc]init];
    [self.searchBar setShowsCancelButton:NO];


    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self generateStudentsArray];
        [self generateSectionInBackGroundWithFilter:self.searchBar.text];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableView reloadData];
        });
    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark - Privat Methods

- (void) generateSectionInBackGroundWithFilter:(NSString*) filter{
    
    [self.operationQueue cancelAllOperations];
    [self.operation cancel];
    
    __weak ViewController* weakSelf = self;
    
    self.operation = [NSBlockOperation blockOperationWithBlock:^{
        
        NSArray* sectionsArray = [weakSelf generateSectionsFromArray:weakSelf.studentsList withFilter:filter];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.sections = sectionsArray;
            [weakSelf.tableView reloadData];
        });
    }];
    
    [self.operationQueue addOperation:self.operation];
}

- (void) generateStudentsArray {
    
    
    
    self.studentsList = [NSMutableArray array];
    
    for (int i = 0; i < studentsCount; i++) {
        Student* std = [Student new];
        [self.studentsList addObject:[std getStudentInfo]];
    }
    
    NSSortDescriptor* sortByMonth = [[NSSortDescriptor alloc] initWithKey:@"birthDateComponents.month" ascending:YES];
    NSSortDescriptor* sortByDay = [[NSSortDescriptor alloc] initWithKey:@"birthDateComponents.day" ascending:YES];
    NSSortDescriptor* sortByYear = [[NSSortDescriptor alloc] initWithKey:@"birthDateComponents.year" ascending:YES];
    
    [self.studentsList sortUsingDescriptors:[NSArray arrayWithObjects:sortByMonth, sortByDay, sortByYear, nil]];
}
-(NSArray*) generateSectionsFromArray:(NSMutableArray*) studentsArray withFilter: (NSString*) filter{
    
    NSString* currentMonth = nil;
    
    NSMutableArray* sec = [NSMutableArray array];
    
    for (Student* student in studentsArray) {
        
        NSString* name = [NSString stringWithFormat:@"%@ %@", student.firstName, student.lastName];
        
        if ([filter length] > 0 && [name rangeOfString:filter].location == NSNotFound) {
            continue;
        }
        
        NSDateFormatter* dateFormater = [[NSDateFormatter alloc]init];
        [dateFormater setDateFormat:@"MMM"];
        
        Section* section = nil;
        NSString* firstMonth = [dateFormater stringFromDate:student.birthDate];
        
        if (![currentMonth isEqualToString:firstMonth]) {
            section = [[Section alloc]init];
            section.sectionName = firstMonth;
            section.sectionItems = [NSMutableArray array];
            
            currentMonth = firstMonth;
            [sec addObject:section];
        } else {
            section = [sec lastObject];
        }
        
        [section.sectionItems addObject:student];
        
        NSSortDescriptor* sortByFirstName = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
        NSSortDescriptor* sortByLastName = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
        NSSortDescriptor* sortByDay = [NSSortDescriptor sortDescriptorWithKey:@"birthDateComponents.day" ascending:YES];
        NSSortDescriptor* sortByYear = [NSSortDescriptor sortDescriptorWithKey:@"birthDateComponents.year" ascending:YES];
        
        [section.sectionItems sortUsingDescriptors:[NSArray arrayWithObjects:sortByDay, sortByFirstName, sortByLastName, sortByYear, nil]];
    }
    
    return sec;
}

#pragma mark - UITableViewDataSource


- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSMutableArray* array = [NSMutableArray array];
    for (Section* section in self.sections){
        [array addObject:section.sectionName];
    }
    
    return array;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    tableView.sectionIndexColor = [UIColor purpleColor];
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    Section* sec = [self.sections objectAtIndex:section];
    return [sec.sectionItems count];
    
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [[self.sections objectAtIndex:section]sectionName];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MyCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[MyCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    Section* section = [self.sections objectAtIndex:indexPath.section];
    
    NSString* firstName = [[section.sectionItems objectAtIndex:indexPath.row]firstName];
    NSString* lastname = [[section.sectionItems objectAtIndex:indexPath.row]lastName];
    NSDate* birthDate = [[section.sectionItems objectAtIndex:indexPath.row]birthDate];
    

    
    NSDateFormatter* dateFormater = [[NSDateFormatter alloc]init];
    [dateFormater setDateFormat:@"dd/MM/yyyy"];
    NSString* date = [dateFormater stringFromDate:birthDate];
    
    cell.nameLable.text = [NSString stringWithFormat:@"%@ %@",firstName, lastname];
    cell.dateLable.text = date;
    
    return cell;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self generateSectionInBackGroundWithFilter:searchText];
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:YES animated:YES];
    searchBar.returnKeyType = UIReturnKeyDone;

}


@end

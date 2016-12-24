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
@property(strong, nonatomic) NSOperation* searchByBirthDayOperation;
@property(strong, nonatomic) NSOperation* searchByFirstNameOperation;
@property(strong, nonatomic) NSOperation* searchByLastNameOperation;
@property(strong, nonatomic) NSOperation* changeSortOperation;
@property(strong, nonatomic) NSOperationQueue* searchQueue;
@property(strong, nonatomic) NSOperationQueue* sortQueue;

@property(strong, nonatomic) NSMutableArray* studentsList;
@property(strong, nonatomic) NSMutableArray* sections;
@end

static const NSInteger studentsCount = 5000;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchQueue = [[NSOperationQueue alloc]init];
    self.sortQueue = [[NSOperationQueue alloc]init];
    self.changeSortOperation = [[NSOperation alloc]init];
    self.searchByBirthDayOperation = [[NSOperation alloc]init];

    [self.activityIndicator startAnimating];
    [self.searchBar setShowsCancelButton:NO animated:YES];    
    
    self.studentsList = [NSMutableArray array];
    self.sections = [NSMutableArray array];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        self.studentsList = [self generateStudentsArray];
        [self sortArray:self.studentsList byParamOne:@"birthDateComponents.month" two:@"firstName" three:@"lastName"];

        dispatch_async(dispatch_get_main_queue(), ^{

            [self generateSectionInBackGroundWithFilter:self.searchBar.text];
            [self.tableView reloadData];
            
        });
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Sort

- (IBAction)changeSortAction:(UISegmentedControl *)sender {

    [self.changeSortOperation cancel];
    
    __weak ViewController* weakSelf = self;
    
    self.changeSortOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        switch (sender.selectedSegmentIndex) {
            case 0:
                [weakSelf sortArray:weakSelf.studentsList byParamOne:@"birthDateComponents.month" two:@"firstName" three:@"lastName"];
                
                break;
            case 1:
                [weakSelf sortArray:weakSelf.studentsList byParamOne:@"firstName" two:@"lastName" three:@"birthDateComponents.year"];
                break;
            case 2:
                [weakSelf sortArray:weakSelf.studentsList byParamOne:@"lastName" two:@"firstName" three:@"birthDateComponents.year"];
                break;
                
            default:
                break;
        }
        
        [weakSelf generateSectionInBackGroundWithFilter:self.searchBar.text];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }];
    
    [self.sortQueue addOperation:self.changeSortOperation];
}

- (void) sortArray:(NSMutableArray*) inputArray byParamOne:(NSString*) paramOne two:(NSString*)paramTwo three:(NSString*)paramThree {
    
    NSSortDescriptor* descriptorOne = [NSSortDescriptor sortDescriptorWithKey:paramOne ascending:YES];
    NSSortDescriptor* descriptorTwo = [NSSortDescriptor sortDescriptorWithKey:paramTwo ascending:YES];
    NSSortDescriptor* descriptorThree = [NSSortDescriptor sortDescriptorWithKey:paramThree ascending:YES];
    
    [inputArray sortUsingDescriptors:[NSArray arrayWithObjects:descriptorOne, descriptorTwo, descriptorThree, nil]];
}

#pragma mark - "Generate" Methods

- (NSMutableArray*) generateStudentsArray {
    NSMutableArray* students = [NSMutableArray array];
    dispatch_apply(studentsCount, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t index) {
        Student* std = [Student new];
        [students addObject:[std getStudentInfo]];
        
    });
    return students;
}

- (void) generateSectionInBackGroundWithFilter:(NSString*) filter{
    
    [self.searchByBirthDayOperation cancel];
    
    if ([self.searchByBirthDayOperation isCancelled]) {
        NSLog(@"cancel");
    }

    __weak ViewController* weakSelf = self;
    
    self.searchByBirthDayOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        NSMutableArray* sectionsArray = [weakSelf generateSectionsFromArray:weakSelf.studentsList withFilter:filter];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.sections = sectionsArray;
            [weakSelf.tableView reloadData];
            [self.activityIndicator stopAnimating];
        });
    }];
    
    [self.searchQueue addOperation:self.searchByBirthDayOperation];
}

-(NSMutableArray*) generateSectionsFromArray:(NSMutableArray*) studentsArray withFilter: (NSString*) filter{
    
    NSString* currentMonth = nil;
    NSMutableArray* sec = [NSMutableArray array];
    
    for (Student* student in studentsArray) {
        
        NSString* fullName = [NSString stringWithFormat:@"%@ %@", student.firstName, student.lastName];
        

        if ([filter length] > 0 && [fullName rangeOfString:filter].location == NSNotFound) {
            continue;
        }
        
        NSDateFormatter* dateFormater = [[NSDateFormatter alloc]init];
        [dateFormater setDateFormat:@"MMM"];
        
        Section* section = nil;
        NSString* firstValue = [dateFormater stringFromDate:student.birthDate];

        switch (self.segmentedControl.selectedSegmentIndex) {
            case 0:
                firstValue = [dateFormater stringFromDate:student.birthDate];
                break;
            case 1:
                firstValue = [NSString stringWithFormat:@"%@", [student.firstName substringToIndex:1]];
                break;
            case 2:
                firstValue = [NSString stringWithFormat:@"%@", [student.lastName substringToIndex:1]];
                break;
                
            default:
                break;
        }
        
        
        if (![currentMonth isEqualToString:firstValue]) {
            
            section = [[Section alloc]init];
            section.sectionName = firstValue;
            section.sectionItems = [NSMutableArray array];
            currentMonth = firstValue;
            [sec addObject:section];
            
        } else {
            section = [sec lastObject];
        }
        
        [section.sectionItems addObject:student];
        
        [self sortArray:section.sectionItems byParamOne:@"birthDateComponents.day" two:@"firstName" three:@"lastName"];
    }
    
    return sec;
}

#pragma mark - UITableViewDataSource


- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    tableView.sectionIndexColor = [UIColor purpleColor];
    NSMutableArray* array = [NSMutableArray array];
    for (Section* section in self.sections){
        [array addObject:section.sectionName];
    }
    
    return array;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
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
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchBarCancelButtonClicked:searchBar];
}


@end

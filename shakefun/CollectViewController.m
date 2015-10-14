//
//  CollectViewController.m
//  shakefun
//
//  Created by zm on 15/9/9.
//  Copyright (c) 2015年 zm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectViewController.h"
#import "URLEntity.h"
#import "ViewController.h"

@implementation CollectViewController 
{
    
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.textViewLogInfo.text = @"";
}

- (IBAction)buttonStartCollectToggle:(id)sender {
    //http://www.hao123.com/gaoxiao?pn=2
    
    [self.view endEditing:YES];
    
    if (self.textfieldPageNum.text.length <= 0) {
        return;
    }
    NSInteger page = [self.textfieldPageNum.text integerValue];
    NSString *pageurl = [NSString stringWithFormat:@"http://www.hao123.com/gaoxiao?pn=%ld", (long)page];
    NSString *dataString = [NSString stringWithContentsOfURL:[NSURL URLWithString:pageurl] encoding:NSUTF8StringEncoding error:nil];
    NSArray *urls = [dataString componentsSeparatedFromString:@"<img selector=\"pic\" img-src=\"" toString:@"\" src="];
    int i = 1;
    NSString *display = @"";
    for (NSString *url in urls) {
        display = [NSString stringWithFormat:@"result %d:%@", i++, url];
        dispatch_async(dispatch_get_main_queue(),^{
                           self.textViewLogInfo.text = [self.textViewLogInfo.text stringByAppendingString:display];
                       });
        
        URLEntity *r = [URLEntity MR_findFirstByAttribute:@"filename" withValue:[url lastPathComponent]];;
        if (!r) {
            r = [URLEntity MR_createEntity];
            r.filename = [url lastPathComponent];
            r.fullurl = url;
        }
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shakefun_reload_urls" object:nil];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
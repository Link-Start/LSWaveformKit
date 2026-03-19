//
//  LSMainViewController.m
//  LSWaveformKitOCDemo
//
//  Created by Link on 2024/01/XX.
//  Copyright © 2024 Link. All rights reserved.
//

#import "LSMainViewController.h"
#import <LSWaveformKit/LSWaveformKit-OC.h>

@interface LSDemoItem : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, assign) NSInteger action;
@end

@implementation LSDemoItem
@end

@interface LSDemoSection : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSArray<LSDemoItem *> *items;
@end

@implementation LSDemoSection
@end

@interface LSMainViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<LSDemoSection *> *dataSource;

@end

@implementation LSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"LSWaveformKit Demo";
    self.view.backgroundColor = UIColor_020120();

    [self setupData];
    [self setupUI];
}

- (void)setupData {
    self.dataSource = @[
        [self createBasicSection],
        [self createAdvancedSection],
        [self createMusicPlayerSection],
        [self createEffectsSection]
    ];
}

- (LSDemoSection *)createBasicSection {
    LSDemoSection *section = [[LSDemoSection alloc] init];
    section.title = @"基础示例";

    NSMutableArray *items = [NSMutableArray array];

    LSDemoItem *item1 = [[LSDemoItem alloc] init];
    item1.title = @"简单录音";
    item1.detail = @"最基础的录音功能";
    item1.action = 0;
    [items addObject:item1];

    LSDemoItem *item2 = [[LSDemoItem alloc] init];
    item2.title = @"音频播放";
    item2.detail = @"播放音频并显示波形";
    item2.action = 1;
    [items addObject:item2];

    section.items = [items copy];
    return section;
}

- (LSDemoSection *)createAdvancedSection {
    LSDemoSection *section = [[LSDemoSection alloc] init];
    section.title = @"高级示例";
    section.items = @[];
    return section;
}

- (LSDemoSection *)createMusicPlayerSection {
    LSDemoSection *section = [[LSDemoSection alloc] init];
    section.title = @"音乐播放器风格";
    section.items = @[];
    return section;
}

- (LSDemoSection *)createEffectsSection {
    LSDemoSection *section = [[LSDemoSection alloc] init];
    section.title = @"音乐特效";
    section.items = @[];
    return section;
}

- (void)setupUI {
    // 创建 TableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = UIColor_020120();
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    [self.view addSubview:self.tableView];

    // 设置约束
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource[section].items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    LSDemoItem *item = self.dataSource[indexPath.section].items[indexPath.row];

    cell.backgroundColor = UIColor_2C2C2C();
    cell.textLabel.textColor = UIColor_FFFFFF();
    cell.textLabel.font = PingFangSCRegular(14);
    cell.textLabel.text = item.title;
    cell.detailTextLabel.textColor = UIColor_D1D6D9();
    cell.detailTextLabel.font = PingFangSCRegular(12);
    cell.detailTextLabel.text = item.detail;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.dataSource[section].title;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    LSDemoItem *item = self.dataSource[indexPath.section].items[indexPath.row];
    [self showDemoWithAction:item.action];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

#pragma mark - Navigation

- (void)showDemoWithAction:(NSInteger)action {
    UIViewController *viewController;

    switch (action) {
        case 0: // 简单录音
            viewController = [[LSSimpleRecordViewController alloc] init];
            break;
        case 1: // 音频播放
            viewController = [[LSAudioPlayViewController alloc] init];
            break;
        default:
            return;
    }

    viewController.title = @"Demo";
    [self.navigationController pushViewController:viewController animated:YES];
}

@end

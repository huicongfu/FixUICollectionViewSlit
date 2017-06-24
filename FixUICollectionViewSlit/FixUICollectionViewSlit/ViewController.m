//
//  ViewController.m
//  FixUICollectionViewSlit
//
//  Created by hunuo on 2017/6/24.
//  Copyright © 2017年 fhc. All rights reserved.
//

#define Wi [UIScreen mainScreen].bounds.size.width
#define He [UIScreen mainScreen].bounds.size.height
#define  randomColor  random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))
#define FHCRandomColor      [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1.0f];


#import "ViewController.h"

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, retain) UICollectionView * collectionView;
@property (nonatomic) CGRect rect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _rect = CGRectMake(0, 0, Wi, He);
    CGFloat realWi = [self fixSlitWith:_rect colCount:4 space:0];
    //    CGSizeMake(realWi, 60);
    
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(realWi, 60);
    //    flowLayout.itemSize = CGSizeMake(Wi/4.0, 60);//93.75
    
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    //    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, Wi, He) collectionViewLayout:flowLayout];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:_rect collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = FHCRandomColor;
    return cell;
}

//只要itemSize的width的小数点后只有1位且最小为5也就是满足1px=0.5pt这个等式。
- (CGFloat)fixSlitWith:(CGRect)rect colCount:(CGFloat)colCount space:(CGFloat)space {
    //    space = 0;
    CGFloat totalSpace = (colCount - 1) * space;//总共留出的距离
    CGFloat itemWidth = (rect.size.width - totalSpace) / colCount;// 按照真实屏幕算出的cell宽度 （iPhone6 375*667）93.75
    CGFloat fixValue = 1 / [UIScreen mainScreen].scale; //(6为1px=0.5pt,6Plus为3px=1pt)1个点有两个像素
    CGFloat realItemWidth = floor(itemWidth) + fixValue;//取整加fixValue  floor:如果参数是小数，则求最大的整数但不大于本身.
    if (realItemWidth < itemWidth) {// 有可能原cell宽度小数点后一位大于0.5
        realItemWidth += fixValue;
    }
    
    CGFloat realWidth = colCount * realItemWidth + totalSpace;//算出屏幕等分后满足`1px=0.5pt`实际的宽度
    CGFloat pointX = (realWidth - rect.size.width) / 2; //偏移距离
    rect.origin.x = -pointX;//向左偏移
    rect.size.width = realWidth;
    _rect = rect;
    return realItemWidth;//(rect.size.width - totalSpace) / colCount; //每个cell的真实宽度
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

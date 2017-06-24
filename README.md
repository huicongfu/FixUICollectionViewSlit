# FixUICollectionViewSlit
修复UICollectionView等分有缝隙

在使用`UICollectionView`开发无缝隙或者间隙为1px的页面的时候应该会遇到这样的问题(iPhone 5s 没有问题)，明明是把屏幕四等分了,但为什么会有下图的空白间隙呢?

![等分有缝隙](http://upload-images.jianshu.io/upload_images/1055266-5e0651de86413a27.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/320)

再检查一下代码:
```
   UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
   flowLayout.itemSize = CGSizeMake(Wi/4.0, 60);//算出来的宽度是93.75
   flowLayout.minimumLineSpacing = 0;
   flowLayout.minimumInteritemSpacing = 0;
   _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, Wi, He) collectionViewLayout:flowLayout];
```
发现代码也是没有问题啊,可为什么会有这样呢?(之前开发遇过这个问题,但是被自己用"画线填充"的方式取巧搞定了,没想到这次有同事问我这个问题,为了能有一个通用的方法,还是要去找出原因)。果然还是从简书找到解决方法[UICollectionView 缝隙修复](http://www.jianshu.com/p/4db0be2f4803),这里我结合我的理解做进一步解释。`有哪位看官对此有更好的阐述希望不吝指导`

* 首先应该了解一下 `[[UIScreen mainScrenn] scale] `

```
iPhone 4 之前的设备为1.0
iPhone 4 ~ iPhone 6s (除plus外) 的为2.0
iPhone 6 plus 和 iPhone 6s plus 的为3.0
对于iPhone 6 Plus之前的手机，pt和px的比例是1：2，而iPhone 6 Plus出来之后，这一比例达到了1：3，
```

还是不太明白的话可以谷歌一下,这里有篇扩展阅读:   [「像素」「渲染像素」以及「物理像素」是什么东西？它们有什么联系？](https://www.zhihu.com/question/27261444)

###造成缝隙的原因
iPhone6的屏幕像素(point,也叫逻辑像素)是`375*667`,物理像素为`750*1334`,等分4份的话每一个item的宽度是`375/4=93.75`,这里是没有问题的,问题是屏幕能分的最小物理像素是1,而iPhone6的`[[UIScreen mainScrenn] scale] `是2.0,也就是说1个屏幕像素(逻辑像素)对应有2个物理像素,即0.5个屏幕像素对应1个物理像素,而iPhone6四等分的宽度是`93.75`,根据前面的分析有`0.25`是不可再分的,这就是造成缝隙的原因。
同理iPhone6 Plus的`[[UIScreen mainScrenn] scale]`是3.0,也就是说1个屏幕像素(逻辑像素)对应有3个物理像素,即0.333333个屏幕像素对应1个物理像素,四等分之后是`414/4=103.5`,有`0.16`是不可再分的,也会有缝隙。
###解决办法
思路:只要itemSize的width的小数点后的值等于`1 / [UIScreen mainScreen].scale`的值即可。

```
- (CGFloat)fixSlitWith:(CGRect)rect colCount:(CGFloat)colCount space:(CGFloat)space {
    CGFloat totalSpace = (colCount - 1) * space;//总共留出的距离
    CGFloat itemWidth = (rect.size.width - totalSpace) / colCount;// 按照真实屏幕算出的cell宽度 （iPhone6 375*667）93.75
    CGFloat fixValue = 1 / [UIScreen mainScreen].scale; //(1px=0.5pt,6Plus为3px=1pt)
    CGFloat realItemWidth = floor(itemWidth) + fixValue;//取整加fixValue  floor:如果参数是小数，则求最大的整数但不大于本身.
    if (realItemWidth < itemWidth) {// 有可能原cell宽度小数点后一位大于0.5
        realItemWidth += fixValue;
    }
    CGFloat realWidth = colCount * realItemWidth + totalSpace;//算出屏幕等分后满足1px=([UIScreen mainScreen].scale)pt实际的宽度,可能会超出屏幕,需要调整一下frame
    CGFloat pointX = (realWidth - rect.size.width) / 2; //偏移距离
    rect.origin.x = -pointX;//向左偏移
    rect.size.width = realWidth;
    _rect = rect;
    return realItemWidth; //每个cell的真实宽度
}
```
####修复后的效果

![修复后的效果](http://upload-images.jianshu.io/upload_images/1055266-6ff4c315d30e778c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/320)

![间隙为1的效果,不会出现有宽窄不一的情况了](http://upload-images.jianshu.io/upload_images/1055266-ddcd06f66a89a432.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/320)

[OC版本demo下载](https://github.com/huicongfu/FixUICollectionViewSlit)

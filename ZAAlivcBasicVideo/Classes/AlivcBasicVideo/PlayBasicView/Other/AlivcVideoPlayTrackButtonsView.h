//
//  AlivcVideoPlayTrackButtonsView.h
//  AlivcLongVideo
//
//  Created by ToT on 2019/12/25.
//

#import <UIKit/UIKit.h>

typedef void(^selectChangedCallBack)(NSInteger index,NSString *title);

@interface AlivcVideoPlayTrackButtonsView : UIView

@property (nonatomic,assign)NSInteger selectIndex;
/// 保留值
@property (nonatomic,retain) NSNumber *indexNumber;
@property (nonatomic,strong)NSArray <NSString *>*titleArray;
@property (nonatomic,strong)selectChangedCallBack callBack;

- (instancetype)initWithFrame:(CGRect)frame isHorizontal:(BOOL)isHorizontal;

- (instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray <NSString *>*)titleArray;

- (instancetype)initHorizontalWithFrame:(CGRect)frame titleArray:(NSArray <NSString *>*)titleArray;

@end



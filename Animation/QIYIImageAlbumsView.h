//
//  QIYIImageAlbumsView.h
//  ITest
//
//  Created by iqiyi on 16/6/29.
//  Copyright © 2016年 iqiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QIYIImageAlbumsView;

@protocol QIYIImageAlbumsViewDelegate <NSObject>

- (void)imageAlbumsView:(QIYIImageAlbumsView *)view tapedCancelButton:(id)sender;

- (void)imageAlbumsView:(QIYIImageAlbumsView *)view selectedIndexPath:(NSIndexPath *)indexPath;

@end

@interface QIYIImageAlbumsView : UIView

@property (nonatomic, strong) NSMutableArray *albumsArray;

@property (nonatomic, weak) id<QIYIImageAlbumsViewDelegate> delegate;

- (void)reloadDataSource;

@end


@interface QIYIImageAlbumsViewCell : UITableViewCell

//显示的数据
@property (nonatomic, strong) id model;

@end

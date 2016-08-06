  /** 选择功能 */
	// 设置3D滚动效果
	[scrollView add3DRotate];
	// 无限滚轮，（必须添加最后一张图片在首部，第一张在尾部）
	[scrollView addInfiniteLoop];
	// 添加自动滚轮定时器
	[scrollView addTimer];
	// 添加scrollView
	[self.view addSubview:scrollView];
	// 一定在添加scrollView之后
	[scrollView addPageControl];

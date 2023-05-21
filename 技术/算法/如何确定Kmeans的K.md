## 如何确定Kmeans的K

http://sofasofa.io/forum_main_post.php?postid=1000282

* 按需选择

例如，游戏公司在对玩家水平进行聚类分析时，区分为顶级/高级/中级/菜鸟，则K=4；房地产企业在对商品房进行划分时，区分为高中低三档，则K=3.

* 观察法 

作图，直观判断类别数。对于高维数据，利用PCA降维，再进行处理。（比较主观）

* 手肘法

对于不同的K值，计算相应的衡量指标，选取指标有明显变化的点（拐点）。指标可选取，所有点到其聚类中心的欧式距离之和/组内方差组间方差比。

* Gap Statistic

https://web.stanford.edu/~hastie/Papers/gap.pdf

Gap Statistic取得最大值对应的K值即为最佳K值。

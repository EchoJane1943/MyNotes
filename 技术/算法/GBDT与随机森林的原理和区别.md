Q：GBDT与随机森林的原理和区别

1.随机森林采用的bagging思想，而GBDT采用的boosting思想。这两种方法都是Bootstrap思想的应用，Bootstrap是一种有放回的抽样方法思想。虽然都是有放回的抽样，但二者的区别在于：Bagging采用有放回的均匀取样，而Boosting根据错误率来取样（Boosting初始化时对每一个训练样例赋相等的权重1／n，然后用该算法对训练集训练t轮，每次训练后，对训练失败的样例赋以较大的权重），因此Boosting的分类精度要优于Bagging。Bagging的训练集的选择是随机的，各训练集之间相互独立，弱分类器可并行，而Boosting的训练集的选择与前一轮的学习结果有关，是串行的。
2.组成随机森林的树可以是分类树，也可以是回归树；而GBDT只能由回归树组成。
3.组成随机森林的树可以并行生成；而GBDT只能是串行生成。
4.对于最终的输出结果而言，随机森林采用多数投票等；而GBDT则是将所有结果累加起来，或者加权累加起来。
5.随机森林对异常值不敏感；GBDT对异常值非常敏感。
6.随机森林对训练集一视同仁；GBDT是基于权值的弱分类器的集成。
7.随机森林是通过减少模型方差提高性能；GBDT是通过减少模型偏差提高性能。

实现简单，可解释性强，容易并行化，计算效率高

# 随机森林

随机森林的决策树完全生长来保证偏差，随机（行采样+列采样）与集成来保证方差。


# GBDT：Gradient Boosting Decision Tree = Gradient Boosting Machine + Decision Tree

其中 Tree 指 CART：classification and regression tree

先学先验知识：CART

## CART

由Breiman等人在1984年提出。

* CART是一棵二叉树  
* CART既是分类树又是回归树  
* 当CART是分类树的时候，采用GINI值作为分裂节点的依据，当CART作为回归树的时候，使用样本的最小方差作为分裂节点的依据  

### 分类树（例子）

分类依据：GINI指数，基尼指数越大，样本集合的不确定性越大。

假设有K个类，样本点属于第k类的概率为P_k，则概率分布的gini指数为：GINI（p）=\sum_{i=1}^{K}P_k(1-P_k).

输入：训练数据集D,停止计算的条件

输出：CART决策树

具体步骤:

(1)计算现有特征对该数据集的基尼指数，对于每一个特征A，可以对样本点根据该特征的某一切分点a将数据集D分成数据集D1,D2。

(2)对于所有的特征A和所有可能的切分点a，选择基尼指数最小的特征以及相对应的切分点作为最优特征和最佳切分点。

(3)对最优子树递归调用(1)(2)，直到满足停止条件。

(4)生成CART分类树。


### 回归树

输入：训练数据集D,停止计算的条件

输出：回归树f(x)

...

例如要预测某连续变量B，使用某一个属性A，A有三个离散取值x,y,z。分{x},{y,z};{y},{x,z};{z},{x,y}三种分类方式，计算不同分类方式下的目标函数并取其最小值（使用B的平均值代表分组后的值计算目标函数）。


## GBM

gradient boosting不同于Adaboost，adaboost通过更新样本的权重来提升效果，而GB通过改变样本的目标值来实现相同的效果。对于损失函数来说，沿着其负梯度方向更新参数能够最快达到最优。GradientBoosting的关键点在于每次针对损失函数的负梯度来构建弱模型（也就是对该样本的负梯度值为新的目标值--对于平方损失函数来说即为残差），然后将这个学习到的弱模型作为加法模型的最新一项集成到加法模型中来，顺序地构造弱模型，直到满足阈值或其它停止条件。

references：

【1】https://blog.csdn.net/gzj_1101/article/details/78355234

【2】机器学习-周志华 第四章决策树

【3】https://zhuanlan.zhihu.com/p/81594571


references:

[1]https://blog.csdn.net/niuniuyuh/article/details/76922210

[2]paper:greedy function approximation: a gradient boosting machine

简介：GBDT：Gradient BoostingDecisionTree，基于boosting的思想，并行地构造多棵决策树来进行数据的预测。具有特征自动组合、高效运算等特点

疑问：为什么能够实现特征自动组合，高效运算等。

先验知识：CART（因为GBDT的T即为CART回归树）

## CART
reference:https://www.cnblogs.com/yonghao/p/5135386.html

1）CART can be classification tree or regression tree

2）when classification tree,采用GINI值作为分裂依据；when regression tree，采用样本的最小方差作为分裂依据

3）CART是一颗二叉树

<a href="https://www.codecogs.com/eqnedit.php?latex=gain&space;=&space;\sum\sigma_i" target="_blank"><img src="https://latex.codecogs.com/gif.latex?gain&space;=&space;\sum\sigma_i" title="gain = \sum\sigma_i" /></a>


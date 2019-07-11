## MarReduce

**Google的三驾马车：GFS（Google File System）/BigTable/MapReduce**

Hadoop文档

中文地址：http://hadoop.apache.org/docs/r1.0.4/cn/index.html

英文地址：http://hadoop.apache.org/docs/current/index.html

* Hadoop MapReduce是一个使用简易的软件框架，基于它写出来的应用程序能够运行在由上千个商用机器组成的大型集群上，并以一种可靠容错的方式并行处理上T级别的数据集。

* 其本质上是一种编程模型，用于大规模数据集（大于1TB）的并行运算。

* mapreduce与hdfs的关系

HDFS负责海量数据存储，Map Reduce负责海量数据计算。

* mapreduce与Spark的关系

Spark延续了Map Reduce的设计思路，对数据的计算也分为Map和Reduce两类。区别在于，一个Spark任务由多个map、reduce构成。这样，计算的中间结果能够高效地传给下一个计算步骤，提高算法性能。（实验结果显示，spark的算法性能比MapReduce提高了10-100倍。）

* MapReduce是六大过程，简单来说：Input, Split, Map, Shuffle, Reduce, Finalize。（Reducer主要包括shuffle、sort、reduce三个阶段）

* Map Reduce框架由一个单独的master JobTracker和每个集群节点一个slave TaskTracker共同组成。master负责调度，slave负责执行由master指派的任务。

* 一个mapreduce作业的输入和输出类型：(input) <k1, v1> -> **map** -> <k2, v2> -> **combine** -> <k2, v2> -> **reduce** -> <k3, v3> (output)

下图是mapreduce的应用示例图，word count

![MapReduce](https://github.com/EchoJane1943/NotesOfMachineLearning/blob/master/biddata/figure/MapReduce.png)

* Map的数目通常由输入数据的大小决定，一般就是输入文件的block数。 Map正常的并行规模大致是每个节点（node）大约10-100个map，对于CPU消耗较小的map任务可以设定到300个左右。由于每个任务需要一档的初始化时间，比较合理的情况是map执行的时间至少超过1min。

Map意为映射，reduce意为归约。其主要思想借鉴了函数式编程语言和矢量编程语言，方便编程人员在不会分布式并行编程的情况下，将自己的程序运行在分布式系统上。

当前的软件实现是指定一个map函数，用来把一组键值对映射成一组新的键值对，指定并发的reduce函数，用来保证所有映射的键值对中的每一个共享相同的键组。


**MapReduce如何解决数据倾斜**

知乎回答地址：https://www.zhihu.com/question/27593027/answer/248861446



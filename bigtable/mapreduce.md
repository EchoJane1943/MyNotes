## 如何解决oom

* return code 2
* outofmemory

 https://blog.csdn.net/oopsoom/article/details/41356251
 
 由于一个map通常配置只有64MB或者128MB，则在Map阶段出现OOM的情况很少见。所以一般发生在reduce阶段。  
 map阶段oom：较少发生，发生解决办法：修改sql  
 reduce阶段oom：  
 1.data skew 数据倾斜：某一个reduce处理的数据超过预期，导致jvm频繁GC  
 2.value对象过多或者过大：某个reduce的value堆积的对象过多，导致jvm频繁GC
 
set hive.groupby.skewindata = true -- group by过程出现倾斜  
hive.optimize.skewjoin = true -- join过程出现倾斜  
使用map join 代替 common join. 可以set hive.auto.convert.join = true  
增加reduce个数，set mapred.reduce.tasks=300  

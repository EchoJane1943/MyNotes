## mapreduce数据倾斜

https://www.zhihu.com/question/27593027/answer/248861446

https://segmentfault.com/a/1190000009166436

https://www.cnblogs.com/skyl/p/4855099.html

* 产生原因

1)group by  
group by 维度少，导致某一维度值比较多；某一类别数据较多。

2）去重 distinct count（1）  
某一特殊值的数据量较多  

3）join 小表join大表；大表join大表

* 解决办法  

1）调优参数  
set hive.map.aggr=true； 需要更多内存  
set hive.groupby.skewindata=true; 生成的查询计划会有两个MRjob  

2)在 key 上面做文章，在 map 阶段将造成倾斜的key 先分成多组，例如 aaa 这个 key,map 时随机在 aaa 后面加上 1,2,3,4 这四个数字之一，
把 key 先分成四组，先进行一次运算，之后再恢复 key 进行最终运算。    

3)能先进行 group 操作的时候先进行 group 操作，把 key 先进行一次 reduce,之后再进行 count 或者 distinct count 操作。--针对2）   

4)join 操作中，使用 map join 在 map 端就先进行 join ，免得到reduce 时卡住。

5）left semi join 应用

6）查询语句中某个关联字段null过多出现数据倾斜，可用解决办法：

  select * from log a left outer join bmw_users b on case when a.user_id is null then concat('dp_hive',rand() ) else a.user_id end = b.user_id;

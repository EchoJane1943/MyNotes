## 如何解决oom

* return code 2
* outofmemory

 https://blog.csdn.net/oopsoom/article/details/41356251
 
数据倾斜：
set hive.groupby.skewindata = true  
hive.optimize.skewjoin = true  

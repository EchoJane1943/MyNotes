https://www.cnblogs.com/shiliye/p/10518151.html

## group by grouping sets

*Group by分组函数的自定义，与group by配合使用可更加灵活的对结果集进行分组，Grouping sets会对各个层级进行汇总，然后将各个层级的汇总值union all在一起，但却比单纯的group by + union all 效率要高*

### 1 创建数据

    CREATE TABLE employee
    (
      name          NVARCHAR2(10),
      gender        NCHAR(1),
      country       NVARCHAR2(10),
      department    NVARCHAR2(10),
      salary        NUMBER(10)
    );
    INSERT INTO employee VALUES ('张三','男','中国','市场部',4000);
    INSERT INTO employee VALUES ('李四','男','中国','市场部',5000);
    INSERT INTO employee VALUES ('王五','女','美国','市场部',3000);  
    INSERT INTO employee VALUES ('赵红','男','中国','技术部',2000);
    INSERT INTO employee VALUES ('李白','女','中国','技术部',5000);  
    INSERT INTO employee VALUES ('王蓝','男','美国','技术部',4000);
    commit;


### 2 实例

    SELECT country, null department, round(avg(salary), 2) FROM employee GROUP BY country
    UNION ALL
    SELECT null country, department, round(avg(salary), 2) FROM employee GROUP BY department;
    等价于
    SELECT country, department, round(avg(salary), 2) FROM employee GROUP BY GROUPING SETS (country, department);


    GROUP BY GROUPING SETS (A,B,C)  等价与  GROUP BY A  
                                            UNION ALL  
                                            GROUP BY B  
                                            UNION ALL  
                                            GROUP BY C


    GROUP BY GROUPING SETS ((A,B,C))  等价与  GROUP BY A,B,C  


    GROUP BY GROUPING SETS (A,(B,C))  等价与  GROUP BY A  
                                              UNION ALL  
                                              GROUP BY B,C


    GROUP BY GROUPING SETS (A)  等价于  GROUP BY A,B,C  
            ,GROUPING SETS (B)  
            ,GROUPING SETS (C)  


    GROUP BY GROUPING SETS (A)  等价于  GROUP BY A,B,C  
            ,GROUPING SETS ((B,C))   


    GROUP BY GROUPING SETS (A)  等价于  GROUP BY A,B  
            ,GROUPING SETS (B,C)        UNION ALL  
                                        GROUP BY A,C


    GROUP BY A                     等价于  GROUP BY A  
            ,B                                     ,B  
            ,GROUPING SETS ((B,C))                 ,C  


    GROUP BY A                    等价于  GROUP BY A,B,C  
            ,B                            UNION ALL  
            ,GROUPING SETS (B,C)          GROUP BY A,B  


    GROUP BY A                    等价于 GROUP BY A,B,C  
            ,B                           UNION ALL  
            ,C                           GROUP BY A,B,C  
            ,GROUPING SETS (B,C)

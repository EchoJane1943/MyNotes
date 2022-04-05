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


#### 视图（View）
  是一种虚拟表，并不在数据库中实际存在，视图就是执行查询语句后所返回的结果集；
  1.	简单高效：因为视图是查询语句执行后返回的已经过滤好的复合条件的结果集，所以使用视图的用户完全不需要关心后面对应的表的结构、关联条件和筛选条件。
  2.	安全：使用视图的用户只能访问他们被允许查询的结果集，对于表的权限管理并不能限制到某个行或者某个列，但是通过视图就可以简单的实现。
  3.	数据独立:一旦视图的结构被确定了，可以屏蔽表结构变化对用户的影响，源表增加列对视图没有影响；源表修改列名，则可以通过修改视图来解决，不会造成对访问者的影响。
  函数【minus】：比较两个表的差异；如 select c1,c2 from a  minus select c1,c2 from b，返回a表中存在而b表不存在的记录；
  行转列【SPARK SQL函数pivot】与列转行【stack()，lateral view + explode()】：

    select
          is_company_name
        , os_decision_stcd_details_name
    from odm.odm_risk_cds_jrm001_jrm_szjc_dh_hb_log_i_d lateral view explode(split(os_decision_stcd_details,',')) table_tmp as os_decision_stcd_details_name;

#### 【日期函数总结】

    last_day('2020-07-09')          -- '2020-07-31' 月末
    to_month('2020-07-09')         -- '2020-07'
    to_quarter('2020-07-09')        -- '2020Q3'
    trunc('2020-07-09', 'MM')       -- '2020-07-01' 月初
    month_add('2020-07-09',1)      -- '2020-08-09'
    add_months('2020-07-09',1)      -- '2020-08-09'  (spark & MR)
    date_sub('2020-07-09', -1)       -- 2020-07-10
    ADD_MONTHS表示从某日期增加或减少指定月份的日期。它考虑了大小月问题，所以计算日期是准确的
    select month_add('2021-02-28',1)  --‘2021-03-28’
    select add_months('2021-02-28',1) -- ‘2021-03-31’

    next_day('2020-07-09', 'TH'); -- '2020-07-16' 返回下一个指定的周几（MO周一，TU周二，WE周三，TH周四，FR周五，SA周六，SU周日）
    string(to_date(from_unixtime(UNIX_TIMESTAMP('20200101', 'yyyyMMdd'))))      -- 转为日期格式
    string(to_date(from_unixtime(UNIX_TIMESTAMP('2020-01-01', 'yyyy-MM-dd'))))  -- 转为日期格式
    sysdate()  -- 系统日期
    sysdate(1) -- 系统日期+1d

#### 【函数总结】

    nvl(expr1,expr2)        若expr1是null（空值），则返回expr2，否则返回expr1



#### 【经典题目】

1、连续交易3天的客户id
            
    use dmr_dev;
    drop table nym_tmp_01;
    create table nym_tmp_01 as
    select stack(8
    ,'1'	,'20180101'	,'1'	,'1'
    ,'2'	,'20180101'	,'2'	,'2'
    ,'3'	,'20180101'	,'3'	,'3'
    ,'1'	,'20180102'	,'4'	,'4'
    ,'2'	,'20180102'	,'5'	,'5'
    ,'2'	,'20180102'	,'6'	,'6'
    ,'1'	,'20180103'	,'7'	,'7'
    ,'3'	,'20180103'	,'8'	,'8'
    )  as (uid,tm,amt,oid)
    ;
    select
        m.uid  
    from dmr_dev.nym_tmp_01 m
    inner join dmr_dev.nym_tmp_01 n
    on m.uid = n.uid
    and m.tm <= n.tm +2
    group by 1
    having count(distinct m.tm) = 3
    ;

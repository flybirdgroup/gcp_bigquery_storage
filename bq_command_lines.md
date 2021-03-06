# bq主要涉及增,删,显示,查,所以从这四方面整理

## 查看数据集的schema 使用bq show 数据集

<!--truncate-->

# 增 bq mk, bk load
```bq
bq mk babaynames 创建新的数据集,在自己项目中命名
#### 创建表格 bq load datasetID tableID data_file Schema
bq load 数据集ID.表格ID(如果空就自己创建一个)  数据文件(比如txt) schema类型
bq load datasetID.tableid your_file name:string,gender:string,count:integer(your schema)
bq load --source_format=AVRO fakedatas.customer "gs://zz_bucket/avro/cust.avro" (avro文件)
```

# 删 bq rm -r
## 删除数据集 bq rm
bq rm -r 数据集id
```
bq rm -r babynames
```
# 显示 bq ls, bq show
### 检测表格是否创建成功或者更新成功
创建后,可以通过bq ls 数据集id 查看是否创建成功
也可以通过bq show 数据集id.tableid 查看schema
```
bq ls 显示所有dataset
bq ls babaynames 显示datasetid的所有table
bq show datasetid 显示dataset的ACL(权限) 比如可以看到 谁是owners,writers,readers
bq show babynames.names2010 显示table的schema类型,多少文本数,字段
```

# 查 bq query --use_legacy_sql=false 'select * from dataset.table'
```
## 运行sql语句命令
总体格式就是 bq query --use_legacy_sql=false 'select 字段 耦合字段(比如count(*)) from datasetid.tableid where 条件 order by 字段 (做排序ASC,DESC) Limit 数字(限制条数)'
注意的地方是 
### use_legacy_sql=false 表示使用标准sql语句
### 条件的时候可以使用双引号做区分""
```sql
bq query "select name,count from babynames.names2010 where gender = 'F' Order by count desc limit 5"

bq query --use_legacy_sql=false 'SELECT word,SUM(word_count) AS count FROM `bigquery-public-data`.samples.shakespeare WHERE word LIKE "%raisin%" GROUP BY word'

第二个例子是选择从bq公共集中选择samples这个dataset,然后从这个dataset的shakespeare表中选择word字段, 执行条件是 word字段必须等于"huzzah"
bq query --use_legacy_sql=false 'SELECT word FROM `bigquery-public-data`.samples.shakespeare WHERE word = "huzzah"'
```

## 运行帮助命令
```
bq help query
```

### 下载数据到项目中
使用wget 数据源连接(比如zip,txt,csv等)
```wget
wget http://www.ssa.gov/OACT/babynames/names.zip
```
### 解压缩zip文件到项目中
```
unzip names.zip
```

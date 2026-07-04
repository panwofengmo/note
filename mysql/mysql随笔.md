1. 索引的效率取决于索引列的值是否散列，即该列的值如果越互不相同，那么索引效率越高
如果记录的列存在大量相同的值，对该列创建索引就没有意义
索引越多，插入、更新和删除记录的速度就越慢


2. 成绩从低到高进行排序, 如果有相同分数的，再按gender列排序
```
SELECT * FROM students ORDER BY score DESC, gender;
```

3. 查询性别为男，并且年龄在20-40岁(含)以内的姓名为三个字的员工。
+ 难点在于：姓名为三个字
```
select * from emp where gender = '男' and age >= 20 and age <= 40 and name like '___';
```

4. 













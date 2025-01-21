# lua常用的table函数

# 1. table.concat

## 基本形式: table.concat(table1,[sep],[start],[end])

	sep: 指定连接符，连接元素之前的符号  
	start: 数组元素开始位置  
	end: 数组元素结束位置

## 功能:输出元素

	该函数用于将指定的 table 数组元素进行字符串连接。连接从 start 索引位置到 end  
	索引位置的所有数组元素, 元素间使用指定的分隔符 sep 隔开。如果 table 是一个混合结构，  
	那么这个连接与 key-value 无关，仅是连接数组元素(下标为1,2,3...的元素)。

```lua

t1 = {"a", age = 23,"b","c",name = "王五", "d"}
 
t = table.concat(t1)
print(t)
t = table.concat(t1,"+",2,3)
print(t)

//输出结果如下：
abcd
b+c
```

‍

‍

# 2.table.unpack

## 基本形式: table.unpack(table1,[i],[j])

	i,j :第i个元素到第j个元素

## 功能：拆包

	拆包。该函数返回指定 table 的数组中的从第 i 个元素到第 j 个元素值。i 与 j 是可选的，默认 i 为 1，j 为数组的最后一个元素。Lua5.1 不支持该函数。

```lua
//示例
t1 = {"a","b",name = "张三",age = 23, "c"}
t,t23,tc = table.unpack(t1)                                                                                                                                                        
print(t)
print(t23)
print(tc)
--输出结果如下：
a
b
c
```

‍

‍

# 3.table.pack()

## 基本形式: table.pack(...)

## 功能：打包

	打包。该函数的参数是一个可变参，其可将指定的参数打包为一个 table 返回。这个返回的 table 中具有一个属性 n，用于表示该 table 包含的元素个数。Lua5.1 不支持该函数。

```lua
//示例：
t1 = table.pack("a","b", "zhangshan")
 
print(t1.n)
print(t1[3])
 
--输出结果如下：
3
zhangshan
```

‍

‍

# 4. table.maxn()

## 基本形式: table.maxn(table1)

## 功能：返回表最大索引值

	该函数返回指定 table 的数组中的最大索引值，即数组包含元素的个数。

```lua
//示例：
t1 = {"a", age = 23,"b","c",name = "王五", "d"}
 
print(table.maxn(t1))
print(t1[5])
print(t1[4])
 
//输出结果如下:
4
nil
d
```

‍

‍

# 5. table.insert

## 基本形式: table.insert(table1,[pos],value)

## 功能：插入元素

	该函数用于在指定 table 的数组部分指定位置 pos 插入值为 value 的一个元素。其后的元素会被后移。pos 参数可选，默认为数组部分末尾。

```lua
//示例：
t1 = {"a", age = 23,"b","c",name = "王五", "d"}
print(t1[1])
table.insert(t1,1,"insetTest")
print(t1[1])
print(t1[2])
 
//输出结果如下：
a
insetTest
a
```

‍

‍

# 6. table.remove

## 基本形式: table.remove(table1,[pos])

## 功能：删除元素

	该函数用于删除并返回指定 table 中数组部分位于 pos 位置的元素。其后的元素会被前移。pos 参数可选，默认删除数组中的最后一个元素。

```lua
//示例：
t1 = {"a", age = 23,"b","c",name = "王五", "d"}
 
print(t1[1])
t = table.remove(t1,1)
print(t)
print(t1[1])
 
//输出结果如下：
a
a
b
```

‍

# 7. table.sort()

## 基本形式: table.sort(table,[fun(a,b)])

## 功能：元素排序

	该函数用于对指定的 table 的数组元素进行升序排序，也可按照指定函数 fun(a,b)中指定的规则进行排序。

	fun(a,b)是一个用于比较 a 与 b 的函数，a 与 b 分别代表数组中的两个相邻元素。

## 注意

1. 如果 arr 中的元素既有字符串又有数值型，那么对其进行排序会报错。
2. 如果数组中多个元素相同，则其相同的多个元素的排序结果不确定，即这些元素的索引谁排前谁排后，不确定。
3. 如果数组元素中包含 nil，则排序会报错。

```lua
//示例：
t2 = {"d", age = 23,"c","b",name = "王五", "a"}
table.sort(t2,function (a,b) return a < b end)
 
local j = table.maxn(t2)
 
for i = 1, j do
	print(t2[i])
end
 
//输出结果如下：
a
b
c
d
```

‍

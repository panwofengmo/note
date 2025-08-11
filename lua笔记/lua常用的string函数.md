# lua常用的string函数

# 1. string.gsub

## 基本形式: string.gsub(s, pattern, replacement [, n])

	s: 原始字符串
	pattern: 是匹配模式（支持Lua特有的正则表达式语法）
	replacement: 可以是字符串或函数,替换者
	n: 可选参数，限制替换次数

## 功能:替换原字符串中的特定子字符串

## 返回值
1. 替换后的新字符串
2. 实际替换次数

## 例1
```lua
t1 = {"123:456", "1:2002", "999:888"}
for
t = table.concat(t1)
print(t)
t = table.concat(t1,"+",2,3)
print(t)

//输出结果如下：
abcd
b+c
```
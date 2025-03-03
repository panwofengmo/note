# <font face="宋体" font color=orange><center> markdown入门教程 </font></center>
## <center><font face> panda </font> </center>

### 一、准备工作
1. **安装vscode**
2. **安装vscode插件**
   1. markdown all in one
   2. markdown preview enhanced
3. **创建.md文件，开始编辑**

### 二、基本语法
1. **标题**  
   一级标题:#  
   二级标题:#  
   ...
2. **引用**
   >使用">"符号来进行引用
3. **列表**
   1. 无序列表：使用符号("-"、"+"、"*")
      - 列表1
      + 列表2
      * 列表3
   2. 有序列表: 使用符号("1."、"2." ...)
   3. todoList：使用符号(-加空格加[ ]加空格)
      - [X] 列表1
      - [ ] 列表2
4. **表格**
   | 左对齐 | 居中对齐 | 右对齐 |
   | :----- | :------: | -----: |
   | a      |    b     |      c |
   | 内容1  |  内容2   |  内容3 |
5. **段落**
   - 换行：两个空格后加回车
   - 分割线：三个以上的"-"、"*"
   ---
   ***
   - 字体
      |  字体  |     语法      |
      | :----: | :-----------: |
      |  粗体  |   **粗体**    |
      |  斜体  |    *斜体*     |
      | 粗斜体 | ***粗斜体***  |
      | 删除线 |  ~~删除线~~   |
      | 下划线 | <u>下划线</u> |
      |  脚注  |   文本[^1]    |
6. **代码**
  - 代码块：使用符号("```")
  ```
  #include <stdio.h>

  int main()
  {
      printf("hello world!\n");
      return 0;
  }
  ```  
  - 单行代码：使用符号("`")
  `printf("hello world!\n");`

7. **超链接**  
   - [超链接名称](超链接地址)  
      [更多参考教程可以参考网站](www.baidu.com)  

   - --[超链接名称]: 超链接地址  
      [更多参考教程可以参考网站]: www.baidu.com

8. **图片**  
   - [更多参考教程可以参考网站](https://www.bilibili.com/video/BV1bK4y1i7BY/?spm_id_from=333.1007.top_right_bar_window_default_collection.content.click&vd_source=e0a5634bca15aaa96226050e0930886e)
   - 23:55开始介绍图床相关的内容

### 三、其他操作
   - **插入latex公式**
     - 行内显示公式：$公式$  例：$f(x) = ax + b$
     - 块内显示数学表达式
     -- $$
        \begin{Bmatrix}
        f(x) = ax + b \\
        g(x) = cx + d
        \end{Bmatrix}
        $$
        
### 四、导出PDF
   - 在预览界面右击，open in browser，然后再浏览器右击，选择打印，最后选择保存为pdf格式即可。





[^1]:脚注内容
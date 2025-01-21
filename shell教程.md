# 一、#!和运行  
1. **`#!`的作用**：`#!` 是一个约定的标记，它告诉系统这个脚本需要什么解释器来执行，即使用哪一种 Shell。
   + `#!/bin/bash`
2. **运行**
   + `./test.sh`
   + `/bin/sh test.sh` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;//这种运行方式不需要再开头使用`#!/bin/bash`

# 二、变量
1. **赋值**
   + 例：`your_name="runoob"`
   + 变量名前不需要有int这样的定义
   + 等号两侧避免使用空格: 如`variable_name = value`    #有可能会导致错误

2. **使用变量**
   + 使用一个定义过的变量，只要在变量名前面加美元符号
   + 例1：
        ```
        your_name="qinjx"
        echo $your_name
        echo ${your_name}
        ```
   + 例2：(推荐给所有变量加上花括号，这是个好的编程习惯)
        ```
        for skill in Ada Coffe Action Java; do
            echo "I am good at ${skill}Script"
        done
        ```

3. **只读变量**
   + 使用 readonly 命令可以将变量定义为只读变量，只读变量的值不能被改变。
   + 实例:
    ```
    #!/bin/bash

    myUrl="https://www.google.com"
    readonly myUrl
    myUrl="https://www.runoob.com"

    运行结果：/bin/sh: NAME: This variable is read only.
    ```

4. **删除变量**
   + 使用 unset 命令可以删除变量
   + 语法：`unset variable_name`
   + 实例：
        ```
        #!/bin/sh

        myUrl="https://www.runoob.com"
        unset myUrl
        echo $myUrl

        运行结果：执行没有任何输出
        ```

5. **变量类型**
   + 字符串变量：在 Shell中，变量通常被视为字符串。可以使用单引号或者双引号来定义字符串
     + `my_string='Hello, World!'` 或者 `my_string="Hello, World!"`
   + 整数变量： 在一些Shell中，你可以使用 declare 或 typeset 命令来声明整数变量。
     + 例如：declare -i my_integer=42
     + 这样的声明告诉 Shell 将 my_integer 视为整数，如果尝试将非整数值赋给它，Shell会尝试将其转换为整数
   + 数组变量：数组可以是整数索引数组或关联数组
     + `my_array=(1 2 3 4 5)    #整数索引数组`
     + 
        ```
        declare -A associative_array
        associative_array["name"]="John"
        associative_array["age"]=30     #关联数组
        ```
6. **环境变量**
   + 这些是由操作系统或用户设置的特殊变量，用于配置 Shell 的行为和影响其执行环境。
7. **特殊变量**
   + 一些特殊变量在 Shell 中具有特殊含义
   + `$0`：表示脚本的名称
   + `$1, $2`：表示脚本的参数
   + `$#`：表示传递给脚本的参数数量
   + `$?`：表示上一个命令的退出状态等


# 三、Shell 字符串
1. **单引号**：单引号里的任何字符都会原样输出，单引号字符串中的变量是无效的
2. **双引号**
   + 双引号里可以有变量
   + 双引号里可以出现转义字符
   + 实例：
      ```
      your_name="runoob"
      str="Hello, I know you are \"$your_name\"! \n"
      echo -e $str

      输出结果:Hello, I know you are "runoob"! 
      ```
3. **拼接字符串**
   + 使用双引号拼接
      ```
      your_name="runoob"
      greeting="hello, "$your_name" !"
      greeting_1="hello, ${your_name} !"
      echo $greeting  $greeting_1

      输出结果:hello, runoob ! hello, runoob !
      ```
   + 使用单引号拼接
      ```
      greeting_2='hello, '$your_name' !'
      greeting_3='hello, ${your_name} !'
      echo $greeting_2  $greeting_3

      输出结果:hello, runoob ! hello, ${your_name} !
      ```
4. **获取字符串长度**
   + 使用`#`进行获取
   



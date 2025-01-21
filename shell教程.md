# 一、#!和运行  
************************
1. **`#!`的作用**：`#!` 是一个约定的标记，它告诉系统这个脚本需要什么解释器来执行，即使用哪一种 Shell。
   + `#!/bin/bash`
2. **运行**
   + `./test.sh`
   + `/bin/sh test.sh` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;//这种运行方式不需要再开头使用`#!/bin/bash`

# 二、变量
************************
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
************************
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
      ```
      string="abcd"
      echo ${#string}   # 输出 4
      echo ${#string[0]}   # 输出 4
      ```
5. **提取子字符串**
   + 实例：
      ```
      string="runoob is a great site"
      echo ${string:1:4} # 输出 unoo
      ```
   + 注意：第一个字符的索引值为 0。
6. **查找子字符串**
   + 实例：
      ```
      string="runoob is a great site"
      echo `expr index "$string" io`  #查找字符 i 或 o 的位置, 输出 4
      #注意：以上脚本中 ` 是反引号，而不是单引号 '
      ```

# 四、Shell 数组
************************
1. **定义数组**
   + 形式：数组名=(值1 值2 ... 值n)
   + 实例：
      ```
      array_name=(value0 value1 value2 value3)
      array_name=(
         value0
         value1
         value2
         value3
      )
      ```
2. **读取数组**
   + 形式：`${数组名[下标]}`
   + 实例：
      ```
      valuen=${array_name[n]}
      echo ${array_name[@]}   #使用 @ 符号可以获取数组中的所有元素
      ```
3. **获取数组的长度**
   + 实例：
      ```
      # 取得数组元素的个数
      length=${#array_name[@]}
      length=${#array_name[*]}
      # 取得数组单个元素的长度
      length=${#array_name[n]}
      ```
4. **关联数组**
   + Bash 支持关联数组，可以使用任意的字符串、或者整数作为下标来访问数组元素
   + 声明关联数组：`declare -A array_name`
   + 实例：
      ```
      declare -A site
      site["google"]="www.google.com"
      site["runoob"]="www.runoob.com"
      site["taobao"]="www.taobao.com"

      #在数组前加一个感叹号 ! 可以获取数组的所有键
      echo "数组的键为: ${!site[*]}"
      echo "数组的键为: ${!site[@]}"
      ```


# 五、Shell 传递参数
1. **获取参数**
   + 格式：`$n`
   + `$1`:表示第一个参数; `$2`:表示第二个参数
   + 用来处理参数的特殊字符
     + `$#`: 传递到脚本的参数个数
     + `$*`: 以一个单字符串显示所有向脚本传递的参数。
     + `$$`: 脚本运行的当前进程ID号
     + `$!`: 后台运行的最后一个进程的ID号
     + `$@`: 与$*相同，但是使用时加引号，并在引号中返回每个参数
     + `$-`: 显示Shell使用的当前选项，与set命令(set命令用于设置shell)功能相同。
     + `$?`: 显示最后命令的退出状态。0表示没有错误，其他任何值表明有错误  
  
   + $* 与 $@ 区别
     + 相同点：都是引用所有参数
     + 不同点：只有在双引号中体现出来。假设在脚本运行时写了三个参数 1、2、3，则 " * " 等价于 "1 2 3"（传递了一个参数），而 "@" 等价于 "1" "2" "3"（传递了三个参数）。


# 六、Shell 基本运算符
****
1. `expr`
   + 一款表达式计算工具，使用它能完成表达式的求值操作
   + 表达式和运算符之间要有空格
   + 完整的表达式要被 \` \` 包含，注意这个字符不是常用的单引号，在 Esc 键下边
2. 算术运算符
   + 乘号(*)前边必须加反斜杠(\)才能实现乘法运算：
      ```
      val=`expr $a \* $b`
      ```


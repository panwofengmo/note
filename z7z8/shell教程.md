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
2. **算术运算符**
   + 乘号(*)前边必须加反斜杠`(\)`才能实现乘法运算：
      ```
      val=`expr $a \* $b`
      ```
3. **关系运算符**
   + 关系运算符只支持数字，不支持字符串，除非字符串的值是数字
   + `-eq`: 是否相等; `[ $a -eq $b ]`
   + `-ne`: 是否不相等; `[ $a -ne $b ] `
   + `-gt`: 是否大于; `[ $a -gt $b ]`
   + `-lt`: 是否小于; `[ $a -lt $b ] `
   + `-ge`: 是否大于等于; `[ $a -ge $b ]`
   + `-le`: 是否小于等于; `[ $a -le $b ] `
4. **布尔运算符**
   + `!`：非运算；[ ! false ] 返回 true。
   + `-o`：或运算，有一个表达式为 true 则返回 true
   + `-a`：与运算，两个表达式都为 true 才返回 true
5. **字符串运算符**
   + `=`：相等；`[ $a = $b ]`
   + `!=`：不相等时为true；`[ $a != $b ]`
   + `-z`：检测字符串长度是否为0，为0返回 true；`[ -z $a ]`
6. 文件测试运算符
7. **自增和自减操作符**
   + 使用 let 命令
      ```
      let num++         # 自增
      let num--         # 自减
      ```
   + 使用 `$(( ))` 进行算术运算
      + `$(( ))` 语法也是进行算术运算的一种方式。
      ```
      num=$((num + 1))  # 自增
      num=$((num - 1))  # 自减
      ```
   + 使用 expr 命令
     + expr 命令可以用于算术运算，但在现代脚本中不如 let 和 $(( )) 常用。
      ```
      num=$(expr $num + 1)
      ```
   + 使用 (( )) 进行算术运算
      ```
      ((num++))   # 自增
      ((num--))   # 自减
      ```

# 七、Shell echo命令
1. 显示变量
   ```
   #!/bin/sh
   read name 
   echo "$name It is a test"

   #可以在标准输入将变量输入
   ```
2. 显示命令
   + 注意： 这里使用的是反引号 `, 而不是单引号 '
   + 能执行反引号内的命令
   ```
   echo `date`
   #输出结果：Thu Jul 24 10:08:46 CST 2014
   echo `ls`
   ```

# 八、Shell printf 命令
1. 实例：
   ```
   printf "Hello, Shell\n"   
   #输出结果：Hello, Shell

   printf "%s\n" abc def
   #输出结果：
   abc
   def
   ```

# 九、Shell test 命令
1. test 命令用于检查某个条件是否成立
   ```
   num1=100
   num2=100
   if test $[num1] -eq $[num2]
   then
      echo '两个数相等！'
   else
      echo '两个数不相等！'
   fi

   #输出结果：两个数相等！

   cd /bin
   if test -e ./bash
   then
      echo '文件已存在!'
   else
      echo '文件不存在!'
   fi
   ```

# 十、Shell 流程控制
1. `if else-if else`
   + 语法格式
      ```
      if condition1
      then
         command1
      elif condition2 
      then 
         command2
      else
         commandN
      fi

      ```
2. **条件判断的几种方式**
   + `[ $a -gt $b ]`
   + `(( $a > $b ))`
   + `test $a -gt $b`

3. **for 循环**
   + 格式
      ```
      for var in item1 item2 ... itemN
      do
         command1
         command2
         ...
         commandN
      done

      ```
   + 实例：
      ```
      for loop in 1 2 3 4 5
      do
         echo "The value is: $loop"
      done
      ```
4. **while 语句**
   + 格式：
      ```
      while condition
      do
         command
      done
      ```
   + 实例
      ```
      #!/bin/bash
      int=1
      while(( $int<=5 ))
      do
         echo $int
         let "int++"
      done
      ```

# 十一、Shell 函数
1. 函数不需要带参数，即函数格式：func(){ ... }
2. 函数返回值
   + return 返回，如果不加，将以最后一条命令运行结果
   + return 语句只能返回一个介于 0 到 255 之间的整数，而两个输入数字的和可能超过这个范围
   + 函数返回值在调用该函数后通过 $? 来获得
     + 实例：
         ```
         funWithReturn(){
            return 10
         }
         funWithReturn
         echo "返回值：$? "   #返回值为10
         ```
3. 函数参数
   + 通过`$n`的形式来获取参数的值，例如，`$1`表示第一个参数，`$2`表示第二个参数
   + `$10` 不能获取第十个参数，获取第十个参数需要`${10}`。当n>=10时，需要使用`${n}`来获取参数

# 十二、Shell 输入/输出重定向
1. **文件描述符**
   + stdin的文件描述符为0
   + stdout 的文件描述符为1
   + stderr的文件描述符为2
2. `/dev/null`
   + /dev/null 是一个特殊的文件，写入到它的内容都会被丢弃
   + 将命令的输出重定向到它，会起到"禁止输出"的效果
3. `$ command > /dev/null 2>&1
`
   + 屏蔽 stdout 和 stderr

# 十三、Shell 文件包含
1. 格式：
   + `. filename`
   + `source filename`
   + 实例：
      ```
      #!/bin/bash
      url="http://www.runoob.com"
      #以上代码为文件test1.sh的内容

      #!/bin/bash
      #使用 . 号来引用test1.sh 文件
      . ./test1.sh
      echo "菜鸟教程官网地址：$url"
      #以上代码为文件test2.sh的内容

      $ chmod +x test2.sh
      $ ./test2.sh 
      菜鸟教程官网地址：http://www.runoob.com
      ```




service_manager.sh文件使用的是Shell脚本语言（Bash Shell），这是一种专为Linux/Unix系统设计的脚本编程语言。

Shell脚本语言特点
解释型语言‌：无需编译，直接由Shell解释器执行
命令组合‌：本质是Linux命令的批处理组合
自动化工具‌：主要用于系统管理、服务部署等运维场景
跨平台性‌：在类Unix系统中通用
学习方法建议
基础阶段

掌握Linux基础命令‌：

文件操作（ls/cp/mv等）
文本处理（grep/awk/sed三剑客）
权限管理（chmod/chown）

语法核心要素‌：

bash
Copy Code
#!/bin/bash  # 解释器声明
variables=value  # 变量定义
if [ condition ]; then  # 条件判断
  commands
fi

变量定义与引用
条件判断（if/case语句）
循环结构（for/while）
进阶提升

实战项目训练‌：

日志分析脚本
服务监控脚本
自动化部署脚本

调试技巧‌：

使用set -x开启调试模式
通过echo $?检查上条命令返回值

安全规范‌：

总是检查命令返回值
对用户输入进行验证
推荐学习路径
先掌握单个命令用法
练习将多个命令组合成脚本
学习添加条件判断和错误处理
最终实现复杂自动化任务

Shell脚本特别适合系统管理员和DevOps工程师实现日常工作的自动化，其学习曲线相对平缓但实用性极强。
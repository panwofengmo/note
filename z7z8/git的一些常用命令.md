https://linux.cn/article-8841-1.html

1. 安装git
	+ sudo apt update && sudo apt install git -y

2. 配置全局账户
	+ git config --global user.name "YourName"
	+ git config --global user.email "your_email@example.com"

3. SSH密钥配置
	+ 生成SSH密钥,默认保存在~/.ssh目录
		+ ssh-keygen -t rsa -C "your_email@example.com"
	+ 添加公钥到GitHub
		+ cat ~/.ssh/id_rsa.pub
		+ 登录GitHub，进入‌Settings → SSH and GPG Keys‌，添加新SSH Key并将公钥粘贴到对应字段
	+ ‌测试SSH连接
		+ ssh -T git@github.com		--一点都不需要改

4. ‌克隆远程仓库
	+ git clone git@github.com:username/repository.git

5. 代码提交与推送
	+ git add .                # 添加所有文件到暂存区
	+ git commit -m "提交说明"  # 提交更改
	+ git push origin main     # 推送到远程分支
	+ 首次推送需关联远程仓库：git remote add origin 仓库URL

6. ‌分支管理
	+ git checkout -b new-feature  # 创建并切换到新分支
	+ git merge main               # 合并分支到主分支








1 remote
	git remote -v：该命令将列出远程仓库的 URL
	git remote add origin <URL>：这里使用 GitHub 提供的 URL 替换 <URL>。这样，你就可以添加、提交和推送更改到你的远程仓库了
	git remote set-url origin <url>：如果你从其他人那里复制了一个仓库，并希望将远程仓库从原始所有者更改为你自己的 GitHub 帐户

2 clone
	git clone <url>：复制仓库

3 分支
	git branch：列出了本地机器上的所有分支
	git branch <name>：创建一个新的分支
	git checkout <name>：可以切换到现有的分支
	git checkout -b <name>：创建一个新的分支并立即切换到它
	git merge <branch>：合并分支。如果你对一个分支进行了一系列的更改，假如说此分支名为 develop，如果想要将该分支合并回主分支（master）上，则使用 git merge <branch> 命令。你需要先检出（checkout）主分支，然后运行 git merge develop 将 develop 合并到主分支中。
	git pull origin <branch>：从远程分支中拉取最新的更改。

4 状态
	git status：看到哪些文件已被更改以及哪些内存正在被跟踪
	git diff --stat：查看每个文件中更改的行

5 日志
	git log：可以输出提交的历史记录

6 强制推送
	git push -f origin master：强制推送是危险的，只有在绝对必要的时候才能执行它。它将覆盖你的应用程序的历史记录，你将失去之后版本的任何信息。
	
# 终端命令提示符显示
export PS1='\[\e[31;1m\]\u\[\e[0m\]\[\e[32;1m\]\[\e[0m\]:\[\e[35;1m\]\w\[\e[0m\]\$ '
export PS1="$PS1\[\e]1337;CurrentDir="'$(pwd)\a\]'    # 报告 CWD 给远程终端
export LANG=zh_CN.UTF-8   # 终端显示中文
export LC_ALL=zh_CN.UTF-8

# 基础类
alias ll='ls -alh'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias vi='vim'
alias sys='systemctl'
alias vbr='vi ~/.bashrc'
alias sbr='source ~/.bashrc'
alias svenv='source ./venv/bin/activate'
alias killpid='kill -9 $(cat pid.txt)'

# AutoDL 服务器
[ -d "/root/autodl-tmp/" ] && cd /root/autodl-tmp/   # 默认进入数据盘

# 应用类
alias py='python'
alias tmls='tmux -u ls'
alias tmnew='tmux -u new -s'
alias tmin='tmux -u attach -t'
alias tmkill='tmux -u kill-session -t'
alias qzgx='git fetch origin main && git reset --hard origin/main'  # Git仓库强制更新到本地

# 网络类
alias curltime="curl -w \"@$HOME/.curl-format\" -o /dev/null -s "
alias curla="curl -o /dev/null -s -w \"HTTP状态码: %{http_code}\nDNS解析时间: %{time_namelookup}秒\n请求地址: %{url_effective}\n总耗时: %{time_total}秒\n\n\" "
alias curlt="curla baidu.com && curla google.com"

# 代理类
proxy_on(){
#     echo -n "请输入本地代理端口号（回车可设置默认端口7890）: "
#     read port
    port="$1"
    if [ ! $port ]; then port=7890; fi    # 默认端口号：7890
    export proxy="http://127.0.0.1:"$port""
    export http_proxy=$proxy
    export https_proxy=$proxy
    export ftp_proxy=$proxy
    export no_proxy="localhost, 127.0.0.1, ::1"
    # # 设置所有代理，curl支持socks5h协议，但是wget不支持，前者请求外网需要代理端解析DNS
    # export ALL_PROXY="socks5h://127.0.0.1:7890"
    # echo "已开启代理，代理地址为："$proxy""
}
# 关闭代理
proxy_off(){
    unset ALL_PROXY
    unset http_proxy
    unset https_proxy
    unset ftp_proxy
    unset no_proxy
    echo "已关闭代理，原代理地址为："$proxy""
}

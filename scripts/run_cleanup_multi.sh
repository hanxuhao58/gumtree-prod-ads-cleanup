#!/bin/bash

###############################################################################
# Gumtree 广告批量删除脚本 - 多账号版本
# 
# 功能: 批量处理多个账号，逐个登录 → 提取广告ID → 批量删除
# 环境: prod 正式环境
# 作者: Donny Han
# 日期: 2025-11-02
###############################################################################

set -e  # 遇到错误立即退出

# 脚本目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

###############################################################################
# 函数定义（必须在脚本开头定义，以便后续使用）
###############################################################################

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_account() {
    echo -e "${MAGENTA}👤 $1${NC}"
}

# 配置文件与目录
# 默认环境为 prod，可通过 --env bixi 切换测试
ENV_NAME="prod"
# 可选：指定要运行的账号（邮箱或用户名），为空则运行所有启用的账号
SELECTED_ACCOUNT=""

# 解析参数
while [[ $# -gt 0 ]]; do
    case "$1" in
        -e|--env)
            ENV_NAME="$2"; shift 2 ;;
        --env=*)
            ENV_NAME="${1#*=}"; shift ;;
        -a|--account)
            SELECTED_ACCOUNT="$2"; shift 2 ;;
        --account=*)
            SELECTED_ACCOUNT="${1#*=}"; shift ;;
        -h|--help)
            echo "用法: bash run_cleanup_multi.sh [--env prod|bixi] [--account EMAIL]"
            echo ""
            echo "选项:"
            echo "  --env, -e        运行环境 (prod|bixi)，默认: prod"
            echo "  --account, -a    指定要运行的账号邮箱，为空则运行所有启用的账号"
            echo "  --help, -h       显示此帮助信息"
            echo ""
            echo "示例:"
            echo "  bash run_cleanup_multi.sh                    # 运行所有账号"
            echo "  bash run_cleanup_multi.sh --account donny.han@gumtree.com  # 只运行指定账号"
            exit 0 ;;
        *)
            shift ;;
    esac
done

if [ "$ENV_NAME" = "bixi" ]; then
    CONFIG_FILE="${PROJECT_ROOT}/config/bixi.env.properties"
else
    CONFIG_FILE="${PROJECT_ROOT}/config/prod.env.properties"
fi

ACCOUNTS_FILE="${PROJECT_ROOT}/data/accounts.csv"
TEST_PLAN="${PROJECT_ROOT}/testcases/ad_cleanup_multi_accounts_v2.jmx"
DATA_DIR="${PROJECT_ROOT}/data"
REPORTS_DIR="${PROJECT_ROOT}/reports"
LOGS_DIR="${PROJECT_ROOT}/logs"

# 时间戳
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${LOGS_DIR}/multi_cleanup_${TIMESTAMP}.log"
REPORT_FILE="${REPORTS_DIR}/multi_cleanup_${TIMESTAMP}.html"

# 如果指定了账号，备份原文件并创建过滤后的账号文件
ORIGINAL_ACCOUNTS_FILE="${ACCOUNTS_FILE}"
ACCOUNTS_BACKUP=""
if [ -n "$SELECTED_ACCOUNT" ]; then
    # 备份原文件
    ACCOUNTS_BACKUP="${DATA_DIR}/accounts_backup_${TIMESTAMP}.csv"
    cp "$ORIGINAL_ACCOUNTS_FILE" "$ACCOUNTS_BACKUP"
    
    # 创建过滤后的文件（直接替换原文件，因为JMeter硬编码了路径）
    TEMP_FILTERED="${DATA_DIR}/accounts_filtered_${TIMESTAMP}.csv"
    head -n 1 "$ORIGINAL_ACCOUNTS_FILE" > "$TEMP_FILTERED"
    # 查找匹配的账号（支持邮箱或用户名匹配）
    grep -i "$SELECTED_ACCOUNT" "$ORIGINAL_ACCOUNTS_FILE" | grep -iE ",(TRUE|true)$" >> "$TEMP_FILTERED" || true
    
    # 检查是否找到账号
    if [ $(wc -l < "$TEMP_FILTERED") -le 1 ]; then
        print_error "未找到匹配的账号: $SELECTED_ACCOUNT"
        print_info "请检查账号邮箱是否正确，且账号状态为 enabled=TRUE"
        # 恢复原文件
        mv "$ACCOUNTS_BACKUP" "$ORIGINAL_ACCOUNTS_FILE"
        rm -f "$TEMP_FILTERED"
        exit 1
    fi
    
    # 替换原文件（JMeter会读取这个路径）
    mv "$TEMP_FILTERED" "$ORIGINAL_ACCOUNTS_FILE"
    print_info "已选择单独账号运行模式: $SELECTED_ACCOUNT"
    print_info "已备份原账号文件到: $ACCOUNTS_BACKUP"
fi

###############################################################################
# 功能函数
###############################################################################

# 检查JMeter是否安装
check_jmeter() {
    print_header "检查环境"
    
    if ! command -v jmeter &> /dev/null; then
        print_error "JMeter 未安装或不在 PATH 中"
        print_info "请安装 JMeter 5.6+ 并添加到 PATH"
        print_info "下载地址: https://jmeter.apache.org/download_jmeter.cgi"
        exit 1
    fi
    
    JMETER_VERSION=$(jmeter --version 2>&1 | head -n 1)
    print_success "JMeter 已安装: ${JMETER_VERSION}"
}

# 检查必需文件
check_files() {
    print_header "检查必需文件"
    
    if [ ! -f "$CONFIG_FILE" ]; then
        print_error "配置文件不存在: $CONFIG_FILE"
        exit 1
    fi
    print_success "配置文件: $CONFIG_FILE"
    
    if [ ! -f "$ACCOUNTS_FILE" ]; then
        print_error "账号文件不存在: $ACCOUNTS_FILE"
        print_info "请创建 config/accounts.csv 文件"
        exit 1
    fi
    print_success "账号文件: $ACCOUNTS_FILE"
    
    if [ ! -f "$TEST_PLAN" ]; then
        print_error "测试计划不存在: $TEST_PLAN"
        exit 1
    fi
    print_success "测试计划: $TEST_PLAN"
}

# 创建必需目录
create_directories() {
    mkdir -p "$DATA_DIR"
    mkdir -p "$REPORTS_DIR"
    mkdir -p "$LOGS_DIR"
    print_success "工作目录已准备"
}

# 统计账号数量
count_accounts() {
    print_header "账号列表"
    
    # 跳过表头，只统计enabled=TRUE的账号
    TOTAL_ACCOUNTS=$(tail -n +2 "$ACCOUNTS_FILE" | grep -iE ",(TRUE|true)$" | wc -l | tr -d ' ')
    
    if [ "$TOTAL_ACCOUNTS" -eq 0 ]; then
        print_error "没有启用的账号"
        print_info "请在 $ACCOUNTS_FILE 中设置 enabled=TRUE"
        print_info "当前文件内容:"
        cat "$ACCOUNTS_FILE"
        exit 1
    fi
    
    echo -e "${CYAN}找到 ${TOTAL_ACCOUNTS} 个启用的账号:${NC}"
    echo ""
    
    # 显示账号列表
    tail -n +2 "$ACCOUNTS_FILE" | grep -iE ",(TRUE|true)$" | while IFS=',' read -r username password user_id account_id team_member notes enabled; do
        print_account "${team_member} <${username}> - ${notes}"
    done
    
    echo ""
}

# 显示配置信息
show_config() {
    print_header "目标环境"
    
    HOST_BFF=$(grep "^HOST_BFF=" "$CONFIG_FILE" | cut -d'=' -f2)
    echo "环境: $ENV_NAME"
    echo "主机: $HOST_BFF"
    echo "测试计划: 多账号批量清理"
    echo "处理账号: ${TOTAL_ACCOUNTS} 个"
    echo ""
}

# 确认执行
confirm_execution() {
    print_warning "⚠️  即将对 ${TOTAL_ACCOUNTS} 个账号执行批量删除！"
    print_warning "此操作不可撤销！"
    if [ "$ENV_NAME" = "prod" ]; then
        print_warning "⚠️  当前为【生产环境】将对线上数据生效 (${HOST_BFF})"
    fi
    echo ""
    read -p "确认继续执行？(yes/no): " -r
    echo
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        print_info "操作已取消"
        exit 0
    fi
}

# 运行JMeter测试
run_jmeter() {
    print_header "开始执行批量清理"
    
    print_info "JMeter 运行中..."
    print_info "日志文件: $LOG_FILE"
    echo ""
    
    # 运行JMeter（非GUI模式）
    # 设置JMeter系统属性：连接超时30秒，响应超时60秒
    jmeter -n \
        -Jsun.net.client.defaultConnectTimeout=30000 \
        -Jsun.net.client.defaultReadTimeout=60000 \
        -t "$TEST_PLAN" \
        -q "$CONFIG_FILE" \
        -l "${REPORTS_DIR}/multi_cleanup_${TIMESTAMP}.jtl" \
        -j "$LOG_FILE" \
        -e -o "${REPORTS_DIR}/multi_cleanup_${TIMESTAMP}_html" \
        2>&1 | tee -a "$LOG_FILE"
    
    JMETER_EXIT_CODE=$?
    
    echo ""
    if [ $JMETER_EXIT_CODE -eq 0 ]; then
        print_success "JMeter 执行完成"
    else
        print_error "JMeter 执行失败，退出码: $JMETER_EXIT_CODE"
        return $JMETER_EXIT_CODE
    fi
}

# 显示结果摘要
show_summary() {
    print_header "执行结果摘要"
    
    echo -e "${CYAN}📊 处理统计${NC}"
    echo ""
    
    # 解析日志文件，提取每个账号的统计
    if [ -f "$LOG_FILE" ]; then
        echo "逐账号结果:"
        echo ""
        
        # 提取账号处理信息
        grep -E "开始处理账号|账号.*处理完成|发现活跃广告|成功删除" "$LOG_FILE" | while read -r line; do
            if [[ $line =~ "开始处理账号" ]]; then
                echo -e "${MAGENTA}${line}${NC}"
            elif [[ $line =~ "处理完成" ]]; then
                echo -e "${GREEN}${line}${NC}"
            else
                echo "$line"
            fi
        done
        
        echo ""
        echo -e "${CYAN}📈 总体统计${NC}"
        
        # 统计总数
        TOTAL_ADS=$(grep -o "发现活跃广告: [0-9]\+" "$LOG_FILE" | awk '{sum += $NF} END {print sum}')
        TOTAL_DELETED=$(grep -o "成功删除: [0-9]\+" "$LOG_FILE" | awk '{sum += $NF} END {print sum}')
        
        echo "  总共发现: ${TOTAL_ADS:-0} 个活跃广告"
        echo "  成功删除: ${TOTAL_DELETED:-0} 个广告"
        
    fi
    
    echo ""
    print_info "详细日志: $LOG_FILE"
    
    if [ -d "${REPORTS_DIR}/multi_cleanup_${TIMESTAMP}_html" ]; then
        print_info "HTML报告: ${REPORTS_DIR}/multi_cleanup_${TIMESTAMP}_html/index.html"
        print_info "在浏览器中打开查看详细报告:"
        echo "  open ${REPORTS_DIR}/multi_cleanup_${TIMESTAMP}_html/index.html"
    fi
}

# 清理临时文件
cleanup_temp_files() {
    print_info "清理7天前的旧文件..."
    find "$LOGS_DIR" -name "*.log" -mtime +7 -delete 2>/dev/null || true
    find "$REPORTS_DIR" -name "*.jtl" -mtime +7 -delete 2>/dev/null || true
    
    # 恢复原账号文件（如果使用了备份）
    if [ -n "$ACCOUNTS_BACKUP" ] && [ -f "$ACCOUNTS_BACKUP" ]; then
        mv "$ACCOUNTS_BACKUP" "$ORIGINAL_ACCOUNTS_FILE"
        print_info "已恢复原账号文件"
    fi
}

###############################################################################
# 主流程
###############################################################################

main() {
    # 设置错误处理：确保退出时恢复原文件
    trap 'if [ -n "$ACCOUNTS_BACKUP" ] && [ -f "$ACCOUNTS_BACKUP" ]; then mv "$ACCOUNTS_BACKUP" "$ORIGINAL_ACCOUNTS_FILE" 2>/dev/null || true; fi' EXIT
    
    print_header "Gumtree 广告批量删除工具 - 多账号版"
    
    # 检查环境
    check_jmeter
    check_files
    create_directories
    
    # 统计账号
    count_accounts
    
    # 显示配置
    show_config
    
    # 确认执行
    confirm_execution
    
    # 运行测试
    if run_jmeter; then
        show_summary
        print_success "多账号批量清理已完成！"
        cleanup_temp_files
        exit 0
    else
        print_error "批量清理执行失败，请检查日志: $LOG_FILE"
        cleanup_temp_files
        exit 1
    fi
}

# 执行主函数
main "$@"


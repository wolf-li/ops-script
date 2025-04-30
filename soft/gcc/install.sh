#!/bin/bash

# 脚本名称: build_gcc.sh
# 描述: 构建 GCC，支持 macOS 和其他 Unix-like 系统
# 作者: [您的名字]
# 日期: 2023-10-20

# 全局变量
GCC_VERSION="14.2.0"
GMP_VERSION="6.2.1"
MPFR_VERSION="4.1.0"
MPC_VERSION="1.2.1"
ISL_VERSION="0.24"
INSTALL_DIR="/opt/gcc-${GCC_VERSION}"
BUILD_DIR="build-gcc"
SRC_DIR="gcc-${GCC_VERSION}"

# 颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 函数: 打印信息
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# 函数: 打印警告
warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 函数: 打印错误并退出
error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# 函数: 检查命令是否存在
check_command() {
    command -v "$1" >/dev/null 2>&1 || error "$1 未安装，请先安装。"
}

# 函数: 获取 CPU 核心数
get_cpu_cores() {
    if [[ "$(uname)" == "Darwin" ]]; then
        sysctl -n hw.ncpu
    elif [[ "$(uname)" == "Linux" ]]; then
        nproc
    else
        echo "4" # 默认值
        warning "无法检测 CPU 核心数，使用默认值 4。"
    fi
}

# 函数: 下载文件
download_file() {
    local url=$1
    local filename=$2
    local retries=3
    local count=0

    info "正在下载 $filename 从 $url..."
    while [ $count -lt $retries ]; do
        if curl -O "$url"; then
            return 0
        fi
        count=$((count + 1))
        warning "下载 $filename 失败，第 $count 次重试..."
        sleep 2
    done
    error "无法下载 $filename，已重试 $retries 次。"
}

# 函数: 解压文件
extract_file() {
    local filename=$1
    info "正在解压 $filename..."
    tar -xzf "$filename" || error "解压 $filename 失败。"
}

# 函数: 创建符号链接
create_symlink() {
    local src=$1
    local dst=$2
    info "创建符号链接 $dst -> $src..."
    ln -s "$src" "$dst" || error "创建符号链接 $dst 失败。"
}

# 主函数
main() {
    # 步骤 1: 环境检查
    info "步骤 1: 检查环境..."
    if [[ "$(uname)" == "Darwin" ]]; then
        info "检测到 macOS 系统。"
        check_command "xcode-select"
    else
        warning "非 macOS 系统，脚本可能需要调整以适配当前平台。"
    fi
    check_command "curl"
    check_command "tar"
    check_command "make"
    check_command "gcc" || warning "未检测到现有 GCC，可能需要手动安装基础编译器。"

    # 检查磁盘空间（至少 10GB 可用）
    local available_space=$(df -h . | tail -1 | awk '{print $4}' | sed 's/G//')
    if [[ $(echo "$available_space < 10" | bc -l) -eq 1 ]]; then
        error "可用磁盘空间不足 10GB，请释放空间后重试。"
    fi

    # 步骤 2: 下载源代码
    info "步骤 2: 下载源代码..."
    download_file "https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz" "gcc-${GCC_VERSION}.tar.gz"
    download_file "https://ftp.gnu.org/gnu/gmp/gmp-${GMP_VERSION}.tar.gz" "gmp-${GMP_VERSION}.tar.gz"
    download_file "https://www.mpfr.org/mpfr-${MPFR_VERSION}/mpfr-${MPFR_VERSION}.tar.gz" "mpfr-${MPFR_VERSION}.tar.gz"
    download_file "http://www.multiprecision.org/downloads/mpc-${MPC_VERSION}.tar.gz" "mpc-${MPC_VERSION}.tar.gz"
    download_file "http://isl.gforge.inria.fr/isl-${ISL_VERSION}.tar.gz" "isl-${ISL_VERSION}.tar.gz"

    # 步骤 3: 准备源代码
    info "步骤 3: 准备源代码..."
    extract_file "gcc-${GCC_VERSION}.tar.gz"
    extract_file "gmp-${GMP_VERSION}.tar.gz"
    extract_file "mpfr-${MPFR_VERSION}.tar.gz"
    extract_file "mpc-${MPC_VERSION}.tar.gz"
    extract_file "isl-${ISL_VERSION}.tar.gz"

    cd "${SRC_DIR}" || error "无法进入 ${SRC_DIR} 目录。"
    create_symlink "../gmp-${GMP_VERSION}" "gmp"
    create_symlink "../mpfr-${MPFR_VERSION}" "mpfr"
    create_symlink "../mpc-${MPC_VERSION}" "mpc"
    create_symlink "../isl-${ISL_VERSION}" "isl"
    cd ..

    # 步骤 4: 配置构建
    info "步骤 4: 配置构建..."
    mkdir -p "${BUILD_DIR}"
    cd "${BUILD_DIR}" || error "无法进入 ${BUILD_DIR} 目录。"
    ../"${SRC_DIR}"/configure --prefix="${INSTALL_DIR}" \
        --enable-languages=c,c++ \
        --disable-multilib || error "配置失败，请检查 config.log 获取详细信息。"

    # 步骤 5: 构建 GCC
    info "步骤 5: 构建 GCC..."
    local cores=$(get_cpu_cores)
    info "使用 $cores 个核心进行并行编译..."
    make -j"$cores" || error "构建失败，请检查上方错误信息。"

    # 步骤 6: 安装 GCC
    info "步骤 6: 安装 GCC..."
    if [[ ! -d "${INSTALL_DIR}" ]]; then
        sudo mkdir -p "${INSTALL_DIR}" || error "创建安装目录失败，可能需要提升权限。"
        sudo chown "$(whoami)" "${INSTALL_DIR}" || warning "更改安装目录权限失败，可能影响安装。"
    fi
    make install || error "安装失败，请检查权限或磁盘空间。"

    # 步骤 7: 测试安装
    info "步骤 7: 测试安装..."
    export PATH="${INSTALL_DIR}/bin:$PATH"
    if ! command -v gcc >/dev/null 2>&1; then
        error "GCC 未在 PATH 中找到，安装可能失败。"
    fi
    gcc --version || error "无法验证 GCC 版本。"
    info "GCC 版本: $(gcc --version | head -1)"

    # 更新 shell 配置文件
    local shell_config="$HOME/.bashrc"
    if [[ "$(uname)" == "Darwin" && -f "$HOME/.zshrc" ]]; then
        shell_config="$HOME/.zshrc"
    fi
    echo "export PATH=\"${INSTALL_DIR}/bin:\$PATH\"" >> "$shell_config"
    source "$shell_config" || warning "刷新 shell 配置失败，请手动执行 'source $shell_config'。"

    # 编译并运行测试程序
    echo '#include <stdio.h>
int main() {
    printf("Hello, World!\\n");
    return 0;
}' > hello.c
    gcc hello.c -o hello || error "无法编译测试程序。"
    ./hello || error "无法运行测试程序。"
    info "测试程序运行成功！"

    # 步骤 8: 清理（可选）
    info "步骤 8: 清理（可选）..."
    read -p "是否清理构建和源代码目录？(y/n): " cleanup
    if [[ "$cleanup" == "y" || "$cleanup" == "Y" ]]; then
        cd ..
        rm -rf "${BUILD_DIR}" "${SRC_DIR}" *.tar.gz
        info "已清理构建和源代码目录。"
    fi

    info "GCC ${GCC_VERSION} 已成功构建并安装至 ${INSTALL_DIR}。"
}

# 执行主函数
main

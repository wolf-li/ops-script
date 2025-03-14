# 端口扫描脚本（支持多个 IP 和端口）
# 作者：Gemini
# 日期：2024-05-07

# 定义参数
param(
  # 目标地址列表，以分号分隔
  [Parameter(Mandatory=$true)]
  [string]$Targets,

  # 端口范围，以逗号分隔
  [Parameter(Mandatory=$true)]
  [string]$Ports,

  # 超时时间（秒）
  [Parameter(Mandatory=$false)]
  [int]$Timeout = 10
)

# 将目标地址列表转换为数组
$TargetsArray = $Targets.Split(';')

# 将端口字符串转换为数组
$PortsArray = $Ports.Split(',')

# 扫描每个目标地址的每个端口
foreach ($Target in $TargetsArray) {
  Write-Output "正在扫描目标地址：$Target"

  foreach ($Port in $PortsArray) {
    # 测试连接
    $TestConnectionResult = Test-NetConnection -ComputerName $Target -Port $Port -Verbose 

    # 检查连接状态
    if ($TestConnectionResult.TcpTestSucceeded) {
      Write-Output "  端口 $Port 已打开"
    } else {
      Write-Output "  端口 $Port 未打开"
    }
  }
}

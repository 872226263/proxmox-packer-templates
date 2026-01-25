# Packer Templates for Proxmox

Packer 自动化构建 Proxmox VM 模板，支持 GPU 直通，适用于 GPU 服务器出租场景。

## 支持的模板

| 模板 | 类型 | 用户名 / 密码 |
|------|------|---------------|
| [Ubuntu 24.04 GPU](./ubuntu-24.04-gpu.pkrvars.hcl) | GPU 直通 | admin / 123456 |
| [Windows 11 GPU](./windows-11-gpu.pkrvars.hcl) | GPU 直通 | Administrator / 123456 |
| [Ubuntu 24.04](./ubuntu-24.04.pkrvars.hcl) | 标准 | Cloud-Init |
| [Ubuntu 22.04](./ubuntu-22.04.pkrvars.hcl) | 标准 | Cloud-Init |
| [Ubuntu 20.04](./ubuntu-20.04.pkrvars.hcl) | 标准 | Cloud-Init |
| [Debian 13](./debian-13.pkrvars.hcl) | 标准 | Cloud-Init |
| [Debian 12](./debian-12.pkrvars.hcl) | 标准 | Cloud-Init |
| [Debian 11](./debian-11.pkrvars.hcl) | 标准 | Cloud-Init |
| [AlmaLinux 10](./almalinux-10.pkrvars.hcl) | 标准 | Cloud-Init |
| [AlmaLinux 9](./almalinux-9.pkrvars.hcl) | 标准 | Cloud-Init |
| [Rocky 10](./rocky-10.pkrvars.hcl) | 标准 | Cloud-Init |
| [Rocky 9](./rocky-9.pkrvars.hcl) | 标准 | Cloud-Init |
| [Alpine 3.22](./alpine-3.22.pkrvars.hcl) | 标准 | Cloud-Init |
| [Windows Server 2025](./windows-server-2025.pkrvars.hcl) | 标准 | Administrator / packer |
| [Windows Server 2022](./windows-server-2022.pkrvars.hcl) | 标准 | Administrator / packer |
| [Windows 11](./windows-11.pkrvars.hcl) | 标准 | Administrator / packer |

## GPU 直通模板配置

| 参数 | Ubuntu GPU | Windows GPU |
|------|------------|-------------|
| 内存 | 42GB | 42GB |
| CPU | 16 核 | 16 核 |
| 系统盘 | 60GB | 60GB |
| GPU | RTX 5090 直通 | RTX 5090 直通 |
| VLAN | 100 | 100 |
| 远程访问 | SSH | RDP |
| Cloud-Init | 支持 | 支持 (cloudbase-init) |

---

## 完整使用教程

### 一、安装 Packer

```bash
# 安装依赖
apt update && apt install -y wget unzip git

# 下载 Packer
wget https://releases.hashicorp.com/packer/1.14.3/packer_1.14.3_linux_amd64.zip

# 解压并安装
unzip packer_1.14.3_linux_amd64.zip
mv packer /usr/local/bin/
chmod +x /usr/local/bin/packer

# 验证安装
packer version
```

---

### 二、配置 GPU 直通（仅 GPU 模板需要）

```bash
# 1. 启用 IOMMU (Intel CPU)
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*"/GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"/' /etc/default/grub
update-grub

# AMD CPU 使用:
# GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on iommu=pt"

# 2. 加载 VFIO 模块
cat >> /etc/modules << 'EOF'
vfio
vfio_iommu_type1
vfio_pci
EOF

# 3. 查看 GPU ID
lspci -nn | grep -i nvidia
# 输出示例: 01:00.0 VGA [10de:2b85] / 01:00.1 Audio [10de:22e8]

# 4. 绑定 GPU 到 VFIO (替换为你的 ID)
echo "options vfio-pci ids=10de:2b85,10de:22e8" > /etc/modprobe.d/vfio.conf
echo -e "blacklist nouveau\nblacklist nvidia" > /etc/modprobe.d/blacklist-nvidia.conf

# 5. 更新并重启
update-initramfs -u
reboot
```

**重启后验证：**
```bash
# 确认 IOMMU 启用
dmesg | grep -i iommu

# 确认 GPU 使用 vfio-pci 驱动
lspci -nnk -s 01:00 | grep -i driver
# 应显示: Kernel driver in use: vfio-pci
```

---

### 三、克隆项目

```bash
cd /root
git clone https://github.com/872226263/proxmox-packer-templates.git
cd proxmox-packer-templates
```

---

### 四、配置凭据

```bash
# 复制模板
cp credentials.pkrvars.hcl.example credentials.pkrvars.hcl

# 编辑凭据
nano credentials.pkrvars.hcl
```

修改内容：
```hcl
proxmox_host         = "127.0.0.1:8006"      # 本机使用 127.0.0.1
proxmox_user         = "root@pam"
proxmox_password     = "你的密码"
proxmox_insecure_tls = true
node                 = "pve"                  # 你的节点名称
```

---

### 五、初始化并构建

```bash
# 初始化 Packer 插件
packer init config.pkr.hcl

# 构建 Ubuntu GPU 模板
packer build -var-file="credentials.pkrvars.hcl" -var-file="ubuntu-24.04-gpu.pkrvars.hcl" .

# 构建 Windows GPU 模板
packer build -var-file="credentials.pkrvars.hcl" -var-file="windows-11-gpu.pkrvars.hcl" .
```

---

### 六、从模板创建 VM

#### 方法 1：Web UI

1. Proxmox Web UI → 找到模板 → 右键 → `Clone` → `Full Clone`
2. 进入新 VM → `Hardware` → `Cloud-Init`
3. 设置：
   - **User**: `admin` (Ubuntu) / `Administrator` (Windows)
   - **Password**: 租户密码
   - **IP Config**: `ip=192.168.2.201/24,gw=192.168.2.1`
   - **DNS**: `8.8.8.8`
4. 启动 VM

#### 方法 2：命令行

```bash
# 克隆模板 (模板 ID 9000，新 VM ID 100)
qm clone 9000 100 --name gpu-vm-01 --full

# 设置 Cloud-Init
qm set 100 --ciuser admin --cipassword "租户密码"
qm set 100 --ipconfig0 ip=192.168.2.201/24,gw=192.168.2.1
qm set 100 --nameserver 8.8.8.8

# 启动
qm start 100
```

---

### 七、连接 VM

**Ubuntu：**
```bash
ssh admin@192.168.2.201
```

**Windows：**
```
远程桌面: 192.168.2.201
用户: Administrator
密码: Cloud-Init 设置的密码
```

---

### 八、IP 分配规划

| VM 名称 | IP |
|---------|-----|
| gpu-vm-01 | 192.168.2.201 |
| gpu-vm-02 | 192.168.2.202 |
| gpu-vm-03 | 192.168.2.203 |
| gpu-vm-04 | 192.168.2.204 |
| gpu-vm-05 | 192.168.2.205 |

---

## 常用命令

```bash
# 验证配置
packer validate -var-file="credentials.pkrvars.hcl" -var-file="ubuntu-24.04-gpu.pkrvars.hcl" .

# 构建并保存日志
packer build -var-file="credentials.pkrvars.hcl" -var-file="ubuntu-24.04-gpu.pkrvars.hcl" . 2>&1 | tee build.log

# 列出所有模板
qm list | grep template

# 删除模板
qm destroy 9000 --purge

# 查看 VM 配置
qm config 100
```

---

## 目录结构

```
proxmox-packer-templates/
├── credentials.pkrvars.hcl.example  # 凭据模板
├── config.pkr.hcl                   # Packer 插件配置
├── generic.pkr.hcl                  # 通用构建逻辑
├── variables.pkr.hcl                # 变量定义
├── ubuntu-24.04-gpu.pkrvars.hcl     # Ubuntu GPU 模板
├── windows-11-gpu.pkrvars.hcl       # Windows GPU 模板
├── ubuntu-24.04.pkrvars.hcl         # Ubuntu 标准模板
├── debian-12.pkrvars.hcl            # Debian 标准模板
└── http/
    ├── ubuntu-gpu/                  # Ubuntu GPU 安装配置
    ├── windows-gpu-scripts/         # Windows GPU 配置脚本
    └── ...
```

---

## 自定义配置

### 修改 GPU PCI 地址

编辑 `ubuntu-24.04-gpu.pkrvars.hcl` 和 `windows-11-gpu.pkrvars.hcl`：

```hcl
pci_devices = [
  { host = "0000:01:00.0", pcie = true, rombar = true },  # GPU
  { host = "0000:01:00.1", pcie = true, rombar = true }   # Audio
]
```

### 修改 VLAN

```hcl
network_adapter_vlan = 100  # 改为你的 VLAN ID
```

### 修改硬件配置

```hcl
memory    = 43008  # 内存 (MB)
cpu_cores = 16     # CPU 核心数
disk_size = "60G"  # 磁盘大小
```

---

## Windows 自定义脚本

创建 `http/windows-gpu-scripts/custom/custom.ps1` 添加自定义配置：

```powershell
# 示例：安装 NVIDIA 驱动
# Invoke-WebRequest -Uri "https://..." -OutFile "nvidia-driver.exe"
# Start-Process -FilePath "nvidia-driver.exe" -ArgumentList "/s" -Wait
```

---

## 许可证

MIT License

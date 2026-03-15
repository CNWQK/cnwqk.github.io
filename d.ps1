$ErrorActionPreference = "SilentlyContinue"

function Restore-ShortcutArrow {
    $path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons"
    if (Test-Path $path) { Remove-ItemProperty -Path $path -Name "29" }
    
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons"
    if (Test-Path $regPath) { Remove-ItemProperty -Path $regPath -Name "29" }

    taskkill /f /im explorer.exe
    $cachePath = "$env:localappdata\IconCache.db"
    if (Test-Path $cachePath) {
        attrib -h -s -r $cachePath
        Remove-Item $cachePath -Force
    }
    start explorer.exe
}

function Show-Interface {
    Clear-Host
    $targetDir = "D:\Desktop_Backup_快捷方式备份"
    $shortcuts = Get-ChildItem "$HOME\Desktop\*.lnk" | Where-Object { $_.Name -match "\(\d+\)\.lnk$" }

    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "         桌面快捷方式还原与整理工具           " -ForegroundColor White -BackgroundColor DarkCyan
    Write-Host "==============================================" -ForegroundColor Cyan

    if ($shortcuts.Count -eq 0) {
        Write-Host " 未发现带数字后缀的副本快捷方式。" -ForegroundColor Yellow
    } else {
        Write-Host " 发现 $($shortcuts.Count) 个副本，将移至: $targetDir" -ForegroundColor Green
        $shortcuts.Name | ForEach-Object { Write-Host " [→] $_" -ForegroundColor Gray }
    }

    Write-Host "`n [!] 操作：强力还原小箭头图标 & 移动副本到D盘" -ForegroundColor Yellow
    $confirm = Read-Host " 请输入 'OK' 确认执行"

    if ($confirm -eq "OK") {
        if (-not (Test-Path $targetDir)) { New-Item -Path $targetDir -ItemType Directory }
        
        Restore-ShortcutArrow
        
        if ($shortcuts) {
            $shortcuts | Move-Item -Destination $targetDir -Force
        }
        
        Write-Host "`n [成功] 箭头已还原，副本已安全移至 D 盘文件夹。" -ForegroundColor Green
    } else {
        Write-Host "`n [取消] 操作已终止。" -ForegroundColor Magenta
    }
}

Show-Interface

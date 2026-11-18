function Show-Header {
    Clear-Host
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host '       PAINEL DE SUPORTE PESSOAL' -ForegroundColor Cyan
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host ("PC: {0}    Usuario: {1}" -f $env:COMPUTERNAME, $env:USERNAME)
    Write-Host ''
}

function Wait-Continue {
    [void](Read-Host 'Pressione Enter para voltar ao menu')
}

while ($true) {
    Show-Header
    Write-Host 'DIAGNOSTICO'
    Write-Host ' 1. Resumo do Windows e do computador'
    Write-Host ' 2. Informacoes de rede'
    Write-Host ' 3. Testar conectividade (IP e HTTPS)'
    Write-Host ' 4. Ver espaco livre nos discos'
    Write-Host ''
    Write-Host 'FERRAMENTAS DO WINDOWS'
    Write-Host ' 5. Abrir Windows Update'
    Write-Host ' 6. Abrir Monitor de Recursos'
    Write-Host ' 7. Abrir configuracoes de armazenamento'
    Write-Host ''
    Write-Host 'MANUTENCAO (com confirmacao)'
    Write-Host ' 8. Limpar cache DNS'
    Write-Host ' 0. Sair'
    Write-Host ''

    $choice = Read-Host 'Escolha uma opcao'
    switch ($choice) {
        '1' {
            Get-ComputerInfo |
                Select-Object WindowsProductName, WindowsVersion, OsBuildNumber, CsManufacturer, CsModel,
                    @{Name='RAM_GB'; Expression={[math]::Round($_.CsTotalPhysicalMemory / 1GB, 1)}} |
                Format-List
            Wait-Continue
        }
        '2' {
            ipconfig.exe /all
            Wait-Continue
        }
        '3' {
            Write-Host 'Testando acesso ao endereco 1.1.1.1...'
            $ipOK = Test-Connection -ComputerName '1.1.1.1' -Count 2 -Quiet -ErrorAction SilentlyContinue
            Write-Host ("Conectividade IP: {0}" -f $(if ($ipOK) {'OK'} else {'FALHOU'}))
            Write-Host 'Testando conexao HTTPS com www.microsoft.com...'
            $httpsOK = Test-NetConnection -ComputerName 'www.microsoft.com' -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue
            Write-Host ("Conexao HTTPS: {0}" -f $(if ($httpsOK) {'OK'} else {'FALHOU'}))
            Wait-Continue
        }
        '4' {
            Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' |
                Select-Object DeviceID,
                    @{Name='Total_GB'; Expression={[math]::Round($_.Size / 1GB, 1)}},
                    @{Name='Livre_GB'; Expression={[math]::Round($_.FreeSpace / 1GB, 1)}} |
                Format-Table -AutoSize
            Wait-Continue
        }
        '5' { Start-Process 'ms-settings:windowsupdate' }
        '6' { Start-Process 'resmon.exe' }
        '7' { Start-Process 'ms-settings:storagesense' }
        '8' {
            $confirm = Read-Host 'Isso limpa apenas o cache DNS local. Continuar? (s/N)'
            if ($confirm -match '^(s|sim)$') {
                Clear-DnsClientCache
                Write-Host 'Cache DNS limpo.' -ForegroundColor Green
            } else {
                Write-Host 'Cancelado.'
            }
            Wait-Continue
        }
        '0' { break }
        default {
            Write-Host 'Opcao invalida.' -ForegroundColor Yellow
            Start-Sleep -Seconds 1
        }
    }
    if ($choice -eq '0') { break }
}
function Show-Header {
    Clear-Host
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host '       PAINEL DE SUPORTE PESSOAL' -ForegroundColor Cyan
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host ("PC: {0}    Usuario: {1}" -f $env:COMPUTERNAME, $env:USERNAME)
    Write-Host ''
}

function Invoke-MenuAction {
    param(
        [Parameter(Mandatory)]
        [string]$Description,


        [Parameter(Mandatory)]
        [scriptblock]$Action
    )

    Write-Host ""
    Write-Host "Executando: $Description" -ForegroundColor Green

    $oldErrorActionPreference = $ErrorActionPreference

    try {
        $ErrorActionPreference = 'Stop'
        & $Action

        Write-Host ""
        Write-Host "Fim da tentativa: confira os resultados." -ForegroundColor Green
    } catch {
        Write-Host ""
        Write-Host "Erro ao executar a ação: $_" -ForegroundColor Red
        Write-Host ("Detalhes do erro: {0}" -f $_.Exception.Message) -ForegroundColor Red
    } finally {
        $ErrorActionPreference = $oldErrorActionPreference
        [void](Read-Host 'Pressione Enter para voltar ao menu')
    }
}

while ($true) {
    Show-Header
    Write-Host 'DIAGNOSTICO'
    Write-Host ' 1. Resumo do Windows e do computador'
    Write-Host ' 2. Informacoes de rede'
    Write-Host ' 3. Ver IP local, gateway e conectividade externa'
    Write-Host ' 4. Ver espaco livre nos discos'
    Write-Host ''
    Write-Host 'FERRAMENTAS DO WINDOWS'
    Write-Host ' 5. Abrir Windows Update'
    Write-Host ' 6. Abrir Monitor de Recursos'
    Write-Host ' 7. Abrir configuracoes de armazenamento'
    Write-Host ''
    Write-Host 'MANUTENCAO (com confirmacao)'
    Write-Host ' 8. Limpar cache DNS'
    Write-Host ' 9. Atualizar aplicativos com WinGet'
    Write-Host '10. Executar SFC /scannow (solicita UAC)'
    Write-Host ' 0. Sair'
    Write-Host ''

    $choice = Read-Host 'Escolha uma opcao'
    switch ($choice) {
        '1' {
            Invoke-MenuAction -Description 'Consultar versao do Windows, modelo do PC e memoria RAM' -Action {
                Get-ComputerInfo -ErrorAction Stop |
                    Select-Object WindowsProductName, WindowsVersion, OsBuildNumber, CsManufacturer, CsModel,
                        @{Name='RAM_GB'; Expression={[math]::Round($_.CsTotalPhysicalMemory / 1GB, 1)}} |
                    Format-List
            }
        }
        '2' {
            Invoke-MenuAction `
                -Description 'Exibindo informacoes de rede' `
                -Action {
                    & ipconfig.exe /all
                    
                    if ($LASTEXITCODE -ne 0) {
                        throw "ipconfig.exe terminou com codigo $LASTEXITCODE."
                    }
                }
        }
        '3' {
            Invoke-MenuAction -Description 'Identificar IP local e gateway, testar gateway e acesso externo' -Action {
                $config = Get-NetIPConfiguration -ErrorAction Stop |
                    Where-Object { $_.IPv4Address -and $_.IPv4DefaultGateway } |
                    Select-Object -First 1

                if (-not $config) {
                    throw 'Nao encontrei um adaptador IPv4 ativo com endereco IP e gateway padrao.'
                }

                $localIP = $config.IPv4Address | Select-Object -First 1
                $gateway = $config.IPv4DefaultGateway | Select-Object -First 1

                Write-Host ("Adaptador: {0}" -f $config.InterfaceAlias)
                Write-Host ("IP local: {0}" -f $localIP.IPAddress)
                Write-Host ("Gateway padrao: {0}" -f $gateway.NextHop)

                Write-Host 'Testando resposta do gateway via ping...'
                $gatewayOK = Test-Connection -ComputerName $gateway.NextHop -Count 2 -Quiet -ErrorAction SilentlyContinue
                Write-Host ("Gateway responde ao ping: {0}" -f $(if ($gatewayOK) {'SIM'} else {'NAO'}))

                Write-Host 'Testando conexao externa TCP na porta 443...'
                $externalOK = Test-NetConnection -ComputerName 'www.microsoft.com' -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue
                Write-Host ("Acesso externo TCP 443: {0}" -f $(if ($externalOK) {'OK'} else {'FALHOU'}))
            }
        }
        '4' {
            Invoke-MenuAction -Description 'Consultar espaco total e livre nos discos locais' -Action {
                Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' -ErrorAction Stop |
                    Select-Object DeviceID,
                        @{Name='Total_GB'; Expression={[math]::Round($_.Size / 1GB, 1)}},
                        @{Name='Livre_GB'; Expression={[math]::Round($_.FreeSpace / 1GB, 1)}} |
                    Format-Table -AutoSize
            }
        }
        '5' { 
            Invoke-MenuAction `
                -Description 'Abrindo Windows Update' `
                -Action {
                    Start-Process 'ms-settings:windowsupdate'
                }
            }
        '6' { 
            Invoke-MenuAction `
                -Description 'Abrindo o Monitor do Sistema' `
                -Action {
                    Start-Process 'resmon.exe'
                }
            }
        '7' { 
            Invoke-MenuAction `
                -Description 'Abrindo o Gerenciador de Armazenamento' `
                -Action {
                    Start-Process 'ms-settings:storagesense'
                }
            }
        '8' {
            Invoke-MenuAction -Description 'Limpar o cache DNS local, se confirmado' -Action {
                $confirm = Read-Host 'Isso limpa apenas o cache DNS local. Continuar? (s/N)'
                if ($confirm -match '^(s|sim)$') {
                    Clear-DnsClientCache -ErrorAction Stop
                    Write-Host 'Cache DNS limpo.' -ForegroundColor Green
                } else {
                    Write-Host 'Cancelado; o cache DNS nao foi alterado.' -ForegroundColor Yellow
                }
            }
        }
        '9' {
            Invoke-MenuAction -Description 'Listar e, se confirmado, atualizar aplicativos com WinGet' -Action {
                if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
                    throw 'WinGet nao foi encontrado. Verifique se o App Installer esta instalado.'
                }

                Write-Host 'Pre-visualizacao das atualizacoes disponiveis:'
                & winget.exe upgrade --include-unknown
                $previewExitCode = $LASTEXITCODE
                if ($previewExitCode -ne 0) {
                    throw "A consulta do WinGet terminou com codigo $previewExitCode."
                }

                $confirm = Read-Host 'Atualizar todos os pacotes listados, inclusive os de versao desconhecida? (s/N)'
                if ($confirm -match '^(s|sim)$') {
                    & winget.exe upgrade --include-unknown --all
                    $upgradeExitCode = $LASTEXITCODE
                    if ($upgradeExitCode -ne 0) {
                        throw "O WinGet terminou com codigo $upgradeExitCode. Confira as mensagens dos pacotes acima."
                    }
                } else {
                    Write-Host 'Cancelado; nenhum pacote foi atualizado.' -ForegroundColor Yellow
                }
            }
        }
        '10' {
            Invoke-MenuAction -Description 'Executar SFC em uma janela elevada, se confirmado' -Action {
                $confirm = Read-Host 'SFC /scannow requer elevacao. Deseja solicitar a elevacao e abrir uma janela para executa-lo? (s/N)'
                if ($confirm -match '^(s|sim)$') {
                    Start-Process -FilePath 'powershell.exe' `
                        -Verb RunAs `
                        -ArgumentList '-NoExit -Command "sfc.exe /scannow"' `
                        -Wait -ErrorAction Stop
                } else {
                    Write-Host 'Cancelado; o SFC nao foi executado.' -ForegroundColor Yellow
                }
            }
        }
        '0' { break }
        default {
            Write-Host 'Opcao invalida.' -ForegroundColor Yellow
            Start-Sleep -Seconds 1
        }
    }
    if ($choice -eq '0') { break }
}
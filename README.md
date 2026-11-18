# Painel de Suporte Pessoal

Menu de diagnóstico e manutenção para Windows, feito em PowerShell. O painel reúne comandos do Windows e do WinGet em uma interface de console.

## Requisitos

- Windows 10 ou Windows 11
- PowerShell
- WinGet (App Installer), para a opção 9
- A opção 10 usa o UAC para abrir uma janela elevada do PowerShell

Não são necessários módulos PowerShell externos.

## Recursos

1. Exibe informações do Windows, computador e memória RAM.
2. Lista detalhes dos adaptadores de rede com `ipconfig /all`.
3. Identifica um adaptador IPv4 com IP e gateway, testa o gateway via ping e testa conectividade externa TCP na porta 443.
4. Exibe espaço total e livre nos discos locais.
5. Abre o Windows Update.
6. Abre o Monitor de Recursos.
7. Abre as configurações de armazenamento.
8. Limpa o cache DNS local após confirmação.
9. Lista atualizações do WinGet e, após confirmação, executa `winget upgrade --include-unknown --all`.
10. Solicita confirmação e abre o SFC (`sfc.exe /scannow`) em uma janela elevada do PowerShell.

As ações mostram o que estão tentando executar, tratam erros do PowerShell e aguardam Enter antes de retornar ao menu.

## Como executar

Deixe `README.md` e `painelSuporte.ps1` na mesma pasta. Abra o PowerShell nessa pasta e rode:

```powershell
.\painelSuporte.ps1
```

Se o PowerShell bloquear a execução do script, configure a política apenas para sua conta, em uma linha separada:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

Depois, execute novamente:

```powershell
.\painelSuporte.ps1
```

## Observações de segurança

- O script não apaga arquivos. A opção 8 altera apenas o cache DNS local e pede confirmação.
- A opção 9 atualiza aplicativos instalados; revise a lista e salve seu trabalho antes de confirmar. Alguns instaladores podem pedir interação ou reinicialização.
- A opção 10 verifica arquivos protegidos do Windows e pode repará-los. Ao confirmar, o UAC pode pedir autorização e uma janela elevada será aberta.
- As opções 2 e 3 exibem informações da rede local. Revise a saída antes de compartilhar capturas ou logs publicamente.
- Um gateway pode bloquear ping; “NAO” no teste de ping não prova, sozinho, que a conexão com a internet falhou.


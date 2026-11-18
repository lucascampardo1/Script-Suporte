# Painel de Suporte Pessoal

Menu de diagnóstico simples para Windows, feito em PowerShell. Reúne informações básicas do computador e da rede e abre ferramentas do próprio Windows.

## Requisitos

- Windows 10 ou Windows 11
- PowerShell incluído no Windows
- Não requer módulos externos

## Recursos

- Exibe informações do Windows, do computador e da memória RAM
- Mostra detalhes da rede
- Testa conectividade IP e HTTPS
- Exibe espaço total e livre nos discos locais
- Abre o Windows Update, o Monitor de Recursos e as configurações de armazenamento
- Permite limpar o cache DNS local após confirmação

## Como executar

Salve `README.md` e `painelSuporte.ps1` na mesma pasta. Abra o PowerShell nessa pasta e execute:

```powershell
.\painelSuporte.ps1
```

Se o Windows bloquear a execução do script, rode este comando uma vez no PowerShell, sem precisar abrir como administrador:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

Depois, execute novamente `.\painelSuporte.ps1`.

## Segurança e privacidade

- O script não se eleva automaticamente como administrador e não apaga arquivos.
- A opção de limpeza DNS pede confirmação e limpa apenas o cache DNS local. Dependendo das permissões do sistema, pode ser necessário abrir o PowerShell como administrador para essa opção.
- A opção de informações de rede pode mostrar dados da sua rede local. Evite publicar essa saída sem revisá-la.

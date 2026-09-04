# Cafezitos e Nothrilo 🇧🇷

Menu em Lua criado por **Cafezl** para **Cart Ride Around Nothing**, no Roblox. O projeto reúne ferramentas de jogador, carrinho, teleporte, mapa e câmera em uma interface em português.

## Recuperação dos projetos — 03/09/2026

Esta revisão recupera arquivos Lua inválidos/incompletos, corrige a inicialização
dos menus e reforça a API existente. As URLs antigas continuam existindo. O
[relatório de recuperação](docs/recuperacao-2026-09-03.md) registra o que foi
corrigido, os testes e as verificações que ainda dependem do ambiente real.

Os menus continuam em Lua/Luau, e o backend em JavaScript para Cloudflare Workers.
React não foi acrescentado: é uma biblioteca para interfaces web, não substitui
a interface nativa desses scripts. Não houve migração para C, C++, C# ou Java.

## Principais recursos

- Ajustes de velocidade, pulo infinito, noclip e anti-AFK.
- Teleporte por clique, até jogadores, partes do mapa e checkpoints.
- Voo do veículo, estabilizador, boost, anti-flip e freio automático.
- ESP, câmera livre, spectate e posições salvas.
- Interface com notificações, menu minimizável e atalhos de teclado.
- Sistema de key grátis com acesso salvo por até 24 horas.

## Como executar

Os arquivos `.lua` não são programas de Windows nem páginas web: precisam de um
ambiente cliente compatível. Teste somente em ambientes em que você tenha
autorização e respeite as regras da plataforma. O código abaixo usa a branch
`main`; uma correção enviada apenas a outra branch ainda não aparece nessa URL.

Abra **Cart Ride Around Nothing** e execute:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/cafezl/cart-ride-nothing-around/main/Nothrilo.lua"))()
```

Na tela inicial do Nothrilo, escolha um dos provedores disponíveis, conclua as etapas no navegador e cole a key gerada. O Nothrilo não solicita a senha da sua conta Roblox.

## Atalhos

| Tecla | Função |
|---|---|
| `V` | Voo do veículo |
| `L` | ESP |
| `P` | Pulo infinito |
| `T` | Teleporte por clique |
| `B` | Boost do carrinho |
| `NumPad 1/2/3` | Ir aos checkpoints |
| `K` | Minimizar ou abrir o menu |
| `X` | Fechar o Nothrilo |

## Arquivos principais

| Arquivo | Papel |
|---|---|
| `Cafezitos.lua` | Fonte principal mantida do Cafezitos |
| `Cafezitos-V2.lua`, `Cafezitos-completo.lua` | Cópias completas da fonte principal para manter as URLs antigas |
| `Nothrilo.lua` | Fonte principal do Nothrilo; corpo legado minificado com inicialização legível |
| `Nothrilo-key-gratis.lua` | Cópia completa do Nothrilo |
| `Nothrilo-classico-funcoes-corrigidas.lua` | Versão clássica legível, mantida separadamente |
| `Cafezitos-teste.lua` | Diagnóstico de download, compilação e execução, com mensagem de erro |
| `key-server/` | API JavaScript e testes do fluxo de keys |
| `assets/` | Arquivos visuais usados pelo carregamento |

Não edite as cópias separadamente. Após mudar uma fonte principal, execute
`node scripts/sync-aliases.mjs --write`; sem `--write`, o comando apenas verifica
se elas estão sincronizadas. As versões anteriores permanecem no histórico Git.

### Se a interface não abrir

O `Cafezitos-teste.lua` usa `Cafezitos.lua` por padrão. Antes de iniciar o
diagnóstico, o ambiente pode definir `CafezlDiagnosticTarget` como `Cafezitos` ou
`Nothrilo` e `CafezlDiagnosticRef` como uma branch ou commit deste repositório.
As opções são lidas de `getgenv()` quando disponível, ou de `_G`.

Na revisão de recuperação, a referência é `fix/restore-menus-api-20260903`.
O próprio arquivo de diagnóstico também precisa ser obtido dessa referência
enquanto ela não estiver em `main`. O diagnóstico não contorna a validação de key.
Anote a mensagem apresentada, sem compartilhar keys, leases, senhas ou tokens.

## Testes de desenvolvimento

Com Node.js 22 ou superior, na raiz do repositório, sem instalar dependências:

```sh
node --test tests/source.test.mjs key-server/test/key-store.test.mjs
node scripts/sync-aliases.mjs
```

Com `luau` e `luau-compile` também disponíveis no PATH:

```sh
node --test tests/client.test.mjs
```

É possível indicar os executáveis por `LUAU_BIN` e `LUAU_COMPILE_BIN`. Os testes
compilam os sete arquivos em O0, O1 e O2 e simulam somente a inicialização da
interface. Não substituem testes no Roblox, nem verificam a física do jogo,
todos os botões, serviços externos ou a instalação real do Worker.

O workflow `Validate menus and API` repete essas verificações sem fazer deploy,
sem acessar segredos dos provedores e com o compilador Luau fixado em um commit.

## Privacidade do sistema de key

A versão atual envia ao servidor do Nothrilo o `UserId`, o `PlaceId` e a key ou autorização temporária necessária para validar o acesso. Quando o ambiente permite salvar arquivos, a autorização válida pode ficar armazenada localmente em `Nothrilo/key-cache-v1.json`. Os provedores de key abrem páginas externas e possuem suas próprias políticas.

## Observações

- Atualizações do Roblox ou do jogo podem exigir ajustes no script.
- O projeto é independente e não possui afiliação com Roblox ou com os criadores do jogo.
- Nunca informe sua senha do Roblox em páginas de key ou executores. Use apenas em ambientes autorizados, por sua conta e risco, e respeite as regras da plataforma.

---

Feito por **Cafezl**.

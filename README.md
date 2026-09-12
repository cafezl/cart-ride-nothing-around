<div align="center">

# 🇧🇷 Nothrilo & Cafezitos ☕

**Dois menus por Cafezl para Cart Ride Around Nothing.**<br>
Carrinho, movimento, exploração e câmera — com interface em português.

[Executar Nothrilo](#-nothrilo-clássico) · [Executar Cafezitos](#-cafezitos) · [Pegar a key](#-key-do-nothrilo) · [Documentação](#-desenvolvimento)

</div>

---

## Escolha seu menu

| | 🇧🇷 Nothrilo | ☕ Cafezitos |
|---|---|---|
| **Visual** | Clássico, com abas laterais e controles no estilo Kavo | Tema de café, com abas e controles próprios |
| **Acesso** | Key gratuita por Linkvertise, Work.ink ou LootLabs, válida por até 24 horas | Abertura direta, sem key |
| **Fonte principal** | [`Nothrilo.lua`](Nothrilo.lua) | [`Cafezitos.lua`](Cafezitos.lua) |

**O Nothrilo Clássico é a versão principal.** O endereço habitual de `Nothrilo.lua` carrega o menu clássico completo com a tela de key. As URLs `Nothrilo-key-gratis.lua` e `Nothrilo-classico-funcoes-corrigidas.lua` recebem o mesmo código, incluindo a validação de acesso.

## 🇧🇷 Nothrilo Clássico

No cliente do Roblox, dentro de **Cart Ride Around Nothing**, execute em um ambiente compatível:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/cafezl/cart-ride-nothing-around/main/Nothrilo.lua"))()
```

O menu reúne **Jogador, Teleporte, Carrinho, Cart+, Extras, Mapa, Eliminador, Troll, Comandos e Interface**. A interface clássica é implementada no próprio arquivo, com controles compatíveis com o estilo Kavo.

### 🔑 Key do Nothrilo

1. Abra o Nothrilo e escolha **Linkvertise**, **Work.ink** ou **LootLabs** na tela de key.
2. Cole no navegador o link gerado pelo menu e conclua as etapas do serviço escolhido.
3. Continue no **mesmo navegador**, mantendo a sessão aberta até aparecer a key.
4. Copie a key, volte ao Roblox e clique em **Validar e abrir o Nothrilo**.

A key libera o menu completo por até **24 horas**. Quando o ambiente permite salvar arquivos, o acesso válido é lembrado nas próximas execuções.

> **Comece sempre pelo link gerado no menu.** Abrir apenas um link público compartilhado do provedor não cria a sessão necessária para emitir sua key. Se a sessão expirar, gere um novo link no Nothrilo e reinicie o processo.

Os três serviços permanecem disponíveis no menu e possuem integração no servidor. A emissão depende da configuração e da confirmação do serviço escolhido.

Na Linkvertise, foi corrigida a validação que recusava o código de retorno (`hash`) quando ele continha caracteres fora do formato hexadecimal. A confirmação pela API do provedor continua obrigatória. Essa correção não equivale a um teste completo de emissão de keys reais nos três serviços.

## ☕ Cafezitos

Para abrir o Cafezitos, execute:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/cafezl/cart-ride-nothing-around/main/Cafezitos.lua"))()
```

O **Cafezitos V2** abre diretamente, com tema de café, notificações e controles de interface. Também reúne as abas de jogador, teleporte, carrinho, física, exploração, câmera e comandos.

## 🎮 Recursos dos menus

| Área | Controles disponíveis |
|---|---|
| **Jogador** | Velocidade, pulo infinito, anti-AFK, ESP e voo do veículo |
| **Teleporte** | Início, botão de carrinho, áreas do mapa, insígnia e sala secreta |
| **Carrinho** | Checkpoints, leitura de velocidade, saída do assento e estabilizador ajustável |
| **Cart+** | Boost, anti-flip e freio automático |
| **Extras** | Noclip, transparência local, força do pulo, gravidade e posição salva |
| **Mapa** | Busca de partes, carrinho próximo e câmera livre |
| **Eliminador / Troll** | Controle de alvo, spectate, câmera giratória e teleporte aleatório |
| **Interface** | Minimizar, reabrir, fechar e consultar atalhos |

### ⌨️ Atalhos

| Tecla | Ação |
|---|---|
| `V` | Ativar ou desativar o voo do veículo |
| `L` | Ativar ou desativar o ESP |
| `P` | Ativar ou desativar o pulo infinito |
| `T` | Criar a ferramenta de teleporte por clique |
| `B` | Ativar ou desativar o boost |
| `NumPad 1 / 2 / 3` | Ir aos checkpoints |
| `K` | Minimizar ou reabrir o menu |
| `X` | Fechar o menu |

## 🔎 Se algo não abrir

**Erro na key:** gere um link novo pelo botão do provedor escolhido, conclua o fluxo no mesmo navegador e verifique se a key ainda está válida. Registre qual serviço foi usado e a mensagem de erro. Não compartilhe URLs de retorno que contenham tokens, keys ou dados da sessão.

**Erro ao iniciar o menu:** [`Cafezitos-teste.lua`](Cafezitos-teste.lua) ajuda a identificar falhas de download, compilação e execução. Ele verifica o Cafezitos por padrão; o alvo também pode ser definido como Nothrilo. Esse diagnóstico mantém a validação de key.

**Uma função falha dentro do jogo:** registre o nome do menu, a função usada, a mensagem de erro e se o personagem estava sentado no carrinho. Isso ajuda a distinguir problemas do menu de mudanças na física ou na organização do mapa.

## 🗂️ Organização do projeto

| Caminho | Conteúdo |
|---|---|
| [`Nothrilo.lua`](Nothrilo.lua) | Fonte principal legível do Nothrilo Clássico, com key |
| [`Nothrilo-key-gratis.lua`](Nothrilo-key-gratis.lua) | Cópia completa e sincronizada do Nothrilo |
| [`Nothrilo-classico-funcoes-corrigidas.lua`](Nothrilo-classico-funcoes-corrigidas.lua) | Mesmo Nothrilo principal, preservando a URL da versão clássica |
| [`Cafezitos.lua`](Cafezitos.lua) | Fonte principal do Cafezitos |
| [`Cafezitos-V2.lua`](Cafezitos-V2.lua) e [`Cafezitos-completo.lua`](Cafezitos-completo.lua) | Cópias completas e sincronizadas do Cafezitos |
| [`INSPIRAÇÃO/`](INSPIRA%C3%87%C3%83O/) | Scripts de referência para comparação de funções; separados dos menus publicados |
| [`key-server/`](key-server/) | API de keys em JavaScript, com Cloudflare Workers e Durable Objects |
| [`key-server/src/ui.js`](key-server/src/ui.js) | Páginas externas do sistema de key em React + JavaScript |
| [`tests/`](tests/) e [`scripts/`](scripts/) | Verificações, diagnóstico e sincronização das cópias |
| [`docs/`](docs/) | Relatórios de manutenção e segurança |

Os menus do Roblox continuam em **Lua/Luau**. **React + JavaScript** atendem às páginas externas e ao servidor de keys. Os arquivos de `INSPIRAÇÃO/` servem para leitura e comparação; seus carregadores externos não fazem parte da inicialização dos menus.

## 🔒 Dados do sistema de key

O Nothrilo envia ao seu servidor o `UserId`, o `PlaceId` e a credencial necessária à validação. Após a primeira validação, o acesso pode ser salvo localmente como uma autorização temporária em `Nothrilo/key-cache-v1.json`, quando o ambiente oferece suporte a arquivos.

A emissão da key depende da confirmação do provedor pelo servidor. Os segredos das integrações ficam no Cloudflare Workers. O Nothrilo não pede a senha da conta Roblox. A navegação na Linkvertise, no Work.ink ou no LootLabs está sujeita às políticas de cada serviço.

Os limites e as propriedades de segurança estão documentados no [README do servidor de keys](key-server/README.md).

## 🛠️ Desenvolvimento

Edite somente as fontes principais e sincronize as cópias antes de publicar. O histórico Git preserva as versões anteriores.

<details>
<summary><strong>Instalação e verificações</strong></summary>

Requisitos: **Node.js 22 ou superior**, a versão de pnpm indicada no `package.json` e, para os testes Lua, `luau` e `luau-compile`.

```sh
corepack enable
pnpm --dir key-server install --frozen-lockfile
pnpm run sync:aliases
pnpm test
pnpm --dir key-server run check
pnpm run check:aliases
pnpm run test:luau
```

Os executáveis Luau podem estar no `PATH` ou ser indicados por `LUAU_BIN` e `LUAU_COMPILE_BIN`.

As verificações cobrem os arquivos publicados, a sincronização das cópias, a API de keys, a compilação Luau em O0/O1/O2 e a inicialização dos menus em um ambiente simulado. **Elas não comprovam a física, todos os botões ou a emissão de uma key real dentro do jogo.**

O workflow [`Validate menus and API`](https://github.com/cafezl/cart-ride-nothing-around/actions/workflows/validate.yml) executa as verificações automáticas. A publicação do servidor é tratada separadamente pelo workflow de deploy.

</details>

<details>
<summary><strong>Opções do diagnóstico e relatórios anteriores</strong></summary>

Antes de executar `Cafezitos-teste.lua`, o ambiente pode definir `CafezlDiagnosticTarget` como `Cafezitos` ou `Nothrilo` e `CafezlDiagnosticRef` como uma branch ou commit deste repositório. As opções são lidas de `getgenv()` quando disponível, ou de `_G`.

- [Servidor de keys: configuração e manutenção](key-server/README.md)
- [Revisão de React e segurança — 05/09/2026](docs/react-seguranca-2026-09-05.md)
- [Relatório de recuperação — 03/09/2026](docs/recuperacao-2026-09-03.md)

Os relatórios registram o estado de cada revisão; os arquivos principais representam a versão atual.

</details>

---

<div align="center">

**Feito por [Cafezl](https://github.com/cafezl).** 🇧🇷 ☕<br>
Projeto independente, sem afiliação com Roblox ou com os criadores do jogo.<br>
Use em ambientes autorizados e respeite as regras da plataforma.

</div>

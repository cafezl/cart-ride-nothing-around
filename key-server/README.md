# Nothrilo Key Server

Backend gratuito e independente do JNKIE para liberar o Nothrilo inteiro após uma conclusão em **uma** destas opções:

- Work.ink
- LootLabs
- Linkvertise

Todas as keys dão o mesmo acesso por 24 horas. Não existe Premium e nenhuma função é vendida separadamente.

## Segurança

- Tokens permanentes nunca entram no Lua, GitHub ou `wrangler.jsonc`.
- Os logs detalhados do Worker ficam desligados por padrão para não registrar
  tokens temporários nem o segredo do postback presente na URL do LootLabs.
- A key fica vinculada ao `UserId` do Roblox. Depois da primeira validação, o Lua guarda somente uma lease opaca — não a key digitada.
- Work.ink e Linkvertise são validados diretamente nas APIs oficiais e consumidos uma vez.
- LootLabs usa postback com rota secreta, sessão curta e `unique_id` de uso único.
- O armazenamento forte é um Durable Object SQLite; não depende da consistência eventual do KV.
- O início de key valida o provedor antes de gravar e limita tentativas por IP,
  usuário e combinação dos dois. Também limita sessões simultâneas pendentes.
- A limpeza do Durable Object é paginada e reagendada, evitando carregar todo o
  armazenamento de uma vez. Um cursor persistente evita que páginas iniciais
  ainda válidas impeçam a limpeza das páginas seguintes.
- As chamadas às APIs dos provedores têm timeout de 10 segundos para uma falha
  externa não prender o Worker.
- As respostas dos provedores são limitadas durante a leitura a 64 KiB por
  padrão, mesmo se `Content-Length` estiver ausente ou incorreto.
- Os corpos JSON de validação e emissão administrativa têm limites de 2.048 e
  1.024 bytes, respectivamente, conferidos durante a leitura do fluxo. Um
  `Content-Length` ausente ou incorreto não remove esse limite.
- A validação exige `Content-Type: application/json`, um objeto JSON, `UserId`
  numérico positivo e exatamente uma credencial (`key` ou `lease`).
- A verificação tem limites por IP e combinação IP/usuário, inclusive sob
  concorrência. O IP vem de `CF-Connecting-IP`, não de `X-Forwarded-For`.
- As páginas usam nonces individuais de CSP, sem `unsafe-inline`. A diretiva
  `connect-src 'self'` permite a consulta de status na própria origem.
- A interface externa é composta em React e os dados dinâmicos são escapados
  pelo renderizador, sem concatenar valores de usuário ao HTML. A tela de espera
  atualiza elementos já renderizados em vez de montar HTML com `innerHTML`.
- As respostas HTML também bloqueiam enquadramento, objetos, manifesto, câmera,
  microfone, localização, pagamentos e acesso USB. Recursos e janelas ficam
  isolados na mesma origem, e redirecionamentos não enviam `Referer`.
- As rotas administrativas e o status vinculado a cookie não permitem leitura
  via CORS. Erros inesperados retornam uma resposta genérica, sem expor exceções,
  URLs com tokens ou corpos de requisições.
- Validar repetidamente uma key com lease ainda válida não regrava os mesmos
  registros de credenciais. Os contadores de limite continuam sendo atualizados.

Isto é uma barreira prática, não DRM absoluto: qualquer código entregue a um executor pode ser analisado ou alterado.

O vínculo ao `UserId` compara o identificador informado; ele não prova, sozinho,
que o solicitante controla aquela conta Roblox. O servidor não recebe uma prova
de identidade Roblox autenticada. Keys e leases continuam sendo credenciais
sensíveis. Hashes de IP usados nos contadores também não são anonimização forte.

## Configuração depois do primeiro deploy

1. Anote a origem do Worker, como `https://nothrilo-key.SUA-CONTA.workers.dev`.
2. Crie/configure os links:
   - Work.ink: ative Key System. O Worker usa a Link Override API para inserir seu callback.
   - Linkvertise: use **Target Link** com destino `ORIGEM/v1/nothrilo/key/callback/linkvertise`.
   - LootLabs: use 1 tarefa e destino `ORIGEM/v1/nothrilo/key/callback/lootlabs`.
3. Troque os quatro placeholders em `wrangler.jsonc` pelos links/ID públicos.
4. Cadastre no LootLabs Advanced o postback:

   `ORIGEM/v1/nothrilo/key/postback/lootlabs?secret=SEGREDO`

5. Grave os segredos somente como Cloudflare Secrets:

   - `LINKVERTISE_ANTI_BYPASS_TOKEN`
   - `LOOTLABS_POSTBACK_SECRET`
   - `ADMIN_ISSUE_SECRET` (segredo aleatório de pelo menos 32 caracteres)

O segredo do postback deve ter pelo menos 32 caracteres aleatórios. O token Linkvertise possui 64 caracteres.
O LootLabs exige o segredo na URL do postback; por isso essa URL deve ser tratada
como credencial, nunca publicada, e o segredo deve ser rotacionado se aparecer em
logs ou capturas. A observabilidade detalhada permanece desligada para reduzir a
exposição.

## Key manual do dono

Existe uma rota administrativa para emitir uma key de teste sem criar uma key
universal e sem colocar segredo no Lua ou no GitHub. A key continua vinculada ao
`UserId` numérico informado e expira normalmente após 24 horas.

Primeiro, grave um segredo aleatório forte de pelo menos 32 caracteres. O comando
abaixo pede o valor de forma interativa; não coloque o valor na própria linha de
comando:

```powershell
pnpm exec wrangler secret put ADMIN_ISSUE_SECRET
```

Para emitir uma key, use o script auxiliar. Ele pede o segredo com a entrada
oculta e o envia somente no cabeçalho HTTPS, sem colocá-lo no histórico do
terminal nem nos argumentos do processo:

```powershell
.\scripts\issue-owner-key.ps1 `
  -WorkerUrl "https://nothrilo-key.SUA-CONTA.workers.dev" `
  -UserId "USER_ID_NUMERICO"
```

Não use nome de exibição ou nome de usuário no lugar do `UserId`. A rota não tem
CORS, responde com `Cache-Control: no-store` e limita, por padrão, 6 emissões por
IP e 3 por usuário a cada 15 minutos. Os limites podem ser ajustados com
`ADMIN_ISSUE_RATE_WINDOW_SECONDS`, `ADMIN_ISSUE_RATE_IP_LIMIT` e
`ADMIN_ISSUE_RATE_USER_LIMIT`.

Ao vencer, uma key não se renova nem vira permanente: é necessário concluir um
provedor novamente ou emitir outra key administrativa. A nova key é aleatória e
diferente da anterior.

### Limites padrão

Em uma janela de 10 minutos são aceitos até 30 inícios por IP, 10 por usuário e
6 pela mesma combinação IP/usuário. Podem ficar pendentes ao mesmo tempo até 20
sessões por IP, 4 por usuário e 3 pela mesma combinação. Esses valores podem ser
ajustados com `START_RATE_WINDOW_SECONDS`, `START_RATE_IP_LIMIT`,
`START_RATE_USER_LIMIT`, `START_RATE_PAIR_LIMIT`, `MAX_PENDING_IP`,
`MAX_PENDING_USER` e `MAX_PENDING_PAIR`.

Na validação, a janela padrão é de 60 segundos, com até 60 requisições por IP e
12 pela mesma combinação IP/usuário. Não há bloqueio global baseado apenas no
`UserId` declarado nessa rota, para que alguém em outro IP não possa bloquear o
titular simplesmente usando seu identificador público. Respostas `429` incluem
`Retry-After`; aguarde antes de tentar novamente.

| Variável opcional | Padrão | Intervalo aceito |
|---|---:|---:|
| `VERIFY_WINDOW_SECONDS` | 60 | 10–3.600 |
| `VERIFY_IP_LIMIT` | 60 | 1–600 |
| `VERIFY_PAIR_LIMIT` | 12 | 1–120 |

Os limites são compartilhados por pessoas que saem pelo mesmo IP público.
Fora da borda Cloudflare, a ausência de `CF-Connecting-IP` usa o mesmo grupo
`unknown`; não exponha uma adaptação do Worker que confie nesse cabeçalho enviado
diretamente pelo cliente. Os limites desta aplicação não substituem controles
de abuso e tráfego na infraestrutura.

## Rotas usadas pelo Lua

- Obter link: `GET /v1/nothrilo/key/start?provider=PROVEDOR&userId=USER_ID`
- Validar key: `POST /v1/nothrilo/key/verify`
- Saúde: `GET /v1/nothrilo/key/health`

A rota `POST /v1/nothrilo/key/admin/issue` é somente administrativa. Ela nunca
deve ser chamada pelo Lua distribuído nem receber o segredo por query string.

Corpo de validação:

Envie com o cabeçalho `Content-Type: application/json`. Para uma lease, substitua
o campo `key` por `lease`; não envie os dois no mesmo corpo.

```json
{
  "key": "NOTH-XXXX-XXXX-XXXX-XXXX-XXXX",
  "userId": "123456"
}
```

## Publicação

O projeto exige Wrangler 4.102.0 ou superior. Também pode ser publicado temporariamente com `wrangler deploy --temporary` e depois reivindicado na conta Cloudflare dentro do prazo mostrado pela ferramenta.

### Publicação pelo GitHub

A arquitetura desta camada usa React com JavaScript. O Worker renderiza os
componentes no servidor e mantém apenas as interações pequenas de copiar e
consultar status no navegador. Assim, o projeto ganha componentes reutilizáveis
sem transformar o fluxo de keys em uma aplicação pesada nem alterar os scripts
Lua/Luau.

O workflow `Deploy key server` valida e publica automaticamente quando arquivos
de `key-server/` chegam à branch `main`. Ele também pode ser iniciado manualmente.
Antes de usá-lo, cadastre em **Settings → Secrets and variables → Actions**:

- `CLOUDFLARE_API_TOKEN`: token restrito à conta e com permissão para editar
  Workers;
- `CLOUDFLARE_ACCOUNT_ID`: ID da conta que possui o Worker.

Nunca coloque esses valores em commits, issues, logs ou mensagens. A URL pública
do LootLabs fica na configuração versionada porque já é revelada ao usuário pelo
próprio redirecionamento; o segredo do postback continua apenas na Cloudflare.
Depois do deploy, o workflow confirma a interface React, a rota de saúde e a
criação de sessões pendentes para Work.ink, LootLabs e Linkvertise sem concluir
anúncios nem registrar keys de teste. Os outros segredos do Worker já existentes
na Cloudflare não são apagados pelo deploy.

O deploy usa versões fixadas do Wrangler e das Actions. O ambiente GitHub
`production` pode receber regras de aprovação nas configurações do repositório.

### Validação desta revisão

Na raiz do repositório, execute:

```sh
corepack enable
pnpm --dir key-server install --frozen-lockfile
pnpm --dir key-server run check
node --test tests/source.test.mjs key-server/test/key-store.test.mjs
pnpm --dir key-server exec wrangler deploy --dry-run
KEY_SERVER_ORIGIN=https://nothrilo-key.urielcafe01.workers.dev pnpm --dir key-server run smoke:production
```
Os testes da API usam armazenamento em memória e respostas de provedores
simuladas; não emitem keys reais nem acessam contas dos provedores.

O smoke test de produção cria somente sessões temporárias que expiram sozinhas.
Ele não segue anúncios, não recebe provas dos provedores e não emite keys. Não há
migração de dados durante a publicação.

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

Isto é uma barreira prática, não DRM absoluto: qualquer código entregue a um executor pode ser analisado ou alterado.

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

O segredo do postback deve ter pelo menos 32 caracteres aleatórios. O token Linkvertise possui 64 caracteres.

## Rotas usadas pelo Lua

- Obter link: `GET /v1/nothrilo/key/start?provider=PROVEDOR&userId=USER_ID`
- Validar key: `POST /v1/nothrilo/key/verify`
- Saúde: `GET /v1/nothrilo/key/health`

Corpo de validação:

```json
{
  "key": "NOTH-XXXX-XXXX-XXXX-XXXX-XXXX",
  "userId": "123456"
}
```

## Publicação

O projeto exige Wrangler 4.102.0 ou superior. Também pode ser publicado temporariamente com `wrangler deploy --temporary` e depois reivindicado na conta Cloudflare dentro do prazo mostrado pela ferramenta.

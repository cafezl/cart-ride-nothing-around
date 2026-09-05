# React, segurança e otimização — 05/09/2026

Branch de trabalho: `feat/react-key-portal-20260904`.

## Escopo preservado

A mudança se limita à camada web externa e ao backend do sistema de key. Os sete
arquivos Lua/Luau publicados não foram editados. A comparação por nome no Git e
por SHA-256 antes e depois da revisão confirmou que o conteúdo dos roteiros
permaneceu idêntico.

Não existe uma forma de impedir totalmente a cópia de código que precisa ser
entregue ao cliente ou mantido em um repositório público. A proteção aplicada
concentra decisões e segredos no servidor e evita uma obfuscação destrutiva que
poderia quebrar o menu.

## Arquitetura React + JavaScript

- `key-server/src/ui.js` contém componentes React em JavaScript para as páginas
  inicial, erro, key liberada e confirmação do LootLabs.
- O Worker renderiza os componentes no servidor com a variante edge do React.
- Apenas copiar a key e consultar o status executam JavaScript no navegador.
- A API, as rotas, o Durable Object, os cookies e os provedores permanecem
  separados da interface.
- React e React DOM estão fixados na versão `19.2.8`, com integridade registrada
  no lockfile.

## Segurança aplicada

- Valores dinâmicos são escapados pelo renderizador React.
- A tela de espera deixou de construir elementos com `innerHTML`.
- A CSP continua usando um nonce aleatório por resposta e não aceita
  `unsafe-inline`.
- Cabeçalhos bloqueiam enquadramento, objetos, manifesto, câmera, microfone,
  localização, pagamentos e USB, além de isolar recursos na mesma origem.
- Redirecionamentos usam `Cache-Control: no-store` e `Referrer-Policy:
  no-referrer`.
- URLs de Work.ink, LootLabs e Linkvertise são analisadas como URLs HTTPS e
  rejeitam credenciais embutidas, fragmentos, portas alternativas e hosts não
  permitidos.
- Respostas externas têm timeout e limite real de 64 KiB durante a leitura, sem
  confiar apenas no cabeçalho `Content-Length`.
- Cookies de sessão inválidos são rejeitados antes de acessar o Durable Object.
- O sistema continua limitando tentativas, sessões pendentes e emissão
  administrativa; keys e leases continuam vinculadas ao `UserId` informado e
  com expiração.

## Otimização

- O Worker agora é minificado pelo Wrangler.
- A interface reutiliza componentes em vez de repetir quatro documentos HTML.
- A tela de espera atualiza elementos existentes, reduzindo criação e análise de
  HTML em tempo de execução.
- O bundle local minificado ficou em aproximadamente 235 KiB.
- O workflow instala dependências pelo lockfile e empacota o Worker em modo
  `--dry-run` antes de compilar os scripts Lua/Luau.

## Validação

Resultado local: **52 testes aprovados, nenhum ignorado**.

- 35 testes do backend e da interface React.
- 3 testes de integridade das fontes e URLs de compatibilidade.
- 14 testes de compilação e inicialização simulada em Lua/Luau.
- Todos os sete arquivos Lua compilam em O0, O1 e O2.
- `node --check`, sincronização dos aliases, empacotamento com esbuild e
  `git diff --check` aprovados.

Os testes de provedores usam respostas simuladas e não criam keys reais. O teste
final no ambiente do jogo e o deploy de produção continuam dependendo da conta
Cloudflare e das configurações reais dos provedores.

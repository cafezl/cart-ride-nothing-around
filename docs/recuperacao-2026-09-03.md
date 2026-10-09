# Recuperação do Cafezitos e Nothrilo

Revisão de 03/09/2026, baseada em
`07f9a600eee7e7c0d1b749214b5eab143ef45444` (`main`).
Branch de trabalho: `fix/restore-menus-api-20260903`.

## Pedido preservado

Recuperar a inicialização dos dois menus após uma alteração interrompida;
melhorar segurança e desempenho da camada externa e da API; aproveitar o código
existente, sem apagar os projetos; deixar o trabalho versionado para continuar
em outro computador. Somente o que estava no GitHub pôde ser recuperado. Este
trabalho não recupera arquivos locais apagados nem conversas de outra conta.

## Falhas confirmadas e mudanças

| Evidência na base | Correção |
|---|---|
| `Cafezitos-completo.lua` continha saída de terminal e um marcador de truncamento no meio do código | Restaurada uma cópia completa da fonte mantida `Cafezitos.lua` |
| `Cafezitos-teste.lua` começava com saída de terminal inválida e buscava o arquivo truncado | Recuperado o diagnóstico, com escolha de projeto/ref, limite de download e erros limitados/redigidos |
| `Cafezitos-V2.lua` e o Nothrilo clássico excediam 200 registradores locais na compilação O0 | V2 sincronizado à fonte mantida; variáveis temporárias do clássico isoladas em blocos |
| Inicialização dependia de `LocalPlayer` e de uma raiz de GUI já disponíveis | Espera limitada, teste real de permissão para anexar GUI e fallback para `PlayerGui` |
| A busca HTTP do Nothrilo ignorava funções herdadas pelo ambiente | Consulta protegida por `pcall`, incluindo herança, com teste de regressão |
| A CSP bloqueava o polling de status porque faltava `connect-src` | Permitida a própria origem e adicionados nonces de scripts/estilos |
| JSON de verificação sem limite de leitura; emissão administrativa limitava caracteres somente depois da leitura | Limites de bytes durante leitura, validação de tipo e credencial única |
| Verificação de key/lease sem orçamento próprio de tentativas | Limites serializados por IP e IP/usuário, com `429` e `Retry-After` |
| Cada limpeza recomeçava pelas primeiras páginas vivas | Cursor persistente, com teste atravessando páginas e recriação do objeto |
| Validações repetidas regravavam credenciais idênticas | Reutilização da lease sem essas gravações desnecessárias |

As URLs antigas continuam válidas. As cópias são sincronizadas por
`scripts/sync-aliases.mjs`, e o teste falha se divergirem. O corpo principal dos
menus foi aproveitado; esta revisão não reimplementa todas as funções de jogo.
Os arquivos antigos continuam acessíveis pelo histórico Git.

## Decisão de arquitetura

Manter Lua/Luau para a interface nativa do Roblox e JavaScript no Worker já
existente. As páginas web do fluxo de key continuam pequenas, geradas pelo
backend. Uma migração para React, TypeScript, C, C++, C# ou Java seria um projeto
separado; ela não é necessária para corrigir as falhas reproduzidas e não foi
feita nesta recuperação.

## Verificações locais

Resultado desta revisão: 49 testes aprovados, sem testes ignorados.

- 32 testes da API, incluindo os 21 testes anteriores.
- 3 testes de integridade das fontes e compatibilidade das URLs.
- 14 testes de compilação e inicialização simulada: sete arquivos compilados
  em O0/O1/O2, GUI visível, jogador/GUI atrasados, GUI sem permissão, conexão
  herdada, rede indisponível, jogador ausente e diagnóstico com erro visível.
- `node --check key-server/src/index.js` e `git diff --check` aprovados.

Compilador/interpreter: Luau 0.736, construído da fonte oficial no commit
`c2ec0d4e5ca50796ba174a7565298f59aa572268`.
O workflow repete os testes sem segredos de provedores e sem deploy.

O modelo em `tests/client-harness.lua` simula somente o bootstrap. As respostas
de validação nele são fixtures de teste, não autorizações reais e não alteram o
servidor. O teste de falha de rede confirma que o Nothrilo não abre o menu sem
uma verificação bem-sucedida.

## Limitações e próximo teste real

- Não foi possível executar Roblox neste ambiente. Não estão comprovados aqui
  o funcionamento de todos os botões, física, respawn, dispositivos móveis ou
  compatibilidade com ambientes externos.
- O Durable Object foi testado em memória, não numa implantação Cloudflare.
  Os fluxos dos provedores foram simulados; não foram consumidos anúncios nem
  emitidas credenciais reais.
- `LOOTLABS_URL` no arquivo versionado ainda contém um placeholder. Nenhum link,
  segredo ou configuração de produção foi alterado. Confirme as configurações
  efetivas antes de habilitar/publicar cada integração.
- O `UserId` declarado não é prova de controle da conta; código cliente pode
  ser alterado. Esta revisão é reforço pontual, não garantia de segurança total.
- Alterar uma branch do GitHub não publica automaticamente a API. Também não
  atualiza os carregadores que continuam apontando para `main` até a integração
  da correção nessa branch.

Antes de publicar, testar em ambiente autorizado: abrir e fechar cada menu;
reabrir sem duplicar GUI/conexões; verificar key válida, inválida e expirada;
testar indisponibilidade/reconexão; conferir as funções já usadas e a interface
no dispositivo real. Registrar mensagens sem credenciais e corrigir regressões
reproduzidas. A publicação do Worker e a integração em `main` são etapas separadas.

## Retomar em outro computador

No GitHub, abra a branch ou o pull request desta recuperação. Faça o checkout
dessa referência, leia este relatório e execute os comandos de teste do README.
Depois de novas alterações, sincronize as cópias e envie um commit ao GitHub.
Um commit que permaneceu apenas no computador ainda não é um backup remoto.

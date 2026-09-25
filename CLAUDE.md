# datasusr — notas para o Claude Code

Pacote R no CRAN (0.1.0 publicado; **0.1.1 submetida em 2026-09-25,
aguardando resposta do CRAN**). Leitor de DBC/DBF do DATASUS em C
(`src/`) + catálogo/FTP/cache em R (`R/datasus_catalog.R`).

## Estado da submissão 0.1.1

- Enviada com `devtools:::upload_cran()` (função interna, por isso
  `:::`); `CRAN-SUBMISSION` tem versão, data e SHA (bc0e105).
  Confirmação por e-mail feita pelo mantenedor.
- Quando o CRAN aceitar:
  [`usethis::use_github_release()`](https://usethis.r-lib.org/reference/use_github_release.html)
  (lê `CRAN-SUBMISSION`), depois iniciar `0.1.1.9000` em `DESCRIPTION` e
  `NEWS.md`.
- Se o CRAN pedir mudanças: editar, subir a versão (0.1.2), atualizar
  `cran-comments.md` e repetir o fluxo de validação abaixo. Pontos mais
  prováveis de reclamação: Windows (parse de inteiros com `long` de 32
  bits em `src/dbf_parser.c`, já protegido por `errno`/`ERANGE`).

## Como validar (sempre antes de commit/submissão)

Nunca use
[`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
para testar C: um `.so` desatualizado no `src/` já causou segfault
falso. Fluxo que funciona (cada passo em diretório de scratch, fora do
repo):

``` sh
R CMD build /Users/leite/Github/datasusr            # com vinhetas
R CMD INSTALL -l ./lib datasusr_*.tar.gz
Rscript -e 'library(datasusr, lib.loc=normalizePath("./lib")); testthat::test_dir("<repo>/tests/testthat", package="datasusr", load_package="none")'
R CMD check --as-cran datasusr_*.tar.gz             # com rede: Status OK; só NOTE do HTML Tidy antigo do macOS
```

ASan (para mudanças em `src/`): extrair o tarball, pôr em `src/Makevars`
`PKG_CFLAGS = -fsanitize=address -fno-omit-frame-pointer -g -O1` e
`PKG_LIBS = -fsanitize=address`,
`R CMD INSTALL --no-test-load -l <lib>`, e rodar com
`R_HOME=/Library/Frameworks/R.framework/Resources DYLD_INSERT_LIBRARIES=/Library/Developer/CommandLineTools/usr/lib/clang/21/lib/darwin/libclang_rt.asan_osx_dynamic.dylib ASAN_OPTIONS=detect_leaks=0 /Library/Frameworks/R.framework/Resources/bin/exec/R --vanilla -q -f script.R`.

## Testes

`tests/testthat/` é 100% offline: `helper-dbf.R` tem `make_dbf()` para
gerar dBase III sintético; `test-catalog.R` usa URLs `file://` e
`local_mocked_bindings()` (testthat \>= 3.1.7). Não adicionar teste que
precise da FTP do DATASUS.

## Site (pkgdown)

- Publicado no branch **`gh-pages`** (GitHub Pages aponta para lá);
  `docs/` está no `.gitignore` e fora do `main`.
- Republicar:
  `pkgdown::deploy_to_branch(branch = "gh-pages", clean = TRUE, new_process = FALSE, install = TRUE)`.
  **Só com `git status` limpo.** Com `new_process = TRUE` o subprocesso
  do callr morre na vinheta `comparison`. Se o branch remoto não
  existir, o pkgdown faz `checkout --orphan` + `git rm -rf .` no repo
  principal e apaga edições não commitadas (aconteceu em 2026-09-25).
- Favicons: `pkgdown::build_favicons(overwrite = TRUE)` (usa
  realfavicongenerator.net) depois de trocar o logo em `man/figures/`.

## Comportamentos decididos na 0.1.1 (não “consertar” de volta)

- Registros DBF apagados (`*`) são descartados; `n_max` conta só
  registros vivos.
- Cache: `<cache>/<source>/<file_type>/<period>/<file_name>`; download
  vai para `.part` e é renomeado no sucesso.
  [`datasus_download()`](https://strategicprojects.github.io/datasusr/reference/datasus_download.md)
  devolve `success`/`error`.
- [`datasus_fetch()`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)
  prefere o arquivo final ao preliminar (inclui aliases
  `SINAN_P`/`ESUSNOTIFICA_P`); um final com `exists = NA` não suprime um
  preliminar confirmado. Um final confirmado que falha no download
  **não** cai para o preliminar (limitação documentada).
- `timeout` padrão `Inf`; transferências paradas são cortadas por
  `low_speed_limit`.
- DOEXT/DOINF/DOMAT ficam mesmo no diretório `DOFET` da FTP (verificado
  ao vivo).
- Limitação aceita: `ftell()`/`long` limita arquivos a 2 GB no Windows.

## Revisão com agentes (fluxo usado em 2026-09-25)

Auditoria por Opus 5.5 (Agent, `model: opus`) + Codex CLI
(`codex exec --skip-git-repo-check -m gpt-6-astra -c model_reasoning_effort=medium --sandbox workspace-write -C <scratch> -o out.md "$(cat prompt.md)" < /dev/null`;
sem `< /dev/null` ele trava lendo stdin). Correções por dois agentes
Opus com arquivos disjuntos (C + wrapper / R + vinhetas), validação
própria, e Codex no fim. Relatórios ficaram no scratchpad da sessão
(efêmero); o resumo está em `NEWS.md` 0.1.1.

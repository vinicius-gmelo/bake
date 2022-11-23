# Bake
Cria backups no Linux, em `/tmp` e no formato .tar.gz. Compatível com POSIX. O root dir, diretório raiz para backups, pode ser setado com `bake set`.
## Requerimentos
Clonar o repositório ou baixar o script, habilitando a execução com `chmod +x bake.sh`. Para executar como um comando do shell, `mv bake.sh bake; mv bake $HOME/.local/bin` (ou `$HOME/.bin`, ou o diretório de scripts do usuário).
## Uso
```sh
$ bake set # seta o root dir
$ bake unset
$ bake what # mostra o diretório em que o backup será executado; root dir ou atual
$ bake # gera o backup
```

# Biblioteca da Preguica

## Informacoes do Projeto

**Curso:** Tecnico em Desenvolvimento de Sistemas  
**Unidade Curricular:** Programacao para Dispositivos Moveis  

## Alunos

| Nome | GitHub |
|------|--------|
| Otavio Augusto | https://github.com/xThinksilverx|
|Caio David Brito KarolkonC | https://github.com/caiobritzig
|Galdino | https://github.com/HenriqueGaldino

## Descricao

Aplicativo mobile desenvolvido em Flutter para busca e organizacao de livros. O usuario pode pesquisar livros pelo titulo, autor, palavras-chave ou genero, visualizar detalhes de cada obra e salvar seus favoritos em uma conta pessoal.

## Tecnologias Utilizadas

| Tecnologia | Finalidade |
|---|---|
| Flutter 3.x | Framework principal para desenvolvimento mobile |
| Dart | Linguagem de programacao |
| Open Library API | Fonte de dados para busca de livros |
| SQFlite | Banco de dados local SQLite para usuarios e favoritos |
| Shared Preferences | Persistencia da sessao do usuario logado |
| HTTP | Requisicoes para a API de livros |
| Cached Network Image | Cache de imagens de capas dos livros |
| Crypto (SHA-256) | Hash seguro das senhas dos usuarios |
| Material Design 3 | Sistema de design da interface |

## Funcionalidades

- **Autenticacao local:** cadastro e login de usuarios com senhas armazenadas com hash SHA-256
- **Busca de livros:** pesquisa por titulo, autor, palavras-chave gerais ou genero via Open Library API
- **Paginacao automatica:** carregamento de mais resultados ao rolar a lista
- **Detalhes do livro:** capa em alta resolucao, descricao, generos, editora, ano e idioma
- **Favoritos por conta:** cada usuario tem sua propria lista de favoritos salva no banco local
- **Remocao de favoritos:** via botao ou gesto de deslizar (swipe) na lista com opcao de desfazer
- **Indicadores de loading e erro:** feedback visual durante carregamento e em caso de falha de conexao
- **Busca limpa:** botao para reiniciar a consulta

## Estrutura do Projeto

```
lib/
  main.dart                  - Entrada do aplicativo e configuracao do tema
  theme/
    app_theme.dart           - Paleta de cores e tema escuro
  models/
    book.dart                - Modelo de livro com serialization JSON
    user.dart                - Modelo de usuario
  services/
    api_service.dart         - Integracao com a Open Library API
    auth_service.dart        - Autenticacao e gestao de sessao
    database_service.dart    - Banco de dados SQLite (usuarios e favoritos)
    favorites_service.dart   - Operacoes de favoritos
  screens/
    splash_screen.dart       - Tela de abertura com verificacao de sessao
    login_screen.dart        - Tela de login
    register_screen.dart     - Tela de cadastro
    home_screen.dart         - Tela principal com busca
    book_detail_screen.dart  - Tela de detalhes do livro
    favorites_screen.dart    - Tela de livros favoritos
  widgets/
    book_card.dart           - Card reutilizavel para exibir livros
    empty_state_widget.dart  - Componente para estados vazios e erros
assets/
  images/
    preguica.jpg             - Icone do aplicativo
```

## Como Instalar e Executar

### Pre-requisitos

- Flutter SDK 3.x instalado
- Android Studio ou VS Code com extensao Flutter
- Dispositivo Android ou emulador configurado

### Passos

```bash
# 1. Clone o repositorio
git clone https://github.com/xThinksilverx/biblioteca_da_preguica

# 2. Acesse a pasta do projeto
cd biblioteca_da_preguica

# 3. Instale as dependencias
flutter pub get

# 4. Execute o aplicativo
flutter run
```

## API Utilizada

**Open Library** - https://openlibrary.org/

- Busca: `GET /search.json?q={query}&fields=...&limit=20&offset={offset}`
- Detalhes: `GET /works/{id}.json`
- Capas: `https://covers.openlibrary.org/b/id/{cover_id}-M.jpg`

A API e publica, gratuita e nao requer autenticacao.

## Armazenamento Local

O aplicativo utiliza SQLite (via SQFlite) com duas tabelas:

- **users** - nome de usuario, email e hash da senha
- **favorites** - referencia ao usuario, chave do livro e dados serializados em JSON

A sessao ativa e mantida via Shared Preferences.


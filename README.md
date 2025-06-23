# Semestre5-Mobile
Repositório para desenvolvimento do software GWI News, para o cumprimento do Projeto Transdisciplinar do curso Desenvolvimento de Software Multiplataforma, na faculdade Fatec Matão - Luiz Marchesan.

---

## Documentação do arquivo `main.dart`

O arquivo `main.dart` é o ponto de entrada da aplicação Flutter **GWI News**. Ele é responsável por inicializar o Firebase e configurar todas as rotas principais do aplicativo, incluindo páginas de dashboard, perfis de usuário, gerenciamento de notícias e usuários.

### Estrutura

- **Importações**
  - `flutter/material.dart`: Biblioteca principal do Flutter para construção da interface.
  - `firebase_core.dart`: Necessário para inicializar o Firebase.
  - Páginas do app: Importa todas as páginas principais, como dashboard, perfis, gerenciamento, etc.
  - `firebase_options.dart`: Configurações do Firebase geradas automaticamente.

### Função principal

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}
```
- Garante a inicialização dos bindings do Flutter.
- Inicializa o Firebase com as opções da plataforma.
- Executa o widget principal `MyApp`.

### Classe MyApp

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GWI News',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const NewsDashboardPage(),
        '/home': (context) => const NewsDashboardPage(),
        '/sobre': (context) => const AboutUsPage(),
        '/faq': (context) => const FaqPage(),
        '/perfil/adm': (context) => const AdmProfilePage(),
        '/perfil/autor': (context) => const AuthorProfilePage(),
        '/perfil/leitor': (context) => const ReaderProfilePage(),
        '/perfil/adm/gerenciamento-noticias':
            (context) => const NewsManagementPage(),
        '/perfil/adm/gerenciamento-noticias/criacao-noticia':
            (context) => const NewsCreatePage(),
        '/perfil/adm/gerenciamento-noticias/edicao-noticia': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return NewsUpdatePage(newsId: args['newsId']);
        },
        '/perfil/adm/gerenciamento-usuarios':
            (context) => const UserManagementPage(),
      },
    );
  }
}
```

#### Propriedades do MaterialApp

- **title**: Define o título do app.
- **debugShowCheckedModeBanner**: Esconde a faixa de debug.
- **initialRoute**: Define a rota inicial como `'/'`.
- **routes**: 
  - `'/'`: Página inicial, carrega `NewsDashboardPage`.
  - `'/home'`: Também carrega `NewsDashboardPage`.
  - `'/sobre'`: Página "Sobre Nós".
  - `'/faq'`: Página de perguntas frequentes.
  - `'/perfil/adm'`: Página de perfil do administrador.
  - `'/perfil/autor'`: Página de perfil do autor.
  - `'/perfil/leitor'`: Página de perfil do leitor.
  - `'/perfil/adm/gerenciamento-noticias'`: Página de gerenciamento de notícias.
  - `'/perfil/adm/gerenciamento-noticias/criacao-noticia'`: Página de criação de notícia.
  - `'/perfil/adm/gerenciamento-noticias/edicao-noticia'`: Página de edição de notícia (recebe argumento `newsId`).
  - `'/perfil/adm/gerenciamento-usuarios'`: Página de gerenciamento de usuários.

---

## Documentação do arquivo `news_dashboard_page.dart`

O arquivo `news_dashboard_page.dart` é responsável pela tela principal do dashboard de notícias do sistema **GWI News**. Ele exibe o carrossel de notícias em destaque, os cards das demais notícias, barra de busca, filtro de notícias, header e navbar.

### Estrutura

- **Importações**
  - Widgets customizados: `Header`, `Navbar`, `NewsCard`, `NewsSearchBar`, `NewsFilter`, `NewsCarousel`
  - Firebase: Para buscar as notícias do Firestore

### Classe `NewsDashboardPage`

- **StatefulWidget**: Permite atualização dinâmica da tela conforme filtros e buscas.

#### Principais propriedades e métodos

- `_newsFuture`: Future que armazena a lista de notícias buscadas do Firestore.
- `_showNewsFilter`: Controla a exibição do filtro lateral.
- `fetchAllNews()`: Função que busca todas as notícias do Firestore, ordenadas por data de publicação (e pode ser expandida para outros critérios).
- `simulatedCarouselNews`: Lista mockada de notícias para testes do carrossel (pode ser removida quando o carrossel usar dados reais).

#### Método `build`

- Calcula tamanhos responsivos para header, navbar e padding.
- Usa um `FutureBuilder` para aguardar o carregamento das notícias.
- **Renderização:**
  - Os 5 primeiros itens da lista de notícias são exibidos no `NewsCarousel`.
  - Os demais itens são exibidos como cards (`NewsCard`) em um `Wrap`.
  - Exibe barra de busca (`NewsSearchBar`) e filtro lateral (`NewsFilter`).
  - O filtro pode ser aberto/fechado via callback do `Navbar`.
  - O header é fixo no topo da tela.

#### Exemplo de uso do carrossel e cards

```dart
final carouselItems = newsList.take(5).toList();
final cardItems = newsList.skip(5).toList();

return Column(
  children: [
    if (carouselItems.isNotEmpty)
      NewsCarousel(items: carouselItems),
    const SizedBox(height: 16),
    if (cardItems.isNotEmpty)
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: cardItems.map((newsItem) {
          return NewsCard(
            newsItem: newsItem,
            categoryName: newsItem['category'] ?? '',
            subcategoriesNames: newsItem['subcategories'] ?? '',
            onTap: () {},
          );
        }).toList(),
      ),
  ],
);
```

### Observações

- O arquivo é totalmente responsivo, adaptando o layout para diferentes larguras de tela.
- O filtro lateral pode ser aberto e fechado, e ocupa 50% da tela em telas maiores.
- O carrossel e os cards são atualizados conforme os dados retornados do Firestore.
- O código está preparado para integração com filtros e busca dinâmica.

---

## Documentação do arquivo `news_page.dart`

O arquivo `news_page.dart` é responsável por exibir a página de detalhes de uma notícia selecionada no sistema **GWI News**. Ele apresenta o conteúdo completo da notícia, incluindo título, subtítulo, imagem, texto, autor, editor, data de publicação, categoria e subcategorias.

### Estrutura

- **Importações**
  - `flutter/material.dart`: Biblioteca principal do Flutter para construção da interface.
  - `cloud_firestore.dart`: Para buscar os dados da notícia no Firestore.
  - Widgets customizados: `Header`, `Navbar`.

### Classe `NewsPage`

- **StatefulWidget**: Permite atualização dinâmica da tela conforme o carregamento da notícia.

#### Propriedades

- `newsCategory`: Categoria da notícia (string).
- `newsSubcategories`: Subcategorias da notícia (string).
- `newsId`: ID do documento da notícia no Firestore (string).

#### Estado

- `newsItem`: Mapa com os dados da notícia buscada.
- `isLoading`: Indica se a notícia está sendo carregada.

#### Principais métodos

- `fetchNewsItem()`: Busca o documento da notícia no Firestore usando o `newsId` e atualiza o estado.
- `formatDate(Timestamp?)`: Formata a data de publicação para o padrão "dd de mês de aaaa".
- `splitTextContent(String?)`: Divide o texto da notícia em parágrafos para melhor apresentação.
- `_capitalize(String?)`: Capitaliza a primeira letra de uma string.

#### Método `build`

- Calcula tamanhos responsivos para header, navbar e padding.
- Exibe um `CircularProgressIndicator` enquanto carrega a notícia.
- Se a notícia não for encontrada, exibe uma mensagem de erro.
- Se encontrada, exibe:
  - Título em destaque.
  - Subtítulo (se houver).
  - Texto da notícia dividido em parágrafos.
  - Imagem principal (se houver).
  - Informações adicionais: categoria, subcategorias, autor, editor e data de publicação.
- Inclui o `Header` e o `Navbar` fixos na tela.

#### Exemplo de uso

A navegação para esta página é feita passando os parâmetros necessários:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => NewsPage(
      newsCategory: news['category'] ?? '',
      newsSubcategories: news['subcategories'] ?? '',
      newsId: news['id'],
    ),
  ),
);
```

### Observações

- O arquivo é totalmente responsivo, adaptando o layout para diferentes larguras de tela.
- O conteúdo da notícia é carregado dinamicamente do Firestore.
- O texto é formatado para melhor legibilidade, com parágrafos e destaque para informações importantes.
- O código está preparado para lidar com erros de carregamento e ausência de dados.

---

## Documentação do arquivo `header.dart`

O arquivo `header.dart` define o widget `Header`, responsável por exibir o cabeçalho fixo do sistema **GWI News** em todas as páginas da aplicação.

### Estrutura

- **Importações**
  - `flutter/material.dart`: Biblioteca principal do Flutter para construção da interface.
  - `flutter_svg/flutter_svg.dart`: Permite renderizar imagens SVG, utilizada para o logo.

### Classe `Header`

- **StatelessWidget**: O cabeçalho não possui estado interno.

#### Responsividade

- O widget ajusta automaticamente o tamanho, alinhamento e padding do cabeçalho de acordo com a largura da tela:
  - **≤ 576px**: O header ocupa toda a largura, centralizado.
  - **≤ 992px**: O header ocupa 40% da largura, alinhado à esquerda com padding menor.
  - **> 992px**: O header ocupa 60% da largura, alinhado à esquerda com padding maior.

#### Elementos

- **Logo**: Exibido como SVG (`assets/GwiNewsLogo.svg`), com tamanho máximo proporcional ao header.
- **Barra inferior**: Linha azul (cor `#1D4988`) com 4px de altura, reforçando a identidade visual.
- **Navegação**: O logo é clicável e executa `Navigator.of(context).maybePop()`, permitindo voltar para a tela anterior se possível.

#### Exemplo de uso

O widget é utilizado diretamente nas páginas principais, por exemplo:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // ...outros widgets...
        const Header(),
      ],
    ),
  );
}
```

### Observações

- O header é totalmente responsivo e mantém a identidade visual do sistema.
- O logo deve estar disponível em `assets/GwiNewsLogo.svg` e o caminho deve estar registrado no `pubspec.yaml`.
- O cabeçalho é fixo e recomendado para uso em todas as páginas principais do app.

---

## Documentação do arquivo `navbar.dart`

O arquivo `navbar.dart` define o widget `Navbar`, responsável por exibir a barra de navegação inferior (em dispositivos móveis) ou superior (em telas maiores) do sistema **GWI News**.

### Estrutura

- **Importações**
  - `flutter/material.dart`: Biblioteca principal do Flutter para construção da interface.

### Classe `Navbar`

- **StatelessWidget**: Não possui estado interno, apenas recebe callbacks.
- **Propriedades**:
  - `onFilterTap`: Callback opcional para acionar a abertura do filtro de notícias.

#### Responsividade

- O widget ajusta automaticamente largura, altura, alinhamento e bordas conforme a largura da tela:
  - **≤ 576px**: Barra fixa na parte inferior, ocupa toda a largura.
  - **≤ 992px**: Barra superior à direita, ocupa 60% da largura.
  - **> 992px**: Barra superior à direita, ocupa 40% da largura.

#### Elementos

- **Ícones de navegação**:
  - Home: Navega para a rota `/home`.
  - Filtro: Executa o callback `onFilterTap` para abrir o filtro lateral.
  - Sobre: Placeholder para informações sobre o app.
  - Perfil: Placeholder para perfil do usuário.
- Cada ícone possui rótulo e efeito visual ao passar o mouse (hover), com destaque azul e borda arredondada.
- O cursor vira pointer ao passar sobre os ícones, indicando que são clicáveis.

#### Classe auxiliar `_NavbarIcon`

- Widget customizado para cada ícone da barra.
- Implementa efeito de hover, animação e estilização consistente com a identidade visual do sistema.

#### Exemplo de uso

O widget é utilizado diretamente nas páginas principais, por exemplo:

```dart
Navbar(
  onFilterTap: () {
    setState(() {
      _showNewsFilter = true;
    });
  },
),
```

### Observações

- O `Navbar` é totalmente responsivo e mantém a identidade visual do sistema.
- O botão de filtro utiliza o callback passado para abrir o filtro lateral.
- Os ícones e rótulos seguem o padrão de cores do sistema (`#1D4988`).
- O componente é recomendado para uso em todas as páginas principais do app.

---

## Documentação do arquivo `news_carousel.dart`

O arquivo `news_carousel.dart` define o widget `NewsCarousel`, responsável por exibir um carrossel de notícias em destaque no sistema **GWI News**.

### Estrutura

- **Importações**
  - `flutter/material.dart`: Biblioteca principal do Flutter para construção da interface.
  - `semestre5_mobile/pages/news_page.dart`: Página de detalhes da notícia.

### Classe `NewsCarousel`

- **StatefulWidget**: Permite atualização dinâmica do carrossel conforme o usuário navega entre os itens.
- **Propriedades**:
  - `items`: Lista de mapas (`List<Map<String, dynamic>>`) contendo os dados das notícias a serem exibidas no carrossel.

#### Principais funcionalidades

- **Navegação por setas**: O carrossel possui botões de seta à esquerda e à direita, permitindo ao usuário navegar entre os itens. As setas só aparecem quando há item anterior ou posterior.
- **Indicadores de página**: Pequenos círculos na parte inferior indicam qual item está sendo exibido.
- **Responsividade**: O tamanho dos itens do carrossel é aumentado em 10% em relação ao padrão, garantindo destaque visual.
- **Acessibilidade**: O título da notícia é envolvido por um `MouseRegion` com cursor pointer, indicando que é clicável.
- **Navegação para detalhes**: Ao clicar no título, o usuário é direcionado para a página de detalhes da notícia (`NewsPage`), com os dados do item selecionado.
- **Estilo visual**:
  - Imagem principal da notícia (`url_image`) como fundo do item.
  - Título sobreposto na parte inferior, com fundo preto translúcido e texto branco.
  - Setas de navegação com fundo azul (`#1D4988`) e 50% de transparência, ícone branco.

#### Exemplo de uso

O widget é utilizado na página principal para exibir os 5 primeiros itens da lista de notícias:

```dart
final carouselItems = newsList.take(5).toList();

NewsCarousel(items: carouselItems),
```

#### Exemplo de item esperado

```dart
{
  'id': '1',
  'title': 'Banco do Brasil Anuncia Abertura de Novas Vagas',
  'url_image': 'https://link-da-imagem.jpg',
  'category': 'Empregos',
  'subcategories': 'Bancos',
  'alt_image': 'Imagem do Banco do Brasil',
}
```

### Observações

- O carrossel não faz requisições ao banco de dados; recebe os dados prontos via parâmetro.
- O componente é totalmente responsivo e visualmente integrado ao padrão do sistema.
- O carrossel é recomendado para exibir notícias em destaque na tela inicial do app.

---

## Documentação do arquivo `news_card.dart`

O arquivo `news_card.dart` define o widget `NewsCard`, responsável por exibir uma notícia individual em formato de card no sistema **GWI News**.

### Estrutura

- **Importações**
  - `flutter/material.dart`: Biblioteca principal do Flutter para construção da interface.
  - `semestre5_mobile/pages/news_page.dart`: Página de detalhes da notícia.

### Classe `NewsCard`

- **StatefulWidget**: Permite animação de hover e interação do usuário.
- **Propriedades**:
  - `newsItem`: Mapa (`Map<String, dynamic>`) com os dados da notícia.
  - `categoryName`: Nome da categoria da notícia.
  - `subcategoriesNames`: Nome(s) das subcategorias da notícia.
  - `onTap`: Callback opcional para ação ao clicar no card.

#### Principais funcionalidades

- **Imagem de capa**: Exibe a imagem principal da notícia (`url_image`). Caso não exista ou não carregue, exibe um ícone e texto alternativo (`alt_image`).
- **Título**: Exibe o título da notícia em destaque, com limite de 2 linhas.
- **Animação de hover**: Ao passar o mouse sobre o card, ele se eleva e ganha sombra, indicando que é clicável.
- **Acessibilidade**: O card utiliza `MouseRegion` com cursor pointer.
- **Navegação para detalhes**: Ao clicar no card, o usuário é direcionado para a página de detalhes da notícia (`NewsPage`), passando os dados necessários.
- **Responsividade**: O card possui tamanho máximo definido e se adapta ao layout responsivo do sistema.

#### Exemplo de uso

O widget é utilizado em um `Wrap` para exibir várias notícias na tela principal:

```dart
Wrap(
  alignment: WrapAlignment.center,
  spacing: 8,
  runSpacing: 8,
  children: newsList.map((newsItem) {
    return NewsCard(
      newsItem: newsItem,
      categoryName: newsItem['category'] ?? '',
      subcategoriesNames: newsItem['subcategories'] ?? '',
      onTap: () {},
    );
  }).toList(),
)
```

#### Exemplo de item esperado

```dart
{
  'id': '1',
  'title': 'Banco do Brasil Anuncia Abertura de Novas Vagas',
  'url_image': 'https://link-da-imagem.jpg',
  'alt_image': 'Imagem do Banco do Brasil',
  // ... outros campos ...
}
```

### Observações

- O card é totalmente responsivo e visualmente integrado ao padrão do sistema.
- O componente é recomendado para exibir notícias em listas ou grades na tela inicial e em resultados de busca/filtro.
- O título e a imagem são destacados para melhor experiência do usuário.
- O card lida com falhas de carregamento de imagem de forma amigável.

---

## Documentação do arquivo `news_search_bar.dart`

O arquivo `news_search_bar.dart` define o widget `NewsSearchBar`, responsável por exibir e controlar a barra de busca de notícias no sistema **GWI News**.

### Estrutura

- **Importações**
  - `flutter/material.dart`: Biblioteca principal do Flutter para construção da interface.
  - `cloud_firestore/cloud_firestore.dart`: Para buscar notícias, categorias e subcategorias no Firestore.
  - `news_card.dart`: Para exibir os resultados da busca em formato de card.

### Classe `NewsSearchBar`

- **StatefulWidget**: Permite atualização dinâmica da barra de busca e dos resultados conforme o usuário digita.

#### Principais propriedades e estado

- `_controller`: Controlador do campo de texto da busca.
- `_searchBarDisplay`: Controla se a barra de busca está visível.
- `_searchTerm` e `_debouncedSearchTerm`: Termos de busca atuais e após debounce.
- `_searchNews`: Lista de notícias retornadas pela busca.
- `_resultSearch`: Indica se há resultados para a busca.
- `_newsCategories` e `_newsSubcategories`: Listas de categorias e subcategorias carregadas do Firestore.
- `_focusNode`: Gerencia o foco do campo de busca.

#### Principais métodos

- `_onSearchChanged()`: Atualiza o termo de busca e aciona o debounce.
- `_debounceSearch()`: Aguarda 750ms antes de buscar, evitando buscas excessivas.
- `_fetchNews()`: Realiza a busca no Firestore pelo campo `normalized_title`, limitado a 5 resultados.
- `_fetchNewsCategories()` e `_fetchNewsSubcategories()`: Carregam categorias e subcategorias do Firestore.
- `_verifyCategoryName(newsItem)`: Retorna o nome da categoria de uma notícia.
- `_verifySubcategoriesNames(newsItem)`: Retorna os nomes das subcategorias de uma notícia.

#### Método `build`

- Exibe um botão para abrir/fechar a barra de busca.
- Quando aberta, exibe um campo de texto com limite de 75 caracteres.
- Mostra os resultados da busca em cards (`NewsCard`) ou uma mensagem de "Nenhum Resultado Encontrado".
- O campo de busca é responsivo e estilizado conforme o padrão visual do sistema.

#### Exemplo de uso

O widget é utilizado na tela principal, geralmente no topo da página:

```dart
const NewsSearchBar(),
```

### Observações

- O campo de busca aceita no máximo 75 caracteres.
- A busca é feita pelo campo `normalized_title` para garantir resultados mesmo com acentuação ou variações.
- Os resultados são exibidos em cards, com nome de categoria e subcategorias resolvidos dinamicamente.
- O componente é totalmente responsivo e integrado ao padrão visual do sistema.

---

## Documentação do arquivo `news_filter.dart`

O arquivo `news_filter.dart` define o widget `NewsFilter`, responsável por exibir e controlar o filtro lateral de notícias no sistema **GWI News**.

### Estrutura

- **Importações**
  - `flutter/material.dart`: Biblioteca principal do Flutter para construção da interface.
  - `cloud_firestore/cloud_firestore.dart`: Para buscar categorias, subcategorias e notícias no Firestore.
  - `news_card.dart`: Para exibir os resultados filtrados em formato de card.

### Classe `NewsFilter`

- **StatefulWidget**: Permite atualização dinâmica do filtro conforme o usuário seleciona categorias e subcategorias.

#### Propriedades

- `showOffcanvas`: Booleano que controla a exibição do filtro lateral.
- `onClose`: Callback para fechar o filtro.

#### Estado

- `_categories`, `_subcategories`: Listas de categorias e subcategorias carregadas do Firestore.
- `_displayedCategories`, `_displayedSubcategories`: Listas paginadas para exibição.
- `_selectedCategories`, `_selectedSubcategories`: IDs das categorias e subcategorias selecionadas.
- `_filteredNews`: Lista de notícias filtradas.
- `_loadingCategories`, `_loadingSubcategories`, `_loadingNews`: Flags de carregamento.
- `_currentPage`, `_currentSubPage`: Controle de paginação para categorias e subcategorias.

#### Principais métodos

- `_fetchCategories()`, `_fetchSubcategories()`: Buscam e paginam categorias e subcategorias do Firestore.
- `_showNextCategories()`, `_showNextSubcategories()`: Carregam mais categorias/subcategorias ao clicar em "Mais categorias"/"Mais subcategorias".
- `_toggleCategory(id)`, `_toggleSubcategory(id)`: Selecionam/deselecionam categorias e subcategorias.
- `_filterNews()`: Busca notícias no Firestore de acordo com as categorias e subcategorias selecionadas.
- `capitalize(String)`: Capitaliza a primeira letra de cada palavra.

#### Método `build`

- Exibe o filtro como um painel lateral centralizado, com largura de 50% da tela em dispositivos maiores que 576px e responsivo em telas menores.
- Um fade escuro cobre o fundo, impedindo interação com o restante da tela enquanto o filtro está aberto.
- Exibe listas de categorias e subcategorias mais acessadas, com botões para carregar mais opções.
- Cada opção de categoria/subcategoria é clicável e exibe o cursor pointer.
- Botão "Filtrar" para aplicar o filtro e exibir os resultados.
- Exibe os resultados filtrados em cards (`NewsCard`).
- Caso não haja resultados, exibe uma mensagem amigável informando que nenhuma notícia foi encontrada para as categorias e/ou subcategorias selecionadas.
- Inclui botão para fechar o filtro.

#### Exemplo de uso

O widget é utilizado na tela principal, geralmente sobrepondo o conteúdo ao ser ativado:

```dart
NewsFilter(
  showOffcanvas: _showNewsFilter,
  onClose: () {
    setState(() {
      _showNewsFilter = false;
    });
  },
),
```

### Observações

- O filtro é totalmente responsivo e visualmente integrado ao padrão do sistema.
- O fade escuro impede interação com o fundo enquanto o filtro está aberto.
- O componente utiliza paginação para categorias e subcategorias, melhorando a usabilidade em grandes volumes de dados.
- O filtro pode ser facilmente expandido para incluir outros critérios de busca.

---

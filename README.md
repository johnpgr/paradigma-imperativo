# Controle de Estoque e Vendas

Atividade Avaliativa AV1 da disciplina Paradigmas de Programação (UNAMA). Prof. Rodrigo Medeiros Costa.

**Integrante:** João Paulo Greidinger dos Reis ([@johnpgr](https://github.com/johnpgr))

**Linguagem:** [Crystal](https://crystal-lang.org), com autorização do professor no lugar de C ou Python.

**Vídeo de demonstração:** LINK DO VÍDEO

**Contribuição dos integrantes:** trabalho individual. Análise, implementação, README e vídeo feitos por João Paulo Greidinger dos Reis.

## Descrição do problema

Uma pequena loja precisa controlar o estoque de seus produtos e as vendas realizadas. O programa roda no terminal e mantém os dados em memória durante a execução.

**Entradas**

- Teclas de navegação no menu: `j` (descer), `k` (subir), `Enter` (selecionar), `q` (sair).
- Dados do produto: nome, preço unitário e quantidade inicial.
- Código do produto e quantidade, nas operações de entrada, venda e remoção.

**Regras**

1. O código do produto é atribuído em sequência (1, 2, 3, ...).
2. O nome não pode ser vazio, o preço deve ser maior que zero e a quantidade inicial não pode ser negativa.
3. Uma entrada de estoque soma a quantidade recebida ao saldo. A quantidade deve ser maior que zero.
4. Uma venda só é aceita se a quantidade for maior que zero e não passar do saldo. Se for aceita, o saldo diminui e a venda é registrada com o seu valor total.
5. Um produto só pode ser removido quando o saldo é zero.
6. Na listagem, produtos com saldo menor ou igual a 5 aparecem em vermelho (alerta de estoque baixo).
7. Uma entrada numérica inválida (por exemplo, `abc`) é pedida de novo.

**Saídas**

- Listagem de produtos com código, nome, preço e saldo.
- Mensagem de sucesso (verde) ou de erro (vermelho) após cada operação.
- Relatório de vendas com cada venda, o total de itens vendidos e o valor total.

## Requisitos e execução

Requisito: Crystal 1.21.1 ou mais recente ([instalação](https://crystal-lang.org/install/)). O programa usa o modo raw do terminal, então deve ser executado em um terminal Linux ou macOS (no Windows, use o WSL).

```sh
git clone https://github.com/johnpgr/paradigma-imperativo
cd paradigma-imperativo
shards build
./bin/paradigma-imperativo
```

Para executar sem gerar o binário: `crystal run src/main.cr`.

## Organização do código

| Arquivo | Conteúdo |
|---|---|
| `src/main.cr` | Estado do programa (variáveis) e laço principal com o menu |
| `src/inventory.cr` | Tipos `Product` e `Sale` e os procedimentos de estoque e vendas |
| `src/terminal.cr` | Leitura de teclas, leitura de valores e exibição de mensagens |

## Explicação da solução

O programa é uma sequência de instruções dentro de um laço. A cada volta, ele desenha o menu com o estado atual, lê uma tecla, altera o estado conforme a tecla e repete. Todo o estado fica em quatro variáveis declaradas no início de `src/main.cr` (linhas 15 a 27):

```crystal
menu_selected = 0
menu_items = [
  {MenuAction::RegisterProduct, "Cadastrar produto"},
  {MenuAction::ListProducts, "Listar produtos"},
  # ...
]
products = [] of Product
sales = [] of Sale
```

Os procedimentos recebem essas variáveis como parâmetros e as alteram. Nenhum dado fica escondido em objetos.

### Sequência de instruções

O corpo do laço principal (`src/main.cr:32-118`) executa sempre na mesma ordem: (1) limpar a tela e desenhar o menu, (2) ler uma tecla, (3) executar a ação. Dentro de cada ação a ordem também é fixa. Por exemplo, ao registrar uma venda (`src/main.cr:92-95`), o programa lê o código, depois a quantidade, depois chama `register_sale` e por fim mostra o resultado.

### Variáveis, atribuição e alteração de estado

- `menu_selected` muda a cada tecla `j` ou `k` (`src/main.cr:51` e `:54`). O operador `%` faz a seleção voltar ao início quando passa do último item.
- `product.quantity += quantity` soma ao saldo na entrada de estoque (`src/inventory.cr:53`).
- `product.quantity -= quantity` diminui o saldo na venda (`src/inventory.cr:65`).
- `products << ...` e `sales << ...` acrescentam registros às listas (`src/inventory.cr:34` e `:66`).
- `products.delete(product)` remove um registro (`src/inventory.cr:91`).

`Product` é uma classe (`src/inventory.cr:3-11`) porque `product.quantity -= n` precisa alterar o produto que está guardado na lista. Com uma `struct`, `find_product` retornaria uma cópia, e a alteração seria perdida.

**Exemplo de alteração de estado:**

| Operação | `products` | `sales` |
|---|---|---|
| Início | `[]` | `[]` |
| Cadastrar "Caneta", R$ 2,50, 10 un. | `[{1, Caneta, 2.5, 10}]` | `[]` |
| Entrada de 5 un. do produto 1 | `[{1, Caneta, 2.5, 15}]` | `[]` |
| Venda de 4 un. do produto 1 | `[{1, Caneta, 2.5, 11}]` | `[{1, Caneta, 4, 10.0}]` |
| Venda de 20 un. do produto 1 | sem alteração ("Saldo insuficiente") | sem alteração |

### Estruturas de decisão

- `case read_key` escolhe o que fazer com a tecla lida (`src/main.cr:48-118`), e `case menu_items[menu_selected][0]` escolhe a ação do menu (`src/main.cr:64-115`).
- `if index == menu_selected` destaca o item selecionado (`src/main.cr:40`).
- `if product.quantity <= LOW_STOCK` mostra em vermelho os produtos com estoque baixo (`src/main.cr:78`).
- As regras de negócio são cláusulas de guarda com `return ... if`. Por exemplo, em `register_sale` (`src/inventory.cr:61-63`), cada condição falsa encerra o procedimento com uma mensagem de erro antes de alterar o estado:

```crystal
return "Produto não encontrado." unless product
return "A quantidade deve ser maior que zero." if quantity <= 0
return "Saldo insuficiente: #{product.quantity} em estoque." if quantity > product.quantity
```

### Estruturas de repetição

- `loop do ... end` é o laço principal do programa (`src/main.cr:32`). Ele termina com `break` quando o usuário aperta `q` ou escolhe "Sair" (`src/main.cr:57` e `:113`).
- `each_with_index` percorre os itens do menu para desenhá-los (`src/main.cr:39`).
- `find_product` faz uma busca linear: percorre a lista e retorna o primeiro produto com o código pedido (`src/inventory.cr:39-44`).
- `register_product` percorre a lista para achar o próximo código livre (`src/inventory.cr:29-32`).
- `sales_summary` usa dois acumuladores, `items` e `total`, que são atualizados a cada venda (`src/inventory.cr:72-82`).
- `prompt_int` e `prompt_float` repetem a pergunta até o usuário digitar um número válido (`src/terminal.cr:29-45`).

### Funções e procedimentos

| Procedimento | Arquivo | O que faz |
|---|---|---|
| `register_product` | `src/inventory.cr:24` | Valida os dados e acrescenta um produto |
| `find_product` | `src/inventory.cr:39` | Busca um produto pelo código |
| `register_entry` | `src/inventory.cr:47` | Soma uma quantidade ao saldo |
| `register_sale` | `src/inventory.cr:58` | Diminui o saldo e registra a venda |
| `sales_summary` | `src/inventory.cr:72` | Calcula os itens vendidos e o valor total |
| `remove_product` | `src/inventory.cr:85` | Remove um produto com saldo zero |
| `hide_cursor`, `show_cursor`, `clear_screen` | `src/terminal.cr:7-17` | Controlam visibilidade do cursor e limpeza de tela |
| `read_key`, `wait_for_key` | `src/terminal.cr:20` e `:47` | Leem uma tecla sem esperar o Enter |
| `prompt`, `prompt_int`, `prompt_float` | `src/terminal.cr:24-45` | Leem um texto ou um número |
| `print_result` | `src/terminal.cr:52` | Mostra a mensagem de sucesso ou de erro |

Os procedimentos que alteram o estado retornam `String?`: uma mensagem de erro, ou `nil` quando a operação é realizada. Assim, `main.cr` trata o resultado de todas as operações da mesma forma, com `print_result`.

## Reflexão

**Decisões**

- Usei Crystal porque a sintaxe é próxima de Python e o programa é compilado com tipos verificados, como em C.
- O modo raw do terminal é ativado só para ler uma tecla do menu. Os formulários usam a leitura de linha comum, então não foi necessário escrever um editor de linha.
- As regras ficam em procedimentos separados da interface (`inventory.cr`). Cada procedimento recebe as listas como parâmetros, assim fica claro qual estado cada operação altera.
- A venda guarda o seu valor total no momento em que é feita, para que o relatório não mude se o preço do produto mudar depois.
- Os dados ficam só em memória, para manter o foco nos conceitos do paradigma imperativo.

**Dificuldades**

- No modo raw, `Enter` envia `\r` e não `\n`, e a quebra de linha não volta o cursor ao início. Por isso o modo raw ficou restrito à leitura de uma tecla.
- Com `Product` como `struct`, alterar o saldo de um produto encontrado na lista não tinha efeito, porque a alteração era feita em uma cópia. A solução foi usar uma classe.
- Garantir que o cursor do terminal volte a aparecer quando o programa termina com `Ctrl+C` (`Process.on_terminate` e `at_exit` em `src/main.cr:29-30`).

**Melhorias possíveis**

- Salvar os dados em arquivo para não perdê-los ao fechar o programa.
- Buscar produtos pelo nome.
- Alterar o preço e o nome de um produto.
- Registrar a data de cada venda e mostrar o relatório por período.

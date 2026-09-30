# Projeto: Sistema de controle de estoque e vendas
#
# entidades: Produto, Saldo, Venda
# transformations:
#   - saida, entrada, cadastro
# actions:
#   - consulta de saldo, calculo do valor das vendas
require "colorize"

HIDE_CURSOR  = "\e[?25l"
SHOW_CURSOR  = "\e[?25h"
CLEAR_SCREEN = "\e[2J\e[H"
NEWLINE      = "\r\n"

selected = 0
items = ["Adicionar", "Listar", "Remover", "Sair"]

begin
  print HIDE_CURSOR
  STDIN.raw do
    loop do
      # 1. Desenhar a tela baseado no estado atual
      print CLEAR_SCREEN

      items.each_with_index do |item, index|
        if index == selected
          print "> #{item}".colorize(:green)
        else
          print "  #{item}"
        end

        print NEWLINE
      end

      # 2. Ler o input
      key = STDIN.read_char
      case key
      when 'j'
        selected = (selected + 1) % items.size
      when 'k'
        selected = (selected - 1) % items.size
      when 'q', '\u{3}'
        break
      end

      # executar acao
    end
  end
ensure
  print SHOW_CURSOR
end

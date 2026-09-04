# Sistema de Aluguel de Carros

Projeto da disciplina de Banco de Dados — modelagem e implementação de um
banco de dados relacional em PostgreSQL.

## Tema
Sistema de aluguel de veículos voltado para motoristas de aplicativo.

## Objetivo geral
Modelar e implementar um banco de dados que controle o cadastro de veículos,
clientes e atendentes, além do registro dos contratos de locação, garantindo
a integridade dos dados por meio de chaves primárias, chaves estrangeiras e
demais restrições de integridade.

## Público-alvo
Empresas de aluguel de veículos que atendem motoristas de aplicativo
(Uber, 99, iFood) e os próprios motoristas que precisam de um veículo para
trabalhar sem possuir um carro próprio.

## Escopo
- **Pessoas:** cadastro único que diferencia cliente e atendente, permitindo
  que um mesmo atendente também seja cliente.
- **Veículos:** placa, marca, modelo e tipo (moto, caminhão, carro de passeio).
- **Clientes:** CPF, nome, sobrenome, endereço, dados bancários e e-mail.
- **Contratos:** número, data, tipo de pagamento (cartão, PIX), cliente
  associado, veículo alugado e período de vigência.

## Modelo de dados
_Em construção — será adicionado na próxima etapa._

## Estrutura do repositório

| Pasta | Conteúdo |
|-------|----------|
| `scripts/` | Scripts SQL de DDL e DML |
| `docs/` | Diagrama do modelo de dados |

## Tecnologias
- PostgreSQL
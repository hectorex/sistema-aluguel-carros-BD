-- Atualizar o tipo ou observação de um veículo
UPDATE veiculos
SET tipo = 'Carro de passeio'
WHERE placa = 'ABC1D23';

-- Atualizar a data de término do contrato (renovação do aluguel)
UPDATE contratos
SET data_fim = '2026-10-15'
WHERE numero_contrato = 'CTR-2026-001';

-- Atualizar dados bancários e endereço de um cliente
UPDATE pessoas
SET endereco = 'Av. Sete de Setembro, 1000',
    dados_bancarios = 'Nubank, Ag 0001, Conta 9988776-5'
WHERE cpf = '12345678901';

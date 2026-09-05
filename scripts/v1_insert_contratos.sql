-- Inserir contrato com pagamento via PIX
INSERT INTO contratos (numero_contrato, data_contrato, tipo_pagamento, id_cliente, id_veiculo, data_inicio, data_fim)
VALUES ('CTR-2026-001', '2026-09-01', 'PIX', 1, 1, '2026-09-01', '2026-09-30')
ON CONFLICT (numero_contrato) DO NOTHING;

-- Inserir contrato com pagamento via Cartão
INSERT INTO contratos (numero_contrato, data_contrato, tipo_pagamento, id_cliente, id_veiculo, data_inicio, data_fim)
VALUES ('CTR-2026-002', '2026-09-05', 'Cartão', 3, 2, '2026-09-05', '2026-09-20')
ON CONFLICT (numero_contrato) DO NOTHING;

-- Contrato com pagamento via PIX feito por um ATENDENTE que também é CLIENTE
INSERT INTO contratos (numero_contrato, data_contrato, tipo_pagamento, id_cliente, id_veiculo, data_inicio, data_fim)
VALUES ('CTR-2026-003', '2026-08-01', 'PIX', 3, 3, '2026-08-01', '2026-08-15')
ON CONFLICT (numero_contrato) DO NOTHING;

-- Contrato antigo já finalizado
INSERT INTO contratos (numero_contrato, data_contrato, tipo_pagamento, id_cliente, id_veiculo, data_inicio, data_fim)
VALUES ('CTR-2026-004', '2026-01-10', 'Cartão', 4, 1, '2026-01-10', '2026-01-20')
ON CONFLICT (numero_contrato) DO NOTHING;

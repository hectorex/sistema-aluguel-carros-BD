-- Inserir um cliente comum
INSERT INTO pessoas (cpf, nome, sobrenome, endereco, dados_bancarios, email, eh_cliente, eh_atendente)
VALUES ('12345678901', 'Carlos', 'Silva', 'Rua das Flores, 123', 'Banco do Brasil, Ag 1234, CC 56789-0', 'carlos.silva@email.com', TRUE, FALSE)
ON CONFLICT (cpf) DO NOTHING;

-- Inserir um atendente da locadora
INSERT INTO pessoas (cpf, nome, sobrenome, endereco, dados_bancarios, email, eh_cliente, eh_atendente)
VALUES ('98765432100', 'Mariana', 'Souza', 'Av. Central, 456', 'Bradesco, Ag 4321, CC 98765-4', 'mariana.atendimento@locadora.com', FALSE, TRUE)
ON CONFLICT (cpf) DO NOTHING;

-- Inserir um atendente que TAMBÉM é cliente
INSERT INTO pessoas (cpf, nome, sobrenome, endereco, dados_bancarios, email, eh_cliente, eh_atendente)
VALUES ('45678912300', 'Lucas', 'Mendes', 'Rua Brasil, 789', 'Caixa, Ag 1111, CC 22222-3', 'lucas.mendes@email.com', TRUE, TRUE)
ON CONFLICT (cpf) DO NOTHING;

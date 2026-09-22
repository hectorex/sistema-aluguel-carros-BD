-- ############################################################################
-- SISTEMA DE ALUGUEL DE CARROS — SCRIPT COMPLETO
--
-- Alunos: Celso Hector, Daniel Lins, Nicolas Araujo
-- Turma:  Banco de Dados 2026 - G2
--
-- Este arquivo reune, na ordem de execucao, todo o conteudo que antes estava
-- dividido nos scripts V1 a V8, mais a Fase 2 (gamificacao dos atendentes).
--
-- O script inteiro pode ser executado quantas vezes for necessario sem erro:
-- o DDL usa CREATE TABLE / CREATE INDEX IF NOT EXISTS, as cargas usam
-- ON CONFLICT ... DO NOTHING e a chave estrangeira nova so e criada se ainda
-- nao existir.
--
-- ORDEM DO ARQUIVO
--   PARTE 1 — DDL: criacao das tabelas base
--   PARTE 2 — DML: carga de dados
--   PARTE 3 — DML: validacao de UPDATE e DELETE
--   PARTE 4 — FASE 2: DDL da gamificacao
--   PARTE 5 — FASE 2: carga de exemplo da gamificacao
-- ############################################################################



-- ############################################################################
-- PARTE 1 — DDL: CRIACAO DAS TABELAS BASE
-- ############################################################################

-- =====================================================================
-- V1__create_table_pessoas.sql
-- Cadastro unico de pessoas.
-- Uma mesma pessoa pode ser cliente, atendente ou ambos, controlado
-- pelas flags eh_cliente e eh_atendente. Evita CPF duplicado em
-- tabelas separadas.
-- =====================================================================

CREATE TABLE IF NOT EXISTS pessoas (
    id_pessoa       SERIAL       PRIMARY KEY,
    cpf             CHAR(11)     NOT NULL UNIQUE,
    nome            VARCHAR(60)  NOT NULL,
    sobrenome       VARCHAR(80)  NOT NULL,
    endereco        VARCHAR(150) NOT NULL,
    dados_bancarios VARCHAR(120),
    email           VARCHAR(120) NOT NULL UNIQUE,
    eh_cliente      BOOLEAN      NOT NULL DEFAULT FALSE,
    eh_atendente    BOOLEAN      NOT NULL DEFAULT FALSE,

    -- CPF deve conter exatamente 11 digitos numericos
    CONSTRAINT chk_pessoas_cpf_numerico
        CHECK (cpf ~ '^[0-9]{11}$'),

    -- E-mail precisa ter formato minimamente valido
    CONSTRAINT chk_pessoas_email_formato
        CHECK (email LIKE '%_@_%.__%'),

    -- Toda pessoa cadastrada precisa ter ao menos um papel
    CONSTRAINT chk_pessoas_possui_papel
        CHECK (eh_cliente OR eh_atendente)
);

-- Indice para consultas por papel (ex.: listar apenas clientes)
CREATE INDEX IF NOT EXISTS idx_pessoas_eh_cliente   ON pessoas (eh_cliente);
CREATE INDEX IF NOT EXISTS idx_pessoas_eh_atendente ON pessoas (eh_atendente);

COMMENT ON TABLE  pessoas               IS 'Cadastro unico de clientes e atendentes da locadora';
COMMENT ON COLUMN pessoas.eh_cliente    IS 'TRUE quando a pessoa pode assinar contratos de locacao';
COMMENT ON COLUMN pessoas.eh_atendente  IS 'TRUE quando a pessoa e funcionaria da locadora';


-- =====================================================================
-- V2__create_table_veiculos.sql
-- Frota disponivel para locacao.
-- Aceita placa no padrao antigo (AAA9999) e no padrao Mercosul (AAA9A99).
-- =====================================================================

CREATE TABLE IF NOT EXISTS veiculos (
    id_veiculo SERIAL      PRIMARY KEY,
    placa      VARCHAR(7)  NOT NULL UNIQUE,
    marca      VARCHAR(40) NOT NULL,
    modelo     VARCHAR(60) NOT NULL,
    tipo       VARCHAR(20) NOT NULL,

    -- Dominio fechado de tipos previsto no escopo do projeto
    CONSTRAINT chk_veiculos_tipo
        CHECK (tipo IN ('Moto', 'Caminhão', 'Carro de passeio')),
    -- Placa antiga AAA9999 ou Mercosul AAA9A99
    CONSTRAINT chk_veiculos_placa_formato
        CHECK (placa ~ '^[A-Z]{3}[0-9][0-9A-Z][0-9]{2}$')
);

CREATE INDEX IF NOT EXISTS idx_veiculos_tipo ON veiculos (tipo);

COMMENT ON TABLE  veiculos      IS 'Veiculos da frota disponiveis para locacao';
COMMENT ON COLUMN veiculos.tipo IS 'Moto, Caminhao ou Carro de passeio';


-- =====================================================================
-- V3__create_table_contratos.sql
-- Contratos de locacao. Liga um cliente a um veiculo por um periodo.
-- Depende de V1__create_table_pessoas.sql e V2__create_table_veiculos.sql.
-- =====================================================================

CREATE TABLE IF NOT EXISTS contratos (
    id_contrato     SERIAL      PRIMARY KEY,
    numero_contrato VARCHAR(20) NOT NULL UNIQUE,
    data_contrato   DATE        NOT NULL DEFAULT CURRENT_DATE,
    tipo_pagamento  VARCHAR(10) NOT NULL,
    id_cliente      INTEGER     NOT NULL,
    id_veiculo      INTEGER     NOT NULL,
    data_inicio     DATE        NOT NULL,
    data_fim        DATE        NOT NULL,

    CONSTRAINT fk_contratos_cliente
        FOREIGN KEY (id_cliente) REFERENCES pessoas (id_pessoa)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_contratos_veiculo
        FOREIGN KEY (id_veiculo) REFERENCES veiculos (id_veiculo)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    -- Formas de pagamento aceitas
    CONSTRAINT chk_contratos_tipo_pagamento
        CHECK (tipo_pagamento IN ('Cartão', 'PIX')),
    -- Vigencia coerente
    CONSTRAINT chk_contratos_periodo
        CHECK (data_fim >= data_inicio),

    -- Contrato nao pode comecar antes de ter sido assinado
    CONSTRAINT chk_contratos_inicio_apos_assinatura
        CHECK (data_inicio >= data_contrato)
);

CREATE INDEX IF NOT EXISTS idx_contratos_cliente  ON contratos (id_cliente);
CREATE INDEX IF NOT EXISTS idx_contratos_veiculo  ON contratos (id_veiculo);
CREATE INDEX IF NOT EXISTS idx_contratos_vigencia ON contratos (data_inicio, data_fim);

COMMENT ON TABLE  contratos                IS 'Contratos de locacao entre cliente e veiculo';
COMMENT ON COLUMN contratos.tipo_pagamento IS 'Cartao ou PIX';



-- ############################################################################
-- PARTE 2 — DML: CARGA DE DADOS
-- ############################################################################

-- =====================================================================
-- V4__insert_into_pessoas.sql
-- =====================================================================

-- Inserir cliente comum
INSERT INTO pessoas (cpf, nome, sobrenome, endereco, dados_bancarios, email, eh_cliente, eh_atendente)
VALUES ('12345678901', 'Carlos', 'Silva', 'Rua das Flores, 123', 'Banco do Brasil, Ag 1234, CC 56789-0', 'carlos.silva@email.com', TRUE, FALSE)
ON CONFLICT (cpf) DO NOTHING;

INSERT INTO pessoas (cpf, nome, sobrenome, endereco, dados_bancarios, email, eh_cliente, eh_atendente)
VALUES ('32165498700', 'Ana', 'Oliveira', 'Rua das Palmeiras, 50', 'Banco Inter, Ag 0001, CC 12345-6', 'ana.oliveira@email.com', TRUE, FALSE)
ON CONFLICT (cpf) DO NOTHING;

-- Inserir um atendente da locadora
INSERT INTO pessoas (cpf, nome, sobrenome, endereco, dados_bancarios, email, eh_cliente, eh_atendente)
VALUES ('98765432100', 'Mariana', 'Souza', 'Av. Central, 456', 'Bradesco, Ag 4321, CC 98765-4', 'mariana.atendimento@locadora.com', FALSE, TRUE)
ON CONFLICT (cpf) DO NOTHING;

-- Inserir um atendente que TAMBÉM é cliente
INSERT INTO pessoas (cpf, nome, sobrenome, endereco, dados_bancarios, email, eh_cliente, eh_atendente)
VALUES ('45678912300', 'Lucas', 'Mendes', 'Rua Brasil, 789', 'Caixa, Ag 1111, CC 22222-3', 'lucas.mendes@email.com', TRUE, TRUE)
ON CONFLICT (cpf) DO NOTHING;


-- =====================================================================
-- V5__insert_into_veiculos.sql
-- =====================================================================

-- Inserir um veículo do tipo Carro
INSERT INTO veiculos (placa, marca, modelo, tipo)
VALUES ('ABC1D23', 'Chevrolet', 'Onix 1.0', 'Carro de passeio')
ON CONFLICT (placa) DO NOTHING;

-- Inserir um veículo do tipo Moto
INSERT INTO veiculos (placa, marca, modelo, tipo)
VALUES ('XYZ9F87', 'Honda', 'CG 160 Fan', 'Moto')
ON CONFLICT (placa) DO NOTHING;

-- Inserir um veículo do tipo Caminhão
INSERT INTO veiculos (placa, marca, modelo, tipo)
VALUES ('DEF4G56', 'Hyundai', 'HR 2.5', 'Caminhão')
ON CONFLICT (placa) DO NOTHING;


-- =====================================================================
-- V6__insert_into_contratos.sql
-- =====================================================================

-- Inserir contrato com pagamento via PIX
INSERT INTO contratos (numero_contrato, data_contrato, tipo_pagamento, id_cliente, id_veiculo, data_inicio, data_fim)
VALUES ('CTR-2026-001', '2026-09-01', 'PIX', 1, 1, '2026-09-01', '2026-09-30')
ON CONFLICT (numero_contrato) DO NOTHING;

-- Inserir contrato com pagamento via Cartão
INSERT INTO contratos (numero_contrato, data_contrato, tipo_pagamento, id_cliente, id_veiculo, data_inicio, data_fim)
VALUES ('CTR-2026-002', '2026-09-05', 'Cartão', 2, 2, '2026-09-05', '2026-09-20')
ON CONFLICT (numero_contrato) DO NOTHING;

-- Contrato com pagamento via PIX feito por um ATENDENTE que também é CLIENTE
INSERT INTO contratos (numero_contrato, data_contrato, tipo_pagamento, id_cliente, id_veiculo, data_inicio, data_fim)
VALUES ('CTR-2026-003', '2026-08-01', 'PIX', 4, 3, '2026-08-01', '2026-08-15')
ON CONFLICT (numero_contrato) DO NOTHING;

-- Contrato antigo já finalizado
INSERT INTO contratos (numero_contrato, data_contrato, tipo_pagamento, id_cliente, id_veiculo, data_inicio, data_fim)
VALUES ('CTR-2026-004', '2026-01-10', 'Cartão', 1, 1, '2026-01-10', '2026-01-20')
ON CONFLICT (numero_contrato) DO NOTHING;



-- ############################################################################
-- PARTE 3 — DML: VALIDACAO DE UPDATE E DELETE
-- ############################################################################

-- =====================================================================
-- V7__update_contratos_e_pessoas.sql
-- =====================================================================

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


-- =====================================================================
-- V8__delete_from_contratos.sql
-- =====================================================================

-- Excluir um contrato cancelado antes do início da vigência
DELETE FROM contratos
WHERE numero_contrato = 'CTR-2026-002';



-- ############################################################################
-- PARTE 4 — FASE 2 (INOVACAO): DDL DA GAMIFICACAO
--
-- Regra de negocio: cada contrato fechado gera pontos para o atendente que o
-- registrou. A cada mes uma campanha apura o ranking da equipe e paga bonus
-- em dinheiro para as primeiras colocacoes. Atendentes tambem desbloqueiam
-- conquistas ao atingir marcos de pontuacao.
-- ############################################################################

-- ----------------------------------------------------------------------------
-- 4.1 — O contrato passa a registrar QUAL atendente o fechou
--       (sem isso nao ha como atribuir pontos a ninguem)
-- ----------------------------------------------------------------------------
ALTER TABLE contratos
    ADD COLUMN IF NOT EXISTS id_atendente INTEGER;

-- cria a FK apenas se ela ainda nao existir, para o script poder rodar de novo
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_contratos_atendente'
    ) THEN
        ALTER TABLE contratos
            ADD CONSTRAINT fk_contratos_atendente
                FOREIGN KEY (id_atendente) REFERENCES pessoas (id_pessoa)
                ON UPDATE CASCADE ON DELETE RESTRICT;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_contratos_atendente ON contratos (id_atendente);

COMMENT ON COLUMN contratos.id_atendente IS 'Atendente responsavel pelo fechamento do contrato';


-- ----------------------------------------------------------------------------
-- 4.2 — CAMPANHAS: a competicao mensal entre os atendentes
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS campanhas (
    id_campanha    SERIAL        PRIMARY KEY,
    nome           VARCHAR(80)   NOT NULL,
    mes_referencia CHAR(7)       NOT NULL UNIQUE,
    data_inicio    DATE          NOT NULL,
    data_fim       DATE          NOT NULL,
    meta_contratos INTEGER       NOT NULL DEFAULT 0,
    valor_bonus    NUMERIC(10,2) NOT NULL DEFAULT 0,
    status         VARCHAR(10)   NOT NULL DEFAULT 'Aberta',

    -- mes_referencia no formato AAAA-MM
    CONSTRAINT chk_campanhas_mes
        CHECK (mes_referencia ~ '^[0-9]{4}-(0[1-9]|1[0-2])$'),

    CONSTRAINT chk_campanhas_periodo
        CHECK (data_fim >= data_inicio),

    CONSTRAINT chk_campanhas_status
        CHECK (status IN ('Aberta', 'Encerrada', 'Apurada')),

    CONSTRAINT chk_campanhas_valores
        CHECK (meta_contratos >= 0 AND valor_bonus >= 0)
);

CREATE INDEX IF NOT EXISTS idx_campanhas_status ON campanhas (status);

COMMENT ON TABLE campanhas IS 'Competicao mensal entre atendentes, com meta e premiacao';


-- ----------------------------------------------------------------------------
-- 4.3 — PONTUACOES: cada evento que rende pontos a um atendente
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pontuacoes (
    id_pontuacao  SERIAL      PRIMARY KEY,
    id_campanha   INTEGER     NOT NULL,
    id_atendente  INTEGER     NOT NULL,
    id_contrato   INTEGER,
    pontos        INTEGER     NOT NULL,
    motivo        VARCHAR(60) NOT NULL,
    data_registro TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_pontuacoes_campanha
        FOREIGN KEY (id_campanha) REFERENCES campanhas (id_campanha)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_pontuacoes_atendente
        FOREIGN KEY (id_atendente) REFERENCES pessoas (id_pessoa)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_pontuacoes_contrato
        FOREIGN KEY (id_contrato) REFERENCES contratos (id_contrato)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    -- o mesmo contrato nao pode pontuar duas vezes na mesma campanha
    CONSTRAINT uk_pontuacoes_contrato_campanha
        UNIQUE (id_campanha, id_contrato),

    CONSTRAINT chk_pontuacoes_pontos
        CHECK (pontos <> 0)
);

CREATE INDEX IF NOT EXISTS idx_pontuacoes_campanha  ON pontuacoes (id_campanha);
CREATE INDEX IF NOT EXISTS idx_pontuacoes_atendente ON pontuacoes (id_atendente);

COMMENT ON TABLE pontuacoes IS 'Extrato de pontos de cada atendente dentro de uma campanha';


-- ----------------------------------------------------------------------------
-- 4.4 — CONQUISTAS: marcos que o atendente pode desbloquear
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS conquistas (
    id_conquista       SERIAL       PRIMARY KEY,
    nome               VARCHAR(60)  NOT NULL UNIQUE,
    descricao          VARCHAR(160) NOT NULL,
    pontos_necessarios INTEGER      NOT NULL,

    CONSTRAINT chk_conquistas_pontos CHECK (pontos_necessarios > 0)
);

COMMENT ON TABLE conquistas IS 'Catalogo de conquistas (badges) da gamificacao';


-- ----------------------------------------------------------------------------
-- 4.5 — ATENDENTE_CONQUISTAS: quem desbloqueou o que, e quando
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS atendente_conquistas (
    id_atendente   INTEGER   NOT NULL,
    id_conquista   INTEGER   NOT NULL,
    data_conquista TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_atendente_conquistas
        PRIMARY KEY (id_atendente, id_conquista),

    CONSTRAINT fk_atendconq_atendente
        FOREIGN KEY (id_atendente) REFERENCES pessoas (id_pessoa)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_atendconq_conquista
        FOREIGN KEY (id_conquista) REFERENCES conquistas (id_conquista)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

COMMENT ON TABLE atendente_conquistas IS 'Conquistas desbloqueadas por cada atendente';


-- ----------------------------------------------------------------------------
-- 4.6 — PREMIACOES: resultado apurado no fim da campanha
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS premiacoes (
    id_premiacao  SERIAL        PRIMARY KEY,
    id_campanha   INTEGER       NOT NULL,
    id_atendente  INTEGER       NOT NULL,
    posicao       INTEGER       NOT NULL,
    total_pontos  INTEGER       NOT NULL,
    valor_bonus   NUMERIC(10,2) NOT NULL,
    data_apuracao DATE          NOT NULL DEFAULT CURRENT_DATE,

    CONSTRAINT fk_premiacoes_campanha
        FOREIGN KEY (id_campanha) REFERENCES campanhas (id_campanha)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_premiacoes_atendente
        FOREIGN KEY (id_atendente) REFERENCES pessoas (id_pessoa)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    -- um atendente so aparece uma vez por campanha, e uma posicao nao se repete
    CONSTRAINT uk_premiacoes_atendente UNIQUE (id_campanha, id_atendente),
    CONSTRAINT uk_premiacoes_posicao   UNIQUE (id_campanha, posicao),

    CONSTRAINT chk_premiacoes_posicao CHECK (posicao > 0),
    CONSTRAINT chk_premiacoes_valores CHECK (total_pontos >= 0 AND valor_bonus >= 0)
);

CREATE INDEX IF NOT EXISTS idx_premiacoes_campanha ON premiacoes (id_campanha);

COMMENT ON TABLE premiacoes IS 'Ranking final e bonus pago em cada campanha encerrada';



-- ############################################################################
-- PARTE 5 — FASE 2 (INOVACAO): CARGA DE EXEMPLO DA GAMIFICACAO
-- ############################################################################

-- ----------------------------------------------------------------------------
-- 5.1 — Catalogo de conquistas
-- ----------------------------------------------------------------------------
INSERT INTO conquistas (nome, descricao, pontos_necessarios) VALUES
    ('Primeira Chave',  'Fechou o primeiro contrato de aluguel da carreira.',        10),
    ('Maratonista',     'Acumulou 100 pontos em uma unica campanha mensal.',        100),
    ('Frota Completa',  'Alugou pelo menos um veiculo de cada tipo na campanha.',   150),
    ('Pe na Tabua',     'Acumulou 300 pontos em uma unica campanha mensal.',        300),
    ('Rei da Pista',    'Acumulou 500 pontos em uma unica campanha mensal.',        500)
ON CONFLICT (nome) DO NOTHING;


-- ----------------------------------------------------------------------------
-- 5.2 — Campanhas mensais (uma aberta e duas ja encerradas)
-- ----------------------------------------------------------------------------
INSERT INTO campanhas (nome, mes_referencia, data_inicio, data_fim, meta_contratos, valor_bonus, status) VALUES
    ('Corrida de Setembro',   '2026-09', '2026-09-01', '2026-09-30', 120, 800.00, 'Aberta'),
    ('Maratona de Agosto',    '2026-08', '2026-08-01', '2026-08-31', 100, 700.00, 'Apurada'),
    ('Arrancada de Janeiro',  '2026-01', '2026-01-01', '2026-01-31',  80, 500.00, 'Apurada')
ON CONFLICT (mes_referencia) DO NOTHING;


-- ----------------------------------------------------------------------------
-- 5.3 — Atribui os contratos ja existentes aos atendentes cadastrados
--       (Mariana, id_pessoa 3, e Lucas, id_pessoa 4)
-- ----------------------------------------------------------------------------
UPDATE contratos
SET id_atendente = (SELECT id_pessoa FROM pessoas WHERE cpf = '98765432100')
WHERE numero_contrato IN ('CTR-2026-001', 'CTR-2026-004');

UPDATE contratos
SET id_atendente = (SELECT id_pessoa FROM pessoas WHERE cpf = '45678912300')
WHERE numero_contrato = 'CTR-2026-003';


-- ----------------------------------------------------------------------------
-- 5.4 — Pontua os contratos dentro da campanha do mes correspondente
--       (10 pontos por contrato fechado)
-- ----------------------------------------------------------------------------
INSERT INTO pontuacoes (id_campanha, id_atendente, id_contrato, pontos, motivo)
SELECT ca.id_campanha,
       ct.id_atendente,
       ct.id_contrato,
       10,
       'Contrato de locacao fechado'
FROM contratos ct
JOIN campanhas ca
  ON ca.mes_referencia::text = to_char(ct.data_contrato, 'YYYY-MM')
WHERE ct.id_atendente IS NOT NULL
ON CONFLICT (id_campanha, id_contrato) DO NOTHING;


-- ----------------------------------------------------------------------------
-- 5.5 — Apuracao das campanhas ja encerradas: monta o ranking e grava o bonus
--       (somente o 1o lugar recebe o bonus da campanha)
-- ----------------------------------------------------------------------------
INSERT INTO premiacoes (id_campanha, id_atendente, posicao, total_pontos, valor_bonus, data_apuracao)
SELECT s.id_campanha,
       s.id_atendente,
       ROW_NUMBER() OVER (PARTITION BY s.id_campanha ORDER BY s.total_pontos DESC, s.id_atendente),
       s.total_pontos,
       CASE ROW_NUMBER() OVER (PARTITION BY s.id_campanha ORDER BY s.total_pontos DESC, s.id_atendente)
            WHEN 1 THEN s.valor_bonus
            ELSE 0
       END,
       s.data_fim
FROM (
    SELECT pt.id_campanha,
           pt.id_atendente,
           SUM(pt.pontos)  AS total_pontos,
           ca.valor_bonus,
           ca.data_fim
    FROM pontuacoes pt
    JOIN campanhas ca ON ca.id_campanha = pt.id_campanha
    WHERE ca.status = 'Apurada'
    GROUP BY pt.id_campanha, pt.id_atendente, ca.valor_bonus, ca.data_fim
) s
ON CONFLICT (id_campanha, id_atendente) DO NOTHING;


-- ----------------------------------------------------------------------------
-- 5.6 — Desbloqueia as conquistas que cada atendente ja atingiu
-- ----------------------------------------------------------------------------
INSERT INTO atendente_conquistas (id_atendente, id_conquista)
SELECT s.id_atendente, c.id_conquista
FROM (
    SELECT id_atendente, SUM(pontos) AS total_pontos
    FROM pontuacoes
    GROUP BY id_atendente
) s
JOIN conquistas c ON c.pontos_necessarios <= s.total_pontos
ON CONFLICT (id_atendente, id_conquista) DO NOTHING;

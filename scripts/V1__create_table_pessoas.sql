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

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
        CHECK (tipo_pagamento IN ('Cartao', 'PIX')),

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

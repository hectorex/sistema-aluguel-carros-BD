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
        CHECK (tipo IN ('Moto', 'Caminhao', 'Carro de passeio')),

    -- Placa antiga AAA9999 ou Mercosul AAA9A99
    CONSTRAINT chk_veiculos_placa_formato
        CHECK (placa ~ '^[A-Z]{3}[0-9][0-9A-Z][0-9]{2}$')
);

CREATE INDEX IF NOT EXISTS idx_veiculos_tipo ON veiculos (tipo);

COMMENT ON TABLE  veiculos      IS 'Veiculos da frota disponiveis para locacao';
COMMENT ON COLUMN veiculos.tipo IS 'Moto, Caminhao ou Carro de passeio';

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

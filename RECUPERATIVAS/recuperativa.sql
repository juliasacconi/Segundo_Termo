-- Active: 1794920752796@@127.0.0.1@3308@rec_retrogame_julia1

DROP DATABASE IF EXISTS REC_RETROGAME_JULIA1;
CREATE DATABASE IF NOT EXISTS REC_RETROGAME_JULIA1;

USE REC_RETROGAME_JULIA1;

CREATE TABLE CLIENTE (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    telefone VARCHAR(20) NULL,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE PLATAFORMA (
    id_plataforma INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE CATEGORIA (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE JOGOS (
    id_jogo INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    codigo VARCHAR(15) NOT NULL UNIQUE,
    ano_lancamento INT NOT NULL,
    quantidade_disponivel INT NOT NULL DEFAULT 0,
    id_plataforma INT NOT NULL,
    id_categoria INT NOT NULL,
    CONSTRAINT chk_estoque_nao_negativo CHECK (quantidade_disponivel >= 0),
    CONSTRAINT fk_jogo_plataforma FOREIGN KEY (id_plataforma) 
        REFERENCES PLATAFORMA(id_plataforma)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_jogo_categoria FOREIGN KEY (id_categoria) 
        REFERENCES CATEGORIA(id_categoria)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE LOCACAO (
    id_locacao INT AUTO_INCREMENT PRIMARY KEY,
    data_retirada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_prevista DATE NOT NULL,
    data_devolucao DATE NULL,
    status_locacao VARCHAR(20) NOT NULL DEFAULT 'ABERTA',
    id_cliente INT NOT NULL,
    id_jogo INT NOT NULL, 
    CONSTRAINT chk_status_locacao CHECK (status_locacao IN ('ABERTA', 'DEVOLVIDA', 'ATRASADA')),
    CONSTRAINT fk_locacao_cliente FOREIGN KEY (id_cliente) 
        REFERENCES CLIENTE(id_cliente)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_locacao_jogo FOREIGN KEY (id_jogo) 
        REFERENCES JOGOS(id_jogo)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

ALTER TABLE JOGOS
ADD COLUMN desenvolvedora VARCHAR(100) NULL AFTER titulo;

SHOW TABLES;
DESCRIBE JOGOS;

-- FASE 2

INSERT INTO CLIENTE (nome, email, telefone, ativo) VALUES
('Júlia Sacconi', 'ju.sacconi@email.com', '(19) 99123-4567', TRUE),
('Mario Fernando', 'mario.fernando@email.com', '(19) 98765-4321', TRUE),
('Rafaela Mendes', 'rafaela.mendes@email.com', NULL, TRUE),
('Bruno Moraes', 'bruno.moraes@email.com', '(19) 99555-1212', TRUE);

INSERT INTO PLATAFORMA (nome) VALUES
('Xbox'),
('Nintendo'),
('PlayStation 1'),
('PlayStation 2');

INSERT INTO CATEGORIA (descricao) VALUES
('Rpg'),
('Ação & Aventura'),
('Terror'); 


INSERT INTO JOGOS (titulo, desenvolvedora, codigo, ano_lancamento, quantidade_disponivel, id_plataforma, id_categoria) VALUES
('Super Mario World', 'Nintendo EAD', 'SNES-001', 1990, 5, 1, 1),
('Chrono Trigger', 'Square', 'SNES-002', 1995, 2, 1, 2),
('Final Fantasy VII', 'Square', 'PS1-001', 1997, 3, 2, 2),
('Sonic the Hedgehog 2', 'Sonic Team', 'MD-001', 1992, 4, 4, 1),
('God of War II', 'Santa Monica Studio', 'PS2-001', 2007, 3, 3, 3),
('Gran Turismo 4', 'Polyphony Digital', 'PS2-002', 2004, 1, 3, 4);

INSERT INTO LOCACAO (data_retirada, data_prevista, status_locacao, id_cliente, id_jogo) VALUES
('2026-11-10 14:30:00', '2026-11-17', 'ABERTA', 1, 1), -- Super Mario World (id 1)
('2026-11-12 10:15:00', '2026-11-19', 'ABERTA', 2, 3), -- Final Fantasy VII (id 3)
('2026-11-14 16:00:00', '2026-11-21', 'ABERTA', 1, 5); -- God of War II (id 5)

UPDATE JOGOS SET quantidade_disponivel = quantidade_disponivel - 1 WHERE id_jogo IN (1, 3, 5);

SELECT * FROM LOCACAO;
SELECT id_jogo, titulo, quantidade_disponivel FROM JOGOS;

SELECT id_cliente, nome, email, telefone FROM CLIENTE WHERE id_cliente = 3;

UPDATE CLIENTE 
SET telefone = '(19) 99988-7766' 
WHERE id_cliente = 3;

SELECT id_cliente, nome, telefone FROM CLIENTE WHERE id_cliente = 3;

UPDATE JOGOS 
SET quantidade_disponivel = quantidade_disponivel + 2 
WHERE ano_lancamento >= 2000;

SELECT id_jogo, titulo, ano_lancamento, quantidade_disponivel FROM JOGOS WHERE ano_lancamento >= 2000;

INSERT INTO CLIENTE (nome, email, telefone) VALUES ('Cliente Temporário', 'temp@email.com', '(19) 90000-0000');
SELECT * FROM CLIENTE WHERE email = 'temp@email.com';


DELETE FROM CLIENTE WHERE email = 'temp@email.com';

DELETE FROM CLIENTE WHERE id_cliente = 1; -- A (FOREIGN KEY) configurada com a cláusula ON DELETE RESTRICT impede que seja feito a exclusão de registros da tabela 1 caso existam registros dependentes na tabela locação, logo preservando o histórico de locações da empresa.


-- FASE 3


SELECT 
    titulo, 
    ano_lancamento, 
    quantidade_disponivel 
FROM JOGOS;

SELECT 
    titulo, 
    codigo, 
    quantidade_disponivel 
FROM JOGOS 
WHERE quantidade_disponivel > 2 
ORDER BY quantidade_disponivel DESC;

SELECT 
    id_jogo, 
    titulo, 
    desenvolvedora, 
    ano_lancamento 
FROM JOGOS 
WHERE titulo LIKE '%Mario%';

SELECT 
    titulo, 
    ano_lancamento, 
    quantidade_disponivel 
FROM JOGOS 
WHERE ano_lancamento BETWEEN 1990 AND 2005 
ORDER BY ano_lancamento ASC;

SELECT 
    COUNT(*) AS total_titulos_cadastrados,
    SUM(quantidade_disponivel) AS estoque_total_unidades,
    ROUND(AVG(quantidade_disponivel), 2) AS media_unidades_por_jogo,
    MIN(quantidade_disponivel) AS menor_estoque,
    MAX(quantidade_disponivel) AS maior_estoque
FROM JOGOS;

SELECT 
    L.id_locacao,
    C.nome AS nome_cliente,
    J.titulo AS titulo_jogo,
    L.data_retirada,
    L.status_locacao
FROM LOCACAO L
INNER JOIN CLIENTE C ON L.id_cliente = C.id_cliente
INNER JOIN JOGOS J ON L.id_jogo = J.id_jogo;

SELECT 
    L.id_locacao,
    C.nome AS nome_cliente,
    J.titulo AS titulo_jogo,
    L.data_retirada,
    L.data_prevista,
    L.status_locacao
FROM LOCACAO L
INNER JOIN CLIENTE C ON L.id_cliente = C.id_cliente
INNER JOIN JOGOS J ON L.id_jogo = J.id_jogo
WHERE L.status_locacao = 'ABERTA';

SELECT 
    C.id_cliente,
    C.nome AS nome_cliente,
    COUNT(L.id_locacao) AS quantidade_locacoes
FROM CLIENTE C
INNER JOIN LOCACAO L ON C.id_cliente = L.id_cliente
GROUP BY C.id_cliente, C.nome
ORDER BY quantidade_locacoes DESC;

SELECT 
    C.id_cliente,
    C.nome AS nome_cliente,
    COUNT(L.id_locacao) AS quantidade_locacoes
FROM CLIENTE C
LEFT JOIN LOCACAO L ON C.id_cliente = L.id_cliente
GROUP BY C.id_cliente, C.nome
ORDER BY quantidade_locacoes DESC, C.nome ASC;


-- FASE 4


START TRANSACTION;

INSERT INTO LOCACAO (data_prevista, status_locacao, id_cliente, id_jogo)
VALUES ('2026-11-24', 'ABERTA', 3, 2);

UPDATE JOGOS 
SET quantidade_disponivel = quantidade_disponivel - 1 
WHERE id_jogo = 2 AND quantidade_disponivel > 0;

SELECT id_jogo, titulo, quantidade_disponivel FROM JOGOS WHERE id_jogo = 2;
SELECT * FROM LOCACAO WHERE id_cliente = 3;

COMMIT;

SELECT id_jogo, titulo, quantidade_disponivel AS estoque_original FROM JOGOS WHERE id_jogo = 4;

START TRANSACTION;

UPDATE JOGOS SET quantidade_disponivel = 999 WHERE id_jogo = 4;


SELECT id_jogo, titulo, quantidade_disponivel AS estoque_alterado_temporario FROM JOGOS WHERE id_jogo = 4;


ROLLBACK;

SELECT id_jogo, titulo, quantidade_disponivel AS estoque_pos_rollback FROM JOGOS WHERE id_jogo = 4;

SELECT id_jogo, titulo, quantidade_disponivel FROM JOGOS WHERE id_jogo IN (1, 6);

START TRANSACTION;

UPDATE JOGOS SET quantidade_disponivel = quantidade_disponivel + 1 WHERE id_jogo = 1;


SAVEPOINT ponto_apos_jogo1;


UPDATE JOGOS SET quantidade_disponivel = 0 WHERE id_jogo = 6;


SELECT id_jogo, titulo, quantidade_disponivel FROM JOGOS WHERE id_jogo IN (1, 6);

ROLLBACK TO SAVEPOINT ponto_apos_jogo1;

COMMIT; -- salvando tudo

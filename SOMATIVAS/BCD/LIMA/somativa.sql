-- Active: 1788267989057@@127.0.0.1@3306@biblioteca_somjulia2

-------------- FASE 1: Criação do banco de dados e tabelas -------------


-- PASSO 1
CREATE DATABASE IF NOT EXISTS biblioteca_somJulia2;

USE biblioteca_somJulia2;


-- PASSO 2

CREATE TABLE usuarios (
    id_usuarios INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE
);


-- PASSO 3

CREATE TABLE livros (
    id_livros INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    autor VARCHAR(255) NOT NULL,
    isbn CHAR(13) NOT NULL UNIQUE,
    ano_publicacao INT,
    genero VARCHAR(100),
    quantidade INT NOT NULL CHECK (quantidade >= 0)
);


-- PASSO 4

CREATE TABLE emprestimo ( 
    id_emprestimo INT AUTO_INCREMENT PRIMARY KEY, 
    id_usuario INT NOT NULL, 
    id_livro INT NOT NULL, 
    data_emprestimo DATE NOT NULL DEFAULT (CURRENT_DATE),
    data_devolucao_prevista DATE NOT NULL DEFAULT (CURRENT_DATE + INTERVAL 14 DAY), 
    status VARCHAR(20) NOT NULL DEFAULT 'Ativo', 
    CONSTRAINT CHK_EMPRESTIMO_STATUS CHECK (status IN ('Ativo', 'Devolvido', 'Atrasado')), 
    CONSTRAINT FK_EMPRESTIMO_USUARIO FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuarios) ON DELETE RESTRICT, 
    CONSTRAINT FK_EMPRESTIMO_LIVRO FOREIGN KEY (id_livro) REFERENCES livros(id_livros) ON DELETE RESTRICT 
);

-- CRIAR +2 TABELAS

CREATE TABLE funcionarios (
    id_funcionario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL
);

CREATE TABLE editoras (
    id_editora INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    endereco VARCHAR(255),
    telefone VARCHAR(15)
);

-- PASSO 5
ALTER TABLE livros ADD editora VARCHAR(100);

ALTER TABLE usuarios ADD telefone VARCHAR(15);


-- -------------- FASE 2: DML -------------


-- PASSO 6

INSERT INTO usuarios (nome, email, senha, telefone) VALUES
('Alice', 'alice@example.com', 'senha123', '1234567890'),
('Bruna', 'brunaLouise@example.com', 'senha456', '1287654321'),
('Charlie', 'charlieMacedo@example.com', 'senha789', '1234567890'),
('David', 'davidCosta@example.com', 'senha012', NULL);

INSERT INTO usuarios (nome, email, senha, telefone) VALUES
('Diana', 'dianaSilva@example.com', 'senha345', '1876543210');

-- PASSO 7

INSERT INTO livros (titulo, autor, isbn, ano_publicacao, genero, quantidade, editora) VALUES
('Harry Potter e o Cálice de fogo', 'J.K. Rowling', '9788532516374', 2000, 'Fantasia', 5, 'HarperCollins'),

('Jogos Vorazes', 'Suzanne Collins', '9788579800245', 2008, 'Distopia', 5, 'Secker & Warburg'),

('Crepúsculo', 'Stephenie Meyer', '9788598078304', 2005, 'Romance', 4, 'Reynal & Hitchcock'),

('A Garota Exemplar', 'Gillian Flynn', '9788580572568', 2012, 'Drama', 6, 'Crown Publishing Group'),

('Bird Box', 'Josh Malerman', '9788551000106', 2014, 'Terror', 5, 'Gallery Books'),

('A Culpa É das Estrelas', 'John Green', '9788580572261', 2012, 'Romance', 4, 'Garnier');


-- PASSO 8

INSERT INTO emprestimo (id_emprestimo, id_usuario, id_livro, data_emprestimo, data_devolucao_prevista, status) VALUES
(1, 1, 1, '2026-01-01', '2026-01-15', 'Ativo'),
(2, 2, 2, '2026-01-02', '2026-01-16', 'Ativo'),
(3, 3, 3, '2026-01-03', '2026-01-17', 'Ativo'),
(4, 4, 4, '2026-01-04', '2026-01-18', 'Ativo');


-- PASSO 9

SELECT * FROM usuarios;
UPDATE usuarios SET telefone = '1234567899' WHERE id_usuarios = 1;
ALTER TABLE usuarios ADD CONSTRAINT UNIQUE(telefone);

-- PASSO 10

UPDATE livros 
SET quantidade = quantidade + 2 
WHERE ano_publicacao >= 2020;

-- PASSO 11

INSERT INTO usuarios (nome, email, senha, telefone) 
VALUES ('Usuario Teste', 'teste@example.com', 'senhaTest123', '99999999999');

DELETE FROM usuarios WHERE email = 'teste@example.com';

DELETE FROM usuarios WHERE id_usuarios = 1;

-- R: Não da para deletar por que ele conta como erro, provavelmente por que ele tem um telefone unico, e não pode ser deletado ou por que seu status conta como ativo.

-- -------------- FASE 3: DQL - CONSULTAS E ANALISES -------------

-- PASSO 12

SELECT titulo, autor, quantidade
FROM livros


-- PASSO 13

SELECT quantidade, titulo 
FROM livros 
WHERE quantidade > 2 
ORDER BY quantidade DESC;



-- PASSO 14

SELECT titulo, autor 
FROM livros 
WHERE titulo LIKE '%Jogos%';


-- PASSO 15

-- MUDEI A PUBLICAÇÂO PARA SER ENTRE 2000 E 2015

SELECT ano_publicacao
FROM livros
WHERE ano_publicacao BETWEEN 2015 AND 2025
ORDER BY ano_publicacao ASC;


-- PASSO 16


SELECT 
COUNT(quantidade) AS total_registros,
SUM(quantidade)   AS quantidade_total,
AVG(quantidade)   AS media_quantidade,
MIN(quantidade)   AS menor_quantidade,
MAX(quantidade)   AS maior_quantidade
FROM livros;


-- PASSO 17

SELECT 
    e.id_emprestimo, 
    u.nome AS usuario, 
    l.titulo AS livro, 
    e.data_emprestimo, 
    e.status 
FROM emprestimo e 
INNER JOIN usuarios u ON e.id_usuario = u.id_usuarios
INNER JOIN livros l ON e.id_livro = l.id_livros; 

-- PASSO 18

SELECT id_emprestimo
FROM emprestimo
WHERE status = 'Ativo';

-- PASSO 19

SELECT 
    u.nome AS usuarios, 
    COUNT(e.id_emprestimo) AS quantidade_emprestimos
FROM usuarios u
INNER JOIN emprestimo e ON u.id_usuarios = e.id_usuario
GROUP BY u.id_usuarios, u.nome
ORDER BY quantidade_emprestimos DESC;



-- PASSO 20

SELECT 
    u.nome AS usuarios, 
    COUNT(e.id_emprestimo) AS quantidade_emprestimos
FROM usuarios u
LEFT JOIN emprestimo e ON u.id_usuarios = e.id_usuario

GROUP BY u.id_usuarios, u.nome
ORDER BY quantidade_emprestimos DESC;


-- -------------- FASE 4: TCL E INTEGRIDADE -------------

-- PASSO 21

START TRANSACTION;

INSERT INTO emprestimo (id_usuario, id_livro, data_emprestimo, status) 
VALUES (1, 6, CURDATE(), 'Ativo');



UPDATE livros 
SET quantidade = quantidade - 1 
WHERE id_livros = 6;

SELECT * FROM emprestimo WHERE id_livro = 6;
SELECT * FROM livros WHERE id_livros = 6;

-- COMMIT
COMMIT;


-- PASSO 22

START TRANSACTION;

UPDATE livros 
SET quantidade = 999 
WHERE id_livros = 1;
SELECT id_livros, quantidade FROM livros WHERE id_livros = 1;
ROLLBACK;

SELECT id_livros, quantidade FROM livros WHERE id_livros = 1;


-- PASSO 23

START TRANSACTION;

UPDATE livros SET quantidade = quantidade + 5 WHERE id_livros = 1;
SAVEPOINT primeira_alteracao;
UPDATE livros SET quantidade = quantidade + 20 WHERE id_livros = 2;
ROLLBACK TO primeira_alteracao;

-- COMMIT
COMMIT;

SELECT id_livros, quantidade FROM livros WHERE id_livros IN (1, 2);


-- PASSO 24

START TRANSACTION;

UPDATE emprestimo 
SET status = 'Devolvido', data_devolucao_prevista = CURDATE() 
WHERE id_emprestimo = 4 AND status = 'Ativo';

UPDATE livros 
SET quantidade = quantidade + 1 
WHERE id_livros = 4;

-- COMMIT
COMMIT;

--- PASSO 25 - DESAFIO DE INTEGRIDADE: 

-- Para cada situação abaixo, identifique o mecanismo mais adequado entre constraint, integridade referencial, transação ou regra da aplicação, e justifique tecnicamente sua escolha.

-- 1: Cadastrar dois usuários com o mesmo e-mail.

-- Mecanismo: Constraint (UNIQUE):

-- Justificativa: A constraint UNIQUE garante que nenhum valor duplicado seja inserido em uma coluna específica.

-- 2: Cadastrar dois livros com o mesmo ISBN.

-- Mecanismo: Constraint (UNIQUE):

-- Justificativa: A constraint UNIQUE garante que nenhum valor duplicado seja inserido em uma coluna específica.

-- 3: Permitir quantidade disponível negativa.

-- Mecanismo: Constraint (CHECK):

-- Justificativa: A constraint CHECK pode ser utilizada para limitar os valores que podem ser inseridos em uma coluna.

-- 4: Criar empréstimo para usuário inexistente.

-- Mecanismo: Integridade Referencial:

-- Justificativa: A integridade referencial garante que os valores de uma coluna de uma tabela sejam válidos e existam na tabela referenciada.

-- 5: Excluir livro com histórico de empréstimos.

-- Mecanismo: Integridade Referencial:

-- Justificativa: A integridade referencial garante que os valores de uma coluna de uma tabela sejam válidos e existam na tabela referenciada.

-- 6: Gravar empréstimo e falhar na redução do estoque.

-- Mecanismo: Transação:

-- Justificativa: As transações garantem que todas as operações sejam concluídas com sucesso ou revertidas em caso de falha.

-- 7: Emprestar livro cuja quantidade disponível seja zero.

-- Mecanismo: Regra da Aplicação:

-- Justificativa: Como o valor zero é válido na tabela de livros (saldo zerado em estoque), a validação antes da liberação do empréstimo deve ser realizada pela regra de negócio na camada da aplicação.
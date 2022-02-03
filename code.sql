-- tables --
-- 1 Crie a estrutura de tabelas acima definindo as chaves primárias,
-- estrangeiras e os tipos de dados adequados. Adicionalmente, as tabelas
-- devem garantir que:
-- a) Não terá pizza com preço menor que R$1
-- b) O valor padrão das colunas “gluten” e “lactose” é true
-- c) Apenas a coluna calorias irá aceitar valores NULL.
-- d) As colunas “nome” não aceitam valores repetidos
-- Informação: É possível restringir os dados que serão armazenados na tabela
-- utilizando restrições condicionais através do CHECK. Verifique as restrições NOT
-- NULL, DEFAULT, UNIQUE e CHECK.
CREATE TABLE tipo(
id_tipo serial PRIMARY KEY,
tipo varchar(64) NOT NULL
);

CREATE TABLE pizza(
id_pizza serial PRIMARY KEY,
nome varchar(64) NOT NULL UNIQUE,
preco decimal(5,2) NOT NULL CHECK (preco > 1),
caloria int,
dt_hr_cadastro timestamp NOT NULL,
id_tipo int NOT NULL,
FOREIGN KEY (id_tipo) REFERENCES tipo(id_tipo)
);

CREATE TABLE ingrediente(
id_ingrediente serial PRIMARY KEY,
nome varchar(64) NOT NULL UNIQUE,
gluten boolean NOT NULL DEFAULT true,
lactose boolean NOT NULL DEFAULT true
);

CREATE TABLE pizza_ingrediente(
id_pizza int,
id_ingrediente int,
PRIMARY KEY (id_pizza, id_ingrediente),
FOREIGN KEY (id_pizza) REFERENCES pizza(id_pizza),
FOREIGN KEY (id_ingrediente) REFERENCES ingrediente(id_ingrediente)
);

-- inserts --
-- 2 Insira ao menos cinco registros em cada tabela. Porém apenas um comando
-- INSERT deve ser utilizado por tabela.
-- Informação: É possível realizar INSERT de múltiplos registros em um comando.
-- Verifique a sintaxe do comando INSERT.
INSERT INTO tipo (tipo)
VALUES
('Tradicional'),
('Diferenciada'),
('Especial'),
('Doce'),
('Caseira');

INSERT INTO pizza (nome, preco, caloria, dt_hr_cadastro, id_tipo)
VALUES
('Margherita', 27.00, 1500, '2020-01-01', 1),
('Calabresa', 29.00, NULL, '2020-01-01', 1),
('Pepperoni', 31.00, 1900, '2020-01-01', 2),
('Camarão', 35.00, 1600, '2020-01-01', 5),
('Siciliana', 31.00, NULL, '2020-01-01', 2),
('Chocolate', 27.00, 2200, '2020-01-01', 4);

INSERT INTO ingrediente (nome, gluten, lactose)
VALUES
('molho de tomate', true , false),
('mussarela', true, true),
('manjericão', false, false),
('calabresa', true, false),
('pepperoni', true, false),
('camarão', true, false),
('alcaparra', false, false),
('anchova', true, false),
('azeitona', false, false),
('chocolate', true, true),
('leite condensado', true, true);

INSERT INTO pizza_ingrediente (id_pizza, id_ingrediente)
VALUES
(1,1),
(1,2),
(1,3),
(2,1),
(2,2),
(2,4),
(3,1),
(3,2),
(3,5),
(4,1),
(4,2),
(4,6),
(5,1),
(5,2),
(5,7),
(5,8),
(5,9),
(6,10),
(6,11);

-- query --
-- 3 Liste o nome de todas as pizzas com o seu tipo associado. O nome dos tipos
-- deve estar em CAIXA ALTA e o nome das pizzas em caixa baixa.
-- Informação: É possível alterar a capitalização do texto utilizando as funções
-- LOWER() e UPPER().
SELECT LOWER(pizza.nome), UPPER(tipo.tipo) FROM pizza
INNER JOIN tipo
ON pizza.id_tipo = tipo.id_tipo;

-- 4 Liste as pizzas com seus ingredientes de forma que no resultado terá uma
-- linha para cada pizza e os ingredientes serão mostrados no seguinte formato
-- “Ingrediente 1, Ingrediente 2, ...”.
-- Informação: É possível agregar valores textuais em um único valor textual com
-- um separador utilizando a função de agregação string_agg().
SELECT pizza.nome, STRING_AGG(ingrediente.nome, ', ') ingrediente
FROM pizza
INNER JOIN pizza_ingrediente
ON pizza.id_pizza = pizza_ingrediente.id_pizza
INNER JOIN ingrediente
ON pizza_ingrediente.id_ingrediente = ingrediente.id_ingrediente
GROUP BY pizza.nome

-- 5 Liste os nomes, preços e calorias de todas as pizzas: a) em ordem da mais
-- calórica para a menos calórica com os valores “null” aparecendo no início;
-- b) em ordem da mais calórica para a menos calórica com os valores “null”
-- aparecendo no final.
-- Informação: É possível definir a posição dos valores NULL em um resultado
-- ordenado utilizando as opções NULLS FIRST e NULLS LAST da cláusula ORDER
-- BY.
SELECT nome, preco, caloria
FROM pizza
ORDER BY caloria DESC
NULLS FIRST

SELECT nome, preco, caloria
FROM pizza
ORDER BY caloria DESC
NULLS LAST

-- 6 Liste o nome das pizzas, o ano em que foram cadastradas e o tempo do
-- cadastro até a data atual.
-- Informação: É possível utilizar funções como extract(), age(), now(), entre outras
-- para manipular dados de datas.
SELECT nome, extract(year from dt_hr_cadastro), AGE(dt_hr_cadastro) FROM pizza

-- 7 Liste os nomes, preços e calorias de todas as pizzas. No caso em que as
-- calorias tem valor “null” mostre no resultado o texto “Sem informação”.
-- Informação: É possível utilizar a função coalesce() para retornar um valor caso
-- um (ou mais) parâmetro seja “null”. Como os parâmetros precisam ser de tipos de
-- dados compatíveis para converter um número em um texto é possível realizar o
-- cast de uma coluna (ex. SELECT coluna::varchar).
SELECT nome, preco, COALESCE(caloria::varchar, 'Sem informação') FROM pizza

-- 8 Qual é o segundo maior preço entre todas as pizzas?
-- Informação: Considere que pode ter mais de uma pizza com o mesmo preço.
SELECT MAX(preco) FROM pizza
WHERE preco
NOT IN (SELECT MAX(preco) FROM pizza);

-- 9 Liste todas as combinações possíveis de pares de pizza com o nome de uma
-- pizza na primeira coluna e o nome da outra pizza na segunda coluna da
-- tabela de resultado (ex. Margherita / Calabresa). Não deve ter pares com
-- duas pizzas com o mesmo nome.
-- Informação: É possível realizar o produto cartesiano (ou outros tipos de junção)
-- de uma tabela com ela própria. Para fazer isso é necessário na cláusula FROM
-- renomear cada uma das referências a essa tabela (ex. FROM pizza p1) e utilizar
-- seu novo nome para referenciar cada coluna (ex. SELECT p1.nome).
SELECT p1.nome, p2.nome FROM pizza p1
CROSS JOIN pizza p2
WHERE p1.nome != p2.nome

-- 10)Liste os tipos de pizza e a média de preço para cada um dos tipos. Renomeie
-- no resultado a coluna com a média de preços para “Média de Preços”.
-- Mostre o preço médio com apenas duas casas decimais.
-- Informação: É possível renomear uma coluna no SELECT utilizando um alias
-- através da cláusula as (Ex. avg(preco) as “Preço”). Para determinar o número de
-- casas em um valor decimal utilize a função “round()”.
SELECT tipo.tipo AS Nome, round(AVG(preco), 2) "Media de Preços" FROM tipo
INNER JOIN pizza
ON tipo.id_tipo = pizza.id_tipo
GROUP BY tipo.tipo

-- 11)Liste o nome das pizzas acompanhado de seu preço no formato “R$valor” e
-- “valor calorias” na tabela de resultado (Ex. Margherita / R$27 / 1500 calorias).
-- Informação: É possível concatenar valores de colunas e textos utilizando a
-- função concat() no SELECT.
SELECT nome || '  / R$' || round(preco,0) || ' / ' || COALESCE(caloria::varchar, 'Sem informação de') || ' calorias'
AS Informação FROM pizza

-- 12)Liste os nomes das pizzas acompanhado dos valores de calorias no formato
-- “valor calorias” (ex. Margherita / 1500 calorias). Nos casos em que o valor de
-- calorias for “null” mostre o texto “Sem informação”.
-- Informação: É possível utilizar a expressão CASE WHEN na cláusula SELECT
-- para realizar operações condicionais.
SELECT nome || ' / ' || 
CASE WHEN caloria IS NULL THEN 1 -- cast type
ELSE caloria END || ' calorias'
AS Informação
FROM pizza

-- 13) Liste todas as pizzas que não contém glúten.
-- Informação: Considere que uma pizza não contém glúten quando nenhum dos
-- seus ingredientes contém glúten.

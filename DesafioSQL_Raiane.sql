-- Database: Vendas
CREATE TABLE FatoDetalhes (
    CupomID varchar(10),
    ProdutoID varchar(10),
    Quantidade int,
	Valor     decimal(10,2),
	Desconto  decimal(10,2),
    Custo     decimal(10,2),
	ValorLiquido decimal(10,2)
);

COPY fatodetalhes 
FROM 'C:\Users\Suporte\Documents\Raiane\Dataset\ModelosDados\FatoDetalhes_DadosModelagem.csv' 
DELIMITER ',' 
CSV HEADER;

SELECT * FROM FATODETALHES;

CREATE TABLE FatoCabecalho (
    Data Date,
    ClienteID varchar(10),
    FuncionarioID varchar(10),
    ValorFrete decimal(10,2),
    CupomID varchar(10),
    EmpresaFrete varchar(30),
    DataEntrega date
);


COPY FATOCABECALHO 
FROM 'C:\Users\Suporte\Documents\Raiane\Dataset\ModelosDados\fatoCabecalho.csv' 
DELIMITER ',' 
CSV HEADER;

SELECT * FROM FATOCABECALHO;

--------------------------------------------------------------------
CREATE TABLE DIMENSOES (
    ClienteID 	varchar(10),
    Cliente 	varchar(50),
    NomeContato varchar(50),
    Endereco 	varchar(70),
    Cidade 		varchar(30),
    Pais 		varchar(20),
    PaisCodigo 	varchar(2),
	Regiao 		varchar(15),
	CEP		 	varchar(5),
	Latitude    varchar(10),
	Longitude  	varchar(10),
	Fax			varchar(16),
	Telefone	varchar(16)
);
ALTER TABLE DIMENSOES
ALTER COLUMN LATITUDE TYPE CHARACTER VARYING(30);
ALTER TABLE DIMENSOES
ALTER COLUMN LONGITUDE TYPE CHARACTER VARYING(30);
ALTER TABLE DIMENSOES
ALTER COLUMN FAX TYPE CHARACTER VARYING(20);
ALTER TABLE DIMENSOES
ALTER COLUMN TELEFONE TYPE CHARACTER VARYING(20);

COPY DIMENSOES 
FROM 'C:\Users\Suporte\Documents\Raiane\Dataset\ModelosDados\dimensoesDados.csv' 
DELIMITER ',' 
CSV HEADER;

SELECT * FROM DIMENSOES;
COMMIT;
-------------------------------------------------------------------------


--- Valor total das vendas e dos fretes por produto e ordem de venda;
SELECT  
    fd.produtoid, 
    fc.data,
	SUM(fd.quantidade) AS quantidade_produtos,
	SUM(fd.valor) AS total_valor,
    SUM(fc.valorfrete) AS total_valorfrete
FROM 
    FatoDetalhes fd
INNER JOIN 
    FatoCabecalho fc ON fd.cupomid = fc.cupomid
GROUP BY 
    fd.cupomid, 
    fd.produtoid, 
    fc.data
ORDER BY 
	fc.data DESC;

----------------------------------------------------------------------	
--- Saída:
/* A consulta acima retorna o id do produto, a data da venda, a quanti-
dade de produtos, o valor total e valor do frete levando em conta o tipo
do produto, o cupom ID e a data, ordenados de forma decresente pela data 
*/
----------------------------------------------------------------------
----------------------------------------------------------------------
--- Valor de venda por tipo de produto ;
SELECT  
    fd.produtoid, 
	SUM(fd.quantidade) AS quantidade_produtos,
	SUM(fd.valor) AS valor_total
FROM FatoDetalhes fd
GROUP BY fd.produtoid
--ORDER BY valor_total DESC;
ORDER BY quantidade_produtos DESC;
----------------------------------------------------------------------
-- Saída: 
/* A consulta retornou o ID produto, a quantidade vendida e o valor total 
em ordem decrescente em relação ao valor total das vendas. Assim, os três 
produtos que tiveram maior faturamento foram: 76 (com 981 vendas e faturamento
de R$ 408674.51), 29 (com 746 vendas e faturamento de R$ 102710.00) e 51 (ccom
889 vendas e faturamento de 93455.53). 
*/
----------------------------------------------------------------------
--- Venda por produto;

SELECT 
	fd.produtoid,
	COUNT(fd.cupomid) AS quantidade_vendas
FROM
	fatodetalhes fd
GROUP BY
	fd.produtoid
ORDER BY 
	quantidade_vendas DESC;
----------------------------------------------------------------------	
--- Saída:
/* A query acima retornou a quantidade de vendas por produto em order
decrescente de acordo com a quantidade de vendas
*/
----------------------------------------------------------------------

---  Quantidade e valor das vendas por dia, mês, ano;
-- por dia:
SELECT
    fc.data,
	SUM(fd.quantidade) AS quantidade_produtos,
	SUM(fd.valor) AS total_valor,
	SUM(fd.valorliquido) AS valor_liquido
FROM 
    FatoDetalhes fd
INNER JOIN 
    FatoCabecalho fc ON fd.cupomid = fc.cupomid
GROUP BY  
    fc.data
ORDER BY 
	fc.data DESC;
	
----------------------------------------------------------------------	
--- Saída:
/* A consulta acima retorna a quantidade de produtos vendidos por dia,
os valores totais das vendas diárias, bem como o seu valor líquido,
em order decrescente de data;
*/
----------------------------------------------------------------------

-- por mês // Lucro dos meses:
SELECT
    DATE_TRUNC('month', fc.data) AS mes,
	SUM(fd.quantidade) AS quantidade_produtos,
	SUM(fd.valor) AS total_valor,
	SUM(fd.valorliquido) AS valor_liquido
FROM 
    FatoDetalhes fd
INNER JOIN 
    FatoCabecalho fc ON fd.cupomid = fc.cupomid
GROUP BY  
    mes
ORDER BY 
    mes DESC;

----------------------------------------------------------------------	
--- Saída:
/* A consulta acima retorna a quantidade de produtos vendidos por mês,
os valores totais das vendas mensais, assim como o seu valor líquido,
em order decrescente de data;
*/
----------------------------------------------------------------------
	
-- por ano:
SELECT
    DATE_TRUNC('year', fc.data) AS ano,
	SUM(fd.quantidade) AS quantidade_produtos,
	SUM(fd.valor) AS total_valor,
	SUM(fd.valorliquido) AS valor_liquido
FROM 
    FatoDetalhes fd
INNER JOIN 
    FatoCabecalho fc ON fd.cupomid = fc.cupomid
GROUP BY  
    ano
ORDER BY 
    ano DESC;
	
----------------------------------------------------------------------	
--- Saída:
/* A consulta acima retorna a quantidade de produtos vendidos por ano,
os valores totais das vendas anuais, bem como o seu valor líquido,
em order decrescente de data;
*/
----------------------------------------------------------------------
	
--- Venda por cliente, cidade do cliente e estado;

--- por cliente:
SELECT
	dc.clienteid,
    COUNT(fd.cupomid) AS quantidade_vendas,
	SUM(fd.valor) AS valor_vendas,
	AVG(fd.valor) AS media_valor_gasto
FROM 
    fatocabecalho fc
INNER JOIN  
    fatodetalhes fd ON fc.cupomid = fd.cupomid
INNER JOIN
    dimensoes dc ON fc.clienteid = dc.clienteid
GROUP BY
	dc.clienteid;

----------------------------------------------------------------------	
--- Saída:
/* A consulta acima retorna a quantidade de vendas por cliente,
os valores faturados com elas e a média dos valores gastos pelo cliente
*/
----------------------------------------------------------------------

--- por cidade:

SELECT
	COUNT(DISTINCT(dc.clienteid)) AS quantidade_clientes,
    COUNT(fd.cupomid) AS quantidade_vendas,
	SUM(fd.valor) AS valor_vendas,
    dc.cidade
FROM 
    fatocabecalho fc
INNER JOIN  
    fatodetalhes fd ON fc.cupomid = fd.cupomid
INNER JOIN
    dimensoes dc ON fc.clienteid = dc.clienteid
GROUP BY
    dc.cidade
ORDER BY
	valor_vendas desc;
	
----------------------------------------------------------------------	
--- Saída:
/* A consulta acima retorna a quantidade de clientes distintos, a 
quantidade e o valor das vendas  por cidade em order decrescente de
valor de vendas
*/
----------------------------------------------------------------------
	
--- por região:
SELECT
	COUNT(DISTINCT(dc.clienteid)) AS quantidade_clientes,
    COUNT(fd.cupomid) AS quantidade_vendas,
	SUM(fd.valor) AS valor_vendas,
    dc.regiao
FROM 
    fatocabecalho fc
INNER JOIN  
    fatodetalhes fd ON fc.cupomid = fd.cupomid
INNER JOIN
    dimensoes dc ON fc.clienteid = dc.clienteid
GROUP BY
    dc.regiao
ORDER BY
	valor_vendas desc;

----------------------------------------------------------------------	
--- Saída:
/* A consulta acima retorna a quantidade de clientes distintos, a 
quantidade e o valor das vendas por região em order decrescente de 
valor de vendas;
*/
----------------------------------------------------------------------

--- média de produto:
SELECT
    AVG(fd.quantidade) AS quantidade_produtos
FROM 
    fatocabecalho fc
INNER JOIN  
    fatodetalhes fd ON fc.cupomid = fd.cupomid;
	
----------------------------------------------------------------------	
--- Saída:
/* A consulta acima retorna a média de produtos que são vendidos por 
pedido
*/
----------------------------------------------------------------------

--- Média de compras que um cliente faz:
SELECT
    quantidade_compras,
    qnt_cliente,
    quantidade_compras / qnt_cliente AS media
FROM (
    SELECT
        COUNT(fc.cupomid) AS quantidade_compras,
        COUNT(DISTINCT fc.clienteid) AS qnt_cliente
    FROM 
        fatocabecalho fc
    INNER JOIN  
        fatodetalhes fd ON fc.cupomid = fd.cupomid
) AS subconsulta;

----------------------------------------------------------------------	
--- Saída:
/* A consulta acima retorna a quantidade de vendas, de clientes distintos
e a média entre estas duas variáveis, que representa a média de compras
que cada cliente faz
*/
----------------------------------------------------------------------


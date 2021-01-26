
CREATE DATABASE BDVENDAS;

/***** Usuario admin com permissao para liberar para outros usuarios *****/
CREATE USER 'admin1'@'%' IDENTIFIED BY '123456';
GRANT ALL ON *.* TO 'admin1'@'%' WITH GRANT OPTION;

/***** Funcionario teste com permissao para fazer selects no banco atual *****/
CREATE USER 'funcionario1'@'localhost' IDENTIFIED BY '123456'
PASSWORD EXPIRE INTERVAL 30 DAY;
GRANT SELECT ON bdvendas.*
TO funcionario1@localhost;

flush privileges;

USE BDVENDAS;
SELECT * FROM bdvendas.tb_vendas;
SELECT * FROM bdvendas.tb_funcionarios;
/***** TABELA CLIENTES *****/
CREATE TABLE tb_clientes (
  id int auto_increment primary key,
  nome varchar(100),
  rg varchar (30),
  cpf varchar (20),
  email varchar(200),
  telefone varchar(30),
  celular varchar(30),
  cep varchar(100),
  endereco varchar (255),
  numero int,
  complemento varchar (200),
  bairro varchar (100),
  cidade varchar (100),
  estado varchar (2)
);
/*****************/

/***** TABELA FORNECEDORES *****/
CREATE TABLE tb_fornecedores (
  id int auto_increment primary key,
  nome varchar(100),
  cnpj varchar (100),
  email varchar(200),
  telefone varchar(30),
  celular varchar(30),
  cep varchar(100),
  endereco varchar (255),
  numero int,
  complemento varchar (200),
  bairro varchar (100),
  cidade varchar (100),
  estado varchar (2)
);
/*****************/

/***** TABELA FUNCIONARIOS *****/
CREATE TABLE tb_funcionarios (
  id int auto_increment primary key,
  nome varchar(100),
  rg varchar (30),
  cpf varchar (20),
  email varchar(200),
  senha varchar(10),
  cargo varchar(100),
  nivel_acesso varchar(50),
  telefone varchar(30),
  celular varchar(30),
  cep varchar(100),
  endereco varchar (255),
  numero int,
  complemento varchar (200),
  bairro varchar (100),
  cidade varchar (100),
  estado varchar (2)
);
/*****************/


/***** TABELA PRODUTOS *****/
CREATE TABLE tb_produtos (
  id int auto_increment primary key,
  descricao varchar(100),
  preco decimal (10,2),
  qtd_estoque int,
  for_id int,

  FOREIGN KEY (for_id) REFERENCES tb_fornecedores(id)
);
/*****************/

/***** TABELA VENDAS *****/
CREATE TABLE tb_vendas (
  id int auto_increment primary key,
  cliente_id int,
  data_venda datetime,
  total_venda decimal (10,2),
  observacoes text,

  FOREIGN KEY (cliente_id) REFERENCES tb_clientes(id)
);
/*****************/

/***** TABELA ITENS_VENDAS *****/
CREATE TABLE tb_itensvendas (
  id int auto_increment primary key,
  venda_id int,
  produto_id int,
  qtd int,
  subtotal decimal (10,2),

  FOREIGN KEY (venda_id) REFERENCES tb_vendas(id),
  FOREIGN KEY (produto_id) REFERENCES tb_produtos(id)
);
/*****************/

select * from tb_clientes;
select * from tb_vendas;
select * from tb_produtos;
select * from tb_itensvendas;

select * from tb_clientes where nome like 'a%';

insert into tb_funcionarios (nome,rg,cpf,email,senha,cargo,nivel_acesso,telefone,celular,cep,endereco,numero,complemento,bairro,cidade,estado) values ("Vitor",1111111,232323223,"admin","123456","admin","Admin",23434242344,234324344,13010215,"Rua 10 de setem",87,"ap","centro","campinas","sp");

insert into tb_funcionarios (nome,rg,cpf,email,senha,cargo,nivel_acesso,telefone,celular,cep,endereco,numero,complemento,bairro,cidade,estado) values ("Vitor 2",1111111,232323223,"usuario","123456","admin","Usuário",23434242344,234324344,13010215,"Rua 10 de setem",87,"ap","centro","campinas","sp");

select * from tb_funcionarios;
select * from tb_clientes;

/***** View para selecionar todos os clientes *****/
Create view selecionar_todos_clientes AS
select * from tb_clientes;

/***** View para selecionar todos os fornecedores *****/
Create view selecionar_todos_fornecedores AS
select * from tb_fornecedores;

/***** View para selecionar todos os funcionarios *****/
Create view selecionar_todos_funcionarios AS
select * from tb_funcionarios;

/***** Procedure para localizar produto pelo id da venda *****/
DROP procedure IF EXISTS prod_venda;
DELIMITER $$
CREATE PROCEDURE prod_venda (IN id_da_venda varchar(20))
BEGIN
SELECT d.descricao, d.preco, d.qtd_estoque
FROM bdvendas.tb_produtos d, bdvendas.tb_itensvendas dl
WHERE d.id = dl.produto_id AND dl.venda_id = id_da_venda;
END$$

/***** Procedure para retornar total de vendas por data especifica *****/
DROP procedure IF EXISTS vendas_xData;
DELIMITER $$
CREATE PROCEDURE vendas_xData (IN data_busca date)
BEGIN
select sum(total_venda) as total from tb_vendas where data_venda = ? = data_busca;
END$$

/***** Procedure para retornar total de vendas por periodo *****/
DROP procedure IF EXISTS vendas_xData_yData;
DELIMITER $$
CREATE PROCEDURE vendas_xData_yData (IN data_init date, IN data_fim date)
BEGIN
select v.id ,  v.data_venda, c.nome, v.total_venda, v.observacoes  from tb_vendas as v 
inner join tb_clientes as c on(v.cliente_id = c.id) where v.data_venda BETWEEN data_init AND data_fim;
END$$

/***** Trigger para atualizar tabela de produtos depois de uma venda*****/
CREATE TRIGGER total_sal2 
AFTER UPDATE ON bdvendas.tb_vendas
FOR EACH ROW
BEGIN
UPDATE bdvendas.tb_produtos
SET tb_produtos.qtd_estoque = tb_produtos.qtd_estoque - OLD.qtd_estoque
WHERE tb_produtos.id = NEW.id;
END;




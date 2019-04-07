-- create the table
create table if not exists movie (
    id integer primary key AUTO_INCREMENT,
    title text,
    price float,
	  categoryId integer
);

-- insert some data
insert into movie values (1, 'Jaws', 9.99, 1);
insert into movie values (2, 'Jaws2', 4, 1);
insert into movie values (3, 'Mama Mia', 9.99, 2);
insert into movie values (4, 'Forget Paris', 8, 3);

-- create the table
create table if not exists category (
    id integer primary key AUTO_INCREMENT,
    title text
);

-- insert some data
insert into category values (1, 'horror');
insert into category values (2, 'romance');
insert into category values (3, 'musical');
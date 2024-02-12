CREATE DATABASE db_LibraryManagement;
use db_LibraryManagement;



create table table_publisher(
    PublisherName VARCHAR(50) PRIMARY KEY NOT NULL,
    PublisherAddress VARCHAR(100) NOT NULL,
    PublisherPhone VARCHAR(20) NOT NULL
);


create table table_book(
    BookID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    Book_Title VARCHAR(100) NOT NULL,
    PublisherName VARCHAR(100) NOT NULL
);


create table table_library_branch(
    library_branch_BranchID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    library_branch_BranchName VARCHAR(100) NOT NULL,
    library_branch_BranchAddress VARCHAR(200) NOT NULL
);


select * from table_library_branch;

create table table_borrower(
    CardNo INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    BorrowerName VARCHAR(100) NOT NULL,
    BorrowerAddress VARCHAR(200) NOT NULL,
    BorrowerPhone VARCHAR(50) NOT NULL
);



CREATE Table table_book_copies(
    CopiesID INT PRIMARY KEY NOT NULL,
    BookID INT NOT NULL,
    BranchID INT NOT NULL,
    No_Of_Copies INT NOT NULL
);


create table table_book_authors(
    AuthorID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    BookID INT NOT NULL,
    AuthorName VARCHAR(50) NOT NULL,
    CONSTRAINT fk_book_id3 FOREIGN KEY (BookID) REFERENCES table_book(BookID) ON UPDATE CASCADE ON DELETE CASCADE
);



create table if not exists `book`(
    `isbn` CHAR(13) NOT NULL,
    `title` VARCHAR(80)  NOT NULL,
    `author` VARCHAR(80) NOT NULL,
    `category` VARCHAR(80) NOT NULL,
    `price` INT NOT NULL,
    `copies` INT NOT NULL
);


create table if not exists `book_issue`(
    `issue_id` int NOT NULL,
    `member` VARCHAR(20) NOT NULL,
    `book_isbn` VARCHAR(13) NOT NULL,
    `due_date` DATE NOT NULL,
    `last_reminded` DATE DEFAULT NULL
);

DELIMITER //

create trigger issue_book BEFORE INSERT ON book_issue
for each ROW
begin
    set new.due_date = DATE_ADD(CURRENT_DATE(), INTERVAL 20 DAY);
    UPDATE member set balance= balance - (select price from book where isbn = new.book_isbn) WHERE username = new.member;
    update book set copies = copies - 1 where isbn = new.book_isbn;
    delete from pending_book_requests where member = new.member and book_isbn = new.book_isbn;
end //

DELIMITER;




DELIMITER //

create trigger return_book before delete on book_issue
for each ROW
BEGIN
    declare book_price decimal(10,2);

    -- fetch the price of the book being returned
    select price into book_price from book where isbn = old.book_isbn;

    -- check if book_price is null, if so, set it to 0
    if book_price is null THEN
        set book_price = 0;
    end if;

    -- update the member's balanace
    update member set balance = balance + book_price where username = old.member;

    -- increase the number of copies of the book
    update book set copies = copies + 1 where isbn = old.book_isbn;
END //

DELIMITER ;






create table if not exists `librarian`(
    `id` int not null,
    `username` VARCHAR(20) not null,
    `password` char(40) not null
);



create table if not exists `member`(
    `id` int not null,
    `username` VARCHAR(20) not null,
    `password` char(40) not null,
    `name` VARCHAR(80) not null,
    `email` VARCHAR(80) not null,
    `balance` int not null
);



DELIMITER //

create trigger add_member after insert on member
for each ROW
begin
    delete from pending_registrations where username=new.username;
end;

//

create trigger remove_member after delete on member
for each ROW
begin
    delete from pending_book_requests where member = old.username;
end;

//

DELIMITER ;




create table if not exists `pending_book_requests`(
    `request_id` int not null,
    `member` VARCHAR(20) not null,
    `book_isbn` VARCHAR(13) not null,
    `time` TIMESTAMP not null DEFAULT CURRENT_TIMESTAMP
);


create table if not exists `pending_registrations`(
    `username` VARCHAR(30) not null,
    `password` char(20) not null,
    `name` VARCHAR(40) not null,
    `email` VARCHAR(20) not null,
    `balance` int(10),
    `time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);




alter TABLE `book` add PRIMARY KEY(`isbn`);

alter table `book_issue` add PRIMARY KEY (`issue_id`);

alter table `librarian` add primary key (`id`), add unique KEY `username`(`username`);

alter table `member` add primary key (`id`), add unique key `username`(`username`), add unique key `email`(`email`);


alter table `pending_book_requests` add primary key (`request_id`);


alter table `pending_registrations` add primary key (`username`);
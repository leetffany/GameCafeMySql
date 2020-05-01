/*ok*/
create table STAFF
(
  username varchar(50) not null,
  password varchar(255) not null,
	StaffID int not null
primary key,
	FirstName varchar(15) not null,
	MiddleName varchar(15),
	LastName varchar(15) not null,
	Ssn int not null,
	SuperVisorID int,
	PayRate Decimal (4,2) not null,
	Tips Decimal (5,2),
	Bonus Decimal (5,2),
	StaffType Char(1),
    constraint STAFF_SUPERVISOR_fk
		foreign key (SuperVisorID) references STAFF(StaffID)
			on delete set null
);



create table GAME
(
	GameID varchar(30) not null
		primary key,
	PlayerNum int,
	BoardName varchar(30),
	ConsoleType varchar(30),
	ControllerAmnt int,
	ComputerNum int,
	GameType char(1)
);

create table BOOTH
(
	BoothID varchar(30) not null
		primary key,
	Floor int not null,
	Seats int not null,
	Availability boolean not null
);

/*ok*/
CREATE TABLE CUSTOMER
(
  username varchar(50) not null,
  password varchar(50) not null,
	CustomerID int not null primary key,
	FirstName varchar(15) ,
	MiddleName varchar(15),
	LastName varchar(15),
	Zip varchar(9),
	Street varchar(50),
	City varchar(30),
	State char(2),
	Hours int,
	GameID varchar(30),
	BoothID varchar(30),
    constraint CUSTOMER_GAME_fk
		foreign key  (GameID) references GAME(GameID)
			on delete set null,
	constraint CUSTOMER_BOOTH_fk
		foreign key (BoothID) references BOOTH(BoothID)
			on delete set null
);


/*ok*/
create table MEMBER
(
	MCustomerID int not null ,
	Points int,
	MembershipType varchar(8),
    constraint MEMBER_uk
		primary key (MCustomerID),
	constraint MEMBER_CUSTOMERID_fk
		foreign key(MCustomerID) references CUSTOMER(CustomerID)
			on delete cascade
);


/*ok*/
create table CUSTOMER_ORDER
(
	OCustomerID int not null ,
	OrderNum int not null,
	Cost decimal(3,2),
	Payment varchar(30),
	constraint CUSTOMER_ORDER_pk
		primary key(OCustomerID),
	constraint CUSTOMER_ORDER_CUSTID_fk
		foreign key (OCustomerID) references CUSTOMER(CustomerID)
			on delete cascade
);

/*ok*/
create table MENU_ITEM
(
	ItemID int not null
		primary key,
	Name varchar(55),
	Price decimal (4,2),
	Quantity int,
	Alcohol decimal (3,2),
	Vegan varchar(1),
	ItemType char(1)
);

/*ok*/
create table ORDER_CONTENTS
(
	CustomerID int not null ,
    OrderNum int not null,
    ItemID int not null,
    constraint ORDER_CONTENTS_pk
		primary key(CustomerID, OrderNum, ITemID),
	constraint ORDER_CONTENTS_CUSTOMER_fk
		foreign key (CustomerID) references CUSTOMER_ORDER(OCustomerID)
			on delete cascade,
	constraint ORDER_CONTENTS_MENU_ITEM_fk
		foreign key (ItemID) references MENU_ITEM(ItemID)
);



/*ok*/
create table MEMBERS_VIEW
(
  username varchar(50) not null,
  password varchar(255) not null,
	CustomerID int not null
		primary key AUTO_INCREMENT,
	FirstName varchar(15) not null,
	MiddleName varchar(15),
	LastName varchar(15) not null,
	Zip char(9) not null,
	Street varchar(50) not null,
	City varchar(30) not null,
	State char(2) not null,
	Hours int,
	GameID int,
	BoothID int,
	Points int,
	MembershipType varchar(8),
    constraint MEMBER_VIEW_fk
		foreign key(CustomerID) references CUSTOMER(CustomerID)
);

/* update CUSTOMER !!
if 123123(updat new.CustomerID) in MEMBER
then Points(20000), MembershiptType(SILVER) FROM MEMBER = new Points, new MembershipType
INSERT THEM MEMEBRS_VIEW
*/

/*ok*/
create table DRINKS_MENU_VIEW
(
	ItemID int not null
		primary key,
	Name varchar(15),
	Price decimal (4,2),
	Quantity int,
	Alcohol decimal (3,2),
	constraint DRINKS_MENU_fk
		foreign key(ItemID) references MENU_ITEM(ItemID)
);

/*ok*/
create table FOOD_MENU_VIEW
(
	ItemID int not null
		primary key,
	Name varchar(15),
	Price decimal(4,2),
	Quantity int,
	vegan varchar(1),
    constraint FOOD_MENU_fk
		foreign key(ItemID) references MENU_ITEM(ItemID)
);
/*ok*/
delimiter //
CREATE TRIGGER customer_update_trigger AFTER UPDATE on gamelounge.CUSTOMER
    FOR EACH ROW
    BEGIN
        DECLARE newPoints int;
        DECLARE newMembershipType varchar(8);

        if old.CustomerID in (select CustomerID from MEMBERS_VIEW) then
            DELETE FROM MEMBERS_VIEW WHERE CustomerID = old.CustomerID;
        end if;

        if new.CustomerID in (select MCustomerID from MEMBER) then
            SELECT Points, MembershipType INTO newPoints, newMembershipType
            FROM MEMBER
            WHERE MCustomerID = new.CustomerID;

            INSERT INTO MEMBERS_VIEW values (new.username, new.password, new.CustomerID, new.FirstName, new.MiddleName, new.LastName, new.Zip, new.Street, new.City, new.State,
                                              new.Hours, new.GameID, new.BoothID, newPoints, newMembershipType);
        end if;

    end //
  delimiter ;


/*function*/

/**/
 delimiter //
 CREATE FUNCTION check_type (Itemtype CHAR, Alcohol DECIMAL(3,2), Vegan VARCHAR) RETURNS BOOLEAN
     BEGIN
         DECLARE isGood BOOLEAN default FALSE;
         CASE (Itemtype)
            WHEN 'F' THEN SET isGood = (Alcohol IS NULL);
            WHEN 'D' THEN SET isGood = (Vegan IS NULL);
        ELSE
            BEGIN
            END;
         END CASE;
         RETURN isGood;
     end //
  delimiter ;

/**/
/* if ItemType is wrong then error messages: inccorct attribute for type.*/
  delimiter //
   CREATE TRIGGER menu_insert_trigger BEFORE INSERT ON gamelounge.MENU_ITEM
       for each row
       begin
           DECLARE isGood BOOLEAN;
           -- check participation and disjoint
           SET isGood = check_type(new.Itemtype, new.Alcohol, new.Vegan);
           IF (!isGood) THEN
               signal sqlstate '45000'
               SET MESSAGE_TEXT = 'Incorrect attribute values for itemtype';
           end if;
       end //
  delimiter ;

  /*after insert ok*/
  delimiter //
   CREATE TRIGGER menu_item_insertafter_trigger AFTER INSERT ON gamelounge.MENU_ITEM
       for each row
       begin
           IF new.Itemtype = 'D' then
              INSERT INTO gamelounge.DRINKS_MENU_VIEW value (new.ItemID, new.Name, new.Price, new.Quantity, new.Alcohol);
  		 end if;
  		 IF new.Itemtype = 'F' then
  			INSERT INTO gamelounge.FOOD_MENU_VIEW value (new.ItemID, new.Name, new.Price, new.Quantity, new.vegan);
           end if;
       end //
  delimiter ;






/* */
/* if ItemType is wrong then error messages: inccorct attribute for type.*/
  delimiter //
  CREATE TRIGGER menu_item_update_trigger BEFORE UPDATE ON gamelounge.MENU_ITEM
      for each row
      begin
          DECLARE isGood BOOLEAN;

          SET isGood = check_type(new.Itemtype, new.Alcohol, new.Vegan);

          IF (!isGood) THEN
              signal sqlstate '45000'
              SET MESSAGE_TEXT = 'Incorrect attribute values for item type.';
              END IF;

      end //
 delimiter ;


/**/
 delimiter //
  CREATE TRIGGER menu_item_updateafter_trigger AFTER UPDATE ON gamelounge.MENU_ITEM
      for each row
      begin

          -- delete old row from materialized view then insert new row
          if old.Itemtype = 'F' then
             DELETE FROM gamelounge.FOOD_MENU_VIEW WHERE FOOD_MENU_VIEW.ItemID = old.ItemID;
          end if;

          if new.Itemtype = 'F' then
             INSERT INTO gamelounge.FOOD_MENU_VIEW value (new.ItemID, new.Name, new.Price, new.Quantity, new.vegan);
 		 end if;

                   -- delete old row from materialized view then insert new row
          if old.Itemtype = 'D' then
             DELETE FROM gamelounge.DRINKS_MENU_VIEW WHERE DRINKS_MENU_VIEW.ItemID = old.ItemID;
          end if;

          if new.Itemtype = 'D' then
             INSERT INTO gamelounge.DRINKS_MENU_VIEW value (new.ItemID, new.Name, new.Price, new.Quantity, new.Alcohol);
 		 end if;
      end //
 delimiter ;


/*ok*/
 delimiter //
  CREATE TRIGGER menu_item_delete_trigger BEFORE DELETE ON gamelounge.MENU_ITEM
      for each row
      begin
          -- delete old row from DRINKS_MENU_VIEW
          if old.ItemID in (select ItemID from DRINKS_MENU_VIEW) then
             DELETE FROM gamelounge.DRINKS_MENU_VIEW WHERE DRINKS_MENU_VIEW.ItemID = old.ItemID;
          end if;
 		 -- delete old row from FOOD_MENU_VIEW
          if old.ItemID in (select ItemID from FOOD_MENU_VIEW) then
             DELETE FROM gamelounge.FOOD_MENU_VIEW WHERE FOOD_MENU_VIEW.ItemID = old.ItemID;
          end if;
      end //
 delimiter ;



/**/
/*insert BEFORE and AFTERok */
insert into MENU_ITEM
values(12123, 'applepie', '9.99', 2, NULL, NULL, 'F');
insert into MENU_ITEM
values(12124, 'VeganCheesecake', '5.99', 3, NULL, NULL, 'F');
/*insert OK. in DRINK_VIEW_ITEM SINCE IT IS D*/
insert into MENU_ITEM
values(12125, 'Ipa(12oz)', '7.99', 4, '0.07', NULL, 'D');

/*triggered*/
insert into MENU_ITEM
values(123123, 'Bluberry Muffin', '9.89', 4, NULL, NULL, 'W');

/*trigger*/
insert into MENU_ITEM
values(12126, 'Sparking Bunny', '15.99', 5, '0.10', NULL, 'D');

insert into MENU_ITEM
values(12127, 'hanarasberry', '17.99', 1, '0.08', NULL, 'D');


/*UPDATE BEFORE and AFTER OK*/
update MENU_ITEM
set Price = '4.99'
where ItemID = 123123;

/*delete ok */
DELETE FROM MENU_ITEM
where ItemID = 10000;


insert into MENU_ITEM
values(10000, 'TEST', '9.89', 4, NULL, NULL, 'F');

update MENU_ITEM
set Vegan = 'V'
where ItemID=12123;


insert into MENU_ITEM
values(23234, 'Test Value1', '9.99', 43, NULL, NULL, 'F');
insert into MENU_ITEM
values(23432, 'Test Value2', '9.99', 53, NULL, NULL, 'M');
insert into MENU_ITEM
values(233452, 'Test Value3', '9.89', 45, '98.23', '23.53', 'M');
insert into MENU_ITEM
values(234672, 'Test Value4', '9.89', 45, NULL, NULL, 'W');
insert into MENU_ITEM
values(287632, 'Test Value5', '9.99', 45, '45.34', '34.23', 'W');

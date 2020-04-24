
/*ok*/
CREATE TABLE CUSTOMER
(
  username varchar(50) not null,
  password varchar(255) not null,
	CustomerID int not null
		primary key,
	FirstName varchar(15) not null,
	MiddleName varchar(15),
	LastName varchar(15) not null,
	Zip varchar(9) not null,
	Street varchar(50) not null,
	City varchar(30) not null,
	State char(2) not null,
	Hours int,
	GameID int,
	BoothID int,
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
	MCustomerID int not null,
	Points int,
	MembershipType varchar(8),
    constraint MEMBER_uk
		primary key (MCustomerID),
	constraint MEMBER_CUSTOMERID_fk
		foreign key(MCustomerID) references CUSTOMER(CustomerID)
			on delete cascade
);


/*ok*/
create table MEMBERS_VIEW
(
	CustomerID int not null
		primary key,
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
    constraint MEMBER_VIEW_pk
		foreign key(CustomerID) references CUSTOMER(CustomerID)
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




/*function*/

/*ok added else*/
 delimiter //
 CREATE FUNCTION check_type (Itemtype CHAR, Alcohol DECIMAL(4,2), Vegan BOOLEAN) RETURNS BOOLEAN
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

/*ok*/
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






/* ok before update */
/* if ItemType is wrong then error messages: inccorct attribute for type.*/
  delimiter //
  CREATE TRIGGER menu_item_update_trigger BEFORE UPDATE ON gamelounge.MENU_ITEM
      for each row
      begin
          DECLARE isGood BOOLEAN;

          SET isGood = check_type(new.Itemtype, new.Alcohol, new.Vegan);

          IF (!isGood) THEN
              signal sqlstate '45000'
              SET MESSAGE_TEXT = 'Incorrect attribute values for item type';
              END IF;

      end //
 delimiter ;


/* ok after update*/
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


/*ok before delete*/
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

/*****view *****/
/*ok*/
create table DRINKS_MENU_VIEW
(
	ItemID int not null
		primary key,
	Name varchar(15),
	Price decimal (5,2),
	Quantity int,
	Alcohol decimal (4,2),
	constraint DRINKS_MENU_fk
		foreign key(ItemID) references MENU_ITEM(ItemID)
);



/*insert ok */
insert into MENU_ITEM
values(12123, 'applepie', '9.99', 2, NULL, NULL, 'F');
/*update ok*/
update MENU_ITEM
set Price = '8.99'
where ItemID = 12123;
/*delete ok */
DELETE FROM MENU_ITEM
where ItemID = 12123;


/*trigger*/
insert into MENU_ITEM
values(12124, 'Vegancheesecake', '9.99', 3, NULL, yes, 'F');
/*insert OK. in DRINK_VIEW_ITEM SINCE IT IS D*/
insert into MENU_ITEM
values(12125, 'ipa', '9.89', 4, '0.07', NULL, 'D');
/*trigger*/
insert into MENU_ITEM
values(12126, 'sparkingbunny', '9.89', 5, '0.10', NULL, 'D');

insert into MENU_ITEM
values(12127, 'hanarasberry', '9.99', 1, '0.08', '34.23', NULL, 'D');



/*ok*/
create table FOOD_MENU_VIEW
(
	ItemID int not null
		primary key,
	Name varchar(15),
	Price decimal(5,2),
	Quantity int,
	vegan boolean,
    constraint FOOD_MENU_fk
		foreign key(ItemID) references MENU_ITEM(ItemID)
);



/*ok*/
create table GAME
(
	GameID int not null
		primary key,
	PlayerNum int,
	BoardName varchar(30),
	ConsoleType varchar(30),
	ControllerAmnt int,
	ComputerNum int,
	GameType char(1)
);

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

/*ok*/
create table STAFF_PHONE
(
	PStaffID int not null,
	PhoneNum varchar(15) not null,
    constraint STAFF_PHONE_pk
		primary key (PStaffID, PhoneNum),
	constraint STAFF_PHONE_fk
		foreign key (PStaffID) references STAFF(StaffID)
		on delete cascade
);

/*ok*/
create table MENU_ITEM
(
	ItemID int not null
		primary key,
	Name varchar(15),
	Price decimal (5,2),
	Quantity int,
	Alcohol decimal (4,2),
	Vegan boolean,
	ItemType char(1)
);

/*ok*/
create table BOOTH
(
	BoothID int not null
		primary key,
	Floor int not null,
	Seats int not null,
	Availability boolean not null
);

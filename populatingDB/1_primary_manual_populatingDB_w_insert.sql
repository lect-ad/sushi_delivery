INSERT INTO TransportTypes 
			(Type) 
	VALUES 
            ('Auto'),
            ('Scooter'),
            ('Bicycle');
            
            
INSERT INTO Couriers 
			(FirstName, LastName, BirthDate, PassportID, StartWorkDate, Phone)
	VALUES
			('Oleg', 'Trufanov', '1986-11-24', '45083496719264', '2020-01-03', '375296319573'),
            ('Kirill', 'Panin', '1992-03-6', '95878236482754', '2020-01-12', '375449678326'),
            ('Alla', 'Shemlei', '1997-02-11', '84721699473127', '2020-01-05', '375297230712'),
            ('Sergei', 'Mironenko', '1983-08-04', '73610847592236', '2020-01-09', '375338471299'),
            ('Andrei', 'Kazak', '2001-04-17', '13249672604810', '2020-01-09', '375337592317'),
            ('Maxim', 'Valenkov', '1993-09-15', '94712649273857', '2020-01-14', '375299570270');
            

INSERT INTO HuskyOwnershipDict
			(id, HuskyOwnership)
	VALUES
			(1, 'NO'),
            (2, 'YES');
            

INSERT INTO CityDistrictsDict
			(district, DeliveryZone)
	VALUES
			('Central', 1),
            ('RW', 1),
            ('Fest', 2),
            ('Volotova', 3);

            
INSERT INTO RestaurantsDict
			(RestaurantAddr, CityDistrict)
	VALUES
			('Sviridova 14', 'Volotova'),
            ('Kirova 42', 'Central');
            
            
INSERT INTO PaymentMethods
			(PayMethod, LaunchDate)
	VALUES
			('Cash', '2020-01-09'),
            ('Card', '2020-01-11'),
            ('Online', '2020-01-13');
            
            
INSERT INTO OrderMethodsDict
			(OrdMethod, LaunchDate)
	VALUES
			('Phone', '2020-01-09'),
            ('Website', '2020-01-11'),
            ('App', '2020-01-13');
            
            
INSERT INTO Assortment
			(Item, Weight, Price)
	VALUES
			('CaliforniaRoll', 300, 6.8),
            ('PhiladelphiaRoll', 400, 7.24),
            ('ClassicCrabRoll', 250, 4.2),
            ('ClassicSalmonRoll', 400, 6.42),
            ('CucumberRoll', 300, 3.8),
            ('AlaskaRoll', 200, 4.25),
            ('KingCrabRoll', 200, 5.12),
            ('DragonRoll', 100, 2.9),
            ('BostonRoll', 300, 6.16);
            
            
INSERT INTO StatusDict
			(Status)
	VALUES
			('Placed'),
            ('Confirmed'),
            ('Fulfilled'),
            ('Canceled');
            
            
INSERT INTO Transport
			(Type, RegNum)
	VALUES
			((SELECT id FROM transporttypes WHERE Type = 'Auto'), 'ET-3456'),
            ((SELECT id FROM transporttypes WHERE Type = 'Auto'), 'EB-8723'),
            ((SELECT id FROM transporttypes WHERE Type = 'Scooter'), 'ET-1298'),
            ((SELECT id FROM transporttypes WHERE Type = 'Scooter'), 'ET-4576'),
            ((SELECT id FROM transporttypes WHERE Type = 'Bicycle'), 'INV01'),
            ((SELECT id FROM transporttypes WHERE Type = 'Bicycle'), 'INV02');
            
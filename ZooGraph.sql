-- Project: Графовая база данных "Зоопарк"
-- Узлы  (NODE): Animal, Enclosure, Feed, Staff
-- Рёбра (EDGE): LivesIn, Eats, Compatible, CaresFor

/*
Created: 01.05.2026
Modified: 01.05.2026
Model: Microsoft SQL Server 2022
Database: MS SQL Server 2022
*/
 
-- ============================================================
-- СОЗДАНИЕ БАЗЫ ДАННЫХ
-- ============================================================
 
Use master
go
 
if exists (select 1 from sys.databases where name = 'Zoo')
begin
    alter database Zoo set single_user with rollback immediate;
    drop database Zoo;
end;
go
 
create database Zoo;
go
 
use Zoo;
go
 
-- ============================================================
-- СОЗДАНИЕ ТАБЛИЦ УЗЛОВ (NODE TABLES)
-- ============================================================
 
-- ------------------------------------------------------------
-- Таблица узлов: Animal (Животные)
-- status: healthy | sick | quarantine | treatment
-- gender: M | F
-- ------------------------------------------------------------
 
CREATE TABLE [dbo].[Animal]
(
 [id]           Int            NOT NULL,
 [name]         Nvarchar(50)   COLLATE Cyrillic_General_CI_AS NOT NULL,
 [species]      Nvarchar(50)   COLLATE Cyrillic_General_CI_AS NOT NULL,
 [age]          Int            NOT NULL,
 [gender]       Nchar(1)       COLLATE Cyrillic_General_CI_AS NOT NULL
                CHECK ([gender] = N'F' OR [gender] = N'M'),
 [weight_kg]    Decimal(6,2)   NOT NULL,
 [status]       Nvarchar(20)   COLLATE Cyrillic_General_CI_AS DEFAULT (N'healthy') NOT NULL
                CHECK ([status] = N'treatment' OR [status] = N'quarantine'
                    OR [status] = N'sick'      OR [status] = N'healthy'),
 [arrival_date] Date           NOT NULL
)
AS NODE
ON [PRIMARY]
go
 
ALTER TABLE [dbo].[Animal] ADD CONSTRAINT [PK_Animal] PRIMARY KEY ([id])
 ON [PRIMARY]
go
 
-- ------------------------------------------------------------
-- Таблица узлов: Enclosure (Вольеры)
-- enclosure_type: predators | herbivores | birds | reptiles | arctic | tropical
-- climate:        tropical | steppe | arctic | temperate | desert
-- ------------------------------------------------------------
 
CREATE TABLE [dbo].[Enclosure]
(
 [id]             Int           NOT NULL,
 [name]           Nvarchar(50)  COLLATE Cyrillic_General_CI_AS NOT NULL,
 [enclosure_type] Nvarchar(30)  COLLATE Cyrillic_General_CI_AS NOT NULL
                  CHECK ([enclosure_type] = N'tropical'   OR [enclosure_type] = N'arctic'
                      OR [enclosure_type] = N'reptiles'   OR [enclosure_type] = N'birds'
                      OR [enclosure_type] = N'herbivores' OR [enclosure_type] = N'predators'),
 [area_sqm]       Decimal(7,2)  NOT NULL,
 [climate]        Nvarchar(20)  COLLATE Cyrillic_General_CI_AS NOT NULL
                  CHECK ([climate] = N'desert'   OR [climate] = N'temperate'
                      OR [climate] = N'arctic'   OR [climate] = N'steppe'
                      OR [climate] = N'tropical'),
 [capacity]       Int           NOT NULL,
 [is_indoor]      Bit           DEFAULT ((0)) NOT NULL
)
AS NODE
ON [PRIMARY]
go
 
ALTER TABLE [dbo].[Enclosure] ADD CONSTRAINT [PK_Enclosure] PRIMARY KEY ([id])
 ON [PRIMARY]
go
 
-- ------------------------------------------------------------
-- Таблица узлов: Feed (Корма)
-- feed_type: meat | fish | hay | vegetables | fruits | grain | insects | special
-- ------------------------------------------------------------
 
CREATE TABLE [dbo].[Feed]
(
 [id]              Int           NOT NULL,
 [name]            Nvarchar(50)  COLLATE Cyrillic_General_CI_AS NOT NULL,
 [feed_type]       Nvarchar(20)  COLLATE Cyrillic_General_CI_AS NOT NULL
                   CHECK ([feed_type] = N'special'    OR [feed_type] = N'insects'
                       OR [feed_type] = N'grain'      OR [feed_type] = N'fruits'
                       OR [feed_type] = N'vegetables' OR [feed_type] = N'hay'
                       OR [feed_type] = N'fish'       OR [feed_type] = N'meat'),
 [calories_per_kg] Decimal(7,2)  NOT NULL,
 [storage_temp]    Nvarchar(20)  COLLATE Cyrillic_General_CI_AS NOT NULL,
 [unit_cost]       Decimal(8,2)  NOT NULL,
 [supplier]        Nvarchar(50)  COLLATE Cyrillic_General_CI_AS NOT NULL
)
AS NODE
ON [PRIMARY]
go
 
ALTER TABLE [dbo].[Feed] ADD CONSTRAINT [PK_Feed] PRIMARY KEY ([id])
 ON [PRIMARY]
go
 
-- ------------------------------------------------------------
-- Таблица узлов: Staff (Сотрудники)
-- role:  keeper | vet | dietitian | trainer
-- shift: morning | day | night
-- ------------------------------------------------------------
 
CREATE TABLE [dbo].[Staff]
(
 [id]               Int           NOT NULL,
 [name]             Nvarchar(60)  COLLATE Cyrillic_General_CI_AS NOT NULL,
 [role]             Nvarchar(30)  COLLATE Cyrillic_General_CI_AS NOT NULL
                    CHECK ([role] = N'trainer'   OR [role] = N'dietitian'
                        OR [role] = N'vet'       OR [role] = N'keeper'),
 [experience_years] Int           NOT NULL,
 [shift]            Nvarchar(10)  COLLATE Cyrillic_General_CI_AS NOT NULL
                    CHECK ([shift] = N'night' OR [shift] = N'day' OR [shift] = N'morning'),
 [phone]            Nvarchar(20)  COLLATE Cyrillic_General_CI_AS NOT NULL,
 [hire_date]        Date          NOT NULL
)
AS NODE
ON [PRIMARY]
go
 
ALTER TABLE [dbo].[Staff] ADD CONSTRAINT [PK_Staff] PRIMARY KEY ([id])
 ON [PRIMARY]
go
 
-- ============================================================
-- СОЗДАНИЕ ТАБЛИЦ РЁБЕР (EDGE TABLES)
-- ============================================================
 
-- ------------------------------------------------------------
-- Ребро: LivesIn (Animal -> Enclosure)
-- Животное живёт в вольере.
-- is_primary: 1 = основной вольер, 0 = временный
-- ------------------------------------------------------------
 
CREATE TABLE [dbo].[LivesIn]
(
 [date_settled] Date NOT NULL,
 [is_primary]   Bit  DEFAULT ((1)) NOT NULL
)
AS EDGE
ON [PRIMARY]
go
 
ALTER TABLE [dbo].[LivesIn] ADD CONSTRAINT [EC_LivesIn] CONNECTION (
  [Animal] TO [Enclosure])
go
 
-- ------------------------------------------------------------
-- Ребро: Eats (Animal -> Feed)
-- Животное питается кормом.
-- ------------------------------------------------------------
 
CREATE TABLE [dbo].[Eats]
(
 [portion_grams] Int  NOT NULL,
 [times_per_day] Int  NOT NULL,
 [last_fed_date] Date NOT NULL
)
AS EDGE
ON [PRIMARY]
go
 
ALTER TABLE [dbo].[Eats] ADD CONSTRAINT [EC_Eats] CONNECTION (
  [Animal] TO [Feed])
go
 
-- ------------------------------------------------------------
-- Ребро: Compatible (Animal -> Animal)
-- Совместимость двух животных.
-- status: compatible | incompatible | conditional
-- ------------------------------------------------------------
 
CREATE TABLE [dbo].[Compatible]
(
 [status]       Nvarchar(20)  COLLATE Cyrillic_General_CI_AS NOT NULL
                CHECK ([status] = N'conditional' OR [status] = N'incompatible'
                    OR [status] = N'compatible'),
 [reason]       Nvarchar(200) COLLATE Cyrillic_General_CI_AS NOT NULL,
 [checked_date] Date          NOT NULL
)
AS EDGE
ON [PRIMARY]
go
 
ALTER TABLE [dbo].[Compatible] ADD CONSTRAINT [EC_Compatible] CONNECTION (
  [Animal] TO [Animal])
go
 
-- ------------------------------------------------------------
-- Ребро: CaresFor (Staff -> Animal)
-- Сотрудник ухаживает за животным.
-- is_primary_caretaker: 1 = основной смотритель
-- ------------------------------------------------------------
 
CREATE TABLE [dbo].[CaresFor]
(
 [since_date]           Date          NOT NULL,
 [is_primary_caretaker] Bit           DEFAULT ((1)) NOT NULL,
 [notes]                Nvarchar(300) COLLATE Cyrillic_General_CI_AS NULL
)
AS EDGE
ON [PRIMARY]
go
 
ALTER TABLE [dbo].[CaresFor] ADD CONSTRAINT [EC_CaresFor] CONNECTION (
  [Staff] TO [Animal])
go
 

-- ============================================================
-- ЧАСТЬ 3: ЗАПОЛНЕНИЕ ТАБЛИЦ УЗЛОВ
-- ============================================================

-- ------------------------------------------------------------
-- 3.1 Данные: Animal (15 животных)
-- ------------------------------------------------------------
INSERT INTO Animal (id, name, species, age, gender, weight_kg, status, arrival_date)
VALUES
    (1,  N'Симба',    N'Лев',              8,  N'M', 190.50, N'healthy',    '2018-03-15'),
    (2,  N'Нала',     N'Лев',              6,  N'F', 130.00, N'healthy',    '2019-06-20'),
    (3,  N'Раджа',    N'Тигр бенгальский', 5,  N'M', 220.00, N'healthy',    '2020-01-10'),
    (4,  N'Эльза',    N'Гепард',           3,  N'F',  55.75, N'healthy',    '2022-05-05'),
    (5,  N'Дамбо',    N'Слон африканский', 12, N'M', 5200.00,N'healthy',    '2013-08-01'),
    (6,  N'Зара',     N'Жираф',            7,  N'F', 820.00, N'healthy',    '2017-11-30'),
    (7,  N'Зебра',    N'Зебра Бурчелла',   4,  N'M', 310.00, N'healthy',    '2021-03-22'),
    (8,  N'Пингви',   N'Пингвин императорский', 2, N'M', 38.50, N'healthy', '2023-01-15'),
    (9,  N'Лора',     N'Попугай ара',      6,  N'F',   1.20, N'healthy',    '2019-09-10'),
    (10, N'Крок',     N'Нильский крокодил',15, N'M', 750.00, N'healthy',    '2010-04-18'),
    (11, N'Умка',     N'Белый медведь',    9,  N'M', 480.00, N'treatment',  '2016-07-07'),
    (12, N'Чита',     N'Шимпанзе',         11, N'F',  52.00, N'healthy',    '2014-02-28'),
    (13, N'Фламинго', N'Розовый фламинго', 5,  N'F',   3.50, N'healthy',    '2020-06-14'),
    (14, N'Волк',     N'Серый волк',       4,  N'M',  45.00, N'quarantine', '2021-12-01'),
    (15, N'Коала',    N'Коала',            3,  N'F',  10.50, N'healthy',    '2022-09-25');
GO

-- ------------------------------------------------------------
-- 3.2 Данные: Enclosure (6 вольеров)
-- ------------------------------------------------------------
INSERT INTO Enclosure (id, name, enclosure_type, area_sqm, climate, capacity, is_indoor)
VALUES
    (1, N'Царство хищников',   N'predators',  850.00, N'steppe',   6,  0),
    (2, N'Саванна',            N'herbivores', 2500.00, N'steppe',   12, 0),
    (3, N'Птичий рай',         N'birds',      400.00,  N'tropical', 20, 1),
    (4, N'Мир рептилий',       N'reptiles',   300.00,  N'tropical', 8,  1),
    (5, N'Арктика',            N'arctic',     600.00,  N'arctic',   4,  0),
    (6, N'Тропический лес',    N'tropical',   750.00,  N'tropical', 10, 1);
GO

-- ------------------------------------------------------------
-- 3.3 Данные: Feed (10 видов корма)
-- ------------------------------------------------------------
INSERT INTO Feed (id, name, feed_type, calories_per_kg, storage_temp, unit_cost, supplier)
VALUES
    (1,  N'Говядина свежая',       N'meat',       2500.00, N'-2..+4°C',   420.00, N'АгроМяс'),
    (2,  N'Курица целая',          N'meat',       1650.00, N'-2..+4°C',   180.00, N'АгроМяс'),
    (3,  N'Форель свежая',         N'fish',       1420.00, N'-2..+4°C',   350.00, N'РыбПром'),
    (4,  N'Сено луговое',          N'hay',         850.00, N'+5..+25°C',   15.00, N'ЭкоФерма'),
    (5,  N'Смесь фруктов тропических', N'fruits', 650.00, N'+8..+15°C',   95.00, N'ФрутИмпорт'),
    (6,  N'Овощное ассорти',       N'vegetables',  380.00, N'+2..+8°C',   45.00, N'ЭкоФерма'),
    (7,  N'Зерновой микс',         N'grain',       3200.00, N'+5..+20°C',  30.00, N'ЗерноТорг'),
    (8,  N'Листья эвкалипта',      N'special',     420.00, N'+5..+15°C', 210.00, N'БотСад'),
    (9,  N'Мучные черви',          N'insects',     2100.00, N'+10..+20°C',  85.00, N'БиоФерм'),
    (10, N'Специальный корм для приматов', N'special', 1800.00, N'+5..+20°C', 320.00, N'ЗооПитание');
GO

-- ------------------------------------------------------------
-- 3.4 Данные: Staff (12 сотрудников)
-- ------------------------------------------------------------
INSERT INTO Staff (id, name, role, experience_years, shift, phone, hire_date)
VALUES
    (1,  N'Иванов Алексей Петрович',     N'keeper',    12, N'morning', N'+7-900-111-0001', '2013-03-01'),
    (2,  N'Петрова Мария Сергеевна',     N'keeper',     7, N'day',     N'+7-900-111-0002', '2018-05-15'),
    (3,  N'Сидоров Дмитрий Николаевич',  N'keeper',     5, N'night',   N'+7-900-111-0003', '2020-01-10'),
    (4,  N'Козлова Анна Владимировна',   N'vet',       15, N'morning', N'+7-900-111-0004', '2010-06-20'),
    (5,  N'Новиков Игорь Александрович', N'vet',        8, N'day',     N'+7-900-111-0005', '2017-09-01'),
    (6,  N'Морозова Елена Ивановна',     N'dietitian', 10, N'morning', N'+7-900-111-0006', '2015-02-14'),
    (7,  N'Волков Сергей Михайлович',    N'keeper',     3, N'day',     N'+7-900-111-0007', '2022-04-01'),
    (8,  N'Зайцева Ольга Павловна',      N'trainer',    6, N'morning', N'+7-900-111-0008', '2019-07-22'),
    (9,  N'Белов Андрей Юрьевич',        N'keeper',     9, N'night',   N'+7-900-111-0009', '2016-11-05'),
    (10, N'Громова Татьяна Борисовна',   N'vet',        4, N'day',     N'+7-900-111-0010', '2021-03-18'),
    (11, N'Орлов Виктор Фёдорович',      N'trainer',   11, N'morning', N'+7-900-111-0011', '2014-08-30'),
    (12, N'Лебедева Светлана Анатольевна', N'dietitian', 2, N'day',   N'+7-900-111-0012', '2023-01-09');
GO

-- ============================================================
-- ЧАСТЬ 4: ЗАПОЛНЕНИЕ ТАБЛИЦ РЁБЕР
-- ============================================================

-- ------------------------------------------------------------
-- 4.1 LivesIn: Животное → Вольер
-- ------------------------------------------------------------
-- Вольер 1 (хищники):   Симба(1), Нала(2), Раджа(3), Эльза(4), Волк(14)
-- Вольер 2 (травоядные):Дамбо(5), Зара(6), Зебра(7), Чита(12)
-- Вольер 3 (птицы):     Лора(9), Фламинго(13)
-- Вольер 4 (рептилии):  Крок(10)
-- Вольер 5 (арктика):   Умка(11), Пингви(8)
-- Вольер 6 (тропики):   Коала(15)
-- ------------------------------------------------------------
INSERT INTO LivesIn ($from_id, $to_id, date_settled, is_primary)
VALUES
    ((SELECT $node_id FROM Animal WHERE id = 1),
     (SELECT $node_id FROM Enclosure WHERE id = 1), '2018-03-15', 1),
    ((SELECT $node_id FROM Animal WHERE id = 2),
     (SELECT $node_id FROM Enclosure WHERE id = 1), '2019-06-20', 1),
    ((SELECT $node_id FROM Animal WHERE id = 3),
     (SELECT $node_id FROM Enclosure WHERE id = 1), '2020-01-10', 1),
    ((SELECT $node_id FROM Animal WHERE id = 4),
     (SELECT $node_id FROM Enclosure WHERE id = 1), '2022-05-05', 1),
    ((SELECT $node_id FROM Animal WHERE id = 14),
     (SELECT $node_id FROM Enclosure WHERE id = 1), '2021-12-01', 0),  
    ((SELECT $node_id FROM Animal WHERE id = 5),
     (SELECT $node_id FROM Enclosure WHERE id = 2), '2013-08-01', 1),
    ((SELECT $node_id FROM Animal WHERE id = 6),
     (SELECT $node_id FROM Enclosure WHERE id = 2), '2017-11-30', 1),
    ((SELECT $node_id FROM Animal WHERE id = 7),
     (SELECT $node_id FROM Enclosure WHERE id = 2), '2021-03-22', 1),
    ((SELECT $node_id FROM Animal WHERE id = 12),
     (SELECT $node_id FROM Enclosure WHERE id = 2), '2014-02-28', 1),
    ((SELECT $node_id FROM Animal WHERE id = 9),
     (SELECT $node_id FROM Enclosure WHERE id = 3), '2019-09-10', 1),
    ((SELECT $node_id FROM Animal WHERE id = 13),
     (SELECT $node_id FROM Enclosure WHERE id = 3), '2020-06-14', 1),
    ((SELECT $node_id FROM Animal WHERE id = 10),
     (SELECT $node_id FROM Enclosure WHERE id = 4), '2010-04-18', 1),
    ((SELECT $node_id FROM Animal WHERE id = 8),
     (SELECT $node_id FROM Enclosure WHERE id = 5), '2023-01-15', 1),
    ((SELECT $node_id FROM Animal WHERE id = 11),
     (SELECT $node_id FROM Enclosure WHERE id = 5), '2016-07-07', 1),
    ((SELECT $node_id FROM Animal WHERE id = 15),
     (SELECT $node_id FROM Enclosure WHERE id = 6), '2022-09-25', 1);
GO

-- ------------------------------------------------------------
-- 4.2 Eats: Животное → Корм
-- ------------------------------------------------------------
INSERT INTO Eats ($from_id, $to_id, portion_grams, times_per_day, last_fed_date)
VALUES
    -- Симба (лев) ест говядину и курицу
    ((SELECT $node_id FROM Animal WHERE id = 1),
     (SELECT $node_id FROM Feed WHERE id = 1), 6000, 1, '2026-04-28'),
    ((SELECT $node_id FROM Animal WHERE id = 1),
     (SELECT $node_id FROM Feed WHERE id = 2), 3000, 1, '2026-04-27'),
    -- Нала (лев) ест говядину
    ((SELECT $node_id FROM Animal WHERE id = 2),
     (SELECT $node_id FROM Feed WHERE id = 1), 4500, 1, '2026-04-28'),
    -- Раджа (тигр) ест говядину и рыбу
    ((SELECT $node_id FROM Animal WHERE id = 3),
     (SELECT $node_id FROM Feed WHERE id = 1), 7000, 1, '2026-04-28'),
    ((SELECT $node_id FROM Animal WHERE id = 3),
     (SELECT $node_id FROM Feed WHERE id = 3), 2000, 1, '2026-04-27'),
    -- Эльза (гепард) ест курицу
    ((SELECT $node_id FROM Animal WHERE id = 4),
     (SELECT $node_id FROM Feed WHERE id = 2), 2500, 1, '2026-04-28'),
    -- Дамбо (слон) ест сено, фрукты, овощи
    ((SELECT $node_id FROM Animal WHERE id = 5),
     (SELECT $node_id FROM Feed WHERE id = 4), 50000, 3, '2026-04-28'),
    ((SELECT $node_id FROM Animal WHERE id = 5),
     (SELECT $node_id FROM Feed WHERE id = 5), 5000, 2, '2026-04-28'),
    ((SELECT $node_id FROM Animal WHERE id = 5),
     (SELECT $node_id FROM Feed WHERE id = 6), 8000, 2, '2026-04-28'),
    -- Зара (жираф) ест сено и фрукты
    ((SELECT $node_id FROM Animal WHERE id = 6),
     (SELECT $node_id FROM Feed WHERE id = 4), 30000, 3, '2026-04-28'),
    ((SELECT $node_id FROM Animal WHERE id = 6),
     (SELECT $node_id FROM Feed WHERE id = 5), 3000, 2, '2026-04-28'),
    -- Зебра ест сено и зерно
    ((SELECT $node_id FROM Animal WHERE id = 7),
     (SELECT $node_id FROM Feed WHERE id = 4), 10000, 3, '2026-04-28'),
    ((SELECT $node_id FROM Animal WHERE id = 7),
     (SELECT $node_id FROM Feed WHERE id = 7), 2000, 2, '2026-04-28'),
    -- Пингви (пингвин) ест рыбу
    ((SELECT $node_id FROM Animal WHERE id = 8),
     (SELECT $node_id FROM Feed WHERE id = 3), 1500, 3, '2026-04-28'),
    -- Лора (попугай) ест фрукты и зерно
    ((SELECT $node_id FROM Animal WHERE id = 9),
     (SELECT $node_id FROM Feed WHERE id = 5), 150, 3, '2026-04-28'),
    ((SELECT $node_id FROM Animal WHERE id = 9),
     (SELECT $node_id FROM Feed WHERE id = 7), 100, 2, '2026-04-28'),
    -- Крок (крокодил) ест говядину и курицу
    ((SELECT $node_id FROM Animal WHERE id = 10),
     (SELECT $node_id FROM Feed WHERE id = 1), 8000, 1, '2026-04-26'),
    ((SELECT $node_id FROM Animal WHERE id = 10),
     (SELECT $node_id FROM Feed WHERE id = 2), 4000, 1, '2026-04-24'),
    -- Умка (белый медведь) ест рыбу и мясо
    ((SELECT $node_id FROM Animal WHERE id = 11),
     (SELECT $node_id FROM Feed WHERE id = 3), 8000, 2, '2026-04-28'),
    ((SELECT $node_id FROM Animal WHERE id = 11),
     (SELECT $node_id FROM Feed WHERE id = 1), 5000, 1, '2026-04-28'),
    -- Чита (шимпанзе) ест фрукты, овощи, спец.корм
    ((SELECT $node_id FROM Animal WHERE id = 12),
     (SELECT $node_id FROM Feed WHERE id = 5), 800,  3, '2026-04-28'),
    ((SELECT $node_id FROM Animal WHERE id = 12),
     (SELECT $node_id FROM Feed WHERE id = 6), 600,  2, '2026-04-28'),
    ((SELECT $node_id FROM Animal WHERE id = 12),
     (SELECT $node_id FROM Feed WHERE id = 10), 300, 1, '2026-04-28'),
    -- Фламинго ест насекомых и зерно
    ((SELECT $node_id FROM Animal WHERE id = 13),
     (SELECT $node_id FROM Feed WHERE id = 9), 200,  2, '2026-04-28'),
    ((SELECT $node_id FROM Animal WHERE id = 13),
     (SELECT $node_id FROM Feed WHERE id = 7), 150,  2, '2026-04-28'),
    -- Волк ест говядину и курицу
    ((SELECT $node_id FROM Animal WHERE id = 14),
     (SELECT $node_id FROM Feed WHERE id = 1), 3000, 1, '2026-04-28'),
    ((SELECT $node_id FROM Animal WHERE id = 14),
     (SELECT $node_id FROM Feed WHERE id = 2), 1500, 1, '2026-04-27'),
    -- Коала ест листья эвкалипта
    ((SELECT $node_id FROM Animal WHERE id = 15),
     (SELECT $node_id FROM Feed WHERE id = 8), 800,  3, '2026-04-28');
GO

-- ------------------------------------------------------------
-- 4.3 Compatible: Животное → Животное (совместимость)
-- ------------------------------------------------------------
INSERT INTO Compatible ($from_id, $to_id, status, reason, checked_date)
VALUES
    -- Симба и Нала (оба льва) — совместимы
    ((SELECT $node_id FROM Animal WHERE id = 1),
     (SELECT $node_id FROM Animal WHERE id = 2),
     N'compatible', N'Одна прайд-группа, привыкли друг к другу', '2024-01-10'),
    -- Симба и Раджа (лев и тигр) — несовместимы
    ((SELECT $node_id FROM Animal WHERE id = 1),
     (SELECT $node_id FROM Animal WHERE id = 3),
     N'incompatible', N'Территориальная агрессия между крупными кошками', '2024-02-15'),
    -- Раджа и Эльза (тигр и гепард) — несовместимы
    ((SELECT $node_id FROM Animal WHERE id = 3),
     (SELECT $node_id FROM Animal WHERE id = 4),
     N'incompatible', N'Тигр нападает на более мелких кошачьих', '2024-02-15'),
    -- Симба и Эльза — условно совместимы
    ((SELECT $node_id FROM Animal WHERE id = 1),
     (SELECT $node_id FROM Animal WHERE id = 4),
     N'conditional', N'Возможно совместное содержание при надзоре', '2024-03-01'),
    -- Дамбо и Зара — совместимы
    ((SELECT $node_id FROM Animal WHERE id = 5),
     (SELECT $node_id FROM Animal WHERE id = 6),
     N'compatible', N'Оба травоядные, мирно сосуществуют', '2024-01-20'),
    -- Дамбо и Зебра — совместимы
    ((SELECT $node_id FROM Animal WHERE id = 5),
     (SELECT $node_id FROM Animal WHERE id = 7),
     N'compatible', N'Слоны и зебры совместимы в условиях саванны', '2024-01-20'),
    -- Зара и Зебра — совместимы
    ((SELECT $node_id FROM Animal WHERE id = 6),
     (SELECT $node_id FROM Animal WHERE id = 7),
     N'compatible', N'Жирафы и зебры — традиционные соседи в саванне', '2024-01-22'),
    -- Лора и Фламинго — условно совместимы
    ((SELECT $node_id FROM Animal WHERE id = 9),
     (SELECT $node_id FROM Animal WHERE id = 13),
     N'conditional', N'Разные виды птиц, возможны конфликты из-за пространства', '2024-04-01'),
    -- Умка и Пингви — несовместимы
    ((SELECT $node_id FROM Animal WHERE id = 11),
     (SELECT $node_id FROM Animal WHERE id = 8),
     N'incompatible', N'Медведь является естественным хищником пингвинов', '2024-03-15'),
    -- Волк и Симба — несовместимы
    ((SELECT $node_id FROM Animal WHERE id = 14),
     (SELECT $node_id FROM Animal WHERE id = 1),
     N'incompatible', N'Волк в карантине, контакт с другими хищниками запрещён', '2024-04-10'),
    -- Чита и Дамбо — совместимы
    ((SELECT $node_id FROM Animal WHERE id = 12),
     (SELECT $node_id FROM Animal WHERE id = 5),
     N'compatible', N'Шимпанзе и слоны — нейтральные соседи', '2024-02-28'),
    -- Нала и Волк — несовместимы
    ((SELECT $node_id FROM Animal WHERE id = 2),
     (SELECT $node_id FROM Animal WHERE id = 14),
     N'incompatible', N'Волк в карантине, любые контакты запрещены', '2024-04-10');
GO

-- ------------------------------------------------------------
-- 4.4 CaresFor: Сотрудник → Животное
-- ------------------------------------------------------------
INSERT INTO CaresFor ($from_id, $to_id, since_date, is_primary_caretaker, notes)
VALUES
    -- Иванов (keeper, morning) — ухаживает за хищниками
    ((SELECT $node_id FROM Staff WHERE id = 1),
     (SELECT $node_id FROM Animal WHERE id = 1), '2018-03-15', 1, N'Основной смотритель Симбы, кормление 08:00'),
    ((SELECT $node_id FROM Staff WHERE id = 1),
     (SELECT $node_id FROM Animal WHERE id = 2), '2019-06-20', 1, N'Основной смотритель Налы'),
    ((SELECT $node_id FROM Staff WHERE id = 1),
     (SELECT $node_id FROM Animal WHERE id = 4), '2022-05-05', 1, N'Основной смотритель Эльзы'),
    -- Петрова (keeper, day) — тигр и волк
    ((SELECT $node_id FROM Staff WHERE id = 2),
     (SELECT $node_id FROM Animal WHERE id = 3), '2020-01-10', 1, N'Основной смотритель Раджи, дневное кормление'),
    ((SELECT $node_id FROM Staff WHERE id = 2),
     (SELECT $node_id FROM Animal WHERE id = 14), '2021-12-01', 1, N'Карантинное наблюдение за волком'),
    -- Сидоров (keeper, night) — ночной контроль
    ((SELECT $node_id FROM Staff WHERE id = 3),
     (SELECT $node_id FROM Animal WHERE id = 1), '2020-06-01', 0, N'Ночной дежурный по вольеру хищников'),
    ((SELECT $node_id FROM Staff WHERE id = 3),
     (SELECT $node_id FROM Animal WHERE id = 10), '2020-06-01', 1, N'Основной смотритель Крока'),
    -- Козлова (vet) — ветеринар для всех проблемных животных
    ((SELECT $node_id FROM Staff WHERE id = 4),
     (SELECT $node_id FROM Animal WHERE id = 11), '2016-07-07', 1, N'Ведёт лечение Умки, ежедневный осмотр'),
    ((SELECT $node_id FROM Staff WHERE id = 4),
     (SELECT $node_id FROM Animal WHERE id = 14), '2021-12-01', 0, N'Ветеринарный контроль карантина волка'),
    ((SELECT $node_id FROM Staff WHERE id = 4),
     (SELECT $node_id FROM Animal WHERE id = 3), '2022-01-15', 0, N'Плановые осмотры тигра'),
    -- Новиков (vet) — ветеринар травоядных
    ((SELECT $node_id FROM Staff WHERE id = 5),
     (SELECT $node_id FROM Animal WHERE id = 5), '2017-09-01', 1, N'Ведёт медкарту слона'),
    ((SELECT $node_id FROM Staff WHERE id = 5),
     (SELECT $node_id FROM Animal WHERE id = 6), '2017-11-30', 1, N'Ведёт медкарту жирафа'),
    ((SELECT $node_id FROM Staff WHERE id = 5),
     (SELECT $node_id FROM Animal WHERE id = 7), '2021-03-22', 1, N'Ведёт медкарту зебры'),
    -- Морозова (dietitian) — диетолог
    ((SELECT $node_id FROM Staff WHERE id = 6),
     (SELECT $node_id FROM Animal WHERE id = 5), '2015-02-14', 1, N'Разрабатывает рацион слона'),
    ((SELECT $node_id FROM Staff WHERE id = 6),
     (SELECT $node_id FROM Animal WHERE id = 12), '2015-02-14', 1, N'Разрабатывает рацион шимпанзе'),
    -- Волков (keeper, day) — птицы
    ((SELECT $node_id FROM Staff WHERE id = 7),
     (SELECT $node_id FROM Animal WHERE id = 9),  '2022-04-01', 1, N'Основной смотритель попугая'),
    ((SELECT $node_id FROM Staff WHERE id = 7),
     (SELECT $node_id FROM Animal WHERE id = 13), '2022-04-01', 1, N'Основной смотритель фламинго'),
    -- Зайцева (trainer) — тренер приматов и гепарда
    ((SELECT $node_id FROM Staff WHERE id = 8),
     (SELECT $node_id FROM Animal WHERE id = 12), '2019-07-22', 1, N'Тренер шимпанзе, поведенческое обогащение'),
    ((SELECT $node_id FROM Staff WHERE id = 8),
     (SELECT $node_id FROM Animal WHERE id = 4),  '2022-06-01', 0, N'Тренировки гепарда по обогащению среды'),
    -- Белов (keeper, night) — ночной контроль арктического и тропического
    ((SELECT $node_id FROM Staff WHERE id = 9),
     (SELECT $node_id FROM Animal WHERE id = 8),  '2023-01-15', 1, N'Основной смотритель пингвина'),
    ((SELECT $node_id FROM Staff WHERE id = 9),
     (SELECT $node_id FROM Animal WHERE id = 11), '2020-01-01', 0, N'Ночной контроль белого медведя'),
    ((SELECT $node_id FROM Staff WHERE id = 9),
     (SELECT $node_id FROM Animal WHERE id = 15), '2022-09-25', 1, N'Основной смотритель коалы'),
    -- Громова (vet, day) — ветеринар птиц и рептилий
    ((SELECT $node_id FROM Staff WHERE id = 10),
     (SELECT $node_id FROM Animal WHERE id = 9),  '2021-03-18', 0, N'Плановые ветеринарные осмотры попугая'),
    ((SELECT $node_id FROM Staff WHERE id = 10),
     (SELECT $node_id FROM Animal WHERE id = 10), '2021-03-18', 0, N'Плановые осмотры крокодила'),
    ((SELECT $node_id FROM Staff WHERE id = 10),
     (SELECT $node_id FROM Animal WHERE id = 13), '2021-03-18', 0, N'Плановые осмотры фламинго'),
    -- Орлов (trainer) — тренер крупных хищников
    ((SELECT $node_id FROM Staff WHERE id = 11),
     (SELECT $node_id FROM Animal WHERE id = 1),  '2014-08-30', 0, N'Тренировки льва, публичные показы'),
    ((SELECT $node_id FROM Staff WHERE id = 11),
     (SELECT $node_id FROM Animal WHERE id = 3),  '2020-01-10', 0, N'Тренировки тигра, контактные занятия'),
    -- Лебедева (dietitian) — диетолог хищников
    ((SELECT $node_id FROM Staff WHERE id = 12),
     (SELECT $node_id FROM Animal WHERE id = 1),  '2023-01-09', 0, N'Корректирует рацион льва'),
    ((SELECT $node_id FROM Staff WHERE id = 12),
     (SELECT $node_id FROM Animal WHERE id = 3),  '2023-01-09', 0, N'Корректирует рацион тигра'),
    ((SELECT $node_id FROM Staff WHERE id = 12),
     (SELECT $node_id FROM Animal WHERE id = 11), '2023-01-09', 1, N'Разрабатывает лечебный рацион медведя');
GO

-- ============================================================
-- ПРОВЕРКА: посмотрим содержимое всех таблиц
-- ============================================================
SELECT N'Animal'   AS [Таблица], COUNT(*) AS [Строк] FROM Animal
UNION ALL
SELECT N'Enclosure',              COUNT(*) FROM Enclosure
UNION ALL
SELECT N'Feed',                   COUNT(*) FROM Feed
UNION ALL
SELECT N'Staff',                  COUNT(*) FROM Staff
UNION ALL
SELECT N'LivesIn',                COUNT(*) FROM LivesIn
UNION ALL
SELECT N'Eats',                   COUNT(*) FROM Eats
UNION ALL
SELECT N'Compatible',             COUNT(*) FROM Compatible
UNION ALL
SELECT N'CaresFor',               COUNT(*) FROM CaresFor;
GO

-- ============================================================
-- ЧАСТЬ 5: ЗАПРОСЫ MATCH (не менее 5, с цепочками 3+ узлов)
-- ============================================================

-- ------------------------------------------------------------
-- Запрос 1: Кто ухаживает за животными в конкретном вольере?
-- Цепочка: Staff → (CaresFor) → Animal → (LivesIn) → Enclosure
-- ------------------------------------------------------------
PRINT N'=== Запрос 1: Сотрудники и животные вольера "Царство хищников" ===';
SELECT
    s.name           AS [Сотрудник],
    s.role           AS [Должность],
    a.name           AS [Животное],
    a.species        AS [Вид],
    cf.is_primary_caretaker AS [Основной],
    e.name           AS [Вольер]
FROM Staff          AS s
   , CaresFor       AS cf
   , Animal         AS a
   , LivesIn        AS li
   , Enclosure      AS e
WHERE MATCH(s-(cf)->a-(li)->e)
  AND e.name = N'Царство хищников'
ORDER BY s.name, a.name;
GO

-- ------------------------------------------------------------
-- Запрос 2: Какой корм получают животные, за которыми
--           ухаживает конкретный сотрудник?
-- Цепочка: Staff → (CaresFor) → Animal → (Eats) → Feed
-- ------------------------------------------------------------
PRINT N'=== Запрос 2: Рационы животных под опекой Иванова А.П. ===';
SELECT
    s.name            AS [Сотрудник],
    a.name            AS [Животное],
    a.species         AS [Вид],
    f.name            AS [Корм],
    f.feed_type       AS [Тип корма],
    ea.portion_grams  AS [Порция (г)],
    ea.times_per_day  AS [Раз в день]
FROM Staff   AS s
   , CaresFor AS cf
   , Animal   AS a
   , Eats     AS ea
   , Feed     AS f
WHERE MATCH(s-(cf)->a-(ea)->f)
  AND s.name = N'Иванов Алексей Петрович'
  AND cf.is_primary_caretaker = 1
ORDER BY a.name, f.name;
GO

-- ------------------------------------------------------------
-- Запрос 3: Найти всех животных, несовместимых с теми,
--           кто живёт в вольере "Царство хищников"
-- Цепочка: Enclosure ← (LivesIn) ← Animal → (Compatible) → Animal2
-- ------------------------------------------------------------
PRINT N'=== Запрос 3: Несовместимые пары животных в вольере хищников ===';
SELECT
    e.name          AS [Вольер],
    a1.name         AS [Животное 1],
    a1.species      AS [Вид 1],
    comp.status     AS [Совместимость],
    comp.reason     AS [Причина],
    a2.name         AS [Животное 2],
    a2.species      AS [Вид 2]
FROM Enclosure  AS e
   , LivesIn    AS li
   , Animal     AS a1
   , Compatible AS comp
   , Animal     AS a2
WHERE MATCH(e<-(li)-a1-(comp)->a2)
  AND e.name   = N'Царство хищников'
  AND comp.status = N'incompatible'
ORDER BY a1.name;
GO

-- ------------------------------------------------------------
-- Запрос 4: Ветеринары, которые ведут больных / карантинных
--           животных + в каком вольере те содержатся
-- Цепочка: Staff → (CaresFor) → Animal → (LivesIn) → Enclosure
-- ------------------------------------------------------------
PRINT N'=== Запрос 4: Ветеринары и их подопечные на лечении/карантине ===';
SELECT
    s.name        AS [Ветеринар],
    s.shift       AS [Смена],
    a.name        AS [Животное],
    a.species     AS [Вид],
    a.status      AS [Статус],
    e.name        AS [Вольер],
    e.enclosure_type AS [Тип вольера]
FROM Staff      AS s
   , CaresFor   AS cf
   , Animal     AS a
   , LivesIn    AS li
   , Enclosure  AS e
WHERE MATCH(s-(cf)->a-(li)->e)
  AND s.role IN (N'vet')
  AND a.status IN (N'sick', N'quarantine', N'treatment')
ORDER BY s.name, a.name;
GO

-- ------------------------------------------------------------
-- Запрос 5: Найти дорогостоящие корма (>200 руб/кг), которыми
--           питаются животные под наблюдением ветеринаров
-- Цепочка: Staff → (CaresFor) → Animal → (Eats) → Feed
-- ------------------------------------------------------------
PRINT N'=== Запрос 5: Дорогие корма у животных под наблюдением ветеринаров ===';
SELECT
    s.name            AS [Ветеринар],
    a.name            AS [Животное],
    a.species         AS [Вид],
    f.name            AS [Корм],
    f.unit_cost       AS [Цена (руб/кг)],
    ea.portion_grams  AS [Порция (г)],
    ea.times_per_day  AS [Раз в день],
    CAST(ea.portion_grams * ea.times_per_day * f.unit_cost
         / 1000.0 AS DECIMAL(10,2)) AS [Стоимость в день (руб)]
FROM Staff   AS s
   , CaresFor AS cf
   , Animal   AS a
   , Eats     AS ea
   , Feed     AS f
WHERE MATCH(s-(cf)->a-(ea)->f)
  AND s.role     = N'vet'
  AND f.unit_cost > 200
ORDER BY [Стоимость в день (руб)] DESC;
GO

-- ------------------------------------------------------------
-- Запрос 6 (бонус): Животные, совместимые с теми, за кем
--           ухаживает тренер — потенциал для совместных тренировок
-- Цепочка: Staff → (CaresFor) → Animal → (Compatible) → Animal2
-- ------------------------------------------------------------
PRINT N'=== Запрос 6: Потенциальные пары для совместных тренировок ===';
SELECT
    s.name        AS [Тренер],
    a1.name       AS [Его животное],
    comp.status   AS [Совместимость],
    a2.name       AS [Партнёр],
    a2.species    AS [Вид партнёра],
    comp.reason   AS [Комментарий]
FROM Staff      AS s
   , CaresFor   AS cf
   , Animal     AS a1
   , Compatible AS comp
   , Animal     AS a2
WHERE MATCH(s-(cf)->a1-(comp)->a2)
  AND s.role  = N'trainer'
  AND comp.status IN (N'compatible', N'conditional')
ORDER BY s.name, a1.name;
GO

-- ============================================================
-- ЧАСТЬ 6: ЗАПРОСЫ SHORTEST_PATH
-- ============================================================

-- ------------------------------------------------------------
-- SP-Запрос 1: Кратчайшая цепочка совместимости между животными
-- Шаблон "+" — повторять 1 или более раз до нахождения пути
-- Используем: STRING_AGG и LAST_VALUE
-- ------------------------------------------------------------
PRINT N'=== SP-Запрос 1: Все цепочки совместимости из "Симбы" (шаблон +) ===';
SELECT
    a1.name AS [Начало],
    STRING_AGG(a2.name, '->') WITHIN GROUP (GRAPH PATH) AS [Путь совместимости],
    COUNT(a2.name)             WITHIN GROUP (GRAPH PATH) AS [Длина пути],
    LAST_VALUE(a2.name)        WITHIN GROUP (GRAPH PATH) AS [Конечный узел]
FROM Animal AS a1
   , Compatible FOR PATH AS comp
   , Animal    FOR PATH AS a2
WHERE MATCH(SHORTEST_PATH(a1(-(comp)->a2)+))
  AND a1.name = N'Симба'
ORDER BY [Длина пути];
GO



-- ------------------------------------------------------------
-- SP-Запрос 2: Кратчайший путь совместимости от Дамбо до Зебры
-- Используем LAST_VALUE для фильтрации конечного узла
-- Шаблон "+" — ищем кратчайший путь
-- ------------------------------------------------------------
PRINT N'=== SP-Запрос 2: Кратчайший путь от Дамбо до Зебры ===';
WITH PathCTE AS
(
    SELECT
        a1.name AS [Начало],
        STRING_AGG(a2.name, '->') WITHIN GROUP (GRAPH PATH) AS [Путь],
        LAST_VALUE(a2.name)        WITHIN GROUP (GRAPH PATH) AS [Конец]
    FROM Animal AS a1
       , Compatible FOR PATH AS comp
       , Animal    FOR PATH AS a2
    WHERE MATCH(SHORTEST_PATH(a1(-(comp)->a2)+))
      AND a1.name = N'Дамбо'
)
SELECT [Начало], [Путь]
FROM PathCTE
WHERE [Конец] = N'Зебра';
GO

-- ------------------------------------------------------------
-- SP-Запрос 3: Все цепочки совместимости глубиной от 1 до 3 шагов
-- Шаблон "{1,3}" — ограничиваем глубину обхода
-- ------------------------------------------------------------
PRINT N'=== SP-Запрос 3: Все цепочки совместимости глубиной 1-3 шага (шаблон {1,3}) ===';
SELECT
    a1.name AS [Исходное животное],
    STRING_AGG(a2.name, '->') WITHIN GROUP (GRAPH PATH) AS [Путь],
    COUNT(a2.name)             WITHIN GROUP (GRAPH PATH) AS [Длина пути],
    LAST_VALUE(a2.name)        WITHIN GROUP (GRAPH PATH) AS [Конечный узел]
FROM Animal AS a1
   , Compatible FOR PATH AS comp
   , Animal    FOR PATH AS a2
WHERE MATCH(SHORTEST_PATH(a1(-(comp)->a2){1,3}))
ORDER BY a1.name, [Длина пути];
GO



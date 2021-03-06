USE [Apteka]
GO
SET IDENTITY_INSERT [dbo].[Types] ON 

INSERT [dbo].[Types] ([id], [name]) VALUES (1, N'tabletki powlekane')
INSERT [dbo].[Types] ([id], [name]) VALUES (2, N'zel')
INSERT [dbo].[Types] ([id], [name]) VALUES (3, N'masc')
INSERT [dbo].[Types] ([id], [name]) VALUES (4, N'kapsulki')
SET IDENTITY_INSERT [dbo].[Types] OFF
INSERT [dbo].[Medicines] ([id], [name], [type_id], [action], [side_effects], [recipe], [expiration_date], [price], [manufacturer], [quantity]) VALUES (12, N'Bodymax', 1, N'wzmacniajace', N'drgawki', 0, CAST(N'2018-01-01' AS Date), CAST(16.45 AS Decimal(5, 2)), N'p13', 100)
INSERT [dbo].[Medicines] ([id], [name], [type_id], [action], [side_effects], [recipe], [expiration_date], [price], [manufacturer], [quantity]) VALUES (15, N'Voltaren', 2, N'przeciwbolowe', N'reakcje skorne', 0, CAST(N'2019-03-20' AS Date), CAST(31.38 AS Decimal(5, 2)), N'P19', 100)
INSERT [dbo].[Medicines] ([id], [name], [type_id], [action], [side_effects], [recipe], [expiration_date], [price], [manufacturer], [quantity]) VALUES (16, N'Masc borowinowa', 3, N'przeciwzapalne', N'wysypka', 0, CAST(N'2018-11-03' AS Date), CAST(15.30 AS Decimal(5, 2)), N'P07', 100)
INSERT [dbo].[Medicines] ([id], [name], [type_id], [action], [side_effects], [recipe], [expiration_date], [price], [manufacturer], [quantity]) VALUES (17, N'Preventic Extra Plus', 4, N'wzmacniajace', N'zaburzenia pokarmowe', 0, CAST(N'2018-09-05' AS Date), CAST(18.90 AS Decimal(5, 2)), N'P05', 100)
INSERT [dbo].[Medicines] ([id], [name], [type_id], [action], [side_effects], [recipe], [expiration_date], [price], [manufacturer], [quantity]) VALUES (18, N'Ampicylina', 1, N'przeciwbakteryjne', N'goraczka', 0, CAST(N'2018-11-02' AS Date), CAST(14.50 AS Decimal(5, 2)), N'P14', 100)
SET IDENTITY_INSERT [dbo].[Transactions] ON 

INSERT [dbo].[Transactions] ([id], [transaction_number], [date], [med_id], [quantity]) VALUES (1, N'000001', CAST(N'2017-12-15' AS Date), 12, 1)
INSERT [dbo].[Transactions] ([id], [transaction_number], [date], [med_id], [quantity]) VALUES (2, N'000002', CAST(N'2017-12-15' AS Date), 15, 2)
INSERT [dbo].[Transactions] ([id], [transaction_number], [date], [med_id], [quantity]) VALUES (3, N'000003', CAST(N'2017-12-15' AS Date), 16, 1)
SET IDENTITY_INSERT [dbo].[Transactions] OFF
SET IDENTITY_INSERT [dbo].[Orders] ON 

INSERT [dbo].[Orders] ([id], [med_id], [order_number], [quantity]) VALUES (1, 12, N'ZAM00001122017', 10)
INSERT [dbo].[Orders] ([id], [med_id], [order_number], [quantity]) VALUES (2, 15, N'ZAM00002122017', 20)
INSERT [dbo].[Orders] ([id], [med_id], [order_number], [quantity]) VALUES (3, 16, N'ZAM00003122017', 25)
SET IDENTITY_INSERT [dbo].[Orders] OFF
INSERT [dbo].[Cities] ([id], [name]) VALUES (N'DB', N'Debica')
INSERT [dbo].[Cities] ([id], [name]) VALUES (N'FW', N'Fort Washington')
INSERT [dbo].[Cities] ([id], [name]) VALUES (N'KU', N'Kutno')
INSERT [dbo].[Cities] ([id], [name]) VALUES (N'LY', N'Lyon')
INSERT [dbo].[Cities] ([id], [name]) VALUES (N'PA', N'Pabianice')
INSERT [dbo].[Cities] ([id], [name]) VALUES (N'PO', N'Poznan')
INSERT [dbo].[Cities] ([id], [name]) VALUES (N'RU', N'Rruga')
INSERT [dbo].[Cities] ([id], [name]) VALUES (N'RZ', N'Rzeszow')
INSERT [dbo].[Cities] ([id], [name]) VALUES (N'WA', N'Warszawa')
INSERT [dbo].[Cities] ([id], [name]) VALUES (N'WR', N'Wroclaw')
INSERT [dbo].[Cities] ([id], [name]) VALUES (N'WY', N'Vysoke Myto')
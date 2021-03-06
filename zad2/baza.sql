USE [Apteka]
GO
/****** Object:  Table [dbo].[Manufacturers]    Script Date: 1/13/2018 7:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Manufacturers](
	[manufacturers_data] [xml] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Medicines]    Script Date: 1/13/2018 7:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Medicines](
	[id] [int] NOT NULL,
	[name] [varchar](30) NOT NULL,
	[type_id] [int] NOT NULL,
	[action] [varchar](30) NOT NULL,
	[side_effects] [varchar](50) NOT NULL,
	[recipe] [bit] NOT NULL,
	[expiration_date] [date] NOT NULL,
	[price] [decimal](5, 2) NOT NULL,
	[manufacturer] [varchar](5) NOT NULL,
	[quantity] [int] NOT NULL,
 CONSTRAINT [PK_Medicines] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Orders]    Script Date: 1/13/2018 7:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Orders](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[med_id] [int] NOT NULL,
	[order_number] [varchar](50) NOT NULL,
	[quantity] [int] NOT NULL,
 CONSTRAINT [PK_Zamowienia] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[recipe_value_subsidiary_table]    Script Date: 1/13/2018 7:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[recipe_value_subsidiary_table](
	[shortcut] [varchar](1) NOT NULL,
	[long_name] [varchar](3) NOT NULL,
	[bit_value] [bit] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Transactions]    Script Date: 1/13/2018 7:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Transactions](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[transaction_number] [varchar](50) NOT NULL,
	[date] [date] NOT NULL,
 CONSTRAINT [PK_Transactions] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TransactionsMedicines]    Script Date: 1/13/2018 7:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TransactionsMedicines](
	[med_id] [int] NOT NULL,
	[tran_id] [int] NOT NULL,
	[quantity] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Types]    Script Date: 1/13/2018 7:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Types](
	[type_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](200) NOT NULL,
 CONSTRAINT [PK_Rodzaje] PRIMARY KEY CLUSTERED 
(
	[type_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Medicines]  WITH CHECK ADD  CONSTRAINT [FK_Medicines_Types] FOREIGN KEY([type_id])
REFERENCES [dbo].[Types] ([type_id])
GO
ALTER TABLE [dbo].[Medicines] CHECK CONSTRAINT [FK_Medicines_Types]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_Medicines] FOREIGN KEY([med_id])
REFERENCES [dbo].[Medicines] ([id])
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_Medicines]
GO
ALTER TABLE [dbo].[TransactionsMedicines]  WITH CHECK ADD  CONSTRAINT [FK_TransactionsMedicines_Medicines] FOREIGN KEY([med_id])
REFERENCES [dbo].[Medicines] ([id])
GO
ALTER TABLE [dbo].[TransactionsMedicines] CHECK CONSTRAINT [FK_TransactionsMedicines_Medicines]
GO
ALTER TABLE [dbo].[TransactionsMedicines]  WITH CHECK ADD  CONSTRAINT [FK_TransactionsMedicines_Transactions] FOREIGN KEY([tran_id])
REFERENCES [dbo].[Transactions] ([id])
GO
ALTER TABLE [dbo].[TransactionsMedicines] CHECK CONSTRAINT [FK_TransactionsMedicines_Transactions]
GO

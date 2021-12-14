# Qld-Crime-Data
## Queensland Crime - a data exploration and visualisation project by Eve Sheridan

### 1	Project Description, Motivation and Value
This project will focus on analysing crime data in Queensland.  Crime affects all populated areas and understanding the types of crime being committed and the areas they are being committed in can be a valuable tool to understand the problems facing society and how to tackle them.

Crime analysis is not a new concept, as police officers have searched for ways to discover patterns and similarities between incidents for years.  For example, the Queensland Police Service provide an Online Crime Map (Queelsand Police, 2021) which provides information on the types of crimes that happened in Queensland over the past two years on an interactive map.  You can zoom in to areas to see the number of offences committed in the selected area over a selected date range.

Analysis stands out amongst the best and most effective tools available to support law enforcement agencies and to inform citizens.  Crime analysis is an effective and necessary constituent for both community and problem-oriented policing.  Ultimately, crime analysis arranges information in such a way that it informs government on better ways to deal with the crime and provides citizens with valuable insights into criminal activity in their community.

### 2	Research Questions
This project will aim to analyse and explore Queensland crime data by developing an interactive web-based visualisation that can be used by interested members of the public to answer the following research questions:

1.	What is the prevalence of violent crime in Queensland and what areas have the highest rates of violent crime?
2.	Is there a relationship between violent crime and sexual offences?
3.	Are drug related crimes on the rise in Queensland?


### 3	Data Sources Used
Five data sources have been used in this project and are outlined in Table 1 below:

- LGA Reported Offences Number (Queensland Government, 2019)
  - Spreadsheet of reported offence numbers by local government area and crime type.
  - Date range: Jan 2001 - Feb 2021	
  - https://www.data.qld.gov.au/dataset/lga_reported_offences_number

- LGA Reported Offences Rates (Queensland Government, 2019)
  - Spreadsheet of reported offence rates per 100,000 persons (population) by Local Government Area (LGA) and crime type.
  - Date range: Jan 2001 - Feb 2021
  - https://www.data.qld.gov.au/dataset/lga_reported_offences_rates

- Local government area boundaries – Queensland (Queensland Government, 2021)
  - The spatial representation of local government areas in Queensland.
  - http://qldspatial.information.qld.gov.au/catalogue/custom/detail.page?fid={3F3DBD69-647B-4833-B0A5-CC43D5E70699} 
  - Note: Access to this dataset is free but you need to request to download the data by entering your email address and a link to the download is emailed to you.

- Queensland Local Government Area ASGS Edition 2019 in .csv Format (ABS, 2020)
  - This contains Local Government Area codes which may be needed in further analysis	Website:
  - https://www.abs.gov.au/AUSSTATS/abs@.nsf/DetailsPage/1270.0.55.003July%202019?OpenDocument

- Coastline and State Border – Queensland
  - This dataset displays the land extent of Queensland and comprises the state border (the cadastral boundary between states) and the coastline of Queensland including marine islands.
  - https://www.data.qld.gov.au/dataset/coastline-and-state-border-queensland
  - Note: Access to this dataset is free but you need to request to download the data by entering your email address and a link to the download is emailed to you.

### 4	Data Wrangling
Python and Tableau were used to do some preliminary wrangling and visualisation however R has been used exclusively to redo the wrangling and complete the visualisation for this final project.  An outline of the main wrangling steps performed are discussed below.

#### 4.1	Read in spatial data
Two different spatial datasets were used and imported into R using the rgdal package.  One contained the local government area (LGA) boundaries in Queensland and the other was an outline of the Queensland coastline which was required to lay over the top as the LGAs extended beyond the mainland to cover islands off the coast. 

#### 4.2	LGA Name and code manipulation
The original wrangling involved changing the LGA names to match what Tableau could recognise and importing codes from a file obtained from the Australian Bureau of Statistics (ABS, 2020).  This was replicated in R and these codes had to be modified slightly to match the geodatabase information.  An abbreviated name from the geodatabase files was also used in the final visualisation.

#### 4.3	Crime Categories
There were 88 separate categories of crimes recorded in each of the files.  In order to specifically analyse the categories of crime as outlined in the research questions (i.e. sexual offences, violent offences and drug offences), some grouping of these categories needed to be undertaken.  Three new attributes SexOffTot,  ViolentOffTot and DrugOffTot were created which summed the relevant fields and are outlined below.  It should be noted that this grouping is arbitrary and should be treated with caution.  Other analysts might choose to group these offences differently.

- SexOffTot
  - Sexual Offences
  - Rape and Attempted Rape
  - Other Sexual Offences

- ViolentOffTot
  - Assault
  - Grievous Assault
  - Serious Assault
  - Serious Assault (Other)
  - Armed Robbery
  - Homicide (Murder)
  - Attempted Murder
  - Other Homicide
  - Manslaughter (excl. by driving)
  - Manslaughter Unlawful Striking Causing Death
  - Unlawful Entry With Violence – Dwelling

- DrugOffTot
  - Possess Drugs
  - Produce Drugs
  - Sell Supply Drugs
  - Trafficking Drugs
  - Drug Offences
  - Other Drug Offences

#### 4.4	Dates
The date field in the original csv files was a 5 character string indicating month and year of the form 'JAN01'.  Both files contained data from JAN01 (January 2001) - FEB21 (February 2021).  As all of the data analysis is done by year, the 2021 data had to be dropped from the files since it did not contain a whole year's worth of data.  In addition to this the "Month Year" column was broken up into "Month" and "Year" and Year was converted to a numeric value.


#### 4.5	Population
An additional variable population was calculated from the two existing variables:
•	rate per 100,000 population and 
•	number of offences
Population = number of offences x 100,000 / rate per 100,000. 
There were five instances in which a LGA had no offences committed for that particular year which caused a problem with this calculation due to dividing by zero.  The areas where this occurred had a very low population.  In these cases, the population was estimated as the average of the previous and subsequent year.
For example, MAPOON ABORIGINAL region reported no offences in any of these categories in 2009.  The population in 2008 was 262 and the population in 2010 was 270, so the estimated population in 2009 was calculated as the average of these (269).
#### 4.6	Linking with geodatabase files
In order to plot using ggplot the crime data had to be linked to the geodatabase data and create a dataframe with all of the required information for the plot.  The R package rgdal was used and the geodatabase information was read in by using the command readOGR.  The required data was extracted from this object for creating a map using the fortify command before being linked with the data.
#### 4.7	Aggregating and Transforming
Aggregating involved calculating totals for each year and region.  Additional data for the whole of Queensland was also calculated and added to the data file.  A new region called “All of Qld” was added with the totals for all of the regions.  In addition to this, a new year = 9999 was added which was an average across Queensland for all of the years.  Note it was decided to add this as a numeric value as this field was already numeric.  Notes will be added to the visualisation field to explain the use of this to the user.  Pivoting was performed to transform the data into the correct format for plotting. 

### 5	Instructions to run the code
The shiny app containing the visualisations was created using Rstudio version 1.4.1106 and R version 4.0.5.  Please follow the following steps to run the application:

The files in this project include:

-	QldCoastline folder - contains geodatabase information about the Queensland coastline and state borders downloaded from the Queensland Spatial Catalogue (Queensland Government, 2021)
-	QLDLGAs folder - contains geodatabase information about Local Government Area boundaries in Queensland downloaded from the Queensland Government Open data portal (Queensland Government, 2019)
-	crimedata.csv - the wrangled datafile
-	app.R - R Shiny app

1. Save these files to a folder on your computer
2. From R Studio choose File | Open File and navigate to the folder.
3. Open the app.R script in your RStudio editor.  
4. Please ensure you have the following R packages installed on your machine before running:
•	tidyverse
•	shiny
•	rgdal
•	ggplot2
•	plotly
•	dplyr
•	rlang
5. Click the Run App button (at the top of the editor).  
6. Click “Open in Browser” to view the visualisation in your browser window.


### 6 Operation
The R Shiny application opens onto the first tab which is the choropleth map and displays violent offences across Queensland by year and broken down by LGA.  The default value in the drop down box will be 9999 which is a calculated field showing the average violent offence rates for all of Queensland from 2001 – 2020.  To change years the viewer simply selects another year from the drop down box. Note: the map data may take a minute to load every time the year is changed please be patient!

Hovering over the map displays further information including Local Government Area Name, Population, The offence rate per 100,000 and the number of offences.  There are further controls in the modebar which can be seen by hovering above the plot.  You can zoom in and pan to whatever area you are interested in.  

The user can switch tabs to the Line Plot which displays Queensland offence rates from 2001 to 2020.  The default value in the drop down box is “All of Qld” which displays the offence rates over the entire state.  The user can select a specific LGA from the drop down box. Again this plot allows the user to hover over the lines to obtain more information including the year, the rate, the number of offences and the population.  

Each plot is created using ggplotly and features an interactive hover mode bar which allows for further user interaction.  Features of the hover mode bar include:
•	Download plot as png file
•	Zoom window
•	Pan (move the plot)
•	Zoom in and out
•	Autoscale
•	Reset Axes
•	Toggle Spike Lines
•	Show closest data on hover
•	Compare data on hover

You are now free to explore the data... enjoy!!



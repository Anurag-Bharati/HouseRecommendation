## HouseRecommendation
>Year II Sem II Data Science Assignment

A basic house recommendation project. 

### Prerequisite
These are some main components required to run the project
1. The <a href="#download">Dataset</a>
2. 7zip file archiver
3. RAM > 500MB for unzipping
4. R and RStudio

### Dependencies
You may need to install these dependencies in order to run the code.
```R
> install.packages("tidyverse")
> install.packages("lubridate")
> install.packages("ggthemes")
> install.packages("scales")
> install.packages("ggdark")
> install.packages("ragg")
> install.packages("fmsb")
```

### Instructions

1. Extract data inside the main project folder
2. Open the Coursework.Rproj file in RStudio
3. Run src/00 Setup/00 Setup.R
4. Run src/00 Setup/00 Functions.R
5. Run all file consecutively inside src/01 Cleaning

### Folder Structure
```
📁 HouseRecommendation
    - 📁 src
        - 📁 00 Setup
        - 📁 01 Clean
        - 📁 02 Graph
        - 📁 03 Model
        - 📁 04 Recom
        - 📁 99 Trash
    - 📁 data (after extraction)
        - 📁 clean
        - 📁 mydata
        - 📁 raw
    - 📄 .gitignore
    - 📄 Coursework.Rproj
```    

### Download
>ℹ NOTE: The data set is highly compressed and decompression may take time

[CLICK HERE](https://drive.google.com/file/d/1kRCReWPzumwDvF_0CjbLo4wFVitGrPvY/view?usp=sharing) TO DOWNLOAD ALL THE DATASETS USED

### Datasets License Information ⚖
Many core datasets, such as crime, housing price, school, flood risk, and geo-code conversion, are 
provided under Open Government License. The bandwidth dataset is provided under the Ofcom 
license, and some helper data, such as Geocode and PGR, are provided under Public Domain 
License (PDL).





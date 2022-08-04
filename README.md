## HouseRecommendation
[![size][size-shield]][size-url]
[![Forks][forks-shield]][forks-url]
[![LastCommit][lastCommit-shield]][size-url]
![SearchHit][hits-shield]
[![Facebook][facebook-shield]][facebook-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

A basic house recommendation project for module **ST5014CEM Data Science For Developers**. 
>Year II Sem II Data Science Assignment

### Prerequisite
These are some main components required to run the project
1. The <a href="#download">Dataset</a>
2. [7zip](https://www.7-zip.org/download.html) file archiver
3. RAM > 500MB for unzipping
4. [R](https://cran.r-project.org/bin/) and [RStudio](https://www.rstudio.com/products/rstudio/download/)
> Note: To download more ram [click here](https://downloadmoreram.com/)
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
6. You may run any other afterwards. :)

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

<!--- IGNORE THESE ---->
[size-shield]:https://img.shields.io/github/repo-size/Anurag-Bharati/HouseRecommendation?style=for-the-badge
[size-url]: https://github.com/Anurag-Bharati/Park-And-Pee
[forks-shield]: https://img.shields.io/github/forks/Anurag-Bharati/HouseRecommendation?style=for-the-badge
[forks-url]: https://github.com/Anurag-Bharati/HouseRecommendation/network/members
[size-shield]:https://img.shields.io/github/repo-size/anurag-bharati/HouseRecommendation?style=for-the-badge
[size-url]: https://github.com/Anurag-Bharati/HouseRecommendation
[lastCommit-shield]:https://img.shields.io/github/last-commit/anurag-bharati/HouseRecommendation?style=for-the-badge
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/in/anurag-bharati-5abb6820a/
[facebook-shield]:https://img.shields.io/badge/Facebook-Anurag-blue?style=for-the-badge
[facebook-url]:https://www.facebook.com/frost.king.1042
[hits-shield]:https://img.shields.io/github/search/anurag-bharati/HouseRecommendation/all?color=green&label=repo%20hits&style=for-the-badge





** Emma Clarke-Deelder
** Replication code for: "Screening, prevention, and management of maternal acute malnutrition and anemia in Ethiopia: evidence from a longitudinal eCohort study"

* Set-up
clear all

* Set globals
global datafolder "J:\HEHS\HE\Emma\Maternal health ecohorts\Ethiopia malnutrition\Github"
global outputfolder "J:\HEHS\HE\Emma\Maternal health ecohorts\Ethiopia malnutrition\Github\Output"

* Set current directory
cd "J:\HEHS\HE\Emma\Maternal health ecohorts\Ethiopia malnutrition\Github"

* Install programs
ssc install table1_mc
ssc install variog 
ssc install qic 

* Open dataset
use "$datafolder/econut_analyticdata_10sept2025.dta", clear

* Run analysis file 1
do "anECONUT01.do"

* Run analysis file 2
do "anECONUT02.do"

* Run analysis file 3
do "anECONUT03.do"

* Run analysis file 4
do "anECONUT04.do"

* Run analysis file 5
do "anECONUT05.do"

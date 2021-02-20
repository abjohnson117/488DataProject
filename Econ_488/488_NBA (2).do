*clears all
clear all

*import future winning percentages file
import excel "\\CTX-Files-01\Citrix\ProdProfiles\osbornat\Downloads\Cleaned_Winning_%.xlsx", sheet("Cleaned_Winning_%") firstrow

*drop unnecessary variable
drop A

*create dummy variables for team names
tabulate Team, generate(team)

*recenter winning percentage to the year following
replace Year = Year-1

*save new dataset
save "\\CTX-Files-01\Citrix\ProdProfiles\osbornat\Documents\future_win.dta"

*add team continuity variable
clear all

import excel "\\CTX-Files-01\Citrix\ProdProfiles\osbornat\Documents\Team Continuity (1).xlsx", sheet("Team Continuity") firstrow

rename Season Year
rename PHI teamCont1
rename POR teamCont2
rename MIL teamCont3
rename CHI teamCont4
rename CHA teamCont5
rename CLE teamCont6
rename BOS teamCont7
rename LAC teamCont8
rename MEM teamCont9
rename ATL teamCont10
rename MIA teamCont11
rename UTA teamCont12
rename SAC teamCont13
rename NYK teamCont14
rename LAL teamCont15
rename ORL teamCont16
rename DAL teamCont17
rename NJN teamCont18
rename DEN teamCont19
rename IND teamCont20
rename NOH teamCont21
rename DET teamCont22
rename TOR teamCont23
rename HOU teamCont24
rename SAS teamCont25
rename PHO teamCont26
rename OKC teamCont27
rename MIN teamCont28
rename GSW teamCont29
rename WAS teamCont30

reshape long teamCont, i(Year) j(Team)

tabulate Team, generate(team)

drop Team

*save new dataset
save "\\CTX-Files-01\Citrix\ProdProfiles\osbornat\Documents\team_continuity.dta"

*clears all
clear all

*import main dataset
import excel "\\CTX-Files-01\Citrix\ProdProfiles\osbornat\Downloads\Cleaned_data_Econ_488_F.xlsx", sheet("Cleaned_data_Econ_488_F") firstrow

*drop unnecessary variable
drop A

*create dummy variables for team names
tabulate Team, generate(team)

*merge future winning percentages file into main dataset
merge m:m team1 team2 team3 team4 team5 team6 team7 team8 team9 team10 team11 team12 team13 team14 team15 team16 team17 team18 team19 team20 team21 team22 team23 team24 team25 team26 team27 team28 team29 team30 Year using "\\CTX-Files-01\Citrix\ProdProfiles\osbornat\Documents\future_win.dta"

drop _merge

*merge team continuity file into main dataset
merge m:m team1 team2 team3 team4 team5 team6 team7 team8 team9 team10 team11 team12 team13 team14 team15 team16 team17 team18 team19 team20 team21 team22 team23 team24 team25 team26 team27 team28 team29 team30 Year using "\\CTX-Files-01\Citrix\ProdProfiles\osbornat\Documents\team_continuity.dta"

drop _merge

*Recenter GB on 8 seed

save "\\CTX-Files-01\Citrix\ProdProfiles\osbornat\Documents\488_1.dta"

gen cutoff_west = 0
replace cutoff_west = 1 if dummy_for_conference == 1 & Position == 8

replace cutoff_west = GB if cutoff_west == 1

collapse (max) cutoff_west, by(Year)

save "\\CTX-Files-01\Citrix\ProdProfiles\osbornat\Documents\488_2.dta"

use \\CTX-Files-01\Citrix\ProdProfiles\osbornat\Documents\488_1.dta

gen cutoff_east = 0
replace cutoff_east = 1 if (dummy_for_conference == 0) & (Position == 8)

replace cutoff_east = GB if (cutoff_east == 1)

collapse (max) cutoff_east, by(Year)

save "\\CTX-Files-01\Citrix\ProdProfiles\osbornat\Documents\488_3.dta"

use \\CTX-Files-01\Citrix\ProdProfiles\osbornat\Documents\488_1.dta

merge m:1 Year using \\CTX-Files-01\Citrix\ProdProfiles\osbornat\Documents\488_2.dta

drop _merge

sort Team Year

merge m:1 Year using \\CTX-Files-01\Citrix\ProdProfiles\osbornat\Documents\488_3.dta

drop _merge

sort Team Year

replace GB = GB - cutoff_west if (dummy_for_conference == 1)

replace GB = GB - cutoff_east if (dummy_for_conference == 0)

drop cutoff_west

drop cutoff_east

*recenter conference position so 8 seed is 0
replace Position = Position - 8
drop if Position == -8

*Test for density discontinuity
DCdensity GB, breakpoint(0) generate(Xj Yj r0 fhat se_fhat) graphname(DCdensity_example.eps)

*create indicator for lottery
gen inlottery = 0
replace inlottery = 1 if Pick < 15 

*create dummy for missed playoffs
gen missplayoffs = 0
replace missplayoffs = 1 if dummy_for_playoffs == 0

*delete data for unnecessary years
drop if Year == 2016

*show first stage
preserve

collapse (mean) inlottery, by(Position)
scatter inlottery Position, xline(0.5)

restore

reg inlottery missplayoffs

preserve

collapse (mean) Pick, by (Position)
scatter Pick Position, xline(0.5)

restore

reg Pick missplayoffs

*create interaction variable
gen lotposition = inlottery*Position

*test for balance of covariates
reg Total_Salary inlottery Position lotposition if abs(Position) < 3
reg teamCont inlottery Position lotposition if abs(Position) < 3

*output scatterplot graphs
preserve 

collapse (mean) FutureWin, by(Position)

scatter FutureWin Position, xline(0.5)

restore

*output regressions

*reduced form on make playoffs
reg FutureWin dummy_for_playoffs Position lotposition if abs(Position) < 3, robust

*reduced with controls on make playoffs
reg FutureWin dummy_for_playoffs Position lotposition Total_Salary teamCont if abs(Position) < 3, robust

*reduced with controls and fixed effects on make playoffs
reg FutureWin dummy_for_playoffs Position lotposition Total_Salary teamCont team1 team2 team3 team4 team5 team6 team7 team8 team9 team10 team11 team12 team13 team14 team15 team16 team17 team18 team19 team20 team21 team22 team23 team24 team24 team25 team26 team27 team28 team29 team30 if abs(Position) < 3, robust

*reduced form on in lottery
reg FutureWin inlottery Position lotposition if abs(Position) < 3, robust

*reduced with controls on in lottery
reg FutureWin inlottery Position lotposition Total_Salary teamCont if abs(Position) < 3, robust

*reduced with controls and fixed effects on in lottery
reg FutureWin inlottery Position lotposition Total_Salary teamCont team1 team2 team3 team4 team5 team6 team7 team8 team9 team10 team11 team12 team13 team14 team15 team16 team17 team18 team19 team20 team21 team22 team23 team24 team24 team25 team26 team27 team28 team29 team30 if abs(Position) < 3, robust

*instrumented
ivregress 2sls FutureWin lotposition (inlottery = Position) if abs(Position) < 3, vce(robust)

*instrumented with controls
ivregress 2sls FutureWin lotposition Total_Salary teamCont (inlottery = Position) if abs(Position) < 3, vce(robust)

*instrumented fixed effects
ivregress 2sls FutureWin lotposition  Total_Salary  teamCont team1 team2 team3 team4 team5 team6 team7 team8 team9 team10 team11 team12 team13 team14 team15 team16 team17 team18 team19 team20 team21 team22 team23 team24 team24 team25 team26 team27 team28 team29 team30 (inlottery = Position) if abs(Position) < 3, vce(robust)

*instrumented at different bandwidths
ivregress 2sls FutureWin lotposition  Total_Salary  teamCont team1 team2 team3 team4 team5 team6 team7 team8 team9 team10 team11 team12 team13 team14 team15 team16 team17 team18 team19 team20 team21 team22 team23 team24 team24 team25 team26 team27 team28 team29 team30 (inlottery = Position) if abs(Position) < 5, vce(robust)

ivregress 2sls FutureWin lotposition  Total_Salary  teamCont team1 team2 team3 team4 team5 team6 team7 team8 team9 team10 team11 team12 team13 team14 team15 team16 team17 team18 team19 team20 team21 team22 team23 team24 team24 team25 team26 team27 team28 team29 team30 (inlottery = Position) if abs(Position) < 7, vce(robust)

ivregress 2sls FutureWin lotposition  Total_Salary  teamCont team1 team2 team3 team4 team5 team6 team7 team8 team9 team10 team11 team12 team13 team14 team15 team16 team17 team18 team19 team20 team21 team22 team23 team24 team24 team25 team26 team27 team28 team29 team30 (inlottery = Position),vce(robust)



